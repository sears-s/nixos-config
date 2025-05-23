{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf specialArgs.hypervisor {
  # Set virt-manager settings
  dconf.settings =
    let
      path = "org/virt-manager/virt-manager";
    in
    {
      "${path}".xmleditor-enabled = true;
      "${path}/console".resize-guest = 1;
      "${path}/new-vm" = {
        cpu-default = "host-passthrough";
        firmware = "uefi";
        graphics-type = "spice";
        storage-format = "qcow2";
      };
    };

  # Install winapps
  home.packages = [ specialArgs.inputs.winapps.packages."${specialArgs.system}".winapps ];

  # Configure winapps
  xdg.configFile."winapps/winapps.conf".text = ''
    RDP_USER="admin"
    RDP_PASS="admin"
    WAFLAVOR="libvirt"
    RDP_SCALE="100"
  '';
}
