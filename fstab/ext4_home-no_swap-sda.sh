# See fstab(5) for details.

# <file system> <dir>                   <type>          <options>

                <dump> <pass>

/dev/sda1  /boot/efi               vfat            rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro       0 2

/dev/sda2  /.snapshots             btrfs           rw,relatime,compress=lzo,ssd,space_cache=v2,subvol=@snapshots 0 0

/dev/sda2  /var/log                btrfs           rw,relatime,compress=lzo,ssd,space_cache=v2,subvol=@log 0 0

/dev/sda2  /var/cache/pacman/pkg   btrfs           rw,relatime,compress=lzo,ssd,space_cache=v2,subvol=@pkg 0 0

/dev/sda2  /tmp                    btrfs           rw,relatime,compress=lzo,ssd,space_cache=v2,subvol=@tmp 0 0

/dev/sda2  /btrfs                  btrfs           rw,relatime,compress=lzo,ssd,space_cache=v2,subvolid=5,subvol=/ 0 0

/dev/sda3  /home                   ext4            rw,relatime     0 2
