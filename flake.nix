{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.pico-sdk = {
    flake = false;
    url = "github:raspberrypi/pico-sdk/develop";
  };

  inputs.tinyusb = {
    flake = false;
    url = "github:hathach/tinyusb/d49938d0f5052bce70e55c652b657c0a6a7e84fe";
  };

  outputs = { nixpkgs, flake-utils, pico-sdk, tinyusb, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = {
          pico-sdk = with pkgs; stdenv.mkDerivation {
            pname = "pico-sdk-unstable";
            version =
              let
                date = pico-sdk.lastModifiedDate;
                year = builtins.substring 0 4 date;
                month = builtins.substring 4 2 date;
                day = builtins.substring 6 2 date;
                iso8601 = "${year}-${month}-${day}";
              in
                iso8601;

            src = pico-sdk;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
            mkdir -p $out/share
            cp -r . $out/share/pico-sdk

            rm -rf $out/share/pico-sdk/lib/tinyusb
            cp -r ${tinyusb} $out/share/pico-sdk/lib/tinyusb
            '';

            setupHook = writeText "setup-hook" ''
            export PICO_SDK_PATH=@out@/share/pico-sdk
            '';
          };
        };
      }
    );
}
