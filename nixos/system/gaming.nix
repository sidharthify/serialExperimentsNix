# nixos/system/gaming.nix

{ config, pkgs, lib, ... }:

{
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice          = 10;
        inhibit_screensaver = 1;
        softrealtime    = "auto";
        reaper_freq     = 5;
      };
      cpu = {
        park_cores = "no";
        governor   = "performance";
      };
      gpu = {
        apply_gpu_optimisations  = "accept-responsibility";
        gpu_device               = 1;
        amd_performance_level    = "auto";
      };
    };
  };

  environment.systemPackages = [ pkgs.mangohud ];

  # match bazzite's mesa/vulkan/proton environment
  environment.sessionVariables = {
    # single file shader cache, much faster than thousands of tiny files
    MESA_DISK_CACHE_SINGLE_FILE = "1";
    # raised from 5G: the cache is already ~500M and modern DX12 titles
    # (Cyberpunk, Forza, GTA V Enhanced) each contribute a lot of pipelines.
    # Evicting them means the shader-compile stutter comes back on relaunch.
    MESA_SHADER_CACHE_MAX_SIZE = "12G";
    # amd pipeline cache
    AMD_VK_USE_PIPELINE_CACHE = "1";
    # force 4 swapchain images for better frame pacing.
    # (Still relevant on a Wayland session: Proton games render through
    # XWayland, so they use the Vulkan X11 WSI, not the Wayland one.)
    vk_x11_override_min_image_count = "4";
    # allow wine to use full address space
    WINE_LARGE_ADDRESS_AWARE = "1";

    # ntsync is the in-kernel Win32 sync primitive - much cheaper than esync/
    # fsync for games with heavy thread contention. The module is loaded and
    # /dev/ntsync exists, so ask Proton for it explicitly rather than relying
    # on autodetection differing between GE / CachyOS builds.
    PROTON_USE_NTSYNC = "1";

    # RDNA4 runs FSR4 natively (FP8), and it is both faster and sharper than
    # the FSR2/3 or DLSS paths a game would otherwise take. This only does
    # anything in titles that expose DLSS *and* where DLSS is selected in the
    # game's own menu - it is a substitution, not a forced upscale, so native
    # rendering is unaffected. Remove this line to go back to stock behaviour.
    PROTON_FSR4_UPGRADE = "1";

    # silence vkd3d/dxvk debug spam
    DXVK_LOG_LEVEL = "none";
    VKD3D_DEBUG = "none";
    VKD3D_SHADER_DEBUG = "none";
  };

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*",      ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]",         ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]",         ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';

  fileSystems."/" = {
    options = [ "noatime" "commit=60" ];
  };
}
