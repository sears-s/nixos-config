{ config, lib, pkgs, specialArgs, modulesPath, ... }: {
  # If lib.mkIf is used, imports isn't recognized
  imports = lib.optionals specialArgs.vm [
    # Enable QEMU guest kernel modules
    (modulesPath + "/profiles/qemu-guest.nix")
    {

      # Kernel modules from hardware scan
      boot = {
        initrd.availableKernelModules = [
          "uhci_hcd"
          "ehci_pci"
          "ahci"
          "virtio_pci"
          "virtio_scsi"
          "sd_mod"
          "sr_mod"
        ];
        kernelModules = [ "kvm-intel" ];
      };

      # Enable VM-specific options
      services = {
        spice-vdagentd.enable = true;
        qemuGuest.enable = true;
      };
    }
  ];
}
