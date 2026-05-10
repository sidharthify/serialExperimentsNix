# this is the root of all imports!!!

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware/hardware-configuration.nix
    ./hardware/bluetooth.nix
    ./hardware/intel.nix
    ./hardware/nvidia.nix
    ./hardware/sata.nix

    ./system/base.nix
    ./system/desktop.nix
    ./system/fonts.nix
    ./system/kernel.nix
    ./system/networking.nix
    ./system/opengl.nix
    ./system/nix-settings.nix
    ./system/android-dev.nix

    ./services/docker-containers.nix
    ./services/misc.nix
    ./services/pipewire.nix
    ./services/steam.nix
    ./services/flatpak.nix
    ./services/tailscale.nix

    ./users/fish.nix
    ./users/sidharthify.nix
    ./users/arkserver.nix
  ];

  environment.systemPackages = import ../packages/packages.nix pkgs;
  system.stateVersion = "25.11";
}
