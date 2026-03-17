{ config, pkgs, spicetify-nix, ... }:

let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in

{
  imports = [
    spicetify-nix.homeManagerModules.spicetify
  ];
  
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
    enabledCustomApps = with spicePkgs.apps; [
      lyricsPlus
      reddit
      marketplace
    ];
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
      betterGenres
      simpleBeautifulLyrics
    ];
    experimentalFeatures = true;
    alwaysEnableDevTools = true;
  };
}