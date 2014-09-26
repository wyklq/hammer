#!/bin/sh
#
# This file is part of the HAMMER build system.
#
# Copyright (C) 2012-2013 Aaro Koskinen <aaro.koskinen@iki.fi>
#
# Licensed under the GNU General Public License version 2 (GPLv2).
#

LOG_FILE="$FAKE_TARGET".log
LOG_DIR=`dirname $LOG_FILE`
PRINT=`echo "$FAKE_TARGET" | cut -d/ -f3,4,6 | sed 's/-build$//'`
mkdir -p $LOG_DIR
echo Building $PRINT...
$1 > $LOG_FILE 2>&1
