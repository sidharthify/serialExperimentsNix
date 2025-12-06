{ config, pkgs, ... }:  

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.interfaces.wlp3s0.useDHCP = false;
  networking.interfaces."wlp3s0".ipv4.addresses = [{
  address = "192.168.1.184";
  prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.1.1";
  networking.resolvconf.enable = false;
  networking.nameservers = [ "192.168.1.1" ];
  networking.interfaces."wlp3s0".mtu = 1500;
  networking.firewall.allowedTCPPorts = [ 25565 24800 59100 59200];
  networking.enableIPv6 = false;

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.mldv2_unsolicited_report_interval" = 0;
    "net.ipv6.conf.default.mldv2_unsolicited_report_interval" = 0;
    };
}

