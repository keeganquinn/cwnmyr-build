#!/bin/sh

INTERFACE=$1

# PTPnet IPv6
ip -6 addr add 2001:470:e962::1281/64 dev $INTERFACE

exit 0

