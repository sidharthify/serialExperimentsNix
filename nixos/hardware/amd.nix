# nixos/hardware/amd.nix

{ config, pkgs, lib, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.amdgpu.overdrive.enable = true;

  # match bazzite's ppfeaturemask (0xfff7bfff)
  # disables PCIe DPM (bit 14) and stutter mode (bit 19)
  # which cause clock instability on RDNA 4
  boot.kernelParams = lib.mkAfter [
    "amdgpu.ppfeaturemask=0xfff7bfff"
  ];

  boot.extraModprobeConfig = ''
    options amdgpu ppfeaturemask=0xfff7bfff
  '';

  # keep lact for fan control only, but disable its performance level management
  services.lact.enable = true;
}
