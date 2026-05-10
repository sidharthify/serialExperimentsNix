{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  imports = [
    ./nixcord.nix
    ./spicetify.nix
    ./vscodium.nix
    ./eldenring.nix
    ./zen.nix
    ./kde.nix
  ];

  };
}
