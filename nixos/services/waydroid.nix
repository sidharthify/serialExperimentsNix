# nixos/services/waydroid.nix
# waydroid — android in a container on wayland

{ config, pkgs, ... }:

{
  virtualisation.waydroid.enable = true;

  # lxc is a hard dep
  virtualisation.lxc.enable = true;

  # ensure the binder modules are loaded at boot
  boot.kernelModules = [
    "binder_linux"
    "ashmem_linux"
  ];

  # waydroid CLI in system path
  environment.systemPackages = with pkgs; [
    waydroid
  ];
}
