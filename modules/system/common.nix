{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Ljubljana";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sl_SI.UTF-8";
    LC_IDENTIFICATION = "sl_SI.UTF-8";
    LC_MEASUREMENT = "sl_SI.UTF-8";
    LC_MONETARY = "sl_SI.UTF-8";
    LC_NAME = "sl_SI.UTF-8";
    LC_NUMERIC = "sl_SI.UTF-8";
    LC_PAPER = "sl_SI.UTF-8";
    LC_TELEPHONE = "sl_SI.UTF-8";
    LC_TIME = "sl_SI.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.galjeza = {
    isNormalUser = true;
    description = "Gal Jeza";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Graphics — Intel iGPU drives the display, NVIDIA RTX 4070 stays asleep
  # until a CUDA workload (or an explicit `nvidia-offload <cmd>`) wakes it.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # VAAPI for Meteor Lake
      vpl-gpu-rt # Intel Quick Sync runtime
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # Pin Sway/wlroots to the Intel iGPU so it doesn't try to use the NVIDIA
  # card for display. card1 = i915 on this machine (the NVIDIA card at PCI
  # 01:00.0 enumerates as card0). Cannot use the by-path identifier here
  # because WLR_DRM_DEVICES splits on ':' and PCI paths contain colons.
  environment.sessionVariables = {
    WLR_DRM_DEVICES = "/dev/dri/card1";
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Bus IDs verified from /sys: Intel 00:02.0, NVIDIA 01:00.0
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Local LLM stack: Ollama daemon with CUDA + Open WebUI on localhost:8080
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "127.0.0.1";
    port = 11434;
  };

  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 8090;
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = "False";
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    sway
    meld
    google-chrome
    firefox
    pritunl-client
    screen
    anydesk
  ];

  systemd.services.pritunl-client = {
    description = "Pritunl Client Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.pritunl-client}/bin/pritunl-client-service";
      Restart = "always";
      RestartSec = "5s";
    };
  };

  # enable x11 for legacy desktop apps
  services.xserver.enable = true;
  #enable sway windows manager
  programs.sway.enable = true;
  # Sway hard-refuses to start when the proprietary NVIDIA driver is loaded;
  # this flag bypasses that check. The iGPU still drives the display via PRIME.
  programs.sway.extraOptions = [ "--unsupported-gpu" ];
  programs.zsh.enable = true;
  programs.steam.enable = true;

  # nix-ld: allow dynamically linked FHS binaries (e.g. prebuilt Electron) to run.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    glibc
    zlib
    glib
    nss
    nspr
    atk
    at-spi2-atk
    at-spi2-core
    cups
    dbus
    expat
    libdrm
    libxkbcommon
    mesa
    libgbm
    alsa-lib
    cairo
    pango
    gdk-pixbuf
    gtk3
    fontconfig
    freetype
    libnotify
    libsecret
    systemd
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libxkbfile
  ];

  # Audio via PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Yoga Pro 9 16IMH9 speaker workaround: force the ALC287 fixup that wires
  # the TAS2781 i2c amps as speaker output. The kernel doesn't have a quirk
  # for PCI SSID 17aa:3811, so we hint the model explicitly.
  boot.extraModprobeConfig = ''
    options snd-hda-intel model=yoga9-bass-spk-pin
  '';

  # Lid close → suspend. Docked (external monitor connected) → ignore so the
  # machine stays up. swayidle still locks before sleep via the before-sleep hook.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # PAM service required for swaylock to authenticate.
  security.pam.services.swaylock = { };

  # Firmware updates via LVFS. Run `fwupdmgr refresh` then `fwupdmgr update`
  # to pull and apply Lenovo BIOS / Thunderbolt / SSD firmware updates.
  services.fwupd.enable = true;

  virtualisation.docker.enable = true;
  #enable extra featuresw  in sway wrapper
  programs.sway.wrapperFeatures.gtk = true;
  #enable policykit so that graphical programs can request elevated privileges
  security.polkit.enable = true;
  services.spice-vdagentd.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
