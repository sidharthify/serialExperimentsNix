{ pkgs, ... }:

{
   # kde!
   services.desktopManager.plasma6.enable = true;
   services.displayManager.sddm.enable = true;
   services.displayManager.autoLogin.enable = true;
   services.displayManager.autoLogin.user = "sidharthify";
   services.displayManager.sddm.autoLogin.relogin = true;

   programs.kdeconnect.enable = true;
   programs.firefox.enable = true;

   programs.ssh.askPassword =
     "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

   # aerothemeplasma
   #programs.aeroshell = {
   #enable = true;
   #fonts.enable = true;
   #polkit.enable = true;
   #aerothemeplasma = {
     #enable = true;
     #sddm.enable = true;
     #plymouth.enable = true;
   #};
 #};

}
