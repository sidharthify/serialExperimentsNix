{ config, pkgs, ... }:

{
  fileSystems."/mnt/sda" = {
    device = "/dev/disk/by-uuid/1c54bc70-824b-4f74-a0a8-d9a45dea2ae7";
    fsType = "ext4"; 
    options = [ "nofail" ]; 
  };
}
