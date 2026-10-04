{ inputs, pkgs, ... }:

{
  environment.systemPackages = [
    inputs.syd.packages.${pkgs.system}.default
  ];
}
