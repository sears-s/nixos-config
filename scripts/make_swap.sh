#!/usr/bin/env bash
set -e
wipefs -af "$1"
parted -s "$1" \
  mklabel gpt \
  mkpart tmpswap linux-swap 1 100%
sleep 1
tmpswap=/dev/disk/by-partlabel/tmpswap
mkswap $tmpswap
swapon $tmpswap
mount -o "remount,size=$2,noatime" /nix/.rw-store
