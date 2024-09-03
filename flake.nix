{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    android = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      ...
    }@inputs:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        rust =
          with inputs.fenix.packages.${system};
          combine [
            complete.rustc
            complete.cargo
            complete.clippy
            complete.rustfmt
            complete.rust-src
            complete.rust-analyzer
            targets.x86_64-unknown-linux-gnu.latest.rust-std
            targets.aarch64-linux-android.latest.rust-std
            targets.x86_64-linux-android.latest.rust-std
          ];
        buildToolsVersion = "34.0.0";
        android = inputs.android.sdk.${system} (
          pkgs: with pkgs; [
            cmdline-tools-latest
            platform-tools
            build-tools-34-0-0
            platforms-android-34
            ndk-27-0-11902837
            emulator
            system-images-android-34-google-apis-arm64-v8a
            system-images-android-34-google-apis-x86-64
          ]
        );
      in
      {
        devShell = pkgs.mkShell rec {
          buildInputs = with pkgs; [
            rust
            android
            jdk17

            pkg-config
            openssl
          ];
          ANDROID_HOME = "${android}/share/android-sdk";
          ANDROID_SDK_ROOT = ANDROID_HOME;
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_HOME}/build-tools/${buildToolsVersion}/aapt2";
          JAVA_HOME = pkgs.jdk17;
        };
      }
    );
}
