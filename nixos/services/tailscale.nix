{ config, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    # "server" enables IP forwarding (ipv4 + ipv6) so this machine can act
    # as a subnet router. After nixos-rebuild switch, run once:
    #   sudo tailscale up --advertise-routes=<YOUR_LAN_CIDR>
    #   e.g.  sudo tailscale up --advertise-routes=192.168.1.0/24
    # Then approve the routes in https://login.tailscale.com/admin/machines
    useRoutingFeatures = "server";
  };

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;
}
