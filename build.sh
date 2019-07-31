#!/usr/bin/env bash

# Build an image for a device.

device=$1
url=$2

[ -z "${url}" ] && echo "Usage: ./build.sh <device> <url>" && exit 2

echo "${device} ${url}"

set -ex

make clean
make prepare

(cd files; perl FOOCAB.pl --url "${url}")

make "${device}"

exit 0
