# Makefile: LEDE image generator for PTP nodes

devices := $(notdir $(wildcard device/*))

BUILDER := $(shell dirname "$(realpath $(lastword $(MAKEFILE_LIST)))")
LEDE ?= lede

.PHONY: default clean prepare all $(devices)

default: all

clean:
	rm -rf image

distclean: clean
	rm -rf "$(LEDE)"

fetch:
	@# Make sure we have the correct LEDE tree
	[ -d "$(LEDE)" ] && \
		(cd "$(LEDE)"; git fetch -q origin) || \
		git clone -q git://git.lede-project.org/source.git "$(LEDE)"
	(cd "$(LEDE)"; git checkout -q `cat "$(BUILDER)/rev-lede"`)

	@# Symlink dl subdirectory, to avoid unneeded redownloading
	mkdir -p dl
	rm -rf "$(LEDE)/dl"
	ln -s "$(BUILDER)/dl" "$(LEDE)/dl"

	mkdir -p "$(LEDE)/feeds"
	cp feeds.conf "$(LEDE)/feeds.conf"

prepare: fetch
	@# Make sure we have the right feeds trees. lede/scripts/feeds does
	@# not support retrieving a specific git revision, so we have to do
	@# this ourselves.
	cat feeds.conf | while read line; do \
		feed=`echo $$line | cut -f2 -d' ' -`; \
		url=`echo $$line | cut -f3 -d' ' -`; \
		[ -d "$(LEDE)/feeds/$$feed" ] && \
			(cd "$(LEDE)/feeds/$$feed"; git fetch -q origin) || \
			git clone -q $$url "$(LEDE)/feeds/$$feed"; \
		(cd "$(LEDE)/feeds/$$feed"; \
			git checkout -q `cat "$(BUILDER)/rev-$$feed"`); \
	done

	@# Update the package index and install all packages
	"$(LEDE)/scripts/feeds" update -i
	"$(LEDE)/scripts/feeds" install -a

	@# Ensure critical parts of the LEDE tree are clean before
	@# (re)populating them
	rm -rf "$(LEDE)/.config*" "$(LEDE)/bin" "$(LEDE)/files"

	@# Create output directory for images
	mkdir -p image

	@# Populate files tree
	cp -r files "$(LEDE)/files"
	git rev-parse HEAD > "$(LEDE)/files/rev-builder"
	cp rev-* "$(LEDE)/files/"

update: fetch
	(cd "$(LEDE)"; git checkout -q master; git pull -q origin master)
	(cd "$(LEDE)"; git rev-parse HEAD > "$(BUILDER)/rev-lede")

	"$(LEDE)/scripts/feeds" update -a
	cat feeds.conf | while read line; do \
		feed=`echo $$line | cut -f2 -d' ' -`; \
		(cd "$(LEDE)/feeds/$$feed"; \
			git checkout -q master; git pull -q origin master); \
		(cd "$(LEDE)/feeds/$$feed"; \
			git rev-parse HEAD > "$(BUILDER)/rev-$$feed"); \
	done

	@# Update the package index and install all packages
	"$(LEDE)/scripts/feeds" update -i
	"$(LEDE)/scripts/feeds" install -a

all: $(devices)

define build
$(1): prepare device/$(1)/config
	@# Install and activate device-specific LEDE build configuration
	cp "device/$(1)/config" "$(LEDE)/.config"
	(cd "$(LEDE)"; make defconfig)
	cp "$(LEDE)/.config" "$(LEDE)/files/config"

	@# Perform build, triggering hook scripts as needed
	[ -x "device/$(1)/prebuild" ] && \
		"device/$(1)/prebuild" "$(LEDE)" || true
	(cd "$(LEDE)"; \
		make BUILD_LOG=1 FORCE_UNSAFE_CONFIGURE=1 IGNORE_ERRORS=m V=99)
	[ -x "device/$(1)/postbuild" ] && \
		"device/$(1)/postbuild" "$(LEDE)" || true
endef

$(foreach device, $(devices), $(eval $(call build,$(device))))
