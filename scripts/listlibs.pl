#!/usr/bin/env perl
#
# listlibs.pl - list shared library files on which executable files depend on
#
# This file is part of the HAMMER build system.
#
# Copyright (C) 2014 Aaro Koskinen <aaro.koskinen@iki.fi>
#
# Licensed under the GNU General Public License version 2 (GPLv2).
#

use Getopt::Long;

sub get_needed($)
{
	my $file = shift;
	my $dynamic;
	my @needed;

	open(OBJDUMP, "-|", "$obj_dump -p $file") or
		die("$0: open(|$obj_dump): $!\n");
	while (<OBJDUMP>) {
		if ((not defined($format)) && /file format elf(32|64)/) {
			$format = $1;
			next;
		}
		if (!$dynamic && /^Dynamic Section:/) {
			$dynamic = 1;
			next;
		}
		if (/^\s*NEEDED\s+(.+)/) {
			push @needed, $1;
			next;
		}
		last if (/^$/ && $dynamic);
	}
	close(OBJDUMP);
	die("$0: $file: unknown ELF file format\n") unless length $format;
	@needed;
}

sub check_file($)
{
	my $file = shift;
	my @needed;

	@needed = get_needed($file);

	if (not @libdirs) {
		if ($format eq "64") {
			@libdirs = ( "/lib64", "/usr/lib64" );
		} else {
			@libdirs = ( "/lib", "/usr/lib" );
		}
	}

	NEEDED: for my $n (@needed) {
		for my $l (@libdirs) {
			if (-f "$l/$n") {
				$needed{"$l/$n"}++;
				check_file("$l/$n") unless $checked{"$l/$n"};
				next NEEDED;
			}
		}
		$missing{$n}++;
	}
	$checked{"$file"}++;
}

die("usage: $0 [--libdir directory] file ...\n")
	if (not GetOptions("libdir=s" => \@libdirs)) or @ARGV < 0;

$obj_dump = $ENV{"OBJDUMP"};
$obj_dump = "objdump" unless length $obj_dump;

for my $file (@ARGV) {

	open(ELF, "<$file") or die("$0: open($file): $!\n");
	read(ELF, $elf, 4);
	close(ELF);
	next unless $elf eq "\177ELF";

	check_file($file);

	die("$0: some libraries needed by $file not found: ",
	    join(", ", keys %missing), "\n")
		if (keys %missing);

}
print join("\n", keys %needed), "\n";
