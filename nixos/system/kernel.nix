# nixos/system/kernel.nix
# CachyOS kernel

{ config, pkgs, lib, ... }:

{
  boot.kernelPackages = pkgs.cachyosKernels."linuxPackages-cachyos-latest";

  boot.kernelParams = [
    "preempt=full"
    "split_lock_detect=off"
    "transparent_hugepage=madvise"
    "nowatchdog"
    "nmi_watchdog=0"
    "intel_pstate=active"
    "quiet" "loglevel=3"
  ];

  boot.kernelModules = [ "ntsync" ];

  powerManagement.cpuFreqGovernor = "performance";

  boot.kernel.sysctl = {
    "fs.file-max"                    = 524288;
    "fs.inotify.max_user_watches"    = 524288;
    "fs.inotify.max_user_instances"  = 512;
    "vm.swappiness"                  = 10;
    "vm.vfs_cache_pressure"          = 50;
    "vm.dirty_ratio"                 = 10;
    "vm.dirty_background_ratio"      = 5;
    "vm.dirty_writeback_centisecs"   = 1500;
    "kernel.sched_autogroup_enabled" = 1;
    "kernel.perf_event_paranoid"     = 1;
    "kernel.kptr_restrict"           = 0;
  };

  services.power-profiles-daemon.enable = false;
}
