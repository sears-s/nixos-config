{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
{
  # Kernel modules from hardware scan
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
      # TODO: ensure external monitor used in boot process
    ];
    kernelModules = [ "kvm-intel" ];
  };

  hardware = {
    # Disable Bluetooth
    bluetooth.enable = lib.mkForce false;

    # CPU microcode
    cpu.intel.updateMicrocode = true;

    # Nvidia driver
    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # Add local NTP servers
  networking.timeServers = lib.mkBefore [
    "ARGOS-DC-1.argos.net"
    "ARGOS-DC-2.argos.net"
  ];

  services = {
    # Can't use here
    dnscrypt-proxy2.enable = lib.mkForce false;

    # Need resolved for WireGuard
    resolved.enable = true;

    # Load Nvidia driver to Xorg and Wayland
    xserver.videoDrivers = [ "nvidia" ];
  };
}
