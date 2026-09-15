# workaround for https://github.com/youwen5/zen-browser-flake/issues/19
# nixpkgs renamed the firefox wrapper's ffmpegSupport -> withFFmpeg and
# gssSupport -> withGSSAPI, but the flake still sets the old names, so ffmpeg
# gets dropped from LD_LIBRARY_PATH and H.264/AAC stop working.
# once youwen5/zen-browser-flake#20 is merged, delete this file and put
# inputs.zen-browser-source.packages.${pkgs.system}.default back in flake-packages.nix

{ inputs, pkgs, ... }:

let
  zenPkgs = inputs.zen-browser-source.packages.${pkgs.system};

  zen-browser-unwrapped = zenPkgs.zen-browser-unwrapped.overrideAttrs (old: {
    passthru = (old.passthru or { }) // {
      withFFmpeg = true;
      withGSSAPI = true;
    };
  });

  # re-wrap through the flake's own callPackage so it stays on its pinned nixpkgs
  zen-browser = zenPkgs.default.override { inherit zen-browser-unwrapped; };
in
{
  environment.systemPackages = [ zen-browser ];
}
