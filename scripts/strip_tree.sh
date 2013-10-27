#!/bin/sh
#
# This file is part of the HAMMER build system.
#
# Copyright (C) 2012-2013 Aaro Koskinen <aaro.koskinen@iki.fi>
#
# Licensed under the GNU General Public License version 2 (GPLv2).
#

set -e

check_file ()
{
	if (echo "$1" | grep -q '\.\([aho]\|exec\|img\|image\|mod\|module\)$')
	then
		return 1
	elif [ -h "$1" ]
	then
		return 1
	elif ! iself "$1"
	then
		return 1
	fi
	return 0
}

copy_debuginfo ()
{
	rm -rf "$DEBUG_DIR/inodes"
	mkdir "$DEBUG_DIR/inodes"
	for FILE in $*
	do
		if [ -e "$DEBUG_DIR/$FILE.debug" ]
		then
			continue
		elif ! check_file $FILE
		then
			continue
		fi
		INODE="$DEBUG_DIR/inodes/"`stat -c%i "$FILE"`
		if [ -e "$INODE" ]
		then
			# If a debuginfo file exists already, create a symlink.
			D=`cat "$INODE"`
			D_DIR=`dirname "$D"`
			D_BASE=`basename "$D"`
			C_DIR=`dirname "$FILE"`
			# Remove leading ./ and/or / from the current directory
			C_DIR=`echo $C_DIR | sed 's/^\(\.\/\|\/\)//g'`
			# Check if the original debuginfo is in different dir.
			if [ "$D_DIR" != "$C_DIR" ]
			then
				# Convert to relative path to root
				R_DIR=`echo "$C_DIR"/ | sed 's/[^\/]*\//..\//g'`
				# Create the symlink to the original debuginfo
				LINK="$DEBUG_DIR/$C_DIR/$D_BASE"
				if [ ! -e "$LINK" ]
				then
					mkdir -p "$DEBUG_DIR/$C_DIR"
					ln -s "$R_DIR$D" "$LINK"
					if [ -e "$DEBUG_DIR/$FILE.debug" ]
					then
						continue
					fi
				fi
			fi
			ln -s "$D_BASE" "$DEBUG_DIR/$FILE.debug"
			continue
		fi
		echo "copying debuginfo from $FILE"
		mkdir -p "$DEBUG_DIR"/`dirname $FILE`
		"$OBJCOPY" -p --only-keep-debug "$FILE" \
			"$DEBUG_DIR/$FILE.debug"
		echo "$FILE.debug" | sed 's/^\(\.\/\|\/\)//g' > "$INODE"
		if [ -w "$FILE" ]
		then
			WRITEABLE=1
		else
			WRITEABLE=0
			chmod u+w "$FILE"
		fi
		"$OBJCOPY" -p --add-gnu-debuglink="$DEBUG_DIR/$FILE.debug" $FILE
		if [ "$WRITEABLE" = "0" ]
		then
			chmod u-w "$FILE"
		fi
	done
	rm -rf "$DEBUG_DIR/inodes"
}

strip_file ()
{
	for FILE in $*
	do
		if ! check_file $FILE
		then
			continue
		fi
		echo "stripping $FILE"
		if [ -w "$FILE" ]
		then
			WRITEABLE=1
		else
			WRITEABLE=0
			chmod u+w "$FILE"
		fi
		"$STRIP" -p "$FILE"
		if [ "$WRITEABLE" = "0" ]
		then
			chmod u-w "$FILE"
		fi
	done
}

DIR="$1"
cd "$DIR"
if [ -n "$OBJCOPY" ]
then
	OBJDUMP=`echo "$OBJCOPY" | sed 's/objcopy$/objdump/'`
	DEBUG_DIR="$DIR/usr/lib/debug"
	mkdir -p "$DEBUG_DIR"
	copy_debuginfo `find ./ \( -path ./usr/lib/debug -prune \) -o \( -type f -print \)`
fi
strip_file `find ./ \( -path ./usr/lib/debug -prune \) -o \( -type f -print \)`

exit 0
