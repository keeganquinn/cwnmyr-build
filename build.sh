#!/usr/bin/env bash

# Build an image for a device.

url=$1

[ -z "${url}" ] && echo "Usage: ./build.sh <url>" && exit 2

echo "Device configuration URL: ${url}"

node="${url}/conf.json"
config="${url}/build_config"
postbuild="${url}/postbuild"
prebuild="${url}/prebuild"

echo
echo "    Node config: ${node}"
echo " OpenWrt config: ${config}"
echo "Post-build hook: ${postbuild}"
echo " Pre-build hook: ${prebuild}"
echo

set -ex

make clean

curl "${config}" -o "./config"

curl "${postbuild}" -o "./postbuild"
if [ -s "./postbuild" ]; then
    chmod +x "./postbuild"
else
    rm -f "./postbuild"
fi

curl "${prebuild}" -o "./prebuild"
if [ -s "./prebuild" ]; then
    chmod +x "./prebuild"
else
    rm -f "./prebuild"
fi

make prepare

(cd files; perl FOOCAB.pl --url "${node}")

make build

exit 0
