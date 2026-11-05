{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  imports = [
    ./nixcord.nix
    ./spicetify.nix
    ./vscodium.nix
    ./eldenring.nix
    ./beamng.nix
    ./yakuza0.nix
    ./firefox.nix
    ./kde.nix
    ./nvim.nix
    ./glyphtune.nix
  ];

}
