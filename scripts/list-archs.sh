#!/bin/sh
#
# This file is part of the HAMMER build system.
#
# Copyright (C) 2012-2013 Aaro Koskinen <aaro.koskinen@iki.fi>
#
# Licensed under the GNU General Public License version 2 (GPLv2).
#

set -e

for OPT in $*
do
	if [ "$OPT" = "-r" ]
	then
		ROOTFS=1
	else
		ROOTFS=0
	fi
done

if [ -n "$HW_ARCH" -a -n "$HW_BOARD" ]
then
	echo "$0: specifying both HW_ARCH and HW_BOARD is not possible"
	exit 1
fi

if [ -n "$HW_ARCH" ]
then
	echo $HW_ARCH
	exit 0
fi

show_arch ()
{
	NO_ROOTFS=0
	[ "$ROOTFS" = "1" ] && NO_ROOTFS=`. "$1/setup" && echo $NO_ROOTFS`
	[ "$NO_ROOTFS" = "1" ] || echo $1
}

cd `cd $(dirname $0)/.. && pwd`/config
for ARCH in *
do
	if [ -z "$HW_BOARD" ]
	then
		test \( "$ARCH" != "host" \) -a -d "$ARCH" && show_arch "$ARCH"
		continue
	fi
	if [ -d "$ARCH/$HW_BOARD" ]
	then
		show_arch $ARCH
		exit 0
	fi
done
