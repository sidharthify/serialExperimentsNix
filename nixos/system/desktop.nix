{ pkgs, ... }:

{
   # kde!
   services.desktopManager.plasma6.enable = true;
   services.displayManager.sddm.enable = true;

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
