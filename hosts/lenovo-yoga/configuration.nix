{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
  ];

  networking.hostName = "lenovo-yoga";

  # Cap battery charge at ~60% via ideapad EC conservation mode.
  systemd.tmpfiles.rules = [
    "w /sys/devices/pci0000:00/0000:00:1f.0/PNP0C09:00/VPC2004:00/conservation_mode - - - - 1"
  ];

  # ── Graphics: Intel iGPU; the RTX 4070 only in the "nvidia" boot entry ─────
  # The proprietary driver hard-froze this machine ten times between
  # 2026-08-26 and 2026-10-21, mostly while idle on the lock screen. The
  # firmware sends the card ACPI `Notify(NPCF, 0xC0)` power-budget events, and
  # the driver's handler (`rm_acpi_nvpcf_notify`) page-faults on the
  # kacpi_notify workqueue with IRQs off. The panel keeps its last frame lit,
  # keys and a power-button tap do nothing because the kernel is gone, and on
  # 10-21 not even a 10 s hold cut the power: it sat there until the battery
  # was flat. Newer drivers and kernels didn't fix it, and no module parameter
  # turns the handler off (NVIDIA forum t/385856, open-gpu-kernel-modules#860).
  #
  # So the default boot never loads the driver and takes the card off the PCI
  # bus. The desktop loses nothing: eDP-1 and HDMI-A-1 both hang off the Intel
  # card, and the NVIDIA card's only connector (eDP-2) is never connected.
  # For games, pick "nvidia" in the boot menu. That entry brings PRIME offload
  # back, and the freeze risk with it, so use it only for gaming sessions.
  #
  # The shared `hardware.graphics.enable` lives in common.nix; only the Intel
  # driver bits are host-specific.
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver # VAAPI for Meteor Lake
    vpl-gpu-rt # Intel Quick Sync runtime
  ];

  # Inert in the default boot: the whole nvidia module sits behind
  # `hardware.nvidia.enabled`, which only the "nvidia" entry turns on. It lives
  # out here so `enableOffloadCmd` reads true in both boots, and common.nix
  # stamps `nvidia-offload` into Steam launch options whichever one Steam
  # first sees a game in.
  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    # Bus IDs verified from /sys: Intel 00:02.0, NVIDIA 01:00.0
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Default boot: remove the card from the PCI bus as soon as udev sees it, so
  # nothing can bind to it and its root port is free to drop it into D3cold. A
  # driverless card left on the bus sits in D0 and keeps the port awake. The
  # blacklist covers a later PCI rescan bringing it back.
  boot.blacklistedKernelModules = lib.mkIf (!config.hardware.nvidia.enabled) [
    "nouveau"
    "nova_core"
    "nvidiafb"
  ];
  services.udev.extraRules = lib.mkIf (!config.hardware.nvidia.enabled) ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{power/control}="auto", ATTR{remove}="1"
  '';
  # ── Local LLM for opencode ────────────────────────────────────────────────
  # Ollama on 127.0.0.1:11434; opencode talks to its OpenAI-compatible /v1
  # endpoint (provider block in ~/.config/opencode/opencode.jsonc).
  #
  # The Vulkan build, not ollama-cuda: it is free, so it comes from
  # cache.nixos.org instead of a long local CUDA build. It uses the RTX 4070
  # in the "nvidia" entry; in the default boot (card off the bus) it runs on
  # the CPU, since Ollama ignores integrated GPUs unless OLLAMA_IGPU_ENABLE=1.
  #
  # qwen3.6:35b-a3b-coding is a MoE with ~3B active parameters, so it is usable
  # with only 8 GB of VRAM. The VRAM/RAM split needs no setting: Ollama leaves
  # -ngl unset, and its bundled llama-server's `--fit` (default on) keeps the
  # attention/dense weights and KV cache in VRAM and spills MoE expert weights
  # to system RAM until it fits. Forcing `LLAMA_ARG_N_CPU_MOE` would override
  # that. It is tagged for tool calling, which opencode's agent loop needs.
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    loadModels = [ "qwen3.6:35b-a3b-coding" ];
    environmentVariables = {
      # Ollama's default context is too small for opencode, whose system prompt
      # and tool definitions alone use ~10k tokens. Only 10 of the model's 42
      # layers keep a KV cache (the rest are linear-attention), so 128k at q8_0
      # is ~1.3 GB of VRAM (32k at f16 was 0.64 GB). The model goes to 256k,
      # but prefill runs at ~170 tok/s with the experts in RAM, so re-reading a
      # full 256k context would take ~25 min. Must match `limit.context` in
      # ~/.config/opencode/opencode.jsonc.
      OLLAMA_CONTEXT_LENGTH = "131072";
      OLLAMA_KV_CACHE_TYPE = "q8_0"; # needs flash attention
      OLLAMA_FLASH_ATTENTION = "1";
    };
  };

  # Steam launch options already say `nvidia-offload gamemoderun %command%`.
  # Without the driver, the command still has to exist; the game simply runs
  # on the Intel GPU.
  environment.systemPackages = lib.mkIf (!config.hardware.nvidia.enabled) [
    (pkgs.writeShellScriptBin "nvidia-offload" ''exec "$@"'')
  ];

  specialisation.nvidia.configuration = {
    system.nixos.tags = [ "nvidia" ];

    services.xserver.videoDrivers = [ "nvidia" ];

    # Pin Sway/wlroots to the Intel iGPU so it doesn't try to use the NVIDIA
    # card for display. With the driver loaded, card1 = i915 (the NVIDIA card
    # at PCI 01:00.0 enumerates as card0). In the default boot there is only
    # one card, so nothing is pinned there. Cannot use the by-path identifier
    # because WLR_DRM_DEVICES splits on ':' and PCI paths contain colons.
    environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/card1";

    # Sway hard-refuses to start when the proprietary NVIDIA driver is loaded;
    # this flag bypasses that check. The iGPU still drives the display via PRIME.
    programs.sway.extraOptions = [ "--unsupported-gpu" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # powerManagement.enable wraps every suspend in nvidia-sleep.sh, which does
    # `chvt 63` before sleeping and switches back on resume so an X server on
    # the NVIDIA card lets go of it. Nothing here displays on that card (sway
    # is pinned to the iGPU above), so all the round-trip does is make sway
    # drop and re-take its VT, DRM master and every input device while
    # swaylock holds the lock. It is the prime suspect for the "dead lock
    # screen" resumes — dark screen, keys do nothing, power button the only way
    # out — which began with the move to greetd (sway on VT1, 2026-09-15): none
    # in the month before, near-daily after. Keep the driver notification (it
    # is what saves VRAM under PreserveVideoMemoryAllocations), drop the VT
    # switch.
    systemd.services =
      let
        nvidiaSleep =
          state:
          lib.mkForce (
            pkgs.writeShellScript "nvidia-${state}" ''
              [ -e /proc/driver/nvidia/suspend ] || exit 0
              echo ${state} > /proc/driver/nvidia/suspend
            ''
          );
      in
      {
        nvidia-suspend.serviceConfig.ExecStart = nvidiaSleep "suspend";
        nvidia-resume.serviceConfig.ExecStart = nvidiaSleep "resume";
      };
  };

  # ── Gaming ──────────────────────────────────────────────────────────────────
  # Steam + gamemode are in common.nix.
  #
  # NOTE: gamescope was tried to fix the XWayland mouse-offset ("can't click
  # buttons") issue, but nested gamescope is broken on this Intel+NVIDIA
  # hybrid (cross-GPU swapchain sharing fails, games die on the first frame).
  # Use the game's own Borderless Windowed mode instead — no resolution change
  # means no XWayland pointer offset, and clicks land correctly.

  # ── Waydroid: Android container (for Boom Beach etc.) ───────────────────────
  # Runs a full Android userspace in an LXC container on the host kernel via
  # binder. Needs Wayland (Sway provides it). After a rebuild, run once:
  #   sudo waydroid init -s GAPPS      # download image WITH Google Play
  #   sudo systemctl start waydroid-container
  #   waydroid session start &         # then: waydroid show-full-ui
  # See the notes at the bottom of this section for getting Boom Beach on.
  virtualisation.waydroid = {
    enable = true;

    # This kernel ships ONLY the nftables netfilter backend — the legacy
    # ip_tables.ko modules don't exist. Waydroid's default waydroid-net.sh
    # hard-prefers the `iptables-legacy` binary, so the container's network
    # setup dies with "can't initialize iptables table `filter'". The package's
    # `withNftables` flag builds the script to drive `nft` directly (and puts
    # it on the script's PATH), which works with the nft_tables module we do
    # have.
    package = pkgs.waydroid.override { withNftables = true; };
  };

  # Boom Beach is online-only, so the container must reach the internet. The
  # NixOS firewall would otherwise drop forwarded traffic on Waydroid's bridge.
  networking.firewall.trustedInterfaces = [ "waydroid0" ];

  # ── Audio: Yoga Pro 9 16IMH9 speaker workaround ─────────────────────────────
  # The speakers hang off TAS2781 i2c smart amps, which only get their firmware
  # and DSP profile when the ALC287 codec is given ALC287_FIXUP_TAS2781_I2C.
  # The kernel has that quirk under this machine's *codec* SSID (17aa:38d6),
  # but PCI SSIDs are matched first, and the PCI SSID here (17aa:3811) collides
  # with the "Legion S7 15IMH05" entry — so the wrong fixup wins, the amps are
  # never bound, and the speakers come out quiet with no bass.
  #
  # "17aa:38d6" is an SSID alias: it tells the fixup lookup to behave as if that
  # were the ID, since the TAS2781 fixup has no model name of its own. The
  # option goes to the SOF driver because SOF owns this card (it has DMICs);
  # 'snd-hda-intel model=' is never read here.
  #
  # Working: 'journalctl -k -b | grep -E "picked fixup|TIAS2781"' shows the
  # codec line "for alias SSID 17aa:38d6" and then "bound i2c-TIAS2781:00".
  boot.extraModprobeConfig = ''
    options snd-sof-intel-hda-generic hda_model=17aa:38d6
  '';

  # Binding is necessary but not sufficient. The amp driver's first setup at
  # boot leaves the two woofer amps dead — it reports no error, the mixer
  # controls appear, and only the tweeters play. Reloading the driver once the
  # user's PipeWire has the speaker sink open sets them up properly (reloading
  # earlier does not), so that is what this service does, at boot and again
  # after every resume. Known bug on this model, no upstream fix yet; approach
  # from https://github.com/Reidafesta/yoga-pro-9-speaker-fix.
  #
  # Two things keep it working afterwards:
  #  - 'Speaker Force Firmware Load': without it, each time the sink reopens
  #    after going idle the driver only switches the amps on, without their DSP
  #    program, and the woofers are gone again. With it, every reopen is a full
  #    setup — which takes ~2.5 s, during which there is no bass.
  #  - hence the WirePlumber rule below: keep the sink open for 5 min of
  #    silence instead of 5 s, so that delay is rare.
  #
  # Check: 'journalctl -t yoga-speaker-fix -b' should end in "done".
  systemd.services.yoga-speaker-fix =
    let
      sleepTargets = [
        "suspend.target"
        "hibernate.target"
        "suspend-then-hibernate.target"
      ];
    in
    {
      description = "Reload the TAS2781 woofer amp driver once user audio is up";
      wantedBy = [ "multi-user.target" ] ++ sleepTargets;
      after = sleepTargets;
      serviceConfig = {
        # "exec", not "oneshot": the script waits for a login, boot must not.
        Type = "exec";
        SyslogIdentifier = "yoga-speaker-fix";
        ExecStart = lib.getExe (
          pkgs.writeShellApplication {
            name = "yoga-speaker-fix";
            runtimeInputs = with pkgs; [
              alsa-utils
              coreutils
              gawk
              gnugrep
              kmod
              pulseaudio # pactl
              systemd
              util-linux # runuser
            ];
            text = ''
              mod=snd_hda_scodec_tas2781_i2c
              amp=/sys/bus/i2c/devices/i2c-TIAS2781:00

              # pactl as the given uid: root can't reach a user's PipeWire.
              upactl() {
                local uid=$1
                shift
                runuser -u "$(id -nu "$uid")" -- \
                  env XDG_RUNTIME_DIR="/run/user/$uid" pactl "$@"
              }

              # "uid sink" for every logged-in user whose PipeWire has the speakers.
              speaker_sinks() {
                local sock uid sink
                for sock in /run/user/*/pulse/native; do
                  [ -S "$sock" ] || continue
                  uid=$(stat -c %u "$sock")
                  [ "$uid" -ge 1000 ] || continue
                  sink=$(upactl "$uid" list short sinks 2>/dev/null |
                    awk '/Speaker__sink/ { print $2; exit }') || true
                  [ -n "$sink" ] && echo "$uid $sink"
                done
                return 0
              }

              # 1. The codec has to have picked the amps up at all (hda_model above).
              for _ in $(seq 120); do
                journalctl -k -b -o cat | grep -q 'bound i2c-TIAS2781' && break
                sleep 0.5
              done
              journalctl -k -b -o cat | grep -q 'bound i2c-TIAS2781' || {
                echo "amps never bound to the codec, giving up"
                exit 1
              }

              # 2. Wait, however long, for a login whose PipeWire shows the speakers.
              until [ -n "$(speaker_sinks)" ]; do sleep 1; done

              # 3. Reload. Right after boot the module can still be busy loading
              #    firmware, so retry for a while.
              for _ in $(seq 60); do
                modprobe -r "$mod" 2>/dev/null && break
                sleep 0.5
              done
              modprobe "$mod"
              sleep 2

              # Keep the amps out of runtime suspend.
              [ -w "$amp/power/control" ] && echo on > "$amp/power/control"

              # 4. Full amp setup on every sink reopen. A reload resets this switch.
              for card in /proc/asound/card[0-9]*; do
                amixer -q -c "''${card##*card}" \
                  cset iface=CARD,name='Speaker Force Firmware Load' on 2>/dev/null || true
              done

              # 5. Close and reopen the sink so the setup happens now.
              speaker_sinks | while read -r uid sink; do
                upactl "$uid" suspend-sink "$sink" 1 || true
                sleep 1
                upactl "$uid" suspend-sink "$sink" 0 || true
              done
              echo "done"
            '';
          }
        );
      };
    };

  services.pipewire.wireplumber.extraConfig."51-yoga-speaker-suspend" = {
    "monitor.alsa.rules" = [
      {
        matches = [ { "node.name" = "~alsa_output.*Speaker__sink"; } ];
        actions.update-props."session.suspend-timeout-seconds" = 300;
      }
    ];
  };

  # ── Laptop: lid switch + bluetooth ──────────────────────────────────────────
  # Lid close → suspend. Docked (external monitor connected) → ignore so the
  # machine stays up. swayidle still locks before sleep via the before-sleep hook.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # Bluetooth + Blueman GUI (blueman-manager for pairing, blueman-applet tray)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true; # battery % reporting for some devices
  };
  services.blueman.enable = true;

  # ── KDE Connect: phone ↔ laptop (notifications, files, clipboard) ───────────
  # Installs kdeconnect-kde and opens its ports (TCP+UDP 1714–1764). The daemon
  # and tray indicator are home-manager user services keyed off this option
  # (see 'modules/home/default.nix'), because sway ignores XDG autostart.
  programs.kdeconnect.enable = true;
}
