# nixos/services/minecraft-prodigium.nix
# Prodigium Reforged 4.2.0422, Forge 1.20.1 / Java 17, 10 GB heap.
#
# the pack ships ServerPackCreator's start.sh, which regenerates
# user_jvm_args.txt from variables.txt on every boot so RAM and GC flags are
# edited in variables.txt (JAVA_ARGS), never in user_jvm_args.txt.
#
# Deliberately NOT wantedBy multi-user.target: start/stop is manual, via `mc`.

{ config, pkgs, lib, ... }:

let
  serverDir = "/home/sidharthify/minecraft/prodigium";
  user      = "sidharthify";
  fifo      = "/run/minecraft-prodigium/console";
  java      = pkgs.temurin-bin-17;

  startScript = pkgs.writeShellScript "minecraft-prodigium-start" ''
    set -eu
    rm -f ${fifo}
    mkfifo -m 600 ${fifo}
    cd ${serverDir}
    exec 3<>${fifo}
    exec bash start.sh <&3
  '';

  stopScript = pkgs.writeShellScript "minecraft-prodigium-stop" ''
    set -u
    # "stop" flushes all dimensions to disk; a bare SIGTERM to start.sh would
    # only kill the wrapper and leave the JVM writing a half-saved world.
    if [ -p ${fifo} ]; then
      echo stop > ${fifo} || true
    fi
    for _ in $(seq 1 140); do
      pgrep -u ${user} -f 'server.jar' > /dev/null || exit 0
      sleep 2
    done
  '';

  mc = pkgs.writeShellScriptBin "mc" ''
    set -u
    SVC=minecraft-prodigium.service
    DIR=${serverDir}
    FIFO=${fifo}
    LOG="$DIR/logs/latest.log"

    case "''${1-}" in
      start)   systemctl start  "$SVC" && echo "starting - follow it with: mc logs" ;;
      stop)    echo "saving and stopping (can take ~30s)..." ; systemctl stop "$SVC" ;;
      restart) systemctl restart "$SVC" ;;
      status)  systemctl status "$SVC" --no-pager ;;
      logs)    journalctl -u "$SVC" -n 200 -f --no-pager ;;
      tail)    tail -n 200 -F "$LOG" ;;
      cmd)     shift
               [ -p "$FIFO" ] || { echo "server is not running" >&2 ; exit 1 ; }
               printf '%s\n' "$*" > "$FIFO" ;;
      console)
               [ -p "$FIFO" ] || { echo "server is not running" >&2 ; exit 1 ; }
               echo "--- console attached: type server commands, Ctrl-C to detach ---"
               tail -n 40 -F "$LOG" &
               TAILPID=$!
               trap 'kill $TAILPID 2>/dev/null' EXIT INT TERM
               while IFS= read -r line; do
                 printf '%s\n' "$line" > "$FIFO"
               done ;;
      ip)      echo "LAN/WAN IPv6 of this host:"
               ip -6 addr show scope global | grep -oE '2401:[0-9a-f:]+' | sort -u ;;
      *)       cat <<'USAGE'
mc start     - start the server
mc stop      - save the world and stop
mc restart   - stop, then start
mc status    - systemd status (uptime, memory, PID)
mc logs      - follow the live log (Ctrl-C to detach)
mc tail      - follow logs/latest.log instead of journald
mc console   - attach an interactive console (type commands directly)
mc cmd ...   - send one command, e.g. mc cmd "op Steve"
mc ip        - show this host's public IPv6 addresses
USAGE
               exit 1 ;;
    esac
  '';
in
{
  systemd.services.minecraft-prodigium = {
    description = "Prodigium Reforged 4.2 (Forge 1.20.1) Minecraft server";
    after    = [ "network-online.target" ];
    wants    = [ "network-online.target" ];
    wantedBy = [ ];                       # manual control, not on boot

    path = [
      java pkgs.bash pkgs.coreutils pkgs.procps
      pkgs.gnused pkgs.gawk pkgs.gnugrep pkgs.curl pkgs.unzip
    ];

    serviceConfig = {
      Type             = "simple";
      User             = user;
      Group            = "users";
      WorkingDirectory = serverDir;

      RuntimeDirectory     = "minecraft-prodigium";
      RuntimeDirectoryMode = "0750";

      ExecStart = startScript;
      ExecStop  = stopScript;

      # 305 mods flushing several dimensions needs far more than the 90s default.
      TimeoutStopSec = 300;
      TimeoutStartSec = 900;
      Restart        = "no";
      LimitNOFILE = 65536;
    };
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "minecraft-prodigium.service" &&
          subject.user == "${user}") {
        return polkit.Result.YES;
      }
    });
  '';

  environment.systemPackages = [ mc ];
}
