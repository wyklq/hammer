#!/bin/sh
# dependencies: ./buildhost.c

set -e

PKG_NAME=buildhost-
PKG_VERSION=NONE

. ./setup

rm -rf "$PKG_STAGING"
mkdir -p "$PKG_STAGING/$BUILD_UTILS/bin"
gcc -O2 -Wall -pedantic -o "$PKG_STAGING/$BUILD_UTILS/bin/buildhost" buildhost.c
pkg_install /
pkg_cleanup
