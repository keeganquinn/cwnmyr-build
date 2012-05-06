OPENWRT_GIT = git://nbd.name/openwrt.git

.PHONY: default prepare all net4521

default: all

prepare:
	[ -d openwrt ] && (cd openwrt; git pull) || git clone $(OPENWRT_GIT)
	cp share/feeds.conf openwrt/feeds.conf
	openwrt/scripts/feeds update -a
	openwrt/scripts/feeds install -a

all: net4521

net4521: prepare devices/net4521/config
	rm -rf openwrt/.config openwrt/.config.old openwrt/files
	cp devices/net4521/config openwrt/.config
	cp -r share/files openwrt/files
	cp -r devices/net4521/files/* openwrt/files/
	(cd openwrt; make oldconfig)
