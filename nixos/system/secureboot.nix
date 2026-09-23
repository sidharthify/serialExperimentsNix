# nixos/system/secureboot.nix
# Wanted to try FACEIT and that requires Secure Boot and TPM 2.0 for its
# kernel-level Anticheat to work, so that's what this is for.
#
# The bootloader stays GRUB (so os-prober, the Catppuccin theme and the
# existing /boot layout all survive) just sign grubx64.efi with a key
# the firmware trusts, and re-enroll Microsoft's CAs so Windows still boots.
#
# Keys live in /var/lib/sbctl. They are NOT in this repo and must not be.

{ config, pkgs, lib, ... }:

let
  esp = config.boot.loader.efi.efiSysMountPoint;
in
{
  # Upstream GRUB calls grub_lockdown() unconditionally whenever Secure Boot is
  # on (grub-core/kern/efi/init.c). Lockdown registers a verifier that DEFERS
  # authentication to shim for modules, Linux kernels and EFI chainloaded
  # images. We have no shim, so with the shim_lock verifier disabled nothing
  # answers the deferral and GRUB drops to rescue with
  #   "verification requested but nobody cares: .../normal.mod"
  # This patch makes lockdown honour the same --disable-shim-lock marker that
  # the shim_lock verifier already honours. Without it, Secure Boot and GRUB
  # without shim cannot boot anything at all.
  nixpkgs.overlays = [
    (final: prev: {
      grub2 = prev.grub2.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./grub-honour-disable-shim-lock.patch ];
      });
    })
  ];

  boot.loader.grub = {
    # THE load-bearing flag. GRUB 2.14 (grub-core/kern/efi/sb.c,
    # grub_shim_lock_verifier_setup) registers its shim_lock verifier the
    # moment it sees SecureBoot=1. We have no shim -- we sign grubx64.efi
    # directly -- so that verifier would fail *every* handoff with
    # "shim protocols not found": the NixOS kernel AND the Windows
    # chainload, because GRUB_FILE_TYPE_EFI_CHAINLOADED_IMAGE is on its
    # checked list. It would also refuse to load GRUB's own modules
    # ("prohibited by secure boot policy"). --disable-shim-lock stamps an
    # OBJ_TYPE_DISABLE_SHIM_LOCK header into the image, which makes that
    # setup function return early and register nothing.
    extraGrubInstallArgs = [ "--disable-shim-lock" ];

    # install-grub.pl only re-runs grub-install when something changed --
    # notably when the grub store path changes, i.e. on every grub update.
    # That rewrites grubx64.efi and drops our signature. extraInstallCommands
    # is appended to install-grub.sh and runs on EVERY activation, so this is
    # the right hook: sign whatever is currently on the ESP.
    extraInstallCommands = ''
      if [ -f /var/lib/sbctl/keys/db/db.key ]; then
        # Sign only what is actually unsigned. Doing it this way (rather than
        # `sbctl sign ... || true`) means a REAL signing failure propagates:
        # install-grub.sh runs under `set -e`, so the rebuild aborts loudly
        # instead of quietly leaving an image the firmware will reject.
        sign_if_needed() {
          if ${pkgs.sbsigntool}/bin/sbverify --list "$1" >/dev/null 2>&1; then
            return 0
          fi
          echo "signing $1 for secure boot..."
          ${pkgs.sbctl}/bin/sbctl sign "$1"
        }

        for img in ${esp}/EFI/*/grubx64.efi; do
          [ -e "$img" ] || continue
          sign_if_needed "$img"

          # Keep the removable fallback path as a signed rescue copy. If the
          # firmware ever loses its NVRAM entry (clearing Secure Boot keys and
          # "load optimized defaults" in the same BIOS visit can do it), this
          # is what boots instead of nothing. It reads the same /boot/grub.
          ${pkgs.coreutils}/bin/mkdir -p ${esp}/EFI/BOOT
          ${pkgs.coreutils}/bin/cp -f "$img" ${esp}/EFI/BOOT/BOOTX64.EFI
          sign_if_needed ${esp}/EFI/BOOT/BOOTX64.EFI
        done

        # The kernel needs signing too. GRUB 2.14 boots Linux through the
        # FIRMWARE's LoadImage (grub-core/loader/efi/linux.c:194
        # grub_arch_efi_linux_boot_image), not its own loader -- so under Secure
        # Boot the firmware verifies the bzImage against db, and an unsigned
        # kernel dies with "cannot load image". (The shim path at
        # grub_efi_get_last_verified_image_handle() returns NULL for us.)
        # install-grub.pl only copies a kernel when it is absent (! -e $dst), so
        # signing in place sticks across rebuilds. The initrd needs no signature
        # -- GRUB hands that over itself and the firmware never sees it.
        for k in ${esp}/kernels/*-bzImage; do
          [ -e "$k" ] || continue
          sign_if_needed "$k"
        done

        # Post-condition. Every image the firmware will verify must carry a
        # signature before we call this activation done. This is the backstop
        # against autoUpgrade (allowReboot = true) rebooting into a generation
        # whose kernel silently failed to get signed.
        unsigned=""
        for img in ${esp}/EFI/*/grubx64.efi ${esp}/EFI/BOOT/BOOTX64.EFI ${esp}/kernels/*-bzImage; do
          [ -e "$img" ] || continue
          ${pkgs.sbsigntool}/bin/sbverify --list "$img" >/dev/null 2>&1 || unsigned="$unsigned $img"
        done
        if [ -n "$unsigned" ]; then
          echo "ERROR: secure boot images left unsigned:$unsigned" >&2
          echo "Refusing to finish activation -- this generation would not boot." >&2
          exit 1
        fi
        echo "secure boot: all bootable images signed"
      else
        echo "sbctl keys not found in /var/lib/sbctl -- skipping secure boot signing" >&2
      fi
    '';
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
