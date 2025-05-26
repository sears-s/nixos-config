#! /usr/bin/env nix-shell
#! nix-shell -i bash -p sbctl
# shellcheck shell=bash
set -e

# Keys created in /var/lib/sbctl
sbctl create-keys
sbctl enroll-keys --microsoft
