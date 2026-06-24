# home/kde.nix
#
# My declarative KDE Plasma setup via plasma-manager.
# Generated from rc2nix output and appletsrc panel layout.
# Catppuccin Mocha Mauve theme from catppuccin/nix.

{ config, pkgs, lib, inputs, ... }:

let
  wallpaper = pkgs.fetchurl {
    url    = "https://drive.usercontent.google.com/download?id=1IRbUxvppEx2NmRsa9ZiH7-3dcbquueZs&export=download&confirm=t";
    sha256 = "13bswcccjhnsq4wsmfi9myznf6q3yb1qm90ssiy4p87zymjxvvk8";
    name   = "johnny-silverhand-cyberpunk-wallpaper.png";
  };

  wallpaperPath = "${config.home.homeDirectory}/Pictures/johnny-silverhand-cyberpunk-wallpaper.png";
in
{
  home.packages = [ pkgs.catppuccin-kde ];

  home.file."Pictures/johnny-silverhand-cyberpunk-wallpaper.png".source = wallpaper;

  # ── Plasma config ───────────────────────────────────────────────────────────
  programs.plasma = {
    enable = true;

    # ── Workspace appearance ─────────────────────────────────────────────────
    workspace = {
      lookAndFeel  = "Catppuccin-Mocha-Mauve";
      colorScheme  = "CatppuccinMochaMauve";
      iconTheme    = "breeze-dark";
      cursor.theme = "breeze_cursors";
      wallpaper    = wallpaperPath;
    };

    # ── Fonts ────────────────────────────────────────────────────────────────
    fonts = {
      general = {
        family = "Inter";
        pointSize = 10;
      };
      fixedWidth = {
        family = "Hack";
        pointSize = 10;
      };
      menu = {
        family = "Inter";
        pointSize = 10;
      };
      toolbar = {
        family = "Inter";
        pointSize = 10;
      };
      small = {
        family = "Inter";
        pointSize = 10;
      };
      windowTitle = {
        family = "Inter";
        pointSize = 10;
        weight = "medium";
      };
    };

    # ── Panel layout ─────────────────────────────────────────────────────────
    panels = [
      {
        location = "bottom";
        height = 44;
        floating = false;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            name = "org.kde.plasma.icontasks";
            config.General.launchers = lib.concatStringsSep "," [
              "preferred://browser"
              "applications:discord.desktop"
              "applications:steam.desktop"
              "applications:spotify.desktop"
              "applications:org.telegram.desktop.desktop"
              "applications:org.kde.konsole.desktop"
              "preferred://filemanager"
            ];
          }
          "org.kde.plasma.marginsseparator"
          {
            name = "org.kde.plasma.systemtray";
            config.General = { };
          }
          {
            name = "org.kde.plasma.digitalclock";
            config.Appearance = {
              showDate = true;
              dateFormat = "shortDate";
            };
          }
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

    # ── KWin effects ─────────────────────────────────────────────────────────
    kwin = {
      effects = {
        blur = {
          enable = true;
          noiseStrength = 4;
        };
        translucency.enable = true;
        wobblyWindows.enable = false;
        cube.enable = false;
      };
      nightLight = {
        enable = false;
      };
      titlebarButtons = {
        left  = [ ];
        right = [ "minimize" "maximize" "close" ];
      };
      tiling.padding = 4;
    };

    # ── Shortcuts ────────────────────────────────────────────────────────────
    shortcuts = {
      "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout"       = "Meta+Alt+K";
      ksmserver."Lock Session"  = [ "Meta+L" "Screensaver" ];
      ksmserver."Log Out"       = "Ctrl+Alt+Del";
      kwin."Edit Tiles"         = "Meta+T";
      kwin.Expose               = "Ctrl+F9";
      kwin.ExposeAll            = [ "Ctrl+F10" "Launch (C)" ];
      kwin.ExposeClass          = "Ctrl+F7";
      kwin."Grid View"          = "Meta+G";
      kwin."Kill Window"        = "Meta+Ctrl+Esc";
      kwin.Overview             = "Meta+W";
      kwin."Show Desktop"       = "Meta+D";
      kwin."Switch One Desktop Down"          = "Meta+Ctrl+Down";
      kwin."Switch One Desktop Up"            = "Meta+Ctrl+Up";
      kwin."Switch One Desktop to the Left"   = "Meta+Ctrl+Left";
      kwin."Switch One Desktop to the Right"  = "Meta+Ctrl+Right";
      kwin."Switch Window Down"  = "Meta+Alt+Down";
      kwin."Switch Window Left"  = "Meta+Alt+Left";
      kwin."Switch Window Right" = "Meta+Alt+Right";
      kwin."Switch Window Up"    = "Meta+Alt+Up";
      kwin."Switch to Desktop 1" = "Ctrl+F1";
      kwin."Switch to Desktop 2" = "Ctrl+F2";
      kwin."Switch to Desktop 3" = "Ctrl+F3";
      kwin."Switch to Desktop 4" = "Ctrl+F4";
      kwin."Walk Through Windows"           = "Alt+Tab";
      kwin."Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
      kwin."Walk Through Windows of Current Application"          = "Alt+`";
      kwin."Walk Through Windows of Current Application (Reverse)" = "Alt+~";
      kwin."Window Close"    = "Alt+F4";
      kwin."Window Maximize" = "Meta+PgUp";
      kwin."Window Minimize" = "Meta+PgDown";
      kwin."Window Quick Tile Bottom" = "Meta+Down";
      kwin."Window Quick Tile Left"   = "Meta+Left";
      kwin."Window Quick Tile Right"  = "Meta+Right";
      kwin."Window Quick Tile Top"    = "Meta+Up";
      kwin."Window One Desktop Down"         = "Meta+Ctrl+Shift+Down";
      kwin."Window One Desktop Up"           = "Meta+Ctrl+Shift+Up";
      kwin."Window One Desktop to the Left"  = "Meta+Ctrl+Shift+Left";
      kwin."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
      kwin."Window to Next Screen"     = "Meta+Shift+Right";
      kwin."Window to Previous Screen" = "Meta+Shift+Left";
      kwin.disableInputCapture = "Meta+Shift+Esc";
      kwin.view_actual_size    = "Meta+0";
      kwin.view_zoom_in        = [ "Meta++" "Meta+=" ];
      kwin.view_zoom_out       = "Meta+-";
      kwin.ToggleMouseClick    = "Meta+*";
      kwin."Window Operations Menu" = "Alt+F3";
      plasmashell."activate application launcher" = [ "Meta" "Alt+F1" ];
      plasmashell."activate task manager entry 1" = "Meta+1";
      plasmashell."activate task manager entry 2" = "Meta+2";
      plasmashell."activate task manager entry 3" = "Meta+3";
      plasmashell."activate task manager entry 4" = "Meta+4";
      plasmashell."activate task manager entry 5" = "Meta+5";
      plasmashell."activate task manager entry 6" = "Meta+6";
      plasmashell."activate task manager entry 7" = "Meta+7";
      plasmashell."activate task manager entry 8" = "Meta+8";
      plasmashell."activate task manager entry 9" = "Meta+9";
      plasmashell."manage activities"   = "Meta+Q";
      plasmashell."next activity"       = "Meta+A";
      plasmashell."previous activity"   = "Meta+Shift+A";
      plasmashell."show dashboard"      = "Ctrl+F12";
      plasmashell."show-on-mouse-pos"   = "Meta+V";
      plasmashell."clipboard_action"    = "Meta+Ctrl+X";
      plasmashell."cycle-panels"        = "Meta+Alt+P";
    };

    # ── Raw config ──────────────────────────────────────────────────────────
    configFile = {
      kdeglobals.General.XftAntialias  = true;
      kdeglobals.General.XftHintStyle  = "hintslight";
      kdeglobals.General.XftSubPixel   = "rgb";
      kdeglobals.KDE.contrast          = 4;
      kdeglobals.KDE.frameContrast     = 0.2;
      kdeglobals.WM.activeBackground   = "30,30,46";
      kdeglobals.WM.activeBlend        = "205,214,244";
      kdeglobals.WM.activeForeground   = "205,214,244";
      kdeglobals.WM.inactiveBackground = "17,17,27";
      kdeglobals.WM.inactiveBlend      = "166,173,200";
      kdeglobals.WM.inactiveForeground = "166,173,200";
      kdeglobals.General.BrowserApplication     = "google-chrome.desktop";
      kdeglobals.General.DeviceLedsAccentColored = false;
      kdeglobals."KFileDialog Settings"."Breadcrumb Navigation"  = true;
      kdeglobals."KFileDialog Settings"."Sort directories first" = true;
      kdeglobals."KFileDialog Settings"."View Style"             = "DetailTree";

      kcminputrc.Mouse.cursorTheme = "breeze_cursors";
      kcminputrc."Libinput/1133/49298/Logitech G102 LIGHTSYNC Gaming Mouse".PointerAccelerationProfile = 1;

      kwinrc."org.kde.kdecoration2".theme                    = "Breeze";
      kwinrc.Effect-blur.NoiseStrength                       = 4;
      kwinrc.Effect-kwin4_effect_geometry_change.Duration    = 300;
      kwinrc.Effect-translucency.Dialogs                     = 99;
      kwinrc.Effect-translucency.MoveResize                  = 100;
      kwinrc.Plugins.glideEnabled                            = true;
      kwinrc.Plugins.sheetEnabled                            = true;
      kwinrc.Plugins.kwin4_effect_geometry_changeEnabled     = true;
      kwinrc.Plugins.fullscreenEnabled                       = false;
      kwinrc.Plugins.maximizeEnabled                         = false;
      kwinrc.Plugins.scaleEnabled                            = false;
      #kwinrc.NightColor.Mode                                 = "Constant";
      #kwinrc.NightColor.NightTemperature                     = 4000;
      kwinrc.Compositing.AllowTearing                        = true;
      kwinrc.Compositing.LatencyPolicy                       = "Low";
      kwinrc."Tiling/dedbc80a-6b77-44d3-9c4e-6aaede62f9ae/8382b5c2-41b5-4ab2-9a04-9eccb2c10f30".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/dedbc80a-6b77-44d3-9c4e-6aaede62f9ae/8382b5c2-41b5-4ab2-9a04-9eccb2c10f30".padding = 4;
      kwinrc.Xwayland.Scale    = 1;
      kwinrc.Desktops.Number   = 1;
      kwinrc.Desktops.Rows     = 1;

      klipperrc.General.IgnoreImages = false;
      klipperrc.General.MaxClipItems = 2000;

      plasmaparc.General.RaiseMaximumVolume = true;

      kscreenlockerrc."Greeter/Wallpaper/org.kde.image/General".Image        = wallpaperPath;
      kscreenlockerrc."Greeter/Wallpaper/org.kde.image/General".PreviewImage = wallpaperPath;

      spectaclerc.ImageSave.translatedScreenshotsFolder = "Screenshots";

      kded5rc.Module-browserintegrationreminder.autoload = false;
      kded5rc.Module-device_automounter.autoload         = false;

      baloofilerc.General.dbVersion = 2;

      katerc.lspclient.SemanticHighlighting = true;
      katerc.lspclient.InlayHints           = false;
      katerc.lspclient.HighlightSymbol      = true;
      katerc.lspclient.FormatOnSave         = false;

      "plasma-localerc".Formats.LANG = "en_IN";
    };
  };
}
