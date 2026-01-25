{ config, pkgs, ... }: 

{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 70;
  };
}
