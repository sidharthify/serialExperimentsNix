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
        # pin GPU clocks while gaming instead of ramping per load
        amd_performance_level    = "high";
      };
      # keep CPUs out of C6/C8/C10 (220-680us wake-up) while a game runs
      custom = {
        start = "${pkgs.systemd}/bin/systemctl start cpu-lowlatency.service";
        end   = "${pkgs.systemd}/bin/systemctl stop cpu-lowlatency.service";
      };
    };
  };

  # Holds a PM QoS request of 2us on /dev/cpu_dma_latency. only POLL and C1E
  # (2us exit) stay allowed. The request lasts exactly as long as the fd is
  # open, so stopping the unit restores normal idle.
  systemd.services.cpu-lowlatency = {
    description = "Block deep CPU C-states while gaming";
    serviceConfig.ExecStart = pkgs.writeShellScript "cpu-lowlatency" ''
      exec 3>/dev/cpu_dma_latency
      printf '\x02\x00\x00\x00' >&3
      exec ${pkgs.coreutils}/bin/sleep infinity
    '';
  };

  # let wheel users (gamemode runs custom scripts as the user) toggle it
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "cpu-lowlatency.service" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # scx_full for A/B testing sched_ext schedulers, e.g. `sudo scx_lavd --performance`
  environment.systemPackages = [ pkgs.mangohud pkgs.scx.full ];

  # match bazzite's mesa/vulkan/proton environment
  environment.sessionVariables = {
    # single file shader cache, much faster than thousands of tiny files
    MESA_DISK_CACHE_SINGLE_FILE = "1";
    MESA_SHADER_CACHE_MAX_SIZE = "12G";
    # amd pipeline cache
    AMD_VK_USE_PIPELINE_CACHE = "1";
    vk_x11_override_min_image_count = "4";
    # allow wine to use full address space
    WINE_LARGE_ADDRESS_AWARE = "1";
    PROTON_USE_NTSYNC = "1";
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
