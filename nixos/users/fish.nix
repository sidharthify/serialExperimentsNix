# fish.nix

{ config, pkgs, ... }:
let
  d = builtins.fromJSON ''"\\u002d"'';
in
{
  programs.fish = {
    enable = true;

    shellAliases = {
      ll = "ls ${d}l";
      fuckoff = "shutdown now";
      "mic${d}loopback" = "pw${d}loopback ${d}${d}capture${d}props=node.name=MicLoopback ${d}${d}playback${d}props=node.target=51";
    };

    interactiveShellInit = ''
      function syncnix
        bash /etc/nixos/scripts/sync${d}nixos.sh $argv
      end
    '';
  };
}
