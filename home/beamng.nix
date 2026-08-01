# home/beamng.nix
# native Linux BeamNG.drive nixos launcher

# beamNG, for me, runs miles better with the linux binary ever since 0.39 dropped, so
# i almost always use it, but nixOS has caveats, so i made a script to open it, but
# then decided to turn it into a proper module so i dont have to deal with it again.
# you're free to steal this module. and if you use a dualsense controller, you finally
# get playstation glyphs and full dualsense haptics!

# as for the technicals:
# beamNG's native build ships an ELF (BinLinux/BeamNG.drive.x64) whose CEF/GTK
# UI links libs that steam-run's stock FHS doesn't carry, so you'd have to run it inside a
# steam-run whose FHS you top up with those libs. the steam launch args for the
# app is patched to point here, so hitting Play launches native (Proton is still
# force-set under Compatibility but i just discard the %command% Steam passes).

{ config, pkgs, lib, ... }:

let
  beamngAppId  = "284160"; # official app id
  steamUserIds = [ "1201891252" "771323558" ]; # well, yknow

  # steam-run whose FHS also carries the libs BeamNG's CEF and GTK UI needs.
  # `steam-run.override` can't take extraPkgs (leaks the fn into the derivation),
  # so override `steam` and take `.run`. `atk` is merged into `at-spi2-core`.
  steamRunWithLibs = (pkgs.steam.override {
    extraPkgs = pkgs: with pkgs; [ at-spi2-core libxcomposite nss nspr ];
  }).run;

  beamng-native = pkgs.writeShellApplication {
    name = "beamng-native";
    runtimeInputs = [ steamRunWithLibs ];
    text = ''
      # steam's SteamAPI_Init() needs these even though we bypass Steam's normal launch
      export SteamAppId=${beamngAppId}
      export SteamGameId=${beamngAppId}
      # read DualSense straight from hidraw. requires steam input to be disabled.
      export SDL_JOYSTICK_HIDAPI=1

      bin="$HOME/.local/share/Steam/steamapps/common/BeamNG.drive/BinLinux"
      cd "$bin" || {
        echo "beamng-native: cannot cd to $bin — is BeamNG installed via Steam?" >&2
        exit 1
      }

      # steam passes the whole Proton %command% as args.
      # discard it and run native
      exec steam-run ./BeamNG.drive.x64
    '';
  };

  launchCmd = "${beamng-native}/bin/beamng-native %command%";
in
{
  home.packages = [ beamng-native ];

  # point the steam launch options at the native launcher, for every local Steam
  # account. same mechanism as home/eldenring.nix.
  home.activation.steamBeamngLaunchOption =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      STEAM_USERDATA="$HOME/.local/share/Steam/userdata"

      patch_vdf() {
        local vdf="$1"
        [ -f "$vdf" ] || return 0

        $DRY_RUN_CMD ${pkgs.python3}/bin/python3 - \
            "$vdf" "${beamngAppId}" "${launchCmd}" << 'PYEOF'
import sys, re

vdf_path, app_id, launch = sys.argv[1], sys.argv[2], sys.argv[3]

with open(vdf_path, 'r', encoding='utf-8') as f:
    text = f.read()

pat = r'("' + re.escape(app_id) + r'"\s*\{)(.*?)(\n(\s*)\})'
m   = re.search(pat, text, re.DOTALL)
if not m:
    print(f"[steam-launch] AppID {app_id} not in {vdf_path}, skipping")
    sys.exit(0)

inner = m.group(2)
if '"LaunchOptions"' in inner:
    inner = re.sub(r'"LaunchOptions"\s*"[^"]*"',
                   f'"LaunchOptions"\t\t"{launch}"', inner)
else:
    inner = inner.rstrip('\n') + f'\n\t\t\t\t\t\t"LaunchOptions"\t\t"{launch}"\n'

new_text = text[:m.start(2)] + inner + text[m.end(2):]
with open(vdf_path, 'w', encoding='utf-8') as f:
    f.write(new_text)
print(f"[steam-launch] Set LaunchOptions for AppID {app_id} in {vdf_path}")
PYEOF
      }

      for uid in ${lib.concatStringsSep " " steamUserIds}; do
        patch_vdf "$STEAM_USERDATA/$uid/config/localconfig.vdf"
      done
    '';
}
