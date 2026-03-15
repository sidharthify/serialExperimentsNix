{ ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "sidharthify" ];

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "electron-35.7.5" ];
    android_sdk.accept_license = true;
  };

  programs.nix-ld.enable = true;
  services.usbmuxd.enable = true;

  programs.nh = {
    enable = true;

    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";

    flake = "/etc/nixos";

  };
}
