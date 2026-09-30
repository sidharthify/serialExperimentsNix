# nixos/services/sunshine.nix
# game streaming host for moonlight clients (xiaomi pad 8, lg tv, lan only)

{ config, pkgs, lib, ... }:

let
  kscreen = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor";
  steam   = "/run/current-system/sw/bin/steam";

  # while streaming, switch the monitor to whatever the client asked for so
  # host refresh and encode rate match its panel (pad: 1440p144, tv: 60).
  # resolutions the monitor can't do (4k) stay at native 1440p.
  desktopMode = "2560x1440@185";

  streamMode = pkgs.writeShellScript "sunshine-stream-mode" ''
    w=''${SUNSHINE_CLIENT_WIDTH:-2560}
    h=''${SUNSHINE_CLIENT_HEIGHT:-1440}
    fps=''${SUNSHINE_CLIENT_FPS:-144}

    # mode names repeat (60 and 59.94 both print as @60), so pick by id:
    # exact size if the monitor has it, else native. then the closest
    # refresh >= fps, else the fastest one there is.
    id=$(${kscreen} -j | ${pkgs.jq}/bin/jq -r --argjson w "$w" --argjson h "$h" --argjson fps "$fps" '
      (.outputs[] | select(.name == "DP-1") | .modes) as $m
      | ([$m[] | select(.size.width == $w and .size.height == $h)]
         | if length > 0 then . else [$m[] | select(.size.width == 2560 and .size.height == 1440)] end) as $c
      | ([$c[] | select(.refreshRate >= $fps - 0.5)] | sort_by(.refreshRate - $fps | fabs) | first)
        // ($c | max_by(.refreshRate))
      | .id')

    echo "sunshine: client ''${w}x''${h}@''${fps} -> DP-1 mode $id"
    exec ${kscreen} output.DP-1.mode."$id"
  '';

  stateDir = "/home/sidharthify/.config/sunshine";
in
{
  services.sunshine = {
    enable       = true;
    autoStart    = true;
    openFirewall = true;  # no-op while networking.firewall.enable = false
    capSysAdmin  = true;  # keeps kms capture available as a fallback backend

    settings = {
      sunshine_name = "nixos";

      # --- capture / encode -------------------------------------------------
      capture      = "kwin";
      encoder      = "vaapi";
      adapter_name = "/dev/dri/renderD128";

      # rdna4 vcn encodes h264 / hevc main+main10 / av1 profile0.
      hevc_mode = 2;
      av1_mode  = 0;

      # --- input ------------------------------------------------------------
      gamepad = "auto";  # ds5 for the real dualsense, x360 for on-screen controls

      # --- state ------------------------------------------------------------
      # /nix/store and is read-only. pin them at a writable location.
      credentials_file = "${stateDir}/sunshine_state.json";
      file_state       = "${stateDir}/sunshine_state.json";
      log_path         = "${stateDir}/sunshine.log";

      # settings is a keyValue format (atoms only), so hand sunshine the
      # prep-cmd list as a pre-serialised json string.
      global_prep_cmd = builtins.toJSON [
        {
          do   = "${streamMode}";
          undo = "${kscreen} output.DP-1.mode.${desktopMode}";
        }
      ];
    };

    applications.apps = [
      {
        name     = "Like a Dragon: Infinite Wealth";
        detached = [ "${steam} steam://rungameid/2072450" ];
      }
      {
        name     = "Steam Big Picture";
        detached = [ "${steam} steam://open/bigpicture" ];
        prep-cmd = [
          {
            do   = "";
            undo = "${steam} steam://close/bigpicture";
          }
        ];
      }
    ];
  };

  # sunshine's virtual mouse/keyboard/gamepad go through /dev/uinput,
  # which hardware.uinput.enable hands to the uinput group.
  users.users.sidharthify.extraGroups = [ "uinput" ];
}
