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
    libvirtd = {
      enable = true;
      qemu = {
        # Makes rebuilding longer since OVMF needs to be compiled
        # Also breaks VMs on update: https://github.com/NixOS/nixpkgs/issues/378894
        /*
          ovmf.packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        */
        # To only emulate host arch:
        # package = pkgs.qemu_kvm;
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  # Autostart default libvirt network
  systemd.services.libvirtd.serviceConfig.ExecStartPost =
    "${lib.getExe' pkgs.libvirt "virsh"} net-autostart default";
}
