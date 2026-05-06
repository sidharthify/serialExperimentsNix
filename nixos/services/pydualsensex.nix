# Mod: https://www.beamng.com/resources/dsx-dualsense-adaptive-triggers.28759/
# Bridge: https://github.com/scj643/pydualsensex
#
# Usage for anybody doing this niche thing:
#   1. Install the BeamNG mod above
#   2. Connect DualSense
#   3. Enable this module and rebuild
#   4. Run `pydualsensex` in a terminal before launching BeamNG
#      OR enable the systemd user service (see below)

{ config, pkgs, lib, ... }:

let
  cfg = config.services.pydualsensex;
  pkg = pkgs.callPackage ../../packages/pydualsensex.nix { };
in {
  options.services.pydualsensex = {
    enable = lib.mkEnableOption "pydualsensex BeamNG DualSense adaptive trigger bridge";
  };

  config = lib.mkIf cfg.enable {
    # udev rule: grant hidraw access to DualSense without root
    # Sony idVendor=054c, DualSense idProduct=0ce6
    services.udev.extraRules = ''
      # DualSense USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", GROUP="input", TAG+="uaccess"
      # DualSense Bluetooth
      KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", GROUP="input", TAG+="uaccess"
      # DualSense Edge USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", GROUP="input", TAG+="uaccess"
      # DualSense Edge Bluetooth
      KERNEL=="hidraw*", KERNELS=="*054C:0DF2*", MODE="0660", GROUP="input", TAG+="uaccess"
    '';

    # add pydualsensex to PATH
    environment.systemPackages = [ pkg ];

    # optional background systemd user service.
    # to auto-start it: `systemctl --user enable --now pydualsensex`
    systemd.user.services.pydualsensex = {
      description = "pydualsensex — DualSense adaptive trigger bridge for BeamNG";
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkg}/bin/pydualsensex";
        Restart = "on-failure";
        RestartSec = "3s";
      };
    };
  };
}
