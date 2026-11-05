{ config, pkgs, ... }:

{
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/3E369C45369BFBD9";
    fsType = "ntfs3";
    options = [
      "nofail"
      "force"
      "uid=1000"
      "gid=100"
      "windows_names"
      "prealloc"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
    ];
  };

  services.udev.extraRules = ''
    ENV{ID_FS_UUID}=="45eae2ee-82d5-44b4-acdf-bfc7cddd77bf", ENV{UDISKS_NAME}="NVME (NixOS)"
    ENV{ID_FS_UUID}=="3E369C45369BFBD9", ENV{UDISKS_NAME}="SATA (Windows)"
  '';
}
