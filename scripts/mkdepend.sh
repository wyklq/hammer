#!/bin/sh
#
# This file is part of the HAMMER build system.
#
# Copyright (C) 2012-2014 Aaro Koskinen <aaro.koskinen@iki.fi>
#
# Licensed under the GNU General Public License version 2 (GPLv2).
#

if [ -z "$HW_ARCH" ]
then
	exit 1
fi

if [ "$WEAK_DEPS" != "1" ]
then
	WEAK_DEPS=""
fi

TARGET="..\/work\/$HW_ARCH\/$BUILD_SUBSYSTEM\/build\/"
#TARGET=`echo $TARGET | sed 's/\//\\\&/g'`

SUBSYSDEP=""
if [ -n "$BUILD_DEPENDS" -a -z "$WEAK_DEPS" ]
then
	for DEP in $BUILD_DEPENDS
	do
		if [ "$BUILD_DEPENDS" = "utils" ]
		then
			SUBSYSDEP="../work/host/utils/build/.modified"
		else
			SUBSYSDEP="../work/$HW_ARCH/$DEP/build/.modified"
		fi
	done
fi

PREPARE=0
for SCRIPT in $*
do
	if [ "$SCRIPT" = "build-prepare.sh" ]
	then
		PREPARE=1
		break
	fi
done

PDEPS="Makefile Makefile.packages setup ../Makefile"
PDEPS="$PDEPS ../scripts/*"

for SCRIPT in $*
do
	PKG_NAME=`cat $SCRIPT | grep -m 1 '^PKG_NAME=' | cut -d= -f 2`
	PKG=`echo $SCRIPT| sed 's/^build-//;s/\.sh$//'`
	S="$PKG-build"
	DEPS=`cat $SCRIPT | grep '^# dependencies: ' | sed 's/.*: //'`
	if [ "$PREPARE" = "1" -a "$SCRIPT" != "build-prepare.sh" ]
	then
		DEPS="prepare $DEPS"
		PDEPS="$PDEPS $SCRIPT"
	fi
	if [ -n "$SUBSYSDEP" ]
	then
		DEPS="$SUBSYSDEP $DEPS"
	fi
	if [ -d "../upstream/$PKG" ]
	then
		PATCHES=`find "../upstream/$PKG" -type f`
		DEPS="$PATCHES $DEPS"
		PDEPS="$PATCHES $PDEPS"
	fi
	PKG_FORCE=$(echo "$PKG" | sed 's/-/_/g')_force
	if (printenv $PKG_FORCE > /dev/null)
	then
		DEPS="../work/${PKG}-sources-build $DEPS"
		DUMMY="../work/${PKG}-sources-build $DUMMY"
	fi
	DD=""
	for D in $DEPS
	do
		echo $D | grep -q '/'
		if [ "$?" = "0" ]
		then
			test ! -h "$D" && DD="$DD $D"
		else
			DD="$DD "`echo $D-build | sed "s/^/$TARGET/"`
		fi
	done
	if [ -n "$DD" ]
	then
		echo $DD | sed "s/^/$TARGET$S: /"
	fi
	if [ "$SCRIPT" != "build-finalize.sh" ]
	then
		ALL=`echo "$ALL" | sed "s/^/ $TARGET$S/"`
	else
		FINALIZE=1
	fi
done

if [ "$PREPARE" = "1" -a -z "$WEAK_DEPS" ]
then
	ls $PDEPS | sed "s/^/${TARGET}prepare-build: /"
fi

for D in $DUMMY
do
	echo "$D: ;"
done

if [ "$FINALIZE" = "1" ]
then
	echo $ALL | sed "s/^/${TARGET}finalize-build: /"
fi
