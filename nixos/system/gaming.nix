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
    MESA_SHADER_CACHE_MAX_SIZE = "5G";
    # amd pipeline cache
    AMD_VK_USE_PIPELINE_CACHE = "1";
    # force 4 swapchain images for better frame pacing
    vk_x11_override_min_image_count = "4";
    # allow wine to use full address space
    WINE_LARGE_ADDRESS_AWARE = "1";
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
