OpenWrt image generator for cwnmyr
==================================

The goal of this project is to automate and expand upon the PTP node build
procedure, as documented in the FooCabFirmwareHowTo wiki page. This process is
used to produce binary images suitable for converting standard wireless network
equipment into PTP gear with advanced integration and management capabilities.

Original documentation:
https://personaltelco.net/wiki/FooCabFirmwareHowTo

For more information about OpenWrt, visit the website: https://openwrt.org

The live PTP cwnmyr can be found at: https://cwnmyr.personaltelco.net/


Device Support
--------------

Device-specific configuration is obtained from the server:
https://cwnmyr.personaltelco.net/device_types


Usage
-----

Once all dependencies are available, simply run:

    ./build.sh <device_url>

Provide the URL to a device in cwnmyr, for example:

    ./build.sh https://cwnmyr.personaltelco.net/devices/134-cat

Resulting images will be stored in the `image` subdirectory. Beware, an
image build can take quite a long time and a lot of disk space.

By default, a known-good set of OpenWrt sources and feeds will be used.
To update to the latest OpenWrt and packages trees:

    make update

After updating the sources, you can perform a new build.


Dependencies
------------

The following Debian packages should be installed to run this script:

    build-essential ca-certificates cpanminus file flex gawk gcc-multilib git
    libncurses5-dev libnet-ssleay-perl libcrypt-ssleay-perl libssl-dev
    openssl pkg-config python rsync subversion unzip wget zlib1g-dev

In addition, the following CPAN packages should be installed:

    NetAddr::IP::Lite Getopt::Long JSON LWP::Simple LWP::Protocol::https

Users of other distributions should install the appropriate corresponding
packages for their systems. Building on non-Linux systems is not recommended.
