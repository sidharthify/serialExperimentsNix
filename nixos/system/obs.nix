# obs.nix - obs-studio wrapped with plugins

{ pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      droidcam-obs
      obs-vaapi
      obs-pipewire-audio-capture
    ];
  };
}
