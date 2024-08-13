{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.nixpkgs-unfree.url = "github:numtide/nixpkgs-unfree";
  inputs.nixpkgs-unfree.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    {
      self,
      nixpkgs-unfree,
      flake-utils,
      ...
    }:
    let
      out =
        system:
        let
          pkgs = nixpkgs-unfree.legacyPackages.${system};
          appliedOverlay = self.overlays.default pkgs pkgs;
          shell =
            {
              mkShell,
              cmake,
              gcc-arm-embedded,
              pico-sdk,
              picotool,
              segger-jlink-headless,
            }:
            mkShell {
              packages = [
                cmake
                gcc-arm-embedded
                pico-sdk
                picotool
              ];
            };
        in
        {
          packages = {
            inherit (appliedOverlay.rp2040Packages) pico-sdk pico-sdk-minimal picotool;
          };

          devShell = appliedOverlay.rp2040Packages.callPackage shell { };
        };
    in
    flake-utils.lib.eachDefaultSystem out
    // {
      overlays.default = final: prev: {
        rp2040Packages = final.callPackage ./scope.nix { };
        inherit (final.rp2040Packages) pico-sdk pico-sdk-minimal picotool;
      };
    };
}
