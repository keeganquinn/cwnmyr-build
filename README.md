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

Usage
-----

Simply:

    git clone git://github.com/keeganquinn/ptpwrt-builder.git
    cd ptpwrt-builder
    make

Resulting images will be stored in the `image` subdirectory.
