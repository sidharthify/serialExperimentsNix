{ config, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      inter
      jetbrains-mono
      hack-font
    ];

    fontconfig = {
      enable = true;
      antialias = true;

      # never fall back to jagged legacy bitmap fonts
      allowBitmaps = false;

      hinting = {
        enable = true;
        autohint = false;
        style = "slight";
      };

      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };

      defaultFonts = {
        sansSerif = [ "Inter" "Noto Sans" "Noto Sans CJK SC" "Noto Color Emoji" ];
        serif = [ "Noto Serif" "Noto Serif CJK SC" "Noto Color Emoji" ];
        monospace = [ "JetBrains Mono" "Noto Sans Mono" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };

      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <alias binding="same">
            <family>Segoe UI</family>
            <prefer><family>Inter</family></prefer>
          </alias>
          <alias binding="same">
            <family>Segoe UI Variable</family>
            <prefer><family>Inter</family></prefer>
          </alias>
          <alias binding="same">
            <family>Helvetica</family>
            <prefer><family>Inter</family></prefer>
          </alias>
          <alias binding="same">
            <family>Helvetica Neue</family>
            <prefer><family>Inter</family></prefer>
          </alias>
          <alias binding="same">
            <family>-apple-system</family>
            <prefer><family>Inter</family></prefer>
          </alias>
          <alias binding="same">
            <family>BlinkMacSystemFont</family>
            <prefer><family>Inter</family></prefer>
          </alias>
          <alias binding="same">
            <family>SF Pro Text</family>
            <prefer><family>Inter</family></prefer>
          </alias>
          <alias binding="same">
            <family>SF Pro Display</family>
            <prefer><family>Inter</family></prefer>
          </alias>
          <alias binding="same">
            <family>system-ui</family>
            <prefer><family>Inter</family></prefer>
          </alias>
        </fontconfig>
      '';
    };
  };

  environment.variables = {
    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0 type1:no-stem-darkening=0 t1cid:no-stem-darkening=0";
  };
}
