# home/zen.nix
#
# Force-installs all Zen extensions via Firefox Policies.
# Dark Reader is also configured via managed storage.
# Font prefs (user.js) and chrome/userContent.css are managed here too.
# Zen themes are browser themes, and those are managed through the Zen UI and don't need declarative installation.

{ config, pkgs, lib, ... }:

let
  # Builds the policies.json that goes into ~/.zen/distribution/policies.json
  zenPolicies = {
    policies = {
      ExtensionSettings = {
        # ── Bring Twitter Back ──────────────────────────────────────────────
        "{1af1a448-95f4-46c6-b093-078ea1023f81}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bring-back-twitter/latest.xpi";
        };
        # ── ClearURLs ───────────────────────────────────────────────────────
        "{74145f27-f039-47ce-a470-a662b129930a}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
        };
        # ── Cookie-Editor ───────────────────────────────────────────────────
        "{c3c10168-4186-445c-9c5b-63f12b8e2c87}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/cookie-editor/latest.xpi";
        };
        # ── Dark Reader ─────────────────────────────────────────────────────
        "addon@darkreader.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        };
        # ── LeechBlock NG ───────────────────────────────────────────────────
        "leechblockng@proginosko.com" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/leechblock-ng/latest.xpi";
        };
        # ── Return YouTube Dislike ──────────────────────────────────────────
        "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
        };
        # ── Stylus ──────────────────────────────────────────────────────────
        "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
        };
        # ── Tampermonkey ────────────────────────────────────────────────────
        "firefox@tampermonkey.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/tampermonkey/latest.xpi";
        };
        # ── To Google Translate ─────────────────────────────────────────────
        "jid1-93WyvpgvxzGATw@jetpack" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/to-google-translate/latest.xpi";
        };
        # ── uBlock Origin ───────────────────────────────────────────────────
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
        # ── User-Agent Switcher ─────────────────────────────────────────────
        "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/user-agent-string-switcher/latest.xpi";
        };
        # ── Wayback Machine ─────────────────────────────────────────────────
        "wayback_machine@mozilla.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/wayback-machine/latest.xpi";
        };
        # ── YCS - YouTube Comment Search ────────────────────────────────────
        "ycs-cont-public@pymaster.tw" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ycs-youtube-comment-search/latest.xpi";
        };
        # ── SponsorBlock ────────────────────────────────────
        "sponsorBlocker@ajay.app" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        };
     };
      # ── Dark Reader managed storage config ──────────────────────────────────
      "3rdparty" = {
        Extensions = {
          "addon@darkreader.org" = {
            theme = {
              mode = 1;          # 1 = dark mode
              brightness = 100;
              contrast = 100;
              sepia = 0;
              grayscale = 0;
            };
            enabledByDefault = true;
            disabledForUrl = [
              "google.com/maps"
            ];
          };
        };
      };
    };
  };

  # The actual profile directory (Zen creates it with a random prefix).
  zenProfile = ".zen/map2mxlp.Default Profile";
in
{
  # Prefs re-applied on every Zen startup; about:config changes to these only
  # last until the next restart.
  home.file."${zenProfile}/user.js".text = ''
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    // Document fonts stay ON; userContent.css forces Inter instead, so ligature
    // icon fonts (Gemini's mat-icons) still render instead of showing as text.
    user_pref("browser.display.use_document_fonts", 1);
    user_pref("font.name.sans-serif.x-western", "Inter Variable");
    user_pref("font.name.serif.x-western", "Inter Display");
    user_pref("font.name.monospace.x-western", "JetBrains Mono");
  '';

  # Catppuccin Mocha for about: pages + global Inter forcing (minus icon fonts).
  home.file."${zenProfile}/chrome/userContent.css".source = ./zen-userContent.css;

  # Place policies.json in the Zen profile's distribution/ directory.
  home.file.".zen/distribution/policies.json" = {
    text = builtins.toJSON zenPolicies;
    onChange = ''
      echo "[zen] policies.json updated"
    '';
  };
}
