# arch-btrfs-install-guide
Arch Linux installation guide with btrfs and snapper for an UEFI system, this guide is based on the information from unicks.eu guide https://www.youtube.com/watch?v=TKdZiCTh3EM
This guide only covers the partitioning. I highly reccommend watching unicks.eu tutorial and checking if my scripts are correct because I am a Linux begginer and I am prone to typos.

The partition layout:
----------------------------------------

EFI system partition (ESP) | Label=EFI | /dev/sda1 | Suggested size is 260-512 MiB
Mountpoint:   /boot/efi  

/dev/sda2 ==> Label=ROOT ==> Btrfs
Btrfs root partition | Label=ROOT | /dev/sda | Suggested size is 23-32 GiB
Subvolume:      @   @log        @pkg                    @snapshots                                            
Mountpoint:     /   /var/log    /var/cache/pacman/pkg   /.snapshots

/dev/sda3 ==> Label=HOME ==> 
XFS home partition | Label=HOME | /dev/sda3                                               
Mountpoint    /home

Optional Linux Swap | Label=Swap | /dev/sda4 

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

When you generate the fstab file it probably will look something like this:
Static information about the filesystems.
See fstab(5) for details.

<file system> <dir> <type> <options> <dump> <pass>
/dev/sda2 UUID=3edd5f74-69b7-4d64-b894-aa9f879ddf01
LABEL=ROOT              /               btrfs           rw,relatime,compress=lzo,ssd,space_cache=v2,subvolid=256,subvol=/@,subvol=@  >

/dev/sda1 UUID=CCE5-B022
LABEL=EFI               /boot/efi       vfat            rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=>

/dev/sda2 UUID=3edd5f74-69b7-4d64-b894-aa9f879ddf01
LABEL=ROOT              /var/log        btrfs           rw,relatime,compress=lzo,ssd,space_cache=v2,subvolid=258,subvol=/@log,subvol=>

/dev/sda2 UUID=3edd5f74-69b7-4d64-b894-aa9f879ddf01
LABEL=ROOT              /var/cache/pacman/pkg   btrfs           rw,relatime,compress=lzo,ssd,space_cache=v2,subvolid=259,subvol=/@pkg>

/dev/sda2 UUID=3edd5f74-69b7-4d64-b894-aa9f879ddf01
LABEL=ROOT              /btrfs          btrfs           rw,relatime,compress=lzo,ssd,space_cache=v2,subvolid=5,subvol=/ 0 0

/dev/sda3 UUID=7f7073bb-4862-44c2-a5cb-0b4f30c44280
LABEL=HOME              /home           xfs             rw,relatime,attr2,inode64,logbufs=8,logbsize=32k,noquota        0 2

/dev/sda4 UUID=cfd09601-0310-40c5-a0d1-99d8bfdcae8c
LABEL=SWAP              none            swap            defaults        0 0

But you should edit it so it looks like this:
-----------------------------------------

Static information about the filesystems.
See fstab(5) for details.

/dev/sda1 UUID=CCE5-B022
LABEL=EFI               /boot/efi       vfat            rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=>

/dev/sda2 UUID=3edd5f74-69b7-4d64-b894-aa9f879ddf01                         
LABEL=ROOT              /var/log        btrfs                                                               rw,relatime,compress=lzo,ssd,space_cache=v2,subvolid=258,subvol=/@log,subvol=>                                          

/dev/sda2 UUID=3edd5f74-69b7-4d64-b894-aa9f879ddf01                                             
LABEL=ROOT              /var/cache/pacman/pkg   btrfs                                                             rw,relatime,compress=lzo,ssd,space_cache=v2,subvolid=259,subvol=/@pkg>                                    

/dev/sda2 UUID=3edd5f74-69b7-4d64-b894-aa9f879ddf01                                                           
LABEL=ROOT              /btrfs          btrfs           rw,relatime,compress=lzo,ssd,space_cache=v2,subvolid=5,subvol=/ 0 0

/dev/sda3 UUID=7f7073bb-4862-44c2-a5cb-0b4f30c44280                                                 
LABEL=HOME              /home           xfs             rw,relatime,attr2,inode64,logbufs=8,logbsize=32k,noquota        0 2

/dev/sda4 UUID=cfd09601-0310-40c5-a0d1-99d8bfdcae8c                                               
LABEL=SWAP              none            swap            defaults        0 0



To install GRUB you just need this command because the /boot/efi directory already exists.
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
