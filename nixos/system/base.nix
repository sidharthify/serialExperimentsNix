# nixos/system/base.nix
# bootloader, time, locale, keyboard, printing, zram, openssh, xdg-portal, auto-upgrade.

{ config, pkgs, ... }:

{
  # bl
  boot.loader.systemd-boot.enable      = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout                  = 10;

  boot.loader.grub = {
    enable             = true;
    devices            = [ "nodev" ];
    efiSupport         = true;
    useOSProber        = true;
    configurationLimit = 10;
    extraEntries = ''
      menuentry "Bazzite" --class fedora --class linux {
        insmod part_gpt
        insmod fat
        search --no-floppy --fs-uuid --set=root 67AA-D0D8
        chainloader /EFI/fedora/shimx64.efi
      }
    '';
  };

  time.hardwareClockInLocalTime = true;

  boot.plymouth.enable         = true;
  boot.initrd.systemd.enable   = true;

  # time
  time.timeZone = "Asia/Kolkata";

  # locale
  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT    = "en_IN";
    LC_MONETARY       = "en_IN";
    LC_NAME           = "en_IN";
    LC_NUMERIC        = "en_IN";
    LC_PAPER          = "en_IN";
    LC_TELEPHONE      = "en_IN";
    LC_TIME           = "en_IN";
  };

  # keyboard
  services.xserver.xkb = {
    layout  = "us";
    variant = "";
  };

  # printing
  services.printing.enable = true;

  # zram
  zramSwap = {
    enable        = true;
    algorithm     = "zstd";
    memoryPercent = 70;
    priority      = 100;    # always hit ZRAM before the 64GB swapfile
  };

  # openssh
  services.openssh = {
    enable                        = true;
    settings.PermitRootLogin      = "no";
    settings.PasswordAuthentication = true;
  };

  # xdg portal
  xdg.portal.enable             = true;
  xdg.portal.extraPortals       = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.xdgOpenUsePortal   = true;
  services.dbus.enable          = true;

  # auto upgrade
  system.autoUpgrade.enable      = true;
  system.autoUpgrade.allowReboot = true;
}
