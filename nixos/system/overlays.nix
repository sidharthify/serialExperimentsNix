{ inputs, pkgs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      parsecgaming = inputs.parsecgaming.packages.${prev.system}.parsecgaming;
    })
    inputs.millennium.overlays.default
    inputs.nix-cachyos-kernel.overlays.pinned
  ];
}
