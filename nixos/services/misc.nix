# nixos/services/misc.nix
# small enable-only service declarations.

{ config, pkgs, ... }:

{
  # openrgb
  services.hardware.openrgb.enable = true;

  # tmate
  services.tmate-ssh-server.enable = true;

  # waydroid
  virtualisation.waydroid.enable = true;

  # zerotier
  services.zerotierone = {
    enable       = true;
    joinNetworks = [ "af415e486fbdfe2b" ];
  };

  # orca
  systemd.user.services.orca = {
    enable     = false;
    unitConfig.ConditionPathExists = "/dev/null";
  };
  services.orca.enable    = false;
  services.speechd.enable = false;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
