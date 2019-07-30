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

	@# Create or link build directory
	[ -n "$(BUILD)" ] && mkdir -p "$(BUILD)" || true
	[ -n "$(BUILD)" -a ! -e "$(OPENWRT)/build_dir" ] && \
		ln -s "$(BUILD)" "$(OPENWRT)/build_dir" || true

	mkdir -p "$(OPENWRT)/feeds"
	cp feeds.conf "$(OPENWRT)/feeds.conf"

prepare: fetch
	@# Make sure we have the right feeds trees. openwrt/scripts/feeds does
	@# not support retrieving a specific git revision, so we have to do
	@# this ourselves.
	cat feeds.conf | while read line; do \
		feed=`echo $$line | cut -f2 -d' ' -`; \
		url=`echo $$line | cut -f3 -d' ' -`; \
		[ -d "$(OPENWRT)/feeds/$$feed" ] && \
			(cd "$(OPENWRT)/feeds/$$feed"; git fetch -q origin) || \
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

	@# Populate files tree
	cp -r files "$(OPENWRT)/files"
	mkdir -p "$(OPENWRT)/files/rev"
	git rev-parse HEAD > "$(OPENWRT)/files/rev/builder"
	cp rev/* "$(OPENWRT)/files/rev/"

update: fetch
	(cd "$(OPENWRT)"; git checkout -q master; git pull -q origin master)
	(cd "$(OPENWRT)"; git rev-parse HEAD > "$(BUILDER)/rev/openwrt")

	"$(OPENWRT)/scripts/feeds" update -i
	cat feeds.conf | while read line; do \
		feed=`echo $$line | cut -f2 -d' ' -`; \
		(cd "$(OPENWRT)/feeds/$$feed"; \
			git checkout -q master; git pull -q origin master); \
		(cd "$(OPENWRT)/feeds/$$feed"; \
			git rev-parse HEAD > "$(BUILDER)/rev/$$feed"); \
	done

	@# Update the package index and install all packages
	"$(OPENWRT)/scripts/feeds" update -i
	"$(OPENWRT)/scripts/feeds" install -a

all: $(devices)

define build
$(1): prepare device/$(1)/config
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
