# arch-btrfs-install-guide
Arch Linux installation guide with btrfs and snapper for an UEFI system, this guide is based on the information from unicks.eu guide https://www.youtube.com/watch?v=TKdZiCTh3EM
This guide only covers the partitioning. I highly reccommend watching unicks.eu tutorial and checking if my scripts are correct because I am a Linux begginer and I am prone to typos.

The partition layout:
----------------------------------------
```
EFI system partition (ESP) | Label=EFI | /dev/sda1 | Suggested size is 260-512 MiB
Mountpoint:   /boot/efi  

/dev/sda2 ==> Label=ROOT ==> Btrfs
Btrfs root partition | Label=ROOT | /dev/sda | Suggested size is 23-32 GiB
Subvolume:      @   @log        @tmp  @pkg                    @snapshots                                            
Mountpoint:     /   /var/log    /tmp  /var/cache/pacman/pkg   /.snapshots

/dev/sda3 ==> Label=HOME ==> 
XFS home partition | Label=HOME | /dev/sda3                                               
Mountpoint    /home

Optional Linux Swap | Label=Swap | /dev/sda4 
```
Reminders: 
----------------------------------------

Double check what is the drives name you want to install on, it might not be /dev/sda.

You need to install the userspace utilities for the different filesystems(xfsprogs, btrfs-progs, dosfstools).

Partitioning
----------------------------------------
You need to partition your drive for yourself, but I for the formating, btrfs subvolume creation, partition and subvolume mounting you can use the scripts that I have made.

Partition your drive:                                               
cfdisk /dev/sda
                                                 
fstab
-----------------------------------------
In the fstab file you should remove the entry with the root partition with the mountpooint '/', because
the entry that is mounted at /btrfs, is the root partition (this is at least how I understood what unicks.eu said)

You need to remove this entry:
```
/dev/sda2 UUID=3edd5f74-69b7-4d64-b894-aa9f879ddf01
LABEL=ROOT              /               btrfs           rw,relatime,compress=lzo,ssd,space_cache=v2,subvolid=256,subvol=/@,subvol=@  >

```

GRUB
---------------------------------------
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
