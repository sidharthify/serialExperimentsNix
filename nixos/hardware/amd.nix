# nixos/hardware/amd.nix

{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.amdgpu.overdrive.enable = true;

  programs.corectrl.enable = true;

  services.lact.enable = true;
}
