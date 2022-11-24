#!/bin/bash

OUT_DIR=/home/user/mugenhwcfg
MUGENHWCFG_SRC_DIR=/opt/mugenhwcfg

PRODUCT_NAME=$(dmidecode -t 1 | grep "Product Name" | cut -d ':' -f 2)
PRODUCT_NAME=$(dmidecode -t 1 | grep "Product Name" | cut -d ':' -f 2)
if [[ -z "${PRODUCT_NAME// }" ]]
then
    MODEL_NAME="unknown"
else
    MODEL_NAME=$(echo "${PRODUCT_NAME}" | sed -r 's/^[[:space:]]*//' | sed -r 's/[[:space:]]/_/g')
fi

DATE=$(date '+%Y%m%d-%H%M')

TARGET=${DATE}-${MODEL_NAME}

mkdir -p "$OUT_DIR/$TARGET"
cd "$OUT_DIR/$TARGET"

echo "Collecting hardware information ..."

(
cat /proc/cpuinfo > cpuinfo
cat /proc/interrupts > interrupts
cat /proc/iomem > iomem
cat /proc/ioports > ioports
acpidump > acpidump
dmidecode > dmidecode
dmesg -s2097152 > dmesg
lsusb > lsusb
lsusb -v > lsusb-v
lspci -vvvnn > lspci
lspci -t -vnn > lspci.tree
lshw -xml -sanitize -numeric > lshw

/opt/vmxcap > vmxcap
/opt/xhci_ext_caps /sys/devices/pci0000\:00/0000\:00\:14.0/resource0 > xhci

(
cd $MUGENHWCFG_SRC_DIR
./mugenhwcfg.py >$OUT_DIR/$TARGET/mugenhwcfg.log 2>&1
mv output.xml $OUT_DIR/$TARGET/
)

insmod /opt/chipsec.ko >chipsec 2>&1
/opt/chipsec/chipsec_main.py >chipsec 2>&1
) 2>> stderr

cd $OUT_DIR

tar cfJ $TARGET.tar.xz $TARGET

echo "Output written to $OUT_DIR/$TARGET.tar.xz"
cd /
sleep 6

if grep -q headless /proc/cmdline
then
	echo "Done -- shut down"
	sync
	/sbin/init 0
fi
