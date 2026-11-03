# home/yakuza0.nix
# don't ask.

{ config, pkgs, lib, ... }:

let
  gameDir    = "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/Yakuza 0/media";
  archiveDir = "${config.home.homeDirectory}/Documents/yakuza0-mods";

  vanillaExeSha = "b3c6c144b7de085591436b9d604cbd92950baf6bc10bdbb4f22a504767f9496c";
  patchedExeSha = "f1c0856ce701ddf918ad4f813a9ac147651119725e6fb68d3f9922dc1810f374";

  nexusArchive = name: sha256: pkgs.requireFile {
    inherit name sha256;
    message = ''
      ${name} is a Nexus download, so nix can't fetch it by itself.
      Put it in ${archiveDir} and run

        nix-store --add-fixed sha256 ${archiveDir}/${name}
    '';
  };

  srmmVersion = "5.0.5";

  srmmWindows = pkgs.fetchurl {
    url    = "https://github.com/SRMM-Studio/ShinRyuModManager/releases/download/v${srmmVersion}/ShinRyuModManager-Windows-${srmmVersion}.zip";
    sha256 = "0hf77wzrsxpfs0r4qs40gm6inx1j7ax85vphw7wiw5rv6rm8fb02";
  };

  srmmLinux = pkgs.fetchurl {
    url    = "https://github.com/SRMM-Studio/ShinRyuModManager/releases/download/v${srmmVersion}/ShinRyuModManager-Linux-${srmmVersion}.zip";
    sha256 = "1vzczl64zqcnvw7a6mccjq1n576rlfmv7lr2hphkpazayvf8spdn";
  };

  srmm = pkgs.runCommand "shin-ryu-mod-manager-${srmmVersion}" {
    nativeBuildInputs = [ pkgs.unzip ];
  } ''
    mkdir -p $out/windows $out/linux
    unzip -q ${srmmWindows} -d $out/windows
    unzip -q ${srmmLinux} -d $out/linux
    chmod +x $out/linux/ShinRyuModManager
  '';

  hdCharacterTextures = pkgs.runCommand "yakuza0-hd-character-textures" {
    src = pkgs.fetchurl {
      url    = "https://gamebanana.com/dl/445965";
      name   = "hd_character_textures_a5509.zip";
      sha256 = "1znlk5zhkc2d4ac729ilwij5nl151x047g8fx785s2rrlgqmfph4";
    };
    nativeBuildInputs = [ pkgs.unzip ];
  } ''
    unzip -q $src -d work
    mv work/data $out
    cat > $out/mod-meta.yaml << 'EOF'
    Name: HD Character Textures
    Author: noko12312
    Version: 5082018
    Description: "Gameplay character models use the 4x cutscene textures."
    EOF
  '';

  lodmod = pkgs.runCommand "yakuza0-lodmod-b7-p4" {
    src = pkgs.fetchurl {
      url    = "https://gamebanana.com/dl/1463238";
      name   = "lodmod_yakuza0_b7-p4.zip";
      sha256 = "0rb900ffd7q03g6zvqnpjf62rbm7adkd7bca382dzrhldk9mj8c1";
    };
    nativeBuildInputs = [ pkgs.unzip ];
  } ''
    unzip -q $src -d work
    mv work/patches $out
  '';

  localMods = pkgs.runCommand "yakuza0-local-mods" { } ''
    mkdir $out
    tar -xf ${nexusArchive "yakuza0-local-mods-1.tar" "1f9lnlh5a2vqnab4pc181j2nk14s8g99lqvrr58l7mq0bvg2p6cm"} -C $out
  '';

  unpackNexus = { name, archive, sha256, folder }:
    pkgs.runCommand "yakuza0-${name}" {
      nativeBuildInputs = [ pkgs.unzip pkgs.unrar pkgs.p7zip ];
    } ''
      src=${nexusArchive archive sha256}
      mkdir work
      cd work
      case "$src" in
        *.rar) unrar x -inul "$src" ./ ;;
        *.zip) unzip -q "$src" ;;
        *.7z)  7z x -bd -y "$src" > /dev/null ;;
      esac
      mv "${folder}" $out
    '';

  hdProject = unpackNexus {
    name    = "hd-project";
    archive = "yakuza0-hd-project-0.4.rar";
    sha256  = "1waqn09x42j8c0bcgrzl5xdh0222md9mfpxfbdmcj68fvvjw59sv";
    folder  = "HDProject";
  };

  styleIcons = unpackNexus {
    name    = "upscaled-style-icons";
    archive = "yakuza0-upscaled-style-icons-1.0.zip";
    sha256  = "0m8ggqlz4w7fy9vzhn3chw6f68s4pj7f8jk9s84wicl5r12c1q3h";
    folder  = "StyleIconUpscale";
  };

  hdMinimap = unpackNexus {
    name    = "hd-minimap";
    archive = "yakuza0-hd-minimap-1.5.7z";
    sha256  = "1h1in9gm77mqi5x3sqqlq1m1zf32dh2k1rzf8i8l63zhkj13aqiw";
    folder  = "HD Mini-Map 0";
  };

  exactions = unpackNexus {
    name    = "exactions";
    archive = "yakuza0-exactions-3.5.1.rar";
    sha256  = "0qcjgih4nv4ap65jngcbc465c6zqrhzd46wdibvm6nn08y2ljcga";
    folder  = "Exactions";
  };

  # load order
  mods = [
    { name = "4K Font";               src = "${localMods}/4K Font"; }
    { name = "PS4 Buttons";           src = "${localMods}/PS4 Buttons"; }
    { name = "HD Character Textures"; src = "${hdCharacterTextures}"; }
    { name = "Yakuza 0 HD Project";   src = "${hdProject}"; }
    { name = "Upscaled Style Icons";  src = "${styleIcons}"; }
    { name = "HD Mini-Map 0";         src = "${hdMinimap}"; }
    { name = "Exactions";             src = "${exactions}"; }
  ];

  lodmodPatches = [
    "2_lodmod-b7-p4_drawdistance.ppf"
    "3_lodmod-b7-p4_scale-lods.ppf"
    "4_lodmod-b7-p4_firstperson-fix.ppf"
  ];

  manifest = pkgs.writeText "yakuza0-mods-manifest" (lib.concatMapStrings (m: "${m.name}=${m.src}\n") mods + "srmm=${srmm}\n");

  writeModList = pkgs.writeText "yakuza0-write-modlist.py" ''
    import struct
    import sys

    out, names = sys.argv[1], sys.argv[2:]
    data = b"SRMM_ML" + bytes([2, 0]) + struct.pack("<H", len(names))
    for name in names:
        raw = name.encode("utf-8")
        data += bytes([0xFF]) + struct.pack("<H", len(raw)) + raw
    with open(out, "wb") as handle:
        handle.write(data)
  '';

  applyPpf = pkgs.writeText "yakuza0-apply-ppf.py" ''
    import struct
    import sys

    exe, patches = sys.argv[1], sys.argv[2:]
    with open(exe, "rb") as handle:
        image = bytearray(handle.read())

    for path in patches:
        with open(path, "rb") as handle:
            ppf = handle.read()
        if ppf[:5] != b"PPF30":
            sys.exit(f"{path} is not a PPF3 patch")
        blockcheck, undo = ppf[0x39], ppf[0x3A]
        pos = 0x3C + (1024 if blockcheck else 0)
        while pos < len(ppf):
            offset = struct.unpack_from("<Q", ppf, pos)[0]
            length = ppf[pos + 8]
            pos += 9
            image[offset:offset + length] = ppf[pos:pos + length]
            pos += length * (2 if undo else 1)

    with open(exe, "wb") as handle:
        handle.write(image)
  '';

