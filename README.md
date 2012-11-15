See the master branch for current information and working code.

This branch contains an attempt at using the 'defconfig' target in OpenWrt
in combination with simplified "template" device config files as an
alternative to distributing full config files for each device.

Unfortunately, this doesn't seem to work as expected; running 'defconfig'
correctly reads the target architecture from the template but ignores most
other settings.
