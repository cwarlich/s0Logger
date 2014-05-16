s0Logger
========

S0 Zähler-Pulse loggen und darstellen.

Installation:
On host:
1) sudo bash -c "~/Dropbox/Source/mini_s0Logger.img.gz | dd of=/dev/sdb bs=1"
2) sudo fdisk /deb/sdb d 2 n p 2 w q
3) e2fsck -f /dev/sdb2
4) resize2fs /dev/sdb2
5) mount /dev/sdb2 /mnt
6) echo {kermit | roth1 | roth2} > /mnt/etc/hostname
7) umount /mnt
On target:
1) make
2) make install
