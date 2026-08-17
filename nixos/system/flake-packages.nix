{ inputs, pkgs, ... }:

{
  environment.systemPackages = [
    inputs.zen-browser-source.packages.${pkgs.system}.default
    inputs.syd.packages.${pkgs.system}.default
  ];
}
