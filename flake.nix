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
    crane.url = "github:ipetkov/crane";
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
        fenix =
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
        crane = (inputs.crane.mkLib pkgs).overrideToolchain fenix;
        android = inputs.android.sdk.${system} (
          pkgs: with pkgs; [
            cmdline-tools-latest
            platform-tools
            build-tools-35-0-0
            platforms-android-35
            ndk-28-0-12433566
            emulator
            system-images-android-35-google-apis-arm64-v8a
            system-images-android-35-google-apis-x86-64
          ]
        );
      in
      {
        devShell = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              fenix
              android
              jdk
              gnumake
              cargo-ndk
              taplo
              pkg-config
              openssl
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (
              with pkgs.darwin.apple_sdk.frameworks;
              [
                AppKit
                Carbon
                CoreFoundation
                CoreGraphics
                CoreServices
                CoreVideo
                Foundation
                Metal
                QuartzCore
                iconv
              ]
            );
          ANDROID_HOME = "${android}/share/android-sdk";
          JAVA_HOME = pkgs.jdk;
          LD_LIBRARY_PATH =
            with pkgs;
            lib.makeLibraryPath [
              wayland
              libxkbcommon
              vulkan-loader
            ];
        };
        packages.default =
          let
            name = "flpov";
            crate = crane.crateNameFromCargoToml { cargoToml = ./crates/flpov/Cargo.toml; };
            # src = crane.cleanCargoSource ./.;
            src = ./.;
            cargoArtifacts = crane.buildDepsOnly {
              pname = name;
              version = crate.version;
              inherit src;
              strictDeps = true;
            };
          in
          crane.buildPackage {
            pname = name;
            inherit (crate) version;
            inherit src;
            cargoExtraArgs = "-p ${name}";
            inherit cargoArtifacts;
          };
      }
    );
}
