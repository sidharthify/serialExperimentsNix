# nixos/services/gpu-passthrough.nix
# single gpu passthrough for windows 11

{ config, pkgs, lib, ... }:

let
  gpuVideoAddr   = "0000:01:00.0";
  gpuAudioAddr   = "0000:01:00.1";

  hookScript = pkgs.writeShellScript "qemu-hook" ''
    GUEST_NAME="$1"
    HOOK_NAME="$2"
    STATE_NAME="$3"

    if [ "$GUEST_NAME" != "win11" ]; then
      exit 0
    fi

    if [ "$HOOK_NAME" = "prepare" ] && [ "$STATE_NAME" = "begin" ]; then
      systemctl stop display-manager.service
      sleep 2

      # unbind vtconsoles
      for vtcon in /sys/class/vtconsole/vtcon*/bind; do
        echo 0 > "$vtcon" 2>/dev/null || true
      done

      # unbind efi framebuffer
      if [ -e /sys/bus/platform/drivers/efi-framebuffer/efi-framebuffer.0 ]; then
        echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind 2>/dev/null || true
      fi

      sleep 1

      # unload nvidia modules
      modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia 2>/dev/null || true
      sleep 1

      # unbind gpu from nvidia driver
      if [ -e /sys/bus/pci/devices/${gpuVideoAddr}/driver ]; then
        echo "${gpuVideoAddr}" > /sys/bus/pci/devices/${gpuVideoAddr}/driver/unbind
      fi
      if [ -e /sys/bus/pci/devices/${gpuAudioAddr}/driver ]; then
        echo "${gpuAudioAddr}" > /sys/bus/pci/devices/${gpuAudioAddr}/driver/unbind
      fi

      # bind to vfio
      modprobe vfio-pci
      echo "10de 2504" > /sys/bus/pci/drivers/vfio-pci/new_id 2>/dev/null || true
      echo "10de 228e" > /sys/bus/pci/drivers/vfio-pci/new_id 2>/dev/null || true

    elif [ "$HOOK_NAME" = "release" ] && [ "$STATE_NAME" = "end" ]; then
      # unbind from vfio
      if [ -e /sys/bus/pci/devices/${gpuVideoAddr}/driver ]; then
        echo "${gpuVideoAddr}" > /sys/bus/pci/devices/${gpuVideoAddr}/driver/unbind
      fi
      if [ -e /sys/bus/pci/devices/${gpuAudioAddr}/driver ]; then
        echo "${gpuAudioAddr}" > /sys/bus/pci/devices/${gpuAudioAddr}/driver/unbind
      fi

      echo "10de 2504" > /sys/bus/pci/drivers/vfio-pci/remove_id 2>/dev/null || true
      echo "10de 228e" > /sys/bus/pci/drivers/vfio-pci/remove_id 2>/dev/null || true

      modprobe -r vfio-pci vfio_iommu_type1 vfio 2>/dev/null || true

      # reload nvidia
      modprobe nvidia
      modprobe nvidia_modeset
      modprobe nvidia_uvm
      modprobe nvidia_drm

      sleep 1

      # rebind vtconsoles
      for vtcon in /sys/class/vtconsole/vtcon*/bind; do
        echo 1 > "$vtcon" 2>/dev/null || true
      done

      # rebind efi framebuffer
      if [ -d /sys/bus/platform/drivers/efi-framebuffer ]; then
        echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind 2>/dev/null || true
      fi

      sleep 1

      systemctl start display-manager.service
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
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
      runAsRoot = true;
    };
    hooks.qemu = {
      "passthrough" = hookScript;
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    looking-glass-client
    virtiofsd
  ];
}
