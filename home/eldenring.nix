# home/eldenring.nix
# i wanted a delclarative method of having the dualsense glyphs mod, and i
# wrote a custom script for that since running the .bat files would erase my
# save files on linux. i didnt wanna lose them so i just wrote this because 
# i'm lazy.

{ config, pkgs, lib, ... }:

let
  gdriveid = "1zX2_8IEmvRsWrtolch_JXqce7QtrAWGG";
  sha256   = "0klvw4rxr12fmankpacvy7qfffaind2hdi93k45b81ii13r71wcg";

  version  = "1.0";

  destDir  = "${config.home.homeDirectory}/Documents/eldenringimportant";
  launchCmd = "${destDir}/launchmod_eldenring.sh %command%";
  eldenRingAppId = "1245620";

  steamUserIds = [ "1201891252" "771323558" ];

  # Fetch the zip from Google Drive
  eldenringZip = pkgs.fetchurl {
    url  = "https://drive.usercontent.google.com/download?id=${gdriveid}&export=download&confirm=t";
    inherit sha256;
    name = "eldenringimportant-${version}.zip";
  };

  # Extract zip into the Nix store
  eldenringStore = pkgs.runCommand "eldenringimportant-${version}" {
    nativeBuildInputs = [ pkgs.unzip ];
  } ''
    mkdir -p $out
    unzip ${eldenringZip} -d $out

    # Zip contains a single top-level folder "eldenringimportant/" — flatten it
    entries=$(ls -1 $out | wc -l)
    topdir=$(ls -1 $out | head -1)
    if [ "$entries" = "1" ] && [ -d "$out/$topdir" ]; then
      shopt -s dotglob
      mv "$out/$topdir"/* "$out/"
      rmdir "$out/$topdir" 2>/dev/null || true
    fi
  '';

in
{
  # Copy ModEngine2 folder to ~/Documents/eldenringimportant/
  # Uses rsync
  home.activation.installEldenRingModEngine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    VERSION_MARKER="${destDir}/.nix-me2-version"

    if [ ! -f "$VERSION_MARKER" ] || \
       [ "$(cat "$VERSION_MARKER" 2>/dev/null)" != "${version}" ]; then

      $DRY_RUN_CMD mkdir -p \
        "${destDir}/mod" \
        "${destDir}/modengine2/logs"

      $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync \
        --archive \
        --ignore-existing \
        --exclude="modengine2/logs/" \
        "${eldenringStore}/" \
        "${destDir}/"

      $DRY_RUN_CMD chmod +x "${destDir}/launchmod_eldenring.sh"
      echo "${version}" > "$VERSION_MARKER"
      echo "ModEngine2: installed/updated to version ${version}"
    else
      echo "ModEngine2: already at version ${version}, skipping"
    fi
  '';

  # Set Steam launch option for Elden Ring
  # Patches localconfig.vdf for all Steam accounts on this machine.
  home.activation.steamEldenRingLaunchOption = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    STEAM_USERDATA="$HOME/.local/share/Steam/userdata"

    patch_vdf() {
      local vdf="$1"
      [ -f "$vdf" ] || return 0

      $DRY_RUN_CMD ${pkgs.python3}/bin/python3 - \
          "$vdf" "${eldenRingAppId}" "${launchCmd}" << 'PYEOF'
import sys, re

vdf_path  = sys.argv[1]
app_id    = sys.argv[2]
launch    = sys.argv[3]

with open(vdf_path, 'r', encoding='utf-8') as f:
    text = f.read()

pat = r'("' + re.escape(app_id) + r'"\s*\{)(.*?)(\n(\s*)\})'
m   = re.search(pat, text, re.DOTALL)

if not m:
    print(f"[steam-launch] AppID {app_id} not in {vdf_path}, skipping")
    sys.exit(0)

inner = m.group(2)

if '"LaunchOptions"' in inner:
    # Update existing entry
    inner = re.sub(
        r'"LaunchOptions"\s*"[^"]*"',
        f'"LaunchOptions"\t\t"{launch}"',
        inner
    )
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
