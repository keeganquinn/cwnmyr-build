.PHONY: default clean prepare all mr3201a net4521 wgt634u

default: all

clean:
	rm -rf image

distclean: clean
	rm -rf openwrt

prepare:
# Make sure we have the correct openwrt tree
	[ -d openwrt ] && \
		(cd openwrt; git fetch origin) || \
		git clone git://nbd.name/openwrt.git openwrt
	(cd openwrt; git checkout `cat ../rev-openwrt`)

# Make sure we have the right feeds trees. openwrt/scripts/feeds doesn't
# support retrieving a specific git revision, so we have to do this ourselves.
	mkdir -p openwrt/feeds
	[ -d openwrt/feeds/packages ] && \
		(cd openwrt/feeds/packages; git fetch origin) || \
		git clone git://nbd.name/packages.git openwrt/feeds/packages
	(cd openwrt/feeds/packages; git checkout `cat ../../../rev-packages`)
	[ -d openwrt/feeds/ptpwrt ] && \
		(cd openwrt/feeds/ptpwrt; git fetch origin) || \
		git clone git://github.com/keeganquinn/ptpwrt-packages.git \
			openwrt/feeds/ptpwrt
	(cd openwrt/feeds/ptpwrt; git checkout `cat ../../../rev-ptpwrt`)

# Update the package index and install all packages
	cp feeds.conf openwrt/feeds.conf
	openwrt/scripts/feeds update -i
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
	(cd openwrt; make oldconfig)

# Tag build with configuration and revision information
	cp device/mr3201a.config openwrt/files/config
	echo -n "ptp-builder revision: " > openwrt/files/build
	git rev-parse HEAD >> openwrt/files/build
	echo -n "openwrt revision: " >> openwrt/files/build
	(cd openwrt; git rev-parse HEAD) >> openwrt/files/build

# Perform build
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
	(cd openwrt; make oldconfig)

# Tag build with configuration and revision information
	cp device/net4521.config openwrt/files/config
	echo -n "ptp-builder revision: " > openwrt/files/build
	git rev-parse HEAD >> openwrt/files/build
	echo -n "openwrt revision: " >> openwrt/files/build
	(cd openwrt; git rev-parse HEAD) >> openwrt/files/build

# Perform build
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
	(cd openwrt; make oldconfig)

# Tag build with configuration and revision information
	cp device/wgt634u.config openwrt/files/config
	echo -n "ptp-builder revision: " > openwrt/files/build
	git rev-parse HEAD >> openwrt/files/build
	echo -n "openwrt revision: " >> openwrt/files/build
	(cd openwrt; git rev-parse HEAD) >> openwrt/files/build

# Perform build
	(cd openwrt; make)

# Copy completed image to output directory
	cp openwrt/bin/brcm47xx/*-brcm47xx-squashfs.trx image/ptpwrt-wgt634u.trx
