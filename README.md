# mugenhwcfg-live

This repository contains tooling to build a [Debian Live](https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html) system, which can be used to run the `mugenhwcfg` [tool](https://git.codelabs.ch/?p=muen/mugenhwcfg.git) and others in an automated fashion.

When booted, the live system will automatically run several tools to collect hardware information and topology.
The generated output will be stored in the `/home/user/mugenhwcfg/` directory.

To build the ISO image on a Debian 11.x (bullseye) system with `live-build` installed, clone this repository and run:

```
sudo lb build
```

Then run the ISO image under KVM/QEMU, it is sufficient to pass it to your desired `qemu` invocation using `-cdrom`.

To boot on real hardware it is sufficient to just dump the ISO image to an USB stick.

Development of this tooling is sponsored by [Nitrokey GmbH](https://nitrokey.com).

## Persistence

The USB stick is `sdb` in the following example (run as root or sudo):

```
dd if=live-image-amd64.hybrid.iso of=/dev/sdb bs=8M
fdisk /dev/sdb <<<$'n\np\n\n\n\nw'
mkfs.ext4 -L persistence /dev/sdb3
mount /dev/sdb3 /mnt
echo '/ union' >/mnt/persistence.conf
umount /mnt
```

Data created during system runtime, e.g. below `/home/user`, is located in the `sdb3/rw/home/user/` folder.
