# nixos/system/kernel.nix
# CachyOS kernel

{ config, pkgs, lib, ... }:

{
  boot.kernelPackages = pkgs.cachyosKernels."linuxPackages-cachyos-latest";

  boot.kernelParams = [
    # full kernel preemption for minimum latency
    "preempt=voluntary"
    # avoid perf penalty from split-lock detection traps
    "split_lock_detect=off"
    # let DXVK/games opt into huge pages via madvise, not forced system-wide
    "transparent_hugepage=madvise"
    # disable watchdog timers
    "nowatchdog"
    "nmi_watchdog=0"
    # better single-core boost behavior
    "intel_pstate=active"
    # quiet boot
    "quiet" "loglevel=3"
  ];

  # specify performance because it defaults to powersave otherwise
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
