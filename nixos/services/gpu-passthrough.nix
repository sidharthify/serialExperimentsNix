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
  # NOTE: services.lact.enable creates the unit as *lactd*, not "lact".
  gpuHolders = [ "lactd.service" ];

  stopHolders  = lib.concatMapStringsSep "\n" (s: ''systemctl stop ${s} 2>> "$LOG" || true'') gpuHolders;
  startHolders = lib.concatMapStringsSep "\n" (s: ''systemctl start ${s} 2>> "$LOG" || true'') gpuHolders;

  hookScript = pkgs.writeShellScript "qemu-hook" ''
    export PATH=/run/current-system/sw/bin:$PATH
    GUEST_NAME="$1"
    HOOK_NAME="$2"
    STATE_NAME="$3"
    LOG=/var/log/passthrough-hook.log

    # written only once the gpu is actually on vfio-pci. release checks it and
    # does nothing if prepare bailed out -- otherwise release "restores" a
    # rollback that already happened, unbinding a live gpu and hanging the
    # kernel in device removal (D state, unkillable, needs a reboot).
    MARKER=/run/gpu-passthrough-active

    log() { echo "$(date '+%F %T'): $*" >> "$LOG"; }

    log "hook: guest=$GUEST_NAME hook=$HOOK_NAME state=$STATE_NAME"
    [ "$GUEST_NAME" = "${guestName}" ] || exit 0

    # never signal these. logind holds /dev/dri/card1 legitimately for seat0
    # and drops it when the session ends; it also has Restart=always, so
    # killing it makes systemd rebuild the whole graphical session and
    # re-grab the gpu. pid 1 ignores SIGKILL anyway.
    protected() {
      [ "$1" = 1 ] && return 0
      case "$2" in
        systemd|systemd-logind|systemd-udevd|dbus-daemon|dbus-broker) return 0 ;;
      esac
      return 1
    }

    # holders of a /dev/dri node, as "pid target comm". walks /proc directly:
    # `fuser` here is busybox's (no -v) and lsof isn't guaranteed on PATH.
    # comm goes LAST because process names contain spaces ("RDD Process") and
    # would otherwise shift every field after them when read.
    drm_clients() {
      for p in /proc/[0-9]*; do
        for fd in "$p"/fd/*; do
          t=$(readlink "$fd" 2>/dev/null) || continue
          case "$t" in
            /dev/dri/*) echo "''${p##*/} $t $(cat "$p/comm" 2>/dev/null)" ;;
          esac
        done
      done 2>/dev/null | sort -u
    }

    killable_drm_clients() {
      drm_clients | while read -r pid tgt comm; do
        protected "$pid" "$comm" || echo "$pid $tgt $comm"
      done
    }

    unbind() {
      if [ -e "/sys/bus/pci/devices/$1/driver" ]; then
        echo "$1" > "/sys/bus/pci/devices/$1/driver/unbind" 2>> "$LOG" || true
      fi
    }

    if [ "$HOOK_NAME" = "prepare" ] && [ "$STATE_NAME" = "begin" ]; then
      log "stopping display manager"
      systemctl stop display-manager.service 2>> "$LOG" || true

      log "isolating multi-user target"
      systemctl isolate multi-user.target 2>> "$LOG"

      # plasma runs as systemd *user* units under user@1000.service, which is
      # WantedBy=sysinit.target and therefore survives the isolate above.
      # killing kwin alone is useless -- the user manager respawns it and it
      # re-grabs the card. terminating the seat takes the graphical session
      # down for good. ssh sessions have no seat, so the lifeline survives.
      log "terminating graphical sessions on seat0"
      loginctl terminate-seat seat0 2>> "$LOG" || true
      sleep 3

      log "stopping gpu holders"
      ${stopHolders}

      # wait for the session to let go on its own rather than killing it.
      # this is the part that has to be patient: compositor teardown and
      # logind releasing the drm device are not instant.
      log "waiting for drm to go idle"
      for _ in $(seq 1 30); do
        [ -z "$(killable_drm_clients)" ] && break
        sleep 1
      done

      leftover=$(killable_drm_clients)
      if [ -n "$leftover" ]; then
        log "still holding drm after 30s:"
        echo "$leftover" | sed 's/^/    /' >> "$LOG"
        echo "$leftover" | while read -r pid tgt comm; do
          log "  killing $comm ($pid) holding $tgt"
          kill -9 "$pid" 2>/dev/null || true
        done
        sleep 3
      fi

      log "unbinding vtconsoles"
      for vtcon in /sys/class/vtconsole/vtcon*/bind; do
        echo 0 > "$vtcon" 2>/dev/null || true
      done

      log "unbinding boot framebuffers"
      echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind 2>/dev/null || true
      echo simple-framebuffer.0 > /sys/bus/platform/drivers/simple-framebuffer/unbind 2>/dev/null || true
      sleep 1

      # retry: udev and logind can take a moment to drop their references
      log "unloading amdgpu"
      for _ in 1 2 3 4 5; do
        modprobe -r amdgpu 2>> "$LOG" && break
        sleep 2
      done

      if lsmod | grep -q "^amdgpu"; then
        log "FAILED - amdgpu still loaded, rolling back"
        log "  refcount: $(lsmod | awk '$1=="amdgpu"{print $3" ("$4")"}')"
        log "  drm clients still open:"
        drm_clients | sed 's/^/    /' >> "$LOG"

        # deliberately do NOT unbind here. the gpu is still live and driving
        # the host; unbinding it now is what wedges device removal.
        for vtcon in /sys/class/vtconsole/vtcon*/bind; do
          echo 1 > "$vtcon" 2>/dev/null || true
        done
        echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind 2>/dev/null || true
        echo simple-framebuffer.0 > /sys/bus/platform/drivers/simple-framebuffer/bind 2>/dev/null || true
        ${startHolders}
        systemctl isolate graphical.target 2>> "$LOG"
        log "rolled back, host session restored"
        exit 1
      fi

      log "binding gpu to vfio-pci"
      modprobe vfio-pci 2>> "$LOG"
      for dev in "${gpuVideoAddr}" "${gpuAudioAddr}"; do
        unbind "$dev"
        echo vfio-pci > "/sys/bus/pci/devices/$dev/driver_override" 2>> "$LOG" || true
        echo "$dev" > /sys/bus/pci/drivers_probe 2>> "$LOG" || true
      done

      touch "$MARKER"
      log "prepare complete"

    elif [ "$HOOK_NAME" = "release" ] && [ "$STATE_NAME" = "end" ]; then
      if [ ! -e "$MARKER" ]; then
        log "release: prepare never completed, nothing to restore"
        exit 0
      fi
      rm -f "$MARKER"

      log "release starting"
      for dev in "${gpuVideoAddr}" "${gpuAudioAddr}"; do
        unbind "$dev"
        echo > "/sys/bus/pci/devices/$dev/driver_override" 2>> "$LOG" || true
      done

      modprobe -r vfio_pci vfio_pci_core vfio_iommu_type1 vfio 2>/dev/null || true

      # load amdgpu if needed, then re-probe BOTH functions explicitly --
      # modprobe alone is a no-op when the module is already loaded and would
      # leave the card with no driver at all.
      log "reloading amdgpu"
      modprobe amdgpu 2>> "$LOG"
      for dev in "${gpuVideoAddr}" "${gpuAudioAddr}"; do
        echo "$dev" > /sys/bus/pci/drivers_probe 2>> "$LOG" || true
      done
      sleep 2

      for dev in "${gpuVideoAddr}" "${gpuAudioAddr}"; do
        drv=$(readlink "/sys/bus/pci/devices/$dev/driver" 2>/dev/null)
        drv="''${drv##*/}"
        log "  $dev -> ''${drv:-UNBOUND}"
      done

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

    # IMPORTANT: editing the hook below is not enough on its own.
    # the symlink into /var/lib/libvirt/hooks/qemu.d/ is written by
    # libvirtd-config.service, a oneshot that only re-runs when libvirtd
    # starts -- and nixos marks libvirtd X-RestartIfChanged=false so a rebuild
    # won't restart it (that would kill running guests). so after any change
    # here:   sudo systemctl restart libvirtd
    # then confirm: readlink /var/lib/libvirt/hooks/qemu.d/passthrough
    hooks.qemu = {
      "passthrough" = hookScript;
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  # without this, virsh as a non-root user silently talks to qemu:///session,
  # where the win11 domain doesn't exist ("failed to get domain") and
  # capabilities are reported wrong. point it at the system connection.
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  # the guest boots off a sata disk, so no virtio driver iso is needed.
  environment.systemPackages = with pkgs; [
    virtiofsd
  ];
}
