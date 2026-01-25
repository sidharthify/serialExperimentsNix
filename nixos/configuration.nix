# this is the root of all imports!!!

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware/hardware-configuration.nix
    ./hardware/bluetooth.nix
    ./hardware/intel.nix
    ./hardware/nvidia.nix
    ./hardware/sata.nix 

    ./system/bootloader.nix
    ./system/desktop.nix
    ./system/fonts.nix
    ./system/kernel.nix
    ./system/networking.nix
    ./system/openssh.nix
    ./system/opengl.nix
    ./system/xdg-portal.nix
    ./system/locale.nix
    ./system/time.nix
    ./system/xkb.nix
    ./system/printing.nix
    ./system/nix-settings.nix
    ./system/auto-upgrade.nix

    ./services/docker-containers.nix
    ./services/orca.nix
    ./services/pipewire.nix
    ./services/steam.nix
    ./services/zerotier-config.nix
    ./services/flatpak.nix
    ./services/tmate.nix
    ./services/openrgb.nix
    ./services/waydroid.nix

    ./users/zsh.nix
    ./users/sidharthify.nix
  ];

  environment.systemPackages = import ../packages/packages.nix pkgs;

  system.stateVersion = "25.11";

}
