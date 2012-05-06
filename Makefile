OPENWRT_GIT = git://nbd.name/openwrt.git

.PHONY: default prepare all net4521

default: all

prepare:
	[ -d openwrt ] && (cd openwrt; git pull) || git clone $(OPENWRT_GIT)
	cp share/feeds.conf openwrt/feeds.conf
	openwrt/scripts/feeds update -a
	openwrt/scripts/feeds install -a

all: net4521

net4521: prepare device/net4521/config
	rm -rf openwrt/.config openwrt/.config.old openwrt/bin openwrt/files
	cp device/net4521/config openwrt/.config
	cp -r share/files openwrt/files
	cp -r device/net4521/files/* openwrt/files/
	(cd openwrt; make oldconfig)
	(cd openwrt; make)
	mkdir -p image
	cp openwrt/bin/x86/*-combined-squashfs.img image/ptpwrt-net4521.img
