echo ""
echo "Welcome to the non-official Alpine Linux (armhf and aarch64) for Raspberry Pi automatic installation."
echo "								By evilrawman."
echo ""

# general setup
echo "http://nl.alpinelinux.org/alpine/v3.8/main" >> /etc/fstab
echo "http://nl.alpinelinux.org/alpine/v3.8/community" >> /etc/fstab
echo "First, you need to custom your system properties manually before beginning: "
setup-alpine
echo "	Well done!"

echo ""

# general update
echo "	Upgrading system..."
apk update
apk upgrade
lbu commit -d
echo "	Done!"

echo ""

# time update
echo "	Setting NTP daemon and clock.."
rc-update add swclock boot
rc-update del hwclock boot
setup-ntp
lbu commit -d
echo "	Done!"

echo ""

# xfce4 install
echo -n "	Would you like to install xfce4? [y/n]: "
read xia
if [ "$xia" = "y" ]
then
	setup-xorg-base ​apk add xf86-video-fbdev xf86-video-vesa xf86-input-mouse xf86-input-keyboard dbus ​set​xkbmap kbd
	rc-update ​​add dbus
	apk add xfce4
	lbu_commit -d
fi

# loopback image with overlayfs
echo "	Making the sd-card writable..."
mount /media/mmcblk0p1 -o rw,remount
echo "	Done!"

echo ""

echo "	Changing fstab to always mount as writeable..."
sed -i '$ d' /etc/fstab
echo "/dev/mmcblk0p1 /media/mmcblk0p1 vfat rw,relatime,fmask=0022,dmask=0022,errors=remount-ro 0 0
echo "	Done!"

echo ""

echo "	Creating 1 GB loop-back file, this may take a time..."
dd if=/dev/zero of=/media/mmcblk0p1/persist.img bs=1024 count=0 seek=1048576
echo "	Done!"

echo ""

echo "	Downloading ext utilities..."
apk add e2fsprogs
echo "	Done!"

echo ""

echo "	Formating the loop-back file..."
mkfs.ext4 /media/mmcblk0p1/persist.img
echo "	Done!"

echo ""

echo "	Mounting the storage..."
echo "/media/mmcblk0p1/persist.img /media/persist ext4 rw,relatime,errors=remount-ro 0 0" >> /etc/fstab
mkdir /media/persist 
mount -a
echo "	Done!"

echo ""

echo "	Making overlay folders..."
mkdir /media/persist/usr
mkdir /media/persist/.work
echo "overlay /usr overlay lowerdir=/usr,upperdir=/media/persist/usr,workdir=/media/persist/.work 0 0" >> /etc/fstab
mount -a
echo "	Done!"
lbu_commit -d