in
{
  home.activation.yakuza0Mods = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    Y0="${gameDir}"

    if [ ! -f "$Y0/Yakuza0.exe" ]; then
      echo "Yakuza 0: not installed at $Y0, skipping"
    else
      $DRY_RUN_CMD install -m644 ${srmm}/windows/ShinRyuModManager.exe "$Y0/ShinRyuModManager.exe"
      $DRY_RUN_CMD install -m644 ${srmm}/windows/YakuzaParless.asi "$Y0/YakuzaParless.asi"
      $DRY_RUN_CMD install -m644 ${srmm}/windows/version.dll "$Y0/dinput8.dll"

      if [ "$(cat "$Y0/.nix-yakuza0-manifest" 2>/dev/null)" != "${manifest}" ]; then
        $DRY_RUN_CMD mkdir -p "$Y0/mods"
        ${lib.concatMapStrings (m: ''
          $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync --archive --delete --chmod=u+w \
            "${m.src}/" "$Y0/mods/${m.name}/"
        '') mods}

        $DRY_RUN_CMD ${pkgs.python3}/bin/python3 ${writeModList} "$Y0/ModList.ml" \
          ${lib.concatMapStringsSep " " (m: lib.escapeShellArg m.name) mods}

        (
          cd "$Y0" && \
          $DRY_RUN_CMD env DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
            ${pkgs.steam-run}/bin/steam-run ${srmm}/linux/ShinRyuModManager -s > /dev/null
        ) && echo "${manifest}" > "$Y0/.nix-yakuza0-manifest" \
          || echo "Yakuza 0: srmm failed to rebuild the mlo, check $Y0/srmm-logs"

        echo "Yakuza 0: mods synced and mlo rebuilt"
      else
        echo "Yakuza 0: mods already up to date"
      fi

      exe="$Y0/Yakuza0.exe"
      sha=$(${pkgs.coreutils}/bin/sha256sum "$exe" | cut -d' ' -f1)

      if [ "$sha" = "${patchedExeSha}" ]; then
        echo "Yakuza 0: lodmod already applied"
      elif [ "$sha" = "${vanillaExeSha}" ]; then
        $DRY_RUN_CMD cp "$exe" "$exe.orig"
        $DRY_RUN_CMD ${pkgs.python3}/bin/python3 ${applyPpf} "$exe" \
          ${lib.concatMapStringsSep " " (p: "${lodmod}/${p}") lodmodPatches}

        if [ -z "$DRY_RUN_CMD" ] && \
           [ "$(${pkgs.coreutils}/bin/sha256sum "$exe" | cut -d' ' -f1)" != "${patchedExeSha}" ]; then
          cp "$exe.orig" "$exe"
          echo "Yakuza 0: lodmod produced an unexpected exe, restored the original"
        else
          echo "Yakuza 0: lodmod applied"
        fi
      else
        echo "Yakuza 0: Yakuza0.exe matches neither vanilla nor patched (game update?), skipping lodmod"
      fi
    fi
  '';
}
