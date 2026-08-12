# nixos/services/libvirt.nix
# plain libvirt/qemu-kvm for ordinary vms. also virtualbox cuz why not?

{ config, pkgs, lib, ... }:

{
  virtualisation.libvirtd = {
    enable = true;

    onBoot = "ignore";
    onShutdown = "shutdown";

    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

   virtualisation.virtualbox.host.enable = true;
   users.extraGroups.vboxusers.members = [ "sidharthify" ];

  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";
}
