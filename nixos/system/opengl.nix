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
      libva
      libva-utils
      libvdpau
      libvdpau-va-gl
      ocl-icd
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
      freetype
    ];
  };
}
