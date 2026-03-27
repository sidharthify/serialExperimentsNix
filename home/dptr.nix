{ config, pkgs, ... }:

{
  systemd.user.services.dptr = {
    Unit = {
      Description = "Daily Personal Terminal Report";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      # Using the global NixOS system path since DPTR was added to environment.systemPackages
      ExecStart = "/run/current-system/sw/bin/dptr --config %h/.config/dptr/config.yaml --terminal";
      TimeoutStartSec = 120;
    };
  };
}
