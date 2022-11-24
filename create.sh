#!/bin/bash

set -e

if [ $(id -u) -ne 0 ]; then
	echo "Must be root"
	exit 1
fi

IMG=mugenhwcfg-live-amd64.hybrid.img
SIZE=1024M

dd if=/dev/zero of=$IMG bs=1 count=0 seek=$SIZE
losetup -Pf $IMG
loop=$(losetup -l | grep $IMG | cut -f1 -d' ')

dd if=live-image-amd64.hybrid.iso of=$loop

fdisk $loop <<<$'n\np\n\n\n\nw'
mkfs.ext4 -L persistence ${loop}p3
mount ${loop}p3 /mnt

echo '/ union' >/mnt/persistence.conf
umount /mnt
losetup -d $loop

echo $IMG created
