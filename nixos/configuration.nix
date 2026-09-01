# this is the root of all imports!!!

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware/hardware-configuration.nix
    ./hardware/bluetooth.nix
    ./hardware/intel.nix
    ./hardware/amd.nix
    ./hardware/sata.nix

    ./system/base.nix
    ./system/desktop.nix
    ./system/fonts.nix
    ./system/kernel.nix
    ./system/networking.nix
    ./system/opengl.nix
    ./system/nix-settings.nix
    ./system/android-dev.nix
    ./system/gaming.nix
    ./system/overlays.nix
    ./system/flake-packages.nix
    ./system/catppuccin.nix
    ./system/wine.nix
    ./system/aula-f75.nix
    ./system/obs.nix

    ./services/misc.nix
    ./services/pipewire.nix
    ./services/steam.nix
    ./services/flatpak.nix
    ./services/tailscale.nix
    ./services/waydroid.nix
    ./services/sunshine.nix
    ./services/libvirt.nix

    ./users/fish.nix
    ./users/sidharthify.nix
    ./users/arkserver.nix
  ];

  environment.systemPackages = import ../packages/packages.nix pkgs;
  system.stateVersion = "25.11";
}
