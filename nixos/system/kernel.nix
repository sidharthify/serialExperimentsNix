 { config, pkgs, ... }:  

{ 
  boot.kernelPackages = pkgs.linuxPackages_6_19;
  boot.kernelParams = [ "nvidia-modeset.hdmi_deepcolor=0" "nvidia.NVreg_EnableGpuFirmware=0" "nvidia_drm.modeset=1"];
}
