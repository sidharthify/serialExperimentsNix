# nixos/services/steam.nix

{ config, pkgs, ... }:

{
  programs.steam = {
    enable      = true;
    #package     = pkgs.millennium-steam;
    remotePlay.openFirewall            = true;
    dedicatedServer.openFirewall       = true;
    localNetworkGameTransfers.openFirewall = true;

    # gamescope session (console mode, selectable from SDDM)
    gamescopeSession.enable = true;
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
}
