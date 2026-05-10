{ pkgs, ... }:

{
  users.users.sidharthify = {
    isNormalUser = true;
    description = "sidharthify";
    shell = pkgs.fish;

    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "dialout"
      "docker"
      "audio"
      "input"
    ];

    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
