# nixos/services/mc-discord-bot.nix
# systemd service for bot for minecraft server with friends
# ignore

{ config, pkgs, lib, ... }:

let
  botDir = "/home/sidharthify/projects/mc-discord-bot";
  user   = "sidharthify";

  pythonEnv = pkgs.python3.withPackages (ps: [ ps.discordpy ]);
in
{
  systemd.services.mc-discord-bot = {
    description = "Discord control bot for the Minecraft server";
    after    = [ "network-online.target" ];
    wants    = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];   # must survive reboots: the whole point
                                          # is working while the owner is away

    path = [ pkgs.systemd ];              # for `systemctl is-active/start/stop`

    serviceConfig = {
      Type             = "simple";
      User             = user;
      Group            = "users";
      WorkingDirectory = botDir;
      ExecStart        = "${pythonEnv}/bin/python3 ${botDir}/bot.py";
      Restart    = "always";
      RestartSec = 15;
      StateDirectory     = "mc-discord-bot";
      StateDirectoryMode = "0700";
      NoNewPrivileges = true;
      PrivateTmp      = true;
      ProtectSystem   = "strict";
      ReadWritePaths  = [ "/var/lib/mc-discord-bot" ];
      RestrictSUIDSGID = true;
    };
  };
}
