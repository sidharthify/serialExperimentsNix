{ inputs, pkgs, ... }:

{
  environment.systemPackages = [
    inputs.zen-browser-source.packages.${pkgs.system}.default
    inputs.syd.packages.${pkgs.system}.default
    pkgs.parsecgaming
    inputs.tuxManager.packages.${pkgs.system}.default
    inputs.balena-etcher.packages.${pkgs.system}.default
  ];
}
