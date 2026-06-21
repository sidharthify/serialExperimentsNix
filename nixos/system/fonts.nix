{ config, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
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
        sansSerif = [ "Inter" "Noto Sans CJK SC" "Noto Color Emoji" ];
        serif = [ "Noto Serif CJK SC" "Noto Color Emoji" ];
        monospace = [ "JetBrains Mono" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  environment.variables = {
    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0 type1:no-stem-darkening=0 t1cid:no-stem-darkening=0";
  };
}
