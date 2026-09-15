{ inputs, pkgs, ... }:

{
  environment.systemPackages = [
    # zen-browser is installed by ./zen-codecs-fix.nix
    inputs.syd.packages.${pkgs.system}.default
  ];
}
