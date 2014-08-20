#!/bin/sh
#
# This file is part of the HAMMER build system.
#
# Copyright (C) 2012-2014 Aaro Koskinen <aaro.koskinen@iki.fi>
#
# Licensed under the GNU General Public License version 2 (GPLv2).
#

PRINT=`echo "$FAKE_TARGET" | cut -d/ -f3,4,6 | sed 's/-list$//'`
$1 list "$PRINT"
