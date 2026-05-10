{ config, pkgs, lib, ... }:

{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  catppuccin.cursors.enable = false;

  home-manager.users.sidharthify = {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "mauve";
      cursors.enable = false;
      gtk.enable = true;
      gtk.icon.enable = true;
    };

    gtk = {
      enable = true;
    };
  };
}
