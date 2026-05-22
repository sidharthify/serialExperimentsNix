# nixos/system/opengl.nix

{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
      nvidia-vaapi-driver
      libvdpau
      ocl-icd
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
      freetype
    ];
  };
}
