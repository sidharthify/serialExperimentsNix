# nixos/system/opengl.nix

{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;

    # RADV patched to not expose VK_KHR_shader_abort. CS2 (since the September 2026
    # update) enables shaderAbort, which makes RADV disable its pipeline cache
    # entirely and every pipeline recompiles mid-match. Same behaviour as Mesa
    # 26.1.x. Drop once Valve or Mesa fixes it:
    # https://github.com/ValveSoftware/csgo-osx-linux/issues/4624
    package = pkgs.mesa.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./radv-no-shader-abort.patch ];
    });

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
