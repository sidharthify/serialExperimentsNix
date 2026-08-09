# nixos/services/gpu-passthrough.nix
# single gpu passthrough for windows 11
# amd rx 9060 xt (navi 44 / rdna4) — no igpu on the 12400F, so the host
# session dies while the guest runs and comes back on release.

{ config, pkgs, lib, ... }:

let
  gpuVideoAddr = "0000:03:00.0";
  gpuAudioAddr = "0000:03:00.1";
  guestName    = "win11";

  # services that hold the gpu open and must be down before we unbind.
  # lact writes amdgpu sysfs continuously; it will pin the driver.
  gpuHolders = [ "lact.service" ];

  stopHolders  = lib.concatMapStringsSep "\n" (s: ''systemctl stop ${s} 2>> "$LOG" || true'') gpuHolders;
  startHolders = lib.concatMapStringsSep "\n" (s: ''systemctl start ${s} 2>> "$LOG" || true'') gpuHolders;

  hookScript = pkgs.writeShellScript "qemu-hook" ''
    export PATH=/run/current-system/sw/bin:$PATH
    GUEST_NAME="$1"
    HOOK_NAME="$2"
    STATE_NAME="$3"
    LOG=/var/log/passthrough-hook.log

    log() { echo "$(date '+%F %T'): $*" >> "$LOG"; }

    log "hook: guest=$GUEST_NAME hook=$HOOK_NAME state=$STATE_NAME"
    [ "$GUEST_NAME" = "${guestName}" ] || exit 0

    unbind() {
      if [ -e "/sys/bus/pci/devices/$1/driver" ]; then
        echo "$1" > "/sys/bus/pci/devices/$1/driver/unbind" 2>> "$LOG" || true
      fi
    }

    # force $1 onto vfio-pci. driver_override is more precise than new_id:
    # it targets this exact device instead of every card sharing its pci id.
    claim_vfio() {
      unbind "$1"
      echo vfio-pci > "/sys/bus/pci/devices/$1/driver_override" 2>> "$LOG" || true
      echo "$1" > /sys/bus/pci/drivers_probe 2>> "$LOG" || true
    }

    if [ "$HOOK_NAME" = "prepare" ] && [ "$STATE_NAME" = "begin" ]; then
      log "isolating multi-user target"
      systemctl isolate multi-user.target 2>> "$LOG"

      log "stopping gpu holders"
      ${stopHolders}
      sleep 2

      log "killing remaining drm clients"
      fuser -k -9 /dev/dri/* 2>/dev/null || true
      sleep 2

      log "unbinding vtconsoles"
      for vtcon in /sys/class/vtconsole/vtcon*/bind; do
        echo 0 > "$vtcon" 2>/dev/null || true
      done

      log "unbinding boot framebuffers"
      echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind 2>/dev/null || true
      echo simple-framebuffer.0 > /sys/bus/platform/drivers/simple-framebuffer/unbind 2>/dev/null || true
      sleep 1

      log "unloading amdgpu"
      modprobe -r amdgpu 2>> "$LOG" || true

      if lsmod | grep -q "^amdgpu"; then
        log "FAILED - amdgpu still loaded, rolling back"
        for vtcon in /sys/class/vtconsole/vtcon*/bind; do
          echo 1 > "$vtcon" 2>/dev/null || true
        done
        ${startHolders}
        systemctl isolate graphical.target 2>> "$LOG"
        exit 1
      fi

      log "binding gpu to vfio-pci"
      modprobe vfio-pci 2>> "$LOG"
      claim_vfio "${gpuVideoAddr}"
      claim_vfio "${gpuAudioAddr}"
      log "prepare complete"

    elif [ "$HOOK_NAME" = "release" ] && [ "$STATE_NAME" = "end" ]; then
      log "release starting"

      # detach from vfio-pci and drop the override so the real drivers match again
      for dev in "${gpuVideoAddr}" "${gpuAudioAddr}"; do
        unbind "$dev"
        echo > "/sys/bus/pci/devices/$dev/driver_override" 2>> "$LOG" || true
      done

      modprobe -r vfio_pci vfio_pci_core vfio_iommu_type1 vfio 2>/dev/null || true

      # amdgpu must be loaded *before* anything can bind to it — loading the
      # module auto-attaches it to the now-free card. snd_hda_intel never got
      # unloaded (onboard audio uses it too), so the audio function just needs
      # an explicit re-probe.
      log "reloading amdgpu"
      modprobe amdgpu 2>> "$LOG"
      echo "${gpuAudioAddr}" > /sys/bus/pci/drivers_probe 2>> "$LOG" || true
      sleep 2

      for vtcon in /sys/class/vtconsole/vtcon*/bind; do
        echo 1 > "$vtcon" 2>/dev/null || true
      done
      sleep 1

      log "restoring graphical session"
      ${startHolders}
      systemctl isolate graphical.target 2>> "$LOG"
      log "release complete"
    fi
  '';
in
{
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
  ];

  boot.kernelModules = [
    "vfio"
    "vfio_iommu_type1"
    "vfio_pci"
  ];

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;  # win11 requires tpm 2.0
      # ovmf images ship with qemu now — the old qemu.ovmf submodule is gone
      runAsRoot = true;
    };
    hooks.qemu = {
      "passthrough" = hookScript;
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  # the guest boots off a sata disk, so no virtio driver iso is needed.
  # nixpkgs' virtio-win ships extracted files rather than an .iso anyway.
  environment.systemPackages = with pkgs; [
    virtiofsd
  ];
}
