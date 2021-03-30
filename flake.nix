{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.pico-sdk = {
    url = "github:raspberrypi/pico-sdk?ref=1.1.0";
    flake = false;
  };

  outputs = { nixpkgs, flake-utils, pico-sdk, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = {
          pico-sdk = with pkgs; stdenv.mkDerivation {
            pname = "pico-sdk";
            version = "1.1.0";

            src = pico-sdk;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
            mkdir -p $out/share
            cp -r $src $out/share/pico-sdk
            '';

            setupHook = writeText "setup-hook" ''
            export PICO_SDK_PATH=@out@/share/pico-sdk
            '';
          };
        };
      }
    );
}
