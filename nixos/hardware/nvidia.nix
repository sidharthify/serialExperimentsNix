# nixos/hardware/nvidia.nix

{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable          = true;
    powerManagement.enable      = false;
    powerManagement.finegrained = false;
    open                        = false;
    nvidiaSettings              = true;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version             = "610.43.02";
      sha256_64bit        = "sha256-MDSgVLtM33dS/43CclZMsQVROAS/9TU4lFkBsWyndGM=";
      sha256_aarch64      = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      openSha256          = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      settingsSha256      = "sha256-mXnf3jyvznfB3OfKd657rxv0rYHQb/dX/Riw/+N9EKU=";
      persistencedSha256  = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  };

  boot.extraModprobeConfig = ''
    # Force max performance P-state on all clocks
    options nvidia NVreg_RegistryDwords="PerfLevelSrc=0x2222"
    # Use Page Attribute Tables
    options nvidia NVreg_UsePageAttributeTable=1
    # Skip zeroing system memory allocations
    options nvidia NVreg_InitializeSystemMemoryAllocations=0
  '';
}
