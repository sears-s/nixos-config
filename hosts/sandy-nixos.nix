{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
{
  # Kernel modules and update microcode from hardware scan
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "i915" # ensure external monitor used in boot process
    ];
    kernelModules = [ "kvm-intel" ];
  };
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Tailscale client
  services.tailscale.enable = true;
}
