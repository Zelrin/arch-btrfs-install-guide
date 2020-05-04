#!/bin/sh
mkfs.vfat -F 32 -n EFI /dev/sda1
mkfs.btrfs -L ROOT /dev/sda2
mount /dev/sda2 /mnt
btrfs sub cr /mnt/@
btrfs sub cr /mnt/@log
btrfs sub cr /mnt/@pkg
btrfs sub cr /mnt/@snapshots
btrfs sub cr /mnt/@home
umount /mnt
mount -o relatime,space_cache=v2,ssd,compress=lzo,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{boot/efi,home,var/log,var/cache/pacman/pkg,btrfs}
mount -o relatime,space_cache=v2,ssd,compress=lzo,subvol=@log /dev/sda2 /mnt/var/log
mount -o relatime,space_cache=v2,ssd,compress=lzo,subvol=@pkg /dev/sda2 /mnt/var/cache/pacman/pkg/
mount -o relatime,space_cache=v2,ssd,compress=lzo,subvolid=5 /dev/sda2 /mnt/btrfs
mount -o relatime,space_cache=v2,ssd,compress=lzo,subvol=@home/dev/sda2 /mnt/home/
mount /dev/sda1 /mnt/boot/efi/
