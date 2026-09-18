# nixos/services/playit.nix
# playit.gg tunnel agent, fronting the Minecraft server
#
# fuckass Airtel drops ALL unsolicited inbound IPv6 on this line
# IPv4 is CGNAT
#
# The direct IPv6 path (mc.sidharthify.tech) is left intact and still works on
# the LAN this is purely an additional way in for anyone on another network.
#
# the secret is NOT in the Nix store (world-readable). Provision it once with (in bash):
#   playit-cli claim generate / url / exchange
#   sudo install -d -m 0700 /var/lib/playit
#   sudo install -m 0600 /dev/stdin /var/lib/playit/secret <<< '<64-char key>'

{ config, pkgs, lib, ... }:

let
  playit = pkgs.stdenv.mkDerivation rec {
    pname = "playit-agent";
    version = "1.0.10";

    src = pkgs.fetchurl {
      url = "https://github.com/playit-cloud/playit-agent/releases/download/v${version}/playit-linux-amd64";
      hash = "sha256-LffZ8QInqzErGtNBhT206KgkPfXPzbrlhxOkJxcRwzk=";
    };

    dontUnpack = true;
    dontBuild  = true;
    dontStrip  = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/playit
      runHook postInstall
    '';

    meta = with lib; {
      description = "playit.gg tunnel agent";
      homepage    = "https://playit.gg";
      platforms   = [ "x86_64-linux" ];
    };
  };
in
{
  systemd.services.playit = {
    description = "playit.gg tunnel agent (fronts minecraft-prodigium)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    partOf   = [ "minecraft-prodigium.service" ];
    wantedBy = [ "minecraft-prodigium.service" ];

    serviceConfig = {
      Type       = "simple";
      ExecStart  = "${playit}/bin/playit --secret-path /var/lib/playit/secret";
      Restart    = "always";
      RestartSec = 10;

      StateDirectory     = "playit";
      StateDirectoryMode = "0700";
      RuntimeDirectory   = "playit";

      # Only needs outbound network and its own secret.
      ProtectSystem   = "strict";
      ProtectHome     = true;
      PrivateTmp      = true;
      NoNewPrivileges = true;
    };
  };

  environment.systemPackages = [ playit ];
}
