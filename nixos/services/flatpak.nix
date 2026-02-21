# home.nix
{ lib, ... }: {

  # enable flatpak
  services.flatpak.enable = true;
 
   # keep the default one (flathub)
  services.flatpak.remotes = lib.mkOptionDefault [{
    name = "flathub-beta";
    location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
  }];

  services.flatpak.update.auto.enable = false;
  services.flatpak.uninstallUnmanaged = false;

  # installed flatpaks
  services.flatpak.packages = [
    "io.github.brunofin.Cohesion"
    "org.kde.kclock"
    "org.vinegarhq.Sober"
    "io.github.ronniedroid.concessio"
    "net.audiorelay.AudioRelay"
    "org.gnome.baobab"
  ];

}
