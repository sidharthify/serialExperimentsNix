{ config, pkgs, ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # NM handles DHCP, don't use per-interface useDHCP
  networking.useDHCP = false;

  # MTU 1372 for Jio 5G — set via NM connection override
  networking.networkmanager.connectionConfig = {
    "ethernet.mtu" = 1372;
    "wifi.mtu" = 1372;
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
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv6.bindv6only" = 1;
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv6.conf.all.mldv2_unsolicited_report_interval" = 1;
    "net.ipv6.conf.default.mldv2_unsolicited_report_interval" = 1;
  };

  # Load required modules for BBR
  boot.kernelModules = [ "tcp_bbr" ];
}
