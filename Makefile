OPENWRT_GIT = git://nbd.name/openwrt.git

.PHONY: default clean prepare all mr3201a net4521 wgt634u

default: all

clean:
	rm -rf image

prepare:
# Make sure we have a current openwrt tree
	[ -d openwrt ] && (cd openwrt; git pull) || git clone $(OPENWRT_GIT)

# Install all packages from our feeds
	cp feeds.conf openwrt/feeds.conf
	openwrt/scripts/feeds update -a
	openwrt/scripts/feeds install -a

# Create output directory for images
	mkdir -p image

all: mr3201a net4521 wgt634u

mr3201a: prepare device/mr3201a.config
# Ensure critical parts of openwrt tree are clean before (re)populating them
	rm -rf openwrt/.config openwrt/.config.old openwrt/bin openwrt/files

# Install device build and runtime configuration into openwrt tree
	cp device/mr3201a.config openwrt/.config
	cp -r files openwrt/files
	rm -f openwrt/files/etc/config/network.sw

# Tag build with configuration and revision information
	cp device/mr3201a.config openwrt/files/config
	echo -n "ptp-builder revision: " > openwrt/files/build
	git rev-parse HEAD >> openwrt/files/build
	echo -n "openwrt revision: " >> openwrt/files/build
	(cd openwrt; git rev-parse HEAD) >> openwrt/files/build

# Activate build configuration and build
	(cd openwrt; make oldconfig)
	(cd openwrt; make)

# Copy completed image to output directory
	cp openwrt/bin/atheros/*-combined.squashfs.img image/ptpwrt-mr3201a.img

net4521: prepare device/net4521.config
# Ensure critical parts of openwrt tree are clean before (re)populating them
	rm -rf openwrt/.config openwrt/.config.old openwrt/bin openwrt/files

# Install device build and runtime configuration into openwrt tree
	cp device/net4521.config openwrt/.config
	cp -r files openwrt/files
	rm -f openwrt/files/etc/config/network.sw

# Tag build with configuration and revision information
	cp device/net4521.config openwrt/files/config
	echo -n "ptp-builder revision: " > openwrt/files/build
	git rev-parse HEAD >> openwrt/files/build
	echo -n "openwrt revision: " >> openwrt/files/build
	(cd openwrt; git rev-parse HEAD) >> openwrt/files/build

# Activate build configuration and build
	(cd openwrt; make oldconfig)
	(cd openwrt; make)

# Copy completed image to output directory
	cp openwrt/bin/x86/*-combined-squashfs.img image/ptpwrt-net4521.img

# Copy VirtualBox image to output directory
# (we're sneaking this into the net4521 target just because we can)
	cp openwrt/bin/x86/*-combined-ext4.vdi image/ptpwrt-vbox.vdi

wgt634u: prepare device/wgt634u.config
# Ensure critical parts of openwrt tree are clean before (re)populating them
	rm -rf openwrt/.config openwrt/.config.old openwrt/bin openwrt/files

# Install device build and runtime configuration into openwrt tree
	cp device/wgt634u.config openwrt/.config
	cp -r files openwrt/files
	mv openwrt/files/etc/config/network.sw openwrt/files/etc/config/network

# Tag build with configuration and revision information
	cp device/wgt634u.config openwrt/files/config
	echo -n "ptp-builder revision: " > openwrt/files/build
	git rev-parse HEAD >> openwrt/files/build
	echo -n "openwrt revision: " >> openwrt/files/build
	(cd openwrt; git rev-parse HEAD) >> openwrt/files/build

# Activate build configuration and build
	(cd openwrt; make oldconfig)
	(cd openwrt; make)

# Copy completed image to output directory
	cp openwrt/bin/brcm47xx/*-brcm47xx-squashfs.trx image/ptpwrt-wgt634u.trx
