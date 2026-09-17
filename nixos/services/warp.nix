{ config, pkgs, ... }:

# Cloudflare WARP as a plain WireGuard tunnel, but ONLY for Valve's IP ranges.
# Jio's hotspot blocks UDP to Valve's SDR relays ("Failed to reach any official
# servers"), so CS2 matchmaking goes through WARP while everything else stays direct.
#
# Profile generated with `wgcf register && wgcf generate`. The private key lives
# outside the store/repo at /var/lib/warp/private.key
# Manual control: sudo systemctl start|stop wg-quick-warp

{
  networking.wg-quick.interfaces.warp = {
    address = [ "172.16.0.2/32" ];
    mtu = 1280;
    privateKeyFile = "/var/lib/warp/private.key";

    peers = [{
      publicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
      endpoint = "162.159.193.10:2408"; # engage.cloudflareclient.com
      persistentKeepalive = 25;

      # Valve (AS32590) — Steam Datagram Relay POPs used by CS2
      allowedIPs = [
        "155.133.224.0/19"
        "162.254.192.0/21"
        "185.25.180.0/22"
        "146.66.152.0/21"
        "103.10.124.0/23"
        "103.28.54.0/23"
        "45.121.184.0/22"
        "205.196.6.0/24"
        "190.217.32.0/22"
        "192.69.96.0/22"
        "208.64.200.0/22"
        "208.78.164.0/22"
      ];
    }];
  };
}
