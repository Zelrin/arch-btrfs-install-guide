# arch-btrfs-install-guide
This is an Arch UEFI installation guide with btrfs and snapper.
This guide doesn't contain all the information needed to install Arch.
It is meant to be used with the Arch installation guide on the Arch wiki, it only contains the diffrences for installing btrfs and snapper, and some other tips.
The btrfs and snapper setup is based on this guide from unicks.eu https://www.youtube.com/watch?v=TKdZiCTh3EM.
I recommend watching the video from unicks.eu, watching an Arch Linux installation tutorial.
My favorite Arch Linux UEFI installation tutorial was from Average Linux User(https://www.youtube.com/watch?v=dOXYZ8hKdmc)

This guide is meant to be used with the Arch installation guide on the Arch wiki. 

# Reminders: 
Double check what is the drives name you want to install on, it might not be /dev/sda.
You need to install the userspace utilities for the different filesystems(xfsprogs, btrfs-progs, dosfstools).
You can use ssh to connect to the computer you are installing Arch Linux on, so you can save time by copying the commands.

# Ssh 
I recommend connecting both of your devices to the same network because it will be much easier to connect with ssh to the computer you are installing Arch on. If you don't know what ssh is and how to connect from a different device
https://www.youtube.com/watch?v=qWKK_PNHnnA.

Setting up ssh on the Arch iso is the same regardless of which OS your second computer uses.

Install and enable shh on the Arch ISO:
```
pacman -Sy --needed openssh
systemctl enable sshd.service
```
To connect you have to find your ip address:
```
ip address
```
It will output something like this:
The first one is a loop, and it does not have the ip address.
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
```
This one is ethernet, in this example I am connected to Wi-Fi and ethernet is disabled, so it does not have the ip address. If you are connected with ethernet it will have more things under it like Wi-Fi.
```
2: enp7s0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 98:fa:9b:a0:b4:38 brd ff:ff:ff:ff:ff:ff
```    
The third one is Wi-Fi because it starts with wl(wireless lan)
The ip address(in brackets) is after inet. 
```
3: wlp0s20f3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 50:e0:85:c4:b6:1b brd ff:ff:ff:ff:ff:ff
    inet [192.158.7.113]/24 brd 192.168.8.255 scope global dynamic noprefixroute wlp0s20f3
       valid_lft 62454sec preferred_lft 62454sec
    inet6 fdd4:62da:c89b:4600:9cae:915f:9bd5:b2e5/64 scope global dynamic noprefixroute 
       valid_lft 7078sec preferred_lft 3478sec
    inet6 fq80::cvfc:3bb6:5994:36c4/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```
Also set a password on the Arch ISO, it is needed to be able to connect.
```
passwd
```

# Partitioning
The partition layout:
```
|EFI system partition (FAT32) | Label=EFI | /dev/your_drive1 | Suggested size is 512 MiB
Mountpoint:   /boot/efi  

Btrfs root partition | Label=ROOT | /dev/your_drive2 | Suggested size is 23-32 GiB
Subvolume:      @   @log        @tmp  @pkg                    @snapshots        |@home|
Mountpoint:     /   /var/log    /tmp  /var/cache/pacman/pkg   /.snapshots       |/home|

Opional XFS or ext4 home partition | Label=HOME | /dev/your_drive3 | rest of your free space                                              
Mountpoint:    /home

Optional Linux Swap | Label=Swap | /dev/your_drive4 | 2x times bigger than ram
```
Check what drives are available with lsblk:
```
lsblk
NAME        MAJ:MIN RM   SIZE 
sda           8:0    1  29.9G  
└─sda1        8:1    1  29.9G   
your_drive     259:0    0 953.9G  
```
Usually sda or sdb is your usb drive with the Arch ISO.
Probably the biggest drive will be your computers hard drive.

You can also find scripts with the most popular system configurations in the install-scripts directory, I don't recommend executing the scripts, the best way is to copy the commands one-by-one incase you need to change something inbetween the commands.

I think the easiest to use partitioner is cfdisk
```
# cfdisk -z /dev/your_drive
```
# Formatting
```
# mkfs.vfat -F 32 -n EFI /dev/your_drive1
# mkfs.btrfs -L ROOT /dev/your_drive2
```
If you have a separate home partition

```
# mkfs.xfs -L HOME /dev/your_drive3
```
Or
```
# mkfs.ext4 -L HOME /dev/your_drive3
```

If you have swap
```
# mkswap -L SWAP /dev/your_drive4
```
# Mounting
```
mount /dev/your_drive2 /mnt
cd /mkt
btrfs sub cr /mnt/@
btrfs sub cr /mnt/@tmp
btrfs sub cr /mnt/@log
btrfs sub cr /mnt/@pkg
btrfs sub cr /mnt/@snapshots
```
If you have one partition for root and home
```
btrfs sub cr /mnt/@home
```
```
cd..
umount /mnt
mount -o relatime,space_cache=v2,ssd,compress=lzo,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{boot/efi,home,var/log,var/cache/pacman/pkg,btrfs,tmp}
mount -o relatime,space_cache=v2,ssd,compress=lzo,subvol=@log /dev/sda2 /mnt/var/log
mount -o relatime,space_cache=v2,ssd,compress=lzo,subvol=@pkg /dev/sda2 /mnt/var/cache/pacman/pkg/
mount -o relatime,space_cache=v2,ssd,compress=lzo,subvol=@tmp /dev/sda2 /mnt/tmp
```
If you have one partition for root and home
```
mount -o relatime,space_cache=v2,ssd,compress=lzo,subvol=@home /dev/sda2 /mnt/home
```
```
mount -o relatime,space_cache=v2,ssd,compress=lzo,subvolid=5 /dev/sda2 /mnt/btrfs
mount /dev/your_drive1 /mnt/boot/efi/
```
If you have separate home partition
```
mount /dev/your_drive3 /mnt/home/
```
If you have swap
```
swapon /dev/your_drive4 
```
# fstab
In the fstab file you should remove the entry with the root partition with the mount point '/', because
the entry that is mounted at /btrfs, is the root partition (this is at least how I understood what unicks.eu said)

You need to remove this entry:
```
/dev/sda2 UUID=3edd5f74-69b7-4d64-b894-aa9f879ddf01
LABEL=ROOT              /               btrfs           rw,relatime,compress=lzo,ssd,space_cache=v2,subvolid=256,subvol=/@,subvol=@  

```

# GRUB
Thes are the commands for installing GRUB used in ALU's tutorial.
```
pacman --needed -Sy grub efibootmgr
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi 
grub-mkconfig -o /boot/grub/grub.cfg
mkdir /boot/efi/EFI/BOOT
cp /boot/efi/EFI/GRUB/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
```
To guarantee that GRUB boots, create a startup script (/boot/efi/startup.nsh) for GRUB with these contents(you can change the name):
```
bcf boot add 1 fs0:\EFI\GRUB\grubx64.efi "GRUB bootloader"
exit
```
You can now reboot.

# /tmp cleanup
This section was definitely not copied from https://github.com/egara/arch-btrfs-installation
Because of **/tmp** is another subvolume mounted as a traditional partition on */fstab*, temporary files won't be deleted by default when the system boots. This can cause some problems like preventing **insync** to start normally for example, because it uses a temporary file called *insync1000.sock* and if this file already exists, it won't run. In order to clean up */tmp* directory on every reboot, add this configuration file **/etc/tmpfiles.d/tmp.conf** with this content:

```
# Cleaning up /tmp directory everytime system boots
D! /tmp 1777 root root 0
```
# Snapper 
I suggest setting snapper up after you have a working system.

Install the required packages for snapper and btrfs:
```
pacman -S snapper grub-btrfs
```
Check your btrfs subvolumes:
```
btrfs sub list /
```
They should look something like this:
```
ID 256 gen 810 top level 5 path @
ID 257 gen 781 top level 5 path @tmp
ID 258 gen 810 top level 5 path @log
ID 259 gen 804 top level 5 path @pkg
ID 260 gen 10 top level 5 path @snapshots
ID 264 gen 34 top level 256 path var/lib/portables
ID 265 gen 35 top level 256 path var/lib/machines
```
Create a snapper config for root:
```
snapper -c root create-config /
```
Check your btrfs subvolumes:
```
btrfs sub list /
```
Now you have a new subvolume for snapshot but there is a problem because the subvolume is below the root subvolume, if you rollback with this configuration /.snapshots will disappear because it depends on the root subvolume.
```
ID 256 gen 810 top level 5 path @
ID 257 gen 781 top level 5 path @tmp
ID 258 gen 810 top level 5 path @log
ID 259 gen 804 top level 5 path @pkg
ID 260 gen 10 top level 5 path @snapshots
ID 264 gen 34 top level 256 path var/lib/portables
ID 265 gen 35 top level 256 path var/lib/machines
ID 267 gen 87 top level 257 path /.snapshots
```
To fix it you have to delete the /.snapshots subvolume and make the /.snapshots directory again
```
btrfs sub del /.snapshots/
mkdir /.snapshots
```
Now you have to mount the /.snapshots directory in /etc/fstab
```
nano -w /etc/fstab
```
Add this line to /etc/fstab(remember to put your drive instead of the example in the beginning)
```
/dev/your_drive2 	/.snapshots  		btrfs     	rw,relatime,compress=lzo,ssd,space_cache=v2,subvol=@snapshots	0 0
```
Mount /.snapshots:
```
mount /.snapshots/
```
Check if you have done it correctly with df -Th, it should look something like this:
```
df -Th 
Filesystem     Type      Size  Used Avail Use% Mounted on
dev            devtmpfs  3.9G     0  3.9G   0% /dev
run            tmpfs     3.9G  1.5M  3.9G   1% /run
/dev/nvme0n1p2 btrfs      32G  7.4G   25G  24% /
tmpfs          tmpfs     3.9G   70M  3.8G   2% /dev/shm
tmpfs          tmpfs     4.0M     0  4.0M   0% /sys/fs/cgroup
/dev/nvme0n1p2 btrfs      32G  7.4G   25G  24% /btrfs
/dev/nvme0n1p2 btrfs      32G  7.4G   25G  24% /tmp
/dev/nvme0n1p2 btrfs      32G  7.4G   25G  24% /var/cache/pacman/pkg
/dev/nvme0n1p2 btrfs      32G  7.4G   25G  24% /var/log
/dev/nvme0n1p1 vfat      511M  564K  511M   1% /boot/efi
/dev/nvme0n1p3 xfs       921G  144G  778G  16% /home
tmpfs          tmpfs     784M   72K  784M   1% /run/user/1000
/dev/nvme0n1p2 btrfs      32G  7.4G   25G  24% /.snapshots
```
To enable that snapshots show up in GRUB
Enable grub-btrfs.path to refresh the shapshot list
```
systemctl enable grub-btrfs.path
```
And enable the snapshot list in the GRUB config

```
nano /etc/default/grub
```
Set this option:
```
GRUB_DISABLE_RECOVERY=false
```
You can exit, now you only have to regenerate the config
```
grub-mkconfig -o /boot/grub/grub.cfg
```
# Snapper config
To enable pre-post pacman snapshots install snap-pac
```
pacman -S snap-pac
```
To enable boot snapshots enable snapper-boot.timer
```
systemctl enable snapper-boot.timer
```
You can also enable hourly snapshots and a limit to the number of shanpshots you want or other options in the snapper config
```
nano /etc/snapper/configs/root
```
To enable hourly snapshots and snapshot cleanup, you have to enable cronie
```
pacman -S --needed cronie
systemctl enable cron.service
```
