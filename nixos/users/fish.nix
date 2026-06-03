# fish.nix

{ config, pkgs, ... }:
let
  d = builtins.fromJSON ''"\u002d"'';
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
      function setfanspeed
        if test (count $argv) ${d}eq 0
          echo "usage: setfanspeed <0 to 100>"
          return 1
        end

        if not string match ${d}qr '^[0-9]+$' $argv[1]; or test $argv[1] ${d}lt 0; or test $argv[1] ${d}gt 100
          echo "fan speed must be an integer between 0 and 100"
          return 1
        end

        echo "setting gpu fan speed to $argv[1]%"
        sudo DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY nvidia${d}settings ${d}a GPUFanControlState=1 ${d}a GPUTargetFanSpeed=$argv[1]

        if test $argv[1] = 100
          echo "setting cpu fan to max"
          for path in /sys/class/hwmon/hwmon*/name
            if grep "hp" "$path" > /dev/null 2>/dev/null
              set hwmongroup (dirname "$path")
              echo 0 | sudo tee $hwmongroup/pwm1_enable > /dev/null 2>/dev/null
            end
          end

          for profile in /sys/devices/platform/hp?wmi/thermal_profile /sys/devices/platform/hp?omen/thermal_profile
            echo 1 | sudo tee $profile > /dev/null 2>/dev/null
          end

          for acpiprof in /sys/firmware/acpi/platform_profile /sys/devices/platform/hp?wmi/platform_profile
            echo "performance" | sudo tee $acpiprof > /dev/null 2>/dev/null
          end
        end
      end

      function syncnix
        bash /etc/nixos/scripts/sync${d}nixos.sh $argv
      end
    '';
  };
}
