# nixos/services/minecraft-backup-archive.nix

{ config, pkgs, lib, ... }:

let
  serverDir  = "/home/sidharthify/minecraft/prodigium";
  sourceDir  = "${serverDir}/simplebackups";
  archiveDir = "/home/sidharthify/minecraft/backups-daily";
  keepDays   = 14;
  user       = "sidharthify";

  archiveScript = pkgs.writeShellScript "mc-backup-archive" ''
    set -eu
    mkdir -p ${archiveDir}
    newest=$(ls -t ${sourceDir}/*.zip 2>/dev/null | head -n1 || true)
    if [ -z "$newest" ]; then
      echo "no snapshots in ${sourceDir} - nothing to archive"
      exit 0
    fi

    today=$(date +%Y-%m-%d)
    target=${archiveDir}/daily_$today.zip

    if [ -e "$target" ]; then
      echo "today's archive already exists: $target"
    else
      cp "$newest" "$target.partial"
      mv "$target.partial" "$target"
      echo "archived $(basename "$newest") -> $(basename "$target") ($(du -h "$target" | cut -f1))"
    fi

    find ${archiveDir} -name 'daily_*.zip' -type f -mtime +${toString keepDays} -print -delete

    echo "archive now holds $(ls -1 ${archiveDir}/daily_*.zip 2>/dev/null | wc -l) daily snapshots, $(du -sh ${archiveDir} | cut -f1) total"
  '';
in
{
  systemd.services.mc-backup-archive = {
    description = "Promote a Minecraft backup into the ${toString keepDays}-day archive";
    serviceConfig = {
      Type = "oneshot";
      User = user;
      Group = "users";
      ExecStart = archiveScript;
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    path = [ pkgs.coreutils pkgs.findutils ];
  };

  systemd.timers.mc-backup-archive = {
    description = "Daily Minecraft backup archive";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "15m";
    };
  };
}
