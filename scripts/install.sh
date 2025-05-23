#! /usr/bin/env nix-shell
#! nix-shell -i bash -p disko
set -e

# Partition and mount
disko --mode disko --flake .#$1

# Create user password file
hp=/mnt/persist/hashedPassword
mkpasswd -m sha512crypt > $hp
chmod 600 $hp

# Install NixOS
nixos-install --no-channel-copy --no-root-password --flake .#$1
