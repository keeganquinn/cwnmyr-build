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

cpanm -l "./perl5" \
      NetAddr::IP::Lite Getopt::Long JSON LWP::Simple LWP::Protocol::https
PERL5LIB=$(readlink -f "./perl5/lib/perl5")
(cd files; PERL5LIB="${PERL5LIB}" perl FOOCAB.pl --url "${node}")

rm -f "./config"
curl -o "./config" -s "${config}"

make build

cp "${OPENWRT}"/bin/targets/*/*/openwrt-* image/

exit 0
