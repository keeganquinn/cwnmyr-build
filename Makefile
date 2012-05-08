OPENWRT_GIT = git://nbd.name/openwrt.git

.PHONY: default clean prepare all mr3201a net4521 wgt634u

default: all

clean:
	rm -rf image

prepare:
	[ -d openwrt ] && (cd openwrt; git pull) || git clone $(OPENWRT_GIT)
	cp share/feeds.conf openwrt/feeds.conf
	openwrt/scripts/feeds update -a
	openwrt/scripts/feeds install -a
	mkdir -p image

all: mr3201a net4521 wgt634u

mr3201a: prepare device/mr3201a/config
	rm -rf openwrt/.config openwrt/.config.old openwrt/bin openwrt/files
	cp device/mr3201a/config openwrt/.config
	cp -r share/files openwrt/files
	cp -r device/mr3201a/files/* openwrt/files/
	(cd openwrt; make oldconfig)
	(cd openwrt; make)
	cp openwrt/bin/atheros/*-combined.squashfs.img image/ptpwrt-mr3201a.img

net4521: prepare device/net4521/config
	rm -rf openwrt/.config openwrt/.config.old openwrt/bin openwrt/files
	cp device/net4521/config openwrt/.config
	cp -r share/files openwrt/files
	cp -r device/net4521/files/* openwrt/files/
	(cd openwrt; make oldconfig)
	(cd openwrt; make)
	cp openwrt/bin/x86/*-combined-squashfs.img image/ptpwrt-net4521.img
	cp openwrt/bin/x86/*-combined-ext4.vdi image/ptpwrt-vbox.vdi

wgt634u: prepare device/wgt634u/config
	rm -rf openwrt/.config openwrt/.config.old openwrt/bin openwrt/files
	cp device/wgt634u/config openwrt/.config
	cp -r share/files openwrt/files
	cp -r device/wgt634u/files/* openwrt/files/
	(cd openwrt; make oldconfig)
	(cd openwrt; make)
	cp openwrt/bin/brcm47xx/*-wgt634u-squashfs.bin image/ptpwrt-wgt634u.img
