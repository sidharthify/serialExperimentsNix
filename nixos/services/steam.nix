# nixos/services/steam.nix

{ config, pkgs, ... }:

let
  switchToGamingMode = pkgs.writeShellScriptBin "switch-to-gaming-mode" ''
    # set gamescope as the next session for SDDM
    sudo ${pkgs.coreutils}/bin/mkdir -p /var/lib/sddm
    echo -e "[Last]\nSession=gamescope-wayland.desktop" | sudo ${pkgs.coreutils}/bin/tee /var/lib/sddm/state.conf > /dev/null
    # log out of KDE
    ${pkgs.libsForQt5.qt5.qttools.bin or pkgs.kdePackages.qttools}/bin/qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout 2>/dev/null \
      || loginctl terminate-user "$USER"
  '';

  returnToDesktop = pkgs.writeShellScriptBin "return-to-desktop" ''
    sudo ${pkgs.coreutils}/bin/mkdir -p /var/lib/sddm
    echo -e "[Last]\nSession=plasma.desktop" | sudo ${pkgs.coreutils}/bin/tee /var/lib/sddm/state.conf > /dev/null
    loginctl terminate-user "$USER"
  '';

  gamingModeDesktopItem = pkgs.makeDesktopItem {
    name = "switch-to-gaming-mode";
    desktopName = "Switch to Gaming Mode";
    comment = "Switch to Steam Big Picture with Gamescope";
    exec = "${switchToGamingMode}/bin/switch-to-gaming-mode";
    icon = "steam";
    categories = [ "Game" ];
  };
in
{
  programs.steam = {
    enable      = true;
    #package     = pkgs.millennium-steam;
    remotePlay.openFirewall            = true;
    dedicatedServer.openFirewall       = true;
    localNetworkGameTransfers.openFirewall = true;

    gamescopeSession.enable = true;
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = [
    switchToGamingMode
    returnToDesktop
    gamingModeDesktopItem
  ];

  # allow the user to write to sddm state without a password prompt
  security.sudo.extraRules = [{
    groups = [ "wheel" ];
    commands = [
      { command = "${pkgs.coreutils}/bin/mkdir -p /var/lib/sddm"; options = [ "NOPASSWD" ]; }
      { command = "${pkgs.coreutils}/bin/tee /var/lib/sddm/state.conf"; options = [ "NOPASSWD" ]; }
    ];
  }];
}
