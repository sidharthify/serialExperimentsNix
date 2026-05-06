{ config, pkgs, ... }:

{
  boot.kernelPackages = let
    linux_7_0_1 = pkgs.linux_latest.override {
      argsOverride = rec {
        version = "7.0.1";
        modDirVersion = version;
        src = pkgs.fetchurl {
          url = "mirror://kernel/linux/kernel/v7.x/linux-${version}.tar.xz";
          sha256 = "1gw7v1j0pp2w6fm5y1n0krhnfvgab2jkrvcvwl8hx614dnikbjdj"; 
        };
      };
    };
  in pkgs.linuxPackagesFor linux_7_0_1;

  boot.kernelParams = [ 
    "nvidia-modeset.hdmi_deepcolor=0" 
    "nvidia.NVreg_EnableGpuFirmware=0" 
    "nvidia_drm.modeset=1"
  ];

  boot.kernel.sysctl = {
    "fs.file-max" = 100000;
  };
}
