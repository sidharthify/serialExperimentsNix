{ config, pkgs, ... }:

{
  services.zerotierone = {
    enable = true;
    joinNetworks = [
     "af415e486fbdfe2b"
    ];
  };
}
