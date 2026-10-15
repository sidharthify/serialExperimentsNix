{ inputs, pkgs, ... }:

{
  environment.systemPackages = [
    inputs.syd.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
