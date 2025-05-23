#! /usr/bin/env nix-shell
#! nix-shell -i bash -p sbctl
# TODO: stick with /var/lib/sbctl once sbctl is updated
set -e
sbctl create-keys
cp -ar /etc/secureboot /var/lib/sbctl
sbctl enroll-keys --microsoft
rm -rf /etc/secureboot
