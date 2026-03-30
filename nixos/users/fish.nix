# fish.nix

{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      ll = "ls -l";
      fuckoff = "shutdown now";
      mic-loopback = "pw-loopback --capture-props=node.name=MicLoopback --playback-props=node.target=51";
    };

    interactiveShellInit = ''
      # setfanspeed
      function setfanspeed
        if test (count $argv) -eq 0
          echo "usage: setfanspeed <0-100>"
          return 1
        end

        if not string match -qr '^[0-9]+$' $argv[1]; or test $argv[1] -lt 0; or test $argv[1] -gt 100
          echo "fan speed must be an integer between 0 and 100"
          return 1
        end

        echo "setting GPU fan speed to $argv[1]%"
        sudo DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY nvidia-settings -a GPUFanControlState=1 -a GPUTargetFanSpeed=$argv[1]
      end

      # syncnix
      function syncnix
        bash /etc/nixos/scripts/sync-nixos.sh $argv
      end
    '';
  };
}
