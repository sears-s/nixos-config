{
  config,
  lib,
  osConfig,
  pkgs,
  specialArgs,
  ...
}:
lib.mkIf specialArgs.hypervisor {
  # Set virt-manager connection
  dconf.settings."org/virt-manager/virt-manager/connections" = {
    autoconnect = [ "qemu:///system" ];
    uris = [ "qemu:///system" ];
  };
}
