# nixos/services/minecraft-ddns.nix
# keeps mc.sidharthify.tech pointed at this machine's IPv6 address.
#
# airtel delegates the LAN /64 dynamically (~15 h lifetime), so the prefix
# changes whenever PPPoE reconnects even though our ::529 suffix is stable.
#
# The OpenWrt firewall rule matches on the suffix alone and needs no updating;
# DNS is the only piece that has to follow the prefix.
#

{ config, pkgs, lib, ... }:

let
  zone       = "sidharthify.tech";
  recordName = "mc.sidharthify.tech";
  iface      = "enp7s0";
  suffix     = "::529";          # must match the OpenWrt Allow-Minecraft-IPv6 rule
  port       = 25565;

  ddns = pkgs.writeShellScript "mc-ddns-update" ''
    set -u
    TOKEN_FILE=/var/lib/mc-ddns/cf-token
    STATE=/var/lib/mc-ddns/last-address
    API=https://api.cloudflare.com/client/v4

    if [ ! -s "$TOKEN_FILE" ]; then
      echo "no Cloudflare token at $TOKEN_FILE yet - nothing to do"
      exit 0
    fi
    TOKEN=$(cat "$TOKEN_FILE")

    ADDR=$(ip -6 -o addr show dev ${iface} scope global \
            | awk '{print $4}' | cut -d/ -f1 \
            | grep -E '^[23]' \
            | grep -E '${suffix}$' | head -n1)
    if [ -z "$ADDR" ]; then
      echo "no global IPv6 ending in ${suffix} on ${iface}" >&2
      exit 1
    fi

    if [ -f "$STATE" ] && [ "$(cat "$STATE")" = "$ADDR" ]; then
      exit 0
    fi
    echo "publishing ${recordName} -> $ADDR"

    api() {
      curl -sS --fail-with-body \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" "$@"
    }

    ZONE_ID=$(api "$API/zones?name=${zone}" | jq -r '.result[0].id // empty')
    if [ -z "$ZONE_ID" ]; then
      echo "token cannot see zone ${zone} - check its scope" >&2
      exit 1
    fi

    # ---- AAAA ----
    REC_ID=$(api "$API/zones/$ZONE_ID/dns_records?type=AAAA&name=${recordName}" \
               | jq -r '.result[0].id // empty')
    BODY=$(jq -nc --arg c "$ADDR" --arg n "${recordName}" \
             '{type:"AAAA", name:$n, content:$c, ttl:60, proxied:false}')

    if [ -n "$REC_ID" ]; then
      RESP=$(api -X PATCH "$API/zones/$ZONE_ID/dns_records/$REC_ID" --data "$BODY")
    else
      RESP=$(api -X POST  "$API/zones/$ZONE_ID/dns_records"         --data "$BODY")
    fi
    echo "$RESP" | jq -e '.success == true' > /dev/null || {
      echo "$RESP" | jq -r '.errors' >&2 ; exit 1 ; }

    # ---- SRV, so players can type the bare hostname with no :25565 ----
    SRV_NAME="_minecraft._tcp.${recordName}"
    SRV_ID=$(api "$API/zones/$ZONE_ID/dns_records?type=SRV&name=$SRV_NAME" \
               | jq -r '.result[0].id // empty')
    if [ -z "$SRV_ID" ]; then
      SRV_BODY=$(jq -nc --arg n "$SRV_NAME" --arg t "${recordName}" \
        '{type:"SRV", name:$n, ttl:60,
          data:{service:"_minecraft", proto:"_tcp", name:$t,
                priority:0, weight:0, port:${toString port}, target:$t}}')
      api -X POST "$API/zones/$ZONE_ID/dns_records" --data "$SRV_BODY" > /dev/null \
        && echo "created SRV $SRV_NAME"
    fi

    printf '%s' "$ADDR" > "$STATE"
  '';
in
{
  systemd.services.mc-ddns = {
    description = "Publish this host's IPv6 address as ${recordName}";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path  = [ pkgs.curl pkgs.jq pkgs.iproute2 pkgs.gnugrep pkgs.gawk pkgs.coreutils ];
    serviceConfig = {
      Type            = "oneshot";
      ExecStart       = ddns;
      StateDirectory  = "mc-ddns";
      StateDirectoryMode = "0700";
      # hardening: this only needs the network and one state dir
      ProtectSystem   = "strict";
      ProtectHome     = true;
      PrivateTmp      = true;
      NoNewPrivileges = true;
    };
  };

  systemd.timers.mc-ddns = {
    description = "Refresh ${recordName} every 5 minutes";
    wantedBy    = [ "timers.target" ];
    timerConfig = {
      OnBootSec      = "1min";
      OnUnitActiveSec = "5min";
      Persistent     = true;
    };
  };
}
