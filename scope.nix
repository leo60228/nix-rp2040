{ lib, newScope }:
lib.makeScope newScope (self: {
  pico-sdk = self.callPackage ./pico-sdk { };
  pico-sdk-minimal = self.callPackage ./pico-sdk {
    minimal = true;
    picotool = null;
  };
  picotool = self.callPackage ./picotool { };
})
