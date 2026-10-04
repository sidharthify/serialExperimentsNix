# home/firefox.nix
#
# Configures Firefox declaratively with policy extensions, Dark Reader,
# Catppuccin Mocha Mauve, hardware acceleration, smooth scrolling,
# clean homepage, anti-tracking, and telemetry disabling.

{ config, pkgs, lib, ... }:

let
  firefoxPolicies = {
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableFeedbackCommands = true;
    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
      EmailTracking = true;
    };

    ExtensionSettings = {
      # Bring Twitter Back
      "{1af1a448-95f4-46c6-b093-078ea1023f81}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/bring-back-twitter/latest.xpi";
      };
      # ClearURLs
      "{74145f27-f039-47ce-a470-a662b129930a}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
      };
      # Cookie-Editor
      "{c3c10168-4186-445c-9c5b-63f12b8e2c87}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/cookie-editor/latest.xpi";
      };
      # Dark Reader
      "addon@darkreader.org" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
      };
      # LeechBlock NG
      "leechblockng@proginosko.com" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/leechblock-ng/latest.xpi";
      };
      # Return YouTube Dislike
      "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
      };
      # Stylus
      "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
      };
      # Tampermonkey
      "firefox@tampermonkey.net" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/tampermonkey/latest.xpi";
      };
      # To Google Translate
      "jid1-93WyvpgvxzGATw@jetpack" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/to-google-translate/latest.xpi";
      };
      # uBlock Origin
      "uBlock0@raymondhill.net" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      };
      # User-Agent Switcher
      "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/user-agent-string-switcher/latest.xpi";
      };
      # Wayback Machine
      "wayback_machine@mozilla.org" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/wayback-machine/latest.xpi";
      };
      # YCS - YouTube Comment Search
      "ycs-cont-public@pymaster.tw" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ycs-youtube-comment-search/latest.xpi";
      };
      # SponsorBlock
      "sponsorBlocker@ajay.app" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
      };
      # Catppuccin Mocha Mauve theme
      "{8446b178-1883-4796-82d8-3e692fb64346}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/catppuccin-mocha-mauve-git/latest.xpi";
      };
    };

    # Dark Reader managed storage config
    "3rdparty" = {
      Extensions = {
        "addon@darkreader.org" = {
          theme = {
            mode = 1;
            brightness = 100;
            contrast = 100;
            sepia = 0;
            grayscale = 0;
          };
          enabledByDefault = true;
          disabledForUrl = [
            "google.com/maps"
            "youtube.com"
            "www.youtube.com"
          ];
        };
      };
    };
  };
in
{
  programs.firefox = {
    enable = true;
    policies = firefoxPolicies;

    profiles.default = {
      id = 0;
      isDefault = true;
      name = "default";

      extensions.force = true;

      userContent = builtins.readFile ./firefox-userContent.css;

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.display.use_document_fonts" = 1;

        # hardware acceleration and webrender
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "widget.dmabuf.force-enabled" = true;

        # smooth scrolling
        "general.smoothScroll" = true;
        "general.smoothScroll.lines.durationMaxMS" = 125;
        "general.smoothScroll.lines.durationMinMS" = 125;
        "general.smoothScroll.mouseWheel.durationMaxMS" = 200;
        "general.smoothScroll.mouseWheel.durationMinMS" = 100;
        "general.smoothScroll.other.durationMaxMS" = 125;
        "general.smoothScroll.other.durationMinMS" = 125;
        "general.smoothScroll.pages.durationMaxMS" = 125;
        "general.smoothScroll.pages.durationMinMS" = 125;
        "general.smoothScroll.pixels.durationMaxMS" = 100;
        "general.smoothScroll.pixels.durationMinMS" = 100;
        "general.smoothScroll.scrollbars.durationMaxMS" = 125;
        "general.smoothScroll.scrollbars.durationMinMS" = 125;
        "mousewheel.default.delta_multiplier_y" = 100;

        # clean home page and zero ads / sponsored content
        "browser.compactmode.show" = true;
        "browser.tabs.firefox-view" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = true;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "extensions.pocket.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.quicksuggest.enabled" = false;
        "browser.urlbar.sponsoredTopSites" = false;

        # tracker protection and cookie isolation (total cookie protection)
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;
        "network.cookie.cookieBehavior" = 5;
        "privacy.partition.network_state" = true;

        # disable tracking pings and prefetching
        "browser.send_pings" = false;
        "beacon.enabled" = false;
        "dom.battery.enabled" = false;
        "network.prefetch-next" = false;
        "network.dns.disablePrefetch" = true;
        "network.http.speculative-parallel-limit" = 0;

        # telemetry and crash reporting
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "experiments.activeExperiment" = false;
        "experiments.supported" = false;
        "network.allow-experiments" = false;
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

        # media compatibility (widevine drm and webrtc stay enabled)
        "media.eme.enabled" = true;
        "media.peerconnection.enabled" = true;
      };
    };
  };

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
}
