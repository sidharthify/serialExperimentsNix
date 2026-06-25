# nixos/services/steam.nix

{ config, pkgs, ... }:

let
  switchToGamingMode = pkgs.writeShellScriptBin "switch-to-gaming-mode" ''
    sudo ${pkgs.coreutils}/bin/mkdir -p /var/lib/sddm
    echo -e "[Last]\nSession=gamescope-wayland.desktop" | sudo ${pkgs.coreutils}/bin/tee /var/lib/sddm/state.conf > /dev/null
    
    sleep 2
    ${pkgs.libsForQt5.qt5.qttools.bin or pkgs.kdePackages.qttools}/bin/qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout 2>/dev/null \
      || loginctl terminate-user "$USER"
  '';

  gamingModeDesktopItem = pkgs.makeDesktopItem {
    name = "switch-to-gaming-mode";
    desktopName = "Switch to Gaming Mode";
    comment = "Switch to Steam Big Picture with Jovian";
    exec = "${switchToGamingMode}/bin/switch-to-gaming-mode";
    icon = "steam";
    categories = [ "Game" ];
  };
in
{
  jovian = {
    steam = {
      enable = true;
      user = "sidharthify";
      desktopSession = "plasma";
    };
  };

  programs.steam = {
    enable      = true;
    remotePlay.openFirewall            = true;
    dedicatedServer.openFirewall       = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  environment.systemPackages = [
    switchToGamingMode
    gamingModeDesktopItem
  ];

  security.sudo.extraRules = [{
    groups = [ "wheel" ];
    commands = [
      { command = "${pkgs.coreutils}/bin/mkdir -p /var/lib/sddm"; options = [ "NOPASSWD" ]; }
      { command = "${pkgs.coreutils}/bin/tee /var/lib/sddm/state.conf"; options = [ "NOPASSWD" ]; }
    ];
  }];
}
