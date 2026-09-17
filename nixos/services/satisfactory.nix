# nixos/services/satisfactory.nix

{ config, pkgs, ... }:

let
  installDir = "/home/steam/satisfactory-server";
in
{
  users.groups.steam = { };
  users.users.steam = {
    isSystemUser = true;
    group        = "steam";
    description  = "satisfactory dedicated server";
    home         = "/home/steam";
    createHome   = true;
    shell        = pkgs.bashInteractive;
  };

  systemd.services.satisfactory = {
    description = "Satisfactory Dedicated Server";
    wantedBy    = [ "multi-user.target" ];
    wants       = [ "network-online.target" ];
    after       = [ "network-online.target" ];

    environment.HOME = "/home/steam";

    serviceConfig = {
      Type             = "simple";
      User             = "steam";
      Group            = "steam";
      WorkingDirectory = "/home/steam";

      # install/update on every start; "-" so a steam outage doesn't block startup
      ExecStartPre = "-${pkgs.steamcmd}/bin/steamcmd +force_install_dir ${installDir} +login anonymous +app_update 1690800 validate +quit";
      ExecStart    = "${pkgs.steam-run}/bin/steam-run ${installDir}/FactoryServer.sh -Port=7777 -multihome=:: -log -unattended";

      Restart         = "always";
      RestartSec      = 15;
      TimeoutStartSec = 3600; # first download is several GB
      LimitNOFILE     = 65535;
    };
  };
}
