#
# This file is part of the HAMMER build system.
#
# Copyright (C) 2012-2013 Aaro Koskinen <aaro.koskinen@iki.fi>
#
# Licensed under the GNU General Public License version 2 (GPLv2).
#

include Makefile.packages

ifndef HW_BOARD
   $(error HW_BOARD not specified.)
endif

override BUILD_SUBSYSTEM = kernel-$(HW_BOARD)

include ../scripts/Makefile.subsystem
