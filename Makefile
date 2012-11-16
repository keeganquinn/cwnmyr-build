# Makefile: OpenWrt image generator for PTP nodes
# Copyright 2012 Personal Telco Project

devices := $(notdir $(wildcard device/*))

.PHONY: default clean prepare all $(devices)

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

	@# Symlink dl subdirectory, to avoid unneeded redownloading
	mkdir -p dl
	rm -rf openwrt/dl
	ln -s ../dl openwrt/dl

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

	@# Update the package index and install all packages, again, to be safe
	openwrt/scripts/feeds update -i
	openwrt/scripts/feeds install -a

all: $(devices)

define build
$(1): prepare device/$(1)/config
	@# Install and activate device-specific OpenWrt build configuration
	cp device/$(1)/config openwrt/.config
	(cd openwrt; make defconfig)
	cp openwrt/.config openwrt/files/config

	@# Perform build, triggering hook scripts as needed
	[ -x device/$(1)/prebuild ] && device/$(1)/prebuild
	(cd openwrt; make)
	[ -x device/$(1)/postbuild ] && device/$(1)/postbuild
endef   

$(foreach device, $(devices), $(eval $(call build,$(device))))
