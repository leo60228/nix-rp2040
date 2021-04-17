{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.pico-sdk = {
    flake = false;
    url = "https://github.com/raspberrypi/pico-sdk.git?ref=1.1.2";
    type = "git";
    submodules = true;
  };

  outputs = { nixpkgs, flake-utils, pico-sdk, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = {
          pico-sdk = with pkgs; stdenv.mkDerivation {
            pname = "pico-sdk";
            version = "1.1.2";

            src = pico-sdk;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
            mkdir -p $out/share
            cp -r . $out/share/pico-sdk
            '';

            setupHook = writeText "setup-hook" ''
            export PICO_SDK_PATH=@out@/share/pico-sdk
            '';
          };
        };
      }
    );
}
