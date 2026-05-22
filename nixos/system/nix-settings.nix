# nixos/system/nix-settings.nix

{ ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users         = [ "root" "sidharthify" ];

    substituters      = [
      "https://cache.nixos.org"
      "https://attic.xuyh0120.win/lantian"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSBd8="
    ];

    max-jobs = "auto";
    cores    = 0;
  };

  nixpkgs.config = {
    allowUnfree          = true;
    permittedInsecurePackages = [ "electron-35.7.5" ];
    android_sdk.accept_license = true;
  };

  programs.nix-ld.enable  = true;
  services.usbmuxd.enable = true;

  programs.nh = {
    enable           = true;
    clean.enable     = true;
    clean.extraArgs  = "--keep-since 4d --keep 3";
    flake            = "/etc/nixos";
  };
}
