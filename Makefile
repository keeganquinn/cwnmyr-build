# Makefile: OperWrt image generator for cwnmyr

devices := $(notdir $(wildcard device/*))

BUILDER := $(shell dirname "$(realpath $(lastword $(MAKEFILE_LIST)))")
OPENWRT ?= openwrt

.PHONY: default clean prepare all $(devices)

default: all

clean:
	rm -rf image

distclean: clean
	rm -rf "$(OPENWRT)"

fetch:
	@# Get the configurator
	@# TODO: point back to personaltelco repo after PR is merged
	[ -d "files" ] && \
		(cd "files"; git fetch -q origin) || \
		git clone -q \
		git://github.com/keeganquinn/ptp-openwrt-files.git \
		"files"
	(cd "files"; git checkout -q `cat "$(BUILDER)/rev/files"`)

	@# Make sure we have the correct OpenWrt tree
	[ -d "$(OPENWRT)" ] && \
		(cd "$(OPENWRT)"; git fetch -q origin) || \
		git clone -q https://git.openwrt.org/openwrt/openwrt.git \
		"$(OPENWRT)"
	(cd "$(OPENWRT)"; git checkout -q `cat "$(BUILDER)/rev/openwrt"`)

	@# Symlink dl subdirectory, to avoid unneeded redownloading
	mkdir -p dl
	rm -rf "$(OPENWRT)/dl"
	ln -s "$(BUILDER)/dl" "$(OPENWRT)/dl"

	mkdir -p "$(OPENWRT)/feeds"
	cp feeds.conf "$(OPENWRT)/feeds.conf"

prepare: fetch
	@# Make sure we have the right feeds trees. openwrt/scripts/feeds does
	@# not support retrieving a specific git revision, so we have to do
	@# this ourselves.
	cat feeds.conf | while read line; do \
		feed=`echo $$line | cut -f2 -d' ' -`; \
		url=`echo $$line | cut -f3 -d' ' - | cut -f1 -d';' -`; \
		[ -d "$(OPENWRT)/feeds/$$feed" ] && \
			(cd "$(OPENWRT)/feeds/$$feed"; \
				git remote set-url origin $$url; \
				git fetch -q origin) || \
			git clone -q $$url "$(OPENWRT)/feeds/$$feed"; \
		(cd "$(OPENWRT)/feeds/$$feed"; \
			git checkout -q `cat "$(BUILDER)/rev/$$feed"`); \
	done

	@# Update the package index and install all packages
	"$(OPENWRT)/scripts/feeds" update -i
	"$(OPENWRT)/scripts/feeds" install -a

	@# Ensure critical parts of the OpenWrt tree are clean before
	@# (re)populating them
	rm -rf "$(OPENWRT)/.config*" "$(OPENWRT)/bin" "$(OPENWRT)/files"

	@# Create output directory for images
	mkdir -p image

update: fetch
	(cd "files"; git checkout -q master; git pull -q origin master)
	(cd "files"; git rev-parse HEAD > "$(BUILDER)/rev/files")

	(cd "$(OPENWRT)"; git checkout -q master; git pull -q origin master)
	(cd "$(OPENWRT)"; git rev-parse HEAD > "$(BUILDER)/rev/openwrt")

	"$(OPENWRT)/scripts/feeds" update -i
	cat feeds.conf | while read line; do \
		feed=`echo $$line | cut -f2 -d' ' -`; \
		branch=`echo $$line | cut -f3 -d' ' - | cut -f2 -d';' -`; \
		(cd "$(OPENWRT)/feeds/$$feed"; \
			git checkout -q $$branch; \
			git pull -q origin $$branch); \
		(cd "$(OPENWRT)/feeds/$$feed"; \
			git rev-parse HEAD > "$(BUILDER)/rev/$$feed"); \
	done

	@# Update the package index and install all packages
	"$(OPENWRT)/scripts/feeds" update -i
	"$(OPENWRT)/scripts/feeds" install -a

all: $(devices)

define build
$(1): prepare device/$(1)/config
	@# Populate files tree
	cp -a files/output "$(OPENWRT)/files"
	mkdir -p "$(OPENWRT)/files/rev"
	git rev-parse HEAD > "$(OPENWRT)/files/rev/builder"
	cp rev/* "$(OPENWRT)/files/rev/"

	@# Install and activate device-specific OpenWrt build configuration
	cp "device/$(1)/config" "$(OPENWRT)/.config"
	(cd "$(OPENWRT)"; make defconfig)
	cp "$(OPENWRT)/.config" "$(OPENWRT)/files/config"

	@# Perform build, triggering hook scripts as needed
	[ -x "device/$(1)/prebuild" ] && \
		"device/$(1)/prebuild" "$(OPENWRT)" || true
	(cd "$(OPENWRT)"; \
		make BUILD_LOG=1 FORCE_UNSAFE_CONFIGURE=1 IGNORE_ERRORS=m V=99)
	[ -x "device/$(1)/postbuild" ] && \
		"device/$(1)/postbuild" "$(OPENWRT)" || true
endef

$(foreach device, $(devices), $(eval $(call build,$(device))))
