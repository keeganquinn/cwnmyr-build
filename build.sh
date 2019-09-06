#!/usr/bin/env bash

# Build an image for a device based on config data from cwnmyr.

export OPENWRT=${OPENWRT:-openwrt}

url=$1

[ -z "${url}" ] && echo "Usage: ./build.sh <url>" && exit 2

echo "Device configuration URL: ${url}"

node="${url}/conf.json"
config="${url}/build_config"

set -ex

make clean
make prepare

(cd splash; yarn install; yarn build)

rm -rf files/output files/splash
cp -a splash/htdocs files/splash

(cd files; perl FOOCAB.pl --url "${node}")

rm -f "./config"
curl -o "./config" -s "${config}"

make build

cp "${OPENWRT}"/bin/targets/*/*/openwrt-* image/

exit 0
