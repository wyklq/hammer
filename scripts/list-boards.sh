#!/bin/sh
#
# This file is part of the HAMMER build system.
#
# Copyright (C) 2012-2013 Aaro Koskinen <aaro.koskinen@iki.fi>
#
# Licensed under the GNU General Public License version 2 (GPLv2).
#

set -e

cd `cd $(dirname $0)/.. && pwd`

if [ -n "$HW_BOARD" ]
then
	echo $HW_BOARD
	exit 0
fi

if [ -z "$1" ]
then
	exit 0
fi

cd config/"$1"

for BOARD in *
do
	test -d "$BOARD" && echo "$BOARD"
done

exit 0
