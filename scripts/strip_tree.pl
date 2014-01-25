#!/usr/bin/env perl
#
# This file is part of the HAMMER build system.
#
# Copyright (C) 2012-2014 Aaro Koskinen <aaro.koskinen@iki.fi>
#
# Licensed under the GNU General Public License version 2 (GPLv2).
#

use File::Find;
use File::Basename;
use File::Path qw(make_path);

die("usage: $0 <directory>\n") if @ARGV != 1;
chdir($ARGV[0]) or die("$0: chdir($ARGV[0]): $!\n");

sub create_dir($)
{
	my $dir = shift;

	return if $dir{$dir};
	make_path($dir);
	$dir{$dir}++;
}

$debug_dir = "usr/lib/debug";
$obj_copy  = $ENV{"OBJCOPY"};
$strip     = $ENV{"STRIP"};
die("$0: STRIP undefined\n") unless length $strip;
create_dir($debug_dir) if length $obj_copy;
 
sub strip_tree {
	my $f = $File::Find::name;
	return if /\.([aho]|exec|img|image|mod|module)$/;
	$f =~ s/^.\///;
	next if $f =~ /^usr\/lib\/debug\//;
	my $target_debug = "$debug_dir/$f.debug";
	next if -e $target_debug;
	return unless -f $_ && not -l $_;
	open(ELF, "<$_") or die("$0: open($_): $!\n");
	read(ELF, $elf, 4);
	my $inode = (stat(ELF))[1];
	close(ELF);
	return unless $elf eq "\177ELF";
	if (defined $inodes{$inode}) {
		next unless length $obj_copy;
		my $orig = $inodes{$inode};
		my $orig_base = basename($orig);
		my $my_dir = dirname($f);
		if (not ($my_dir eq dirname($orig))) {
			my $rel_dir = "$my_dir/";
			$rel_dir =~ s/[^\/]*\//..\//g;
			$link = "$debug_dir/$my_dir/$orig_base.debug";
			$target = "$rel_dir$orig.debug";
			if (! -e $link) {
				create_dir("$debug_dir/$my_dir");
				symlink($target, $link) or
					die("$0: symlink($link): $!\n");
				return if -e $target_debug;
			}
		}
		symlink("$orig_base.debug", $target_debug) or
			die("$0: symlink($target_debug): $!\n");
	} else {
		if (length $obj_copy) {
			create_dir("$debug_dir/" . dirname($f));
			system($obj_copy, '-p', '--only-keep-debug', $f,
			       $target_debug) == 0 or
				die("$0: $obj_copy($f): $?\n");
		}
		$inodes{$inode} = $f;
		print "stripping $f...\n";
		my $read_only = ! -w $f;
		my $perm;
		if ($read_only) {
			$perm = (stat($f))[2] & 07777;
			chmod 0600, $f or die("$0: chmod($f): $!\n");
		}
		system($strip, '-p', $f) == 0 or die("$0: $strip($f): $?\n");
		if ($read_only) {
			chmod $perm, $f or die("$0: chmod($f): $!\n");
		}
	}
}

find({ wanted => \&strip_tree, no_chdir => 1 }, "./");
