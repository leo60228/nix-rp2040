{
  lib,
  stdenv,
  fetchgit,
  fetchFromGitHub,
  cmake,
  writeText,
  picotool,
  minimal ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pico-sdk";
  version = "2.0.0";

  src =
    if minimal then
      fetchFromGitHub {
        owner = "raspberrypi";
        repo = "pico-sdk";
        rev = finalAttrs.version;
        hash = "sha256-d6mEjuG8S5jvJS4g8e90gFII3sEqUVlT2fgd9M9LUkA=";
      }
    else
      (fetchgit {
        url = "https://github.com/raspberrypi/pico-sdk.git";
        rev = finalAttrs.version;
        fetchSubmodules = false;
        hash = "sha256-fVSpBVmjeP5pwkSPhhSCfBaEr/FEtA82mQOe/cHFh0A=";
      }).overrideAttrs
        (oldAttrs: {
          NIX_PREFETCH_GIT_CHECKOUT_HOOK = "git -C $out submodule update --init --depth=1; find $out -name .git -print0 | xargs -0 rm -rf";
        });

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ picotool ];

  # SDK contains libraries and build-system to develop projects for RP2040 chip
  # We only need to compile pioasm binary
  sourceRoot = "${finalAttrs.src.name}/tools/pioasm";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/pico-sdk
    cp -a ../../../* $out/lib/pico-sdk/
    chmod 755 $out/lib/pico-sdk/tools/pioasm/build/pioasm
    runHook postInstall
  '';

  setupHook = writeText "setupHook.sh" ''
    addPicoSdkPath() {
      if [ -e "$1/lib/pico-sdk" ]; then
        export PICO_SDK_PATH="$1/lib/pico-sdk"
      fi
    }

    addEnvHooks "$hostOffset" addPicoSdkPath
  '';

  meta = with lib; {
    homepage = "https://github.com/raspberrypi/pico-sdk";
    description = "SDK provides the headers, libraries and build system necessary to write programs for the RP2040-based devices";
    license = if minimal then licenses.bsd3 else licenses.unfree;
    platforms = platforms.unix;
  };
})
