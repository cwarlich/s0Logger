s0Logger
========

S0 Zähler-Pulse loggen und darstellen.

Installation:
On host:
1) Installation von RaspbianMini aud /dev/sdb: sudo make prepare
5) mount /dev/sdb2 /mnt
6) echo {kermit | roth1 | roth2} > /mnt/etc/hostname
7) umount /mnt
On target:
1) make
2) make install
3) reboot
