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

  # Add NTP servers
  networking.timeServers = lib.mkBefore [
    "10.50.1.10"
    "10.50.1.11"
    "10.50.1.12"
  ];

  services = {
    # No automatic timezone
    automatic-timezoned.enable = lib.mkForce false;

    # Can't use here
    dnscrypt-proxy2.enable = lib.mkForce false;

    # Need resolved for WireGuard
    resolved.enable = true;

    # Load Nvidia driver to Xorg and Wayland
    xserver.videoDrivers = [ "nvidia" ];
  };

  # Force timezone to Central
  time.timeZone = lib.mkForce "US/Central";
}
