{ config, pkgs, ... }:

let
  # override openldap ONLY for wine's dependency tree, not globally.
  pkgsWithFixedLdap = pkgs.extend (final: prev: {
    openldap = prev.openldap.overrideAttrs { doCheck = false; };
  });
in
{
  environment.systemPackages = [
    pkgsWithFixedLdap.wineWow64Packages.waylandFull
    pkgsWithFixedLdap.bottles
    pkgs.winetricks
    pkgs.cabextract
    pkgs.dxvk
    pkgs.vkd3d
    pkgs.vkd3d-proton
  ];

  environment.sessionVariables = {
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";
  };
}
