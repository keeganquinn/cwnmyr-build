OpenWrt image generator for cwnmyr
==================================

The goal of this project is to automate and expand upon the PTP OpenWrt node
build procedure. This process is used to produce binary images suitable for
converting standard wireless network equipment into PTP gear with advanced
integration and management capabilities.

Original documentation: https://personaltelco.net/wiki/FooCabFirmwareHowTo

For more information about OpenWrt, visit the website: https://openwrt.org

The live PTP cwnmyr can be found at: https://cwnmyr.personaltelco.net


Device Support
--------------

Device-specific configuration is obtained from the server:
https://cwnmyr.personaltelco.net/device_types


Dependencies
------------

The following Debian packages should be installed to run this script:

    build-essential ca-certificates cpanminus file flex gawk gcc-multilib git
    libncurses5-dev libnet-ssleay-perl libcrypt-ssleay-perl libssl-dev
    openssl pkg-config python rsync unzip wget zlib1g-dev

Users of other distributions should install the appropriate corresponding
packages for their systems. Building on non-Linux systems is not recommended.


Usage
-----

Once all dependencies are available, you may start a build by calling
`build.sh` with a URL to a cwnmyr device. For example:

    ./build.sh https://cwnmyr.personaltelco.net/devices/134-cat

Optionally, you can specify a buildroot location in the environment:

    export OPENWRT=/src/openwrt

The specified buildroot may already exist or it will be created. You may
also use an `openwrt` symlink in the cwnmyr-build directory for this purpose.

After a successful build, resulting images will be stored in the `image`
subdirectory. Beware, an image build can take quite a long time and a lot of
disk space.


Reproducible Build Support
--------------------------

By default, a known-good set of OpenWrt sources and feeds will be used.
These are tracked by revisions stored in the `rev` directory. To update to the
latest revisions of these trees:

    make update

To set the revisions to match a past date:

    make rewind DATE=2019-07-21

You may also freely edit `feeds.conf` to meet your needs; all git sources
are supported. Be sure to specify the branch for each feed, even when it
is master, as shown in the provided file. Simply run `make update` again
after changing `feeds.conf` to ensure new revision files are created.

These reproducible build features are implemented in `Makefile` and can be
used with any OpenWrt buildroot independent from the cwnmyr build script.
