# nixos/services/sunshine.nix
# game streaming host for moonlight clients (xiaomi pad 8, lan only)

{ config, pkgs, lib, ... }:

let
  kscreen = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor";
  steam   = "/run/current-system/sw/bin/steam";

  # drop the G255F from 185Hz to 144Hz while streaming so host refresh,
  # encode rate and the pad's 144Hz panel are all 1:1 — no cadence judder
  streamMode  = "2560x1440@144";
  desktopMode = "2560x1440@185";

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
      # kwin = native plasma 6 wayland screencast (zkde_screencast_unstable_v1).
      # fall back to "kms" (needs capSysAdmin, already on) if kwingrab misbehaves.
      capture      = "kwin";
      encoder      = "vaapi";
      adapter_name = "/dev/dri/renderD128";

      # rdna4 vcn encodes h264 / hevc main+main10 / av1 profile0.
      # advertise hevc; leave av1 on auto so the client takes it if it wants.
      hevc_mode = 2;
      av1_mode  = 0;

      # --- input ------------------------------------------------------------
      gamepad = "ds5";  # dualsense passthrough -> playstation button prompts

      # --- state ------------------------------------------------------------
      # relative paths resolve next to the config file, which lives in
      # /nix/store and is read-only. pin them at a writable location.
      credentials_file = "${stateDir}/sunshine_state.json";
      file_state       = "${stateDir}/sunshine_state.json";
      log_path         = "${stateDir}/sunshine.log";

      # settings is a keyValue format (atoms only), so hand sunshine the
      # prep-cmd list as a pre-serialised json string.
      global_prep_cmd = builtins.toJSON [
        {
          do   = "${kscreen} output.DP-1.mode.${streamMode}";
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
