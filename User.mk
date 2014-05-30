DerivedDirectory=derived
Prerequisites=counter tools

# Map host names to logger configuration.
kermit=Haselhang+ Haselhang-
roth1=Roth1
roth2=Roth2

conf=$(addsuffix .conf,$(addprefix /etc/s0Logger.d/,$($(shell hostname))))
$(foreach i,\
          $($(shell hostname)),\
          $(eval /etc/s0Logger.d/$i.conf: $(SourceDirectory)/devices/$i/s0Logger.conf | /etc/s0Logger.d /var/log/s0Logger;\
          	cp $$< $$@)\
)
vtun: /etc/vtund.conf /etc/default/vtun
/etc/vtund.conf: $(SourceDirectory)/contrib/vtund.conf.$(shell hostname); cp $< $@
/etc/default/vtun: $(SourceDirectory)/contrib/vtun.$(shell hostname); cp $< $@

dest=/usr/local/bin
prepare:
	@read -p "All data on /dev/sdb will be deleted! Press y if this is ok. " yes; \
	if [ "$$yes" != "y" ]; then echo Nothing done.; false; fi
	xz -dc ~christof/Dropbox/s0Logger/mini_s0Logger.mbr.xz | dd of=/dev/sdb
	mkfs.vfat /dev/sdb1
	mkfs.ext4 /dev/sdb2
	mount /dev/sdb1 /mnt
	tar -C /mnt -xf ~christof/Dropbox/s0Logger/mini_s0Logger.sdb1.txz
	umount /mnt
	mount /dev/sdb2 /mnt
	tar -C /mnt -xf ~christof/Dropbox/s0Logger/mini_s0Logger.sdb2.txz
	git clone file://`pwd` /mnt/root/git/s0Logger
	cd /mnt/root/git/s0Logger && git config --local remote.origin.url https://github.com/cwarlich/s0Logger
	umount /mnt
	echo -e "d\n2\nn\n\n\n\n\nw" | fdisk /dev/sdb
install: $(addprefix $(dest)/,counter buffer sender s0Logger reboot.exp) /etc/init.d/s0Logger.sh /etc/logrotate.d/s0Logger $(conf) vtun
	update-rc.d s0Logger.sh defaults 90 10
	#apt-get install -y curl
$(dest)/counter: $(DerivedDirectory)/counter | /usr/local/bin ; cp $< $@
$(dest)/buffer: $(DerivedDirectory)/buffer | /usr/local/bin ; cp $< $@
$(dest)/sender: $(SourceDirectory)/tools/sender | /usr/local/bin ; cp $< $@
$(dest)/reboot.exp: $(SourceDirectory)/tools/reboot.exp | /usr/local/bin ; cp $< $@
$(dest)/s0Logger: $(SourceDirectory)/tools/s0Logger | /usr/local/bin ; cp $< $@
/etc/init.d/s0Logger.sh: $(SourceDirectory)/tools/s0Logger.sh ; cp $< $@
/etc/logrotate.d/s0Logger: $(SourceDirectory)/tools/logrotate.conf ; cp $< $@
/usr/local/bin: ; mkdir -p $@
/etc/s0Logger.d: ; mkdir -p $@
/var/log/s0Logger: ; mkdir -p $@

uninstall:
	rm -rf /var/log/s0Logger /etc/s0Logger.d /etc/logrotate.d/soLogger /etc/init.d/s0Logger.sh $(addprefix $(dest)/,counter buffer sender s0Logger)
