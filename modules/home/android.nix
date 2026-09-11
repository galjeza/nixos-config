{
  pkgs,
  lib,
  osConfig,
  ...
}:
# Android SDK for React Native / Expo development (lime-booking marketplace).
#
# The versions below are NOT arbitrary — they are what the Expo SDK 57 /
# React Native 0.86 project resolves to after `expo prebuild`, read from
# `node_modules/react-native/gradle/libs.versions.toml` (the version catalog
# `expoAutolinking.useExpoVersionCatalog()` pulls in). Gradle refuses to
# substitute a different NDK or build-tools revision, and the Nix store is
# read-only, so it cannot download the missing one the way it would on a normal
# distro: a mismatch here is a hard build failure, not a slow first build.
# Re-check them after an Expo SDK bump.
let
  buildToolsVersion = "36.0.0";
  # Expo's own gradle plugin falls back to 35.0.0 for modules whose version
  # catalog lookup misses (ExpoRootProjectPlugin.kt), so :expo and friends ask
  # for it regardless of what the root project resolves to.
  fallbackBuildToolsVersion = "35.0.0";
  platformVersion = "36";

  # React Native's pin, applied to every module that opts in via the
  # `rootProject.hasProperty("ndkVersion")` snippet in its build.gradle.
  ndkVersion = "27.1.12297006";
  # ...and AGP 8.12's *own* default, which the modules lacking that snippet
  # (expo-updates among them) ask for. On a normal distro Gradle downloads it
  # on demand; the Nix store is read-only, so it has to be here up front or the
  # build dies with "The SDK directory is not writable".
  agpDefaultNdkVersion = "27.0.12077973";

  # Only the two physical machines get this — the closure is ~6.3 GB of SDK,
  # NDKs and toolchain, and the VMs never build Android.
  androidHosts = [
    "lenovo-yoga"
    "desktop"
  ];
  enable = osConfig != null && builtins.elem osConfig.networking.hostName androidHosts;

  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [
      platformVersion
      "35" # some autolinked libraries still compile against 35
    ];
    buildToolsVersions = [
      buildToolsVersion
      fallbackBuildToolsVersion
    ];
    ndkVersions = [
      ndkVersion
      agpDefaultNdkVersion
    ];
    # 3.30.5 is React Native's own pin (ReactAndroid/build.gradle.kts);
    # 3.22.1 is what older third-party modules still ask for.
    cmakeVersions = [
      "3.30.5"
      "3.22.1"
    ];
    includeNDK = true;
    includeEmulator = false; # Waydroid is the device on these hosts
    includeSystemImages = false;
    abiVersions = [ "x86_64" ];
  };

  sdkRoot = "${androidComposition.androidsdk}/libexec/android-sdk";
in
{
  # The SDK is deliberately NOT in home.packages: its bin/ exports adb and
  # fastboot, which would shadow the system-wide android-tools (common.nix).
  # Gradle only needs ANDROID_HOME, so keeping one adb on PATH avoids the
  # "adb server version doesn't match this client" restart loop.
  home.packages = lib.optional enable pkgs.jdk17;

  home.sessionVariables = lib.optionalAttrs enable {
    ANDROID_HOME = sdkRoot;
    ANDROID_SDK_ROOT = sdkRoot; # deprecated by Google, still read by some tools
    ANDROID_NDK_ROOT = "${sdkRoot}/ndk/${ndkVersion}";
    JAVA_HOME = "${pkgs.jdk17}";

    # AGP normally pulls aapt2 from Maven as a prebuilt binary linked against
    # /lib64/ld-linux-x86-64.so.2, which does not exist on NixOS. Point it at
    # the autopatchelf'd copy that ships inside the Nix build-tools package.
    GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${sdkRoot}/build-tools/${buildToolsVersion}/aapt2";
  };
}
