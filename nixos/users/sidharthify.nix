{ pkgs, ... }:

{
  users.users.sidharthify = {
    isNormalUser = true;
    description = "sidharthify";
    shell = pkgs.fish;

    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirt"
      "dialout"
      "docker"
      "audio"
    ];

    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
