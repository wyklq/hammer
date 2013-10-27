#!/bin/sh
# dependencies: ./iself.c

set -e

PKG_NAME=iself-
PKG_VERSION=NONE

. ./setup

rm -rf "$PKG_STAGING"
mkdir -p "$PKG_STAGING/$BUILD_UTILS/bin"
gcc -O2 -Wall -pedantic -o "$PKG_STAGING/$BUILD_UTILS/bin/iself" iself.c
pkg_install /
pkg_cleanup
