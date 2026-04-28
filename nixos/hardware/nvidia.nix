{ config, pkgs, ... }:  

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
     package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  boot.extraModprobeConfig = ''
    options nvidia NVreg_RegistryDwords="PerfLevelSrc=0x2222"
  '';
}
