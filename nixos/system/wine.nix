{ config, pkgs, ... }:

{
  # overlay to bypass broken openldap tests that are blocking wine from building
  nixpkgs.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (old: {
        doCheck = false;
      });
    })
  ];


  environment.systemPackages = with pkgs; [
    wineWowPackages.waylandFull
    winetricks
    cabextract
    dxvk
    vkd3d
    vkd3d-proton
    bottles
  ];

  environment.sessionVariables = {
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";

    # fsync
    WINEFSYNC = "1";
    WINEESYNC = "1";
  };
}
