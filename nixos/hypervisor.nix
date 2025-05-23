{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf specialArgs.hypervisor {
  # Enable client (virt-manager)
  programs.virt-manager.enable = true;

  # Enable libvirt
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  # Autostart default libvirt network
  systemd.services.libvirtd.serviceConfig.ExecStartPost =
    "${lib.getExe' pkgs.libvirt "virsh"} net-autostart default";
}
