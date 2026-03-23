 { config, pkgs, ... }:  

{ 
  boot.kernelPackages = pkgs.linuxPackages_testing;
  boot.kernelParams = [ "nvidia-modeset.hdmi_deepcolor=0" "nvidia.NVreg_EnableGpuFirmware=0" "nvidia_drm.modeset=1"];
}
