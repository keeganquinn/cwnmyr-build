# Makefile: OpenWrt image generator for PTP nodes
# Copyright 2012 Personal Telco Project

DEVICES := alix2 atheros net45xx wgt634u

.PHONY: default clean distclean prepare update all $(DEVICES)

default: all

clean:
	rm -rf image

distclean: clean
	rm -rf openwrt

prepare:
	@# Make sure we have the correct openwrt tree
	[ -d openwrt ] && \
		(cd openwrt; git fetch origin) || \
		git clone git://nbd.name/openwrt.git openwrt
	(cd openwrt; git checkout `cat ../rev-openwrt`)

	@# Make sure we have the right feeds trees. openwrt/scripts/feeds does
	@# not support retrieving a specific git revision, so we have to do
	@# this ourselves.
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

	@# Update the package index and install all packages
	cp feeds.conf openwrt/feeds.conf
	openwrt/scripts/feeds update -i
	openwrt/scripts/feeds install -a

	@# Ensure critical parts of openwrt tree are clean before
	@# (re)populating them
	rm -rf openwrt/.config openwrt/.config.old openwrt/bin openwrt/files

	@# Create output directory for images
	mkdir -p image

	@# Populate files tree
	cp -r files openwrt/files
	git rev-parse HEAD > openwrt/files/rev-builder
	cp rev-openwrt rev-packages rev-ptpwrt openwrt/files/

update: prepare
	(cd openwrt; git checkout master; git pull origin master)
	(cd openwrt; git rev-parse HEAD > ../rev-openwrt)

	(cd openwrt/feeds/packages; git checkout master; git pull origin master)
	(cd openwrt/feeds/packages; git rev-parse HEAD > ../../../rev-packages)

	(cd openwrt/feeds/ptpwrt; git checkout master; git pull origin master)
	(cd openwrt/feeds/ptpwrt; git rev-parse HEAD > ../../../rev-ptpwrt)

	cp rev-openwrt rev-packages rev-ptpwrt openwrt/files/

	@# Update the package index and install all packages, again
	openwrt/scripts/feeds update -i
	openwrt/scripts/feeds install -a

all: $(DEVICES)

alix2: prepare device/alix2.config
	@# Install device build and runtime configuration into openwrt tree
	cp device/alix2.config openwrt/.config
	cp device/alix2.config openwrt/files/config-template
	cp openwrt/files/etc/config/network.ok openwrt/files/etc/config/network
	(cd openwrt; make defconfig)
	cp openwrt/.config openwrt/files/config-final

	@# Perform build
	(cd openwrt; make)

	@# Copy completed image to output directory
	cp openwrt/bin/x86/*-combined-squashfs.img image/ptpwrt-alix2.img

atheros: prepare device/atheros.config
	@# Install device build and runtime configuration into openwrt tree
	cp device/atheros.config openwrt/.config
	cp device/atheros.config openwrt/files/config-template
	cp openwrt/files/etc/config/network.ok openwrt/files/etc/config/network
	(cd openwrt; make defconfig)
	cp openwrt/.config openwrt/files/config-final

	@# Perform build
	(cd openwrt; make)

	@# Copy completed image to output directory
	cp openwrt/bin/atheros/*-combined.squashfs.img image/ptpwrt-atheros.img

net45xx: prepare device/net45xx.config
	@# Install device build and runtime configuration into openwrt tree
	cp device/net45xx.config openwrt/.config
	cp device/net45xx.config openwrt/files/config-template
	cp openwrt/files/etc/config/network.ok openwrt/files/etc/config/network
	(cd openwrt; make defconfig)
	cp openwrt/.config openwrt/files/config-final

	@# Perform build
	(cd openwrt; make)

	@# Copy completed image to output directory
	cp openwrt/bin/x86/*-combined-squashfs.img image/ptpwrt-net45xx.img

	@# Copy VirtualBox image to output directory
	@# (we are sneaking this into the net45xx target just because we can)
	cp openwrt/bin/x86/*-combined-ext4.vdi image/ptpwrt-vbox.vdi

wgt634u: prepare device/wgt634u.config
	@# Install device build and runtime configuration into openwrt tree
	cp device/wgt634u.config openwrt/.config
	cp device/wgt634u.config openwrt/files/config-template
	cp openwrt/files/etc/config/network.sw openwrt/files/etc/config/network
	(cd openwrt; make defconfig)
	cp openwrt/.config openwrt/files/config-final

	@# Perform build
	(cd openwrt; make)

	@# Copy completed image to output directory
	cp openwrt/bin/brcm47xx/*-brcm47xx-squashfs.trx image/ptpwrt-wgt634u.trx

