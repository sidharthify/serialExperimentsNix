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

  # cachyos kernel injects ppfeaturemask=0xfffd7fff at default priority
  # mkAfter ensures this comes last on the cmdline, and the kernel uses the last value
  boot.kernelParams = lib.mkAfter [
    "amdgpu.ppfeaturemask=0xffffffff"
  ];

  boot.extraModprobeConfig = ''
    options amdgpu ppfeaturemask=0xffffffff
  '';

  services.lact.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="drm", KERNEL=="card[0-9]*", DRIVERS=="amdgpu", RUN+="${pkgs.bash}/bin/bash -c 'echo 1 > /sys/class/drm/%k/device/pp_power_profile_mode'"
  '';
}
