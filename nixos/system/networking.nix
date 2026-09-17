{ config, pkgs, ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # NM handles DHCP, don't use per-interface useDHCP
  networking.useDHCP = false;

  # MTU: back on Airtel fibre, so wifi returns to 1500.
  # (1372 was the Jio-5G-hotspot era value — re-set it only if that comes back.)
  # The PPPoE path MTU to the internet is 1480; the router clamps TCP MSS
  # (firewall mtu_fix=1) and tcp_mtu_probing in net-tune.nix covers the rest,
  # so the LAN link itself stays at a full 1500.
  networking.networkmanager.connectionConfig = {
    "ethernet.mtu" = 1500;
    "wifi.mtu" = 1500;
  };

  # Disable NM-wait-online
  systemd.services.NetworkManager-wait-online.enable = false;

  # Disable WiFi power save
  networking.networkmanager.wifi.powersave = false;

  networking.firewall.enable = false; # for now
 # networking.firewall.allowedTCPPorts = [ 25565 24800 5520 59100 59200 3478 443 32330 ];
 # networking.firewall.allowedUDPPorts = [ 5520 7777 7778 27015];
  networking.enableIPv6 = true;
  #networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Measured 2026-09-18: router dnsmasq cache = 0-1 ms, Cloudflare = 12 ms,
  # Google = 27 ms, Quad9 = 83 ms. The router forwards misses to Airtel's
  # resolvers (7 ms) and Cloudflare in parallel, so misses are fast too.
  # Cloudflare stays listed as a fallback for when the router is unreachable.
  networking.nameservers = [ "192.168.2.1" "1.1.1.1" "1.0.0.1" ];

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv6.bindv6only" = 1;
    "net.ipv6.conf.all.mldv2_unsolicited_report_interval" = 1;
    "net.ipv6.conf.default.mldv2_unsolicited_report_interval" = 1;
  };

  # Load required modules for BBR
  boot.kernelModules = [ "tcp_bbr" ];
}
