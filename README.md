Personal Telco Project build kit for LEDE
=========================================

The goal of this project is to automate and expand upon the PTP node build
procedure, as documented in the FooCabFirmwareHowTo wiki page. This process is
used to produce binary images suitable for converting standard wireless network
equipment into PTP gear with advanced integration and management capabilities.

Original documentation:
https://personaltelco.net/wiki/FooCabFirmwareHowTo

For more information about LEDE, visit: https://lede-project.org/


Device Support
--------------

Currently, three targets are supported: `mr3201a`, `net4521` and `wgt634u`.

All that is needed to add support for additional targets is an appropriate
LEDE `.config` file for each device - contributions are welcome! Here's how
to create one:

    make prepare-update
    cd lede
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

On a system which is capable of building LEDE directly, simply run:

    make <target>

You can also build in a Docker container. See the section below for details.

Resulting images will be stored in the `image` subdirectory. If you do not
select a target, all available targets will be built. Be aware, this can take
quite a long time and a lot of disk space.

To update to the latest LEDE and packages trees and generate a new
matching .config:

    make <target>-update

For interactive configuration changes:

    make <target>-update UPDATE_TARGET=menuconfig

After updating the build configuration, you can perform a new build.


Docker
------

You can use Docker Compose to perform the build:

    docker-compose build
    docker-compose run main make <target>

In a similar manner, you can simply prefix the `make` command with
`docker-compose run main` to run any of the commands described above.
