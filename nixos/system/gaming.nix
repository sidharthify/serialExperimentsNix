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

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*",      ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]",         ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]",         ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';

  fileSystems."/" = {
    options = [ "noatime" "commit=60" ];
  };
}
