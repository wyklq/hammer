#!/bin/sh

set -e

PKG_NAME=prepare-
PKG_VERSION=NONE

. ./setup

test -d "$BUILD_UTILS" && rm -rf "$BUILD_UTILS"
pkg_dummy
