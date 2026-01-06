# intel.nix

{ config, pkgs, ... }:

{
  boot.kernelModules = [ "snd_hda_intel" ];

  boot.extraModprobeConfig = ''
    # disable power saving to prevent state confusion with the windows driver
    options snd_hda_intel power_save=0 power_save_controller=N
  '';
}
