Personal Telco Project build kit for OpenWrt
============================================

For more information about OpenWrt, visit https://openwrt.org/

For more information about the Personal Telco Project, visit
https://personaltelco.net/wiki/

Concept
-------

Essentially, the goal of this project is to automate the procedure
documented in the FooCabFirmwareHowTo wiki page, building standardized
binary images with generic configuration files for each of the device
targets which are commonly utilized as PTP nodes.

Device Support
--------------

Currently, three targets are supported: `mr3201a`, `net4521` and `wgt634u`.

All that is needed to add support for additional targets is an appropriate
OpenWrt `.config` file for each device - contributions are welcome! Here's how
to create one:

    make prepare-update
    cd openwrt
    rm -f .config .config.old
    make menuconfig

Use the menu system to select the correct options for your hardware platform.
Be sure to select the Personal Telco Node metapackage, as well as the correct
hardware options. When you're done, there should be a `.config` file in the
working directory. Send it to `keeganquinn@gmail.com`, or open an issue or pull
request on the github page for this project with a description of the new
target platform to have it included in the distribution.

Usage
-----

Simply:

    git clone git://github.com/keeganquinn/ptpwrt-builder.git
    cd ptpwrt-builder
    make <target>

Resulting images will be stored in the `image` subdirectory. If you do not
select a target, all available targets will be built. Be aware, this can take
quite a long time and a lot of disk space.

To update to the latest openwrt and packages trees and generate a new
matching .config:

    make <target>-update

For interactive configuration changes:

    make <target>-update UPDATE_TARGET=menuconfig

After updating the build configuration, you can perform a new build.
