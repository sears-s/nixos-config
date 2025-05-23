# Nix Config

## Installation

Mount the minimal ISO. Escalate privileges:

```bash
sudo -i
```

Connect to WiFi if needed:

```bash
systemctl start wpa_supplicant
wpa_cli
add_network
set_network 0 ssid "{ssid}"
set_network 0 psk "{password}"
set_network 0 key_mgmt WPA-PSK
enable_network 0
quit
```

Set `root` password with `passwd` to continue installation over SSH. Clone this repository:

```bash
git clone https://github.com/sears-s/nixos-config.git
cd nixos-config
```

If RAM is less than 4GB, a temporary swap with an external disk may be needed:

```bash
./scripts/make_swap.sh <external_disk> 8G
```

Run the installer for the desired configuration:

```bash
./scripts/install.sh <hostname>
```

## Secure Boot

1. Disable secure boot in the BIOS
1. Disable the secure boot module in `flake.nix`
1. Boot into the ISO and follow the instructions above to install NixOS to the drive
1. Enable secure boot setup mode in the BIOS (may involve resetting secure boot)
1. Boot into NixOS and run `sudo ./scripts/secure_boot.sh`
1. Enable the secure boot module in `flake.nix`
1. Enable secure boot in the BIOS
1. Boot back into NixOS and verify secure boot is enabled with `sudo bootctl status`

## Commands

If getting a database error for `command-not-found`:

```bash
sudo nix-channel --update
```
