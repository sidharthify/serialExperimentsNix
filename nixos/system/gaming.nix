# nixos/system/gaming.nix

{ config, pkgs, lib, ... }:

{
  # gamemode!
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice          = 10;
        inhibit_screensaver = 1;
        softrealtime    = "off";
        reaper_freq     = 5;
      };
      cpu = {
        park_cores = "no";
        governor   = "performance";
      };
      gpu = {
        apply_gpu_optimisations  = "accept-responsibility";
        gpu_device               = 0;
        nv_powermizer_mode       = 1;
      };
    };
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
