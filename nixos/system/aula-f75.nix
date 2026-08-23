# nixos/system/aula-f75.nix
# AULA F75 keyboard configurator (windows-only) under wine

# AULA never shipped anything but a windows driver for the F75, so the only way to
# touch the RGB, macros and remapping is their OemDrv.exe under wine. the reddit
# writeup going around only gets you halfway, so this is a proper module instead of
# a pile of one-off commands. install the driver once into the prefix below and it's
# `aula-f75` from anywhere, or the entry in the app launcher.

{ config, pkgs, lib, ... }:

let
  prefix = "$HOME/.local/share/wineprefixes/aula-f75";

  aula-f75 = pkgs.writeShellApplication {
    name = "aula-f75";
    text = ''
      export WINEPREFIX="''${WINEPREFIX:-${prefix}}"
      export WINEDEBUG="''${WINEDEBUG:--all}"

      app="$WINEPREFIX/drive_c/Program Files (x86)/AULA/F75"
      cd "$app" || {
        echo "aula-f75: no driver at $app" >&2
        echo "grab it from https://www.aulastar.com/drive/ and install it into that prefix:" >&2
        echo "  WINEPREFIX=$WINEPREFIX wine 'AULA F75 driver.exe' /VERYSILENT" >&2
        exit 1
      }

      exec wine OemDrv.exe "$@"
    '';
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "aula-f75";
    desktopName = "AULA F75";
    comment = "keyboard lighting, macros and remapping";
    exec = "aula-f75";
    icon = "input-keyboard";
    categories = [ "Settings" "HardwareSettings" ];
  };
in
{
  environment.systemPackages = [ aula-f75 desktopItem ];

  # the config interface is a separate hidraw node from the one you type on, and
  # which number it lands on moves around, so match the device and cover both.
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="258a", ATTRS{idProduct}=="010c", GROUP="input", MODE="0660"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="fa09", GROUP="input", MODE="0660"
  '';
}
