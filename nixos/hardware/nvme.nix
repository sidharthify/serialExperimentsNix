# nvme.nix
# this is a definition for my nvme that i plug in with an enclosure. this for now handles my docker containers.

{ config, pkgs, ... }:

{
  fileSystems."/mnt/sdb" = {
    device = "/dev/disk/by-uuid/d32f9701-aebe-486b-8b82-33a672cfe58c";
    fsType = "ext4"; 
    options = [ "nofail" ]; 
  };
}
