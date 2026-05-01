# shadps4-qtlauncher: Qt-based launcher/frontend for the shadPS4 emulator
# https://github.com/shadps4-emu/shadps4-qtlauncher
# SPDX-FileCopyrightText: 2024 shadPS4 Emulator Project
# SPDX-License-Identifier: GPL-2.0-or-later

{ pkgs, ... }:

let
  shadps4-qtlauncher = pkgs.stdenv.mkDerivation rec {
    pname = "shadps4-qtlauncher";
    version = "unstable-2025-05-01";

    src = pkgs.fetchFromGitHub {
      owner = "shadps4-emu";
      repo = "shadps4-qtlauncher";
      rev = "c39f5977f667e4fea126a2d6d2ab5cb68efcda6a";
      hash = "sha256-mStjj6HKlIUHpHrMuURfKESZoQbNXBQgBe2Gj8/udsk=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = with pkgs; [
      llvmPackages_18.clang
      cmake
      pkg-config
      git
      qt6.wrapQtAppsHook
      qt6.qttools # lrelease / linguist
    ];

    buildInputs = with pkgs; [
      qt6.qtbase
      qt6.qttools
      qt6.qtmultimedia
      qt6.qtwayland
      openal
      libpulseaudio
      vulkan-headers
      vulkan-loader
      SDL2
      sdl3
      libxkbcommon
      wayland
      wayland-protocols
      libxcb
      xcbutil
      xcbutilkeysyms
      xcbutilwm
      openssl
      fmt
      libpng
      libglvnd
      ffmpeg
    ];

    cmakeFlags = [
      "-DENABLE_UPDATER=OFF"
      # Provide static git info so CMake doesn't call git at configure time
      "-DGIT_REV=${src.rev}"
      "-DGIT_DESC=${src.rev}"
      "-DGIT_BRANCH=main"
    ];

    preConfigure = ''
      git init -q
      git config user.email "nix@build"
      git config user.name "nix"
      git add -A
      git commit -q -m "nix" --allow-empty
    '';

    meta = with pkgs.lib; {
      description = "Qt-based launcher and frontend for the shadPS4 PS4 emulator";
      homepage = "https://github.com/shadps4-emu/shadps4-qtlauncher";
      license = licenses.gpl2Plus;
      platforms = platforms.linux;
      mainProgram = "shadPS4QtLauncher";
    };
  };
in
{
  environment.systemPackages = [ shadps4-qtlauncher ];
}
