/*
 * iself.c
 *
 * Copyright (C) 2013 Aaro Koskinen <aaro.koskinen@iki.fi>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 2 of the License.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 */

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <linux/elf.h>
#include <sys/types.h>

int main (int argc, char **argv)
{
	char elf_magic[SELFMAG];
	ssize_t amount;
	int fd;

	if (argc != 2) {
		fprintf(stderr, "usage: %s <file>\n", argv[0]);
		return EXIT_FAILURE;
	}
	fd = open(argv[1], O_RDONLY);
	if (fd == -1) {
		fprintf(stderr, "%s: could not open %s: %d\n",
			argv[0], argv[1], errno);
		return EXIT_FAILURE;
	}
	amount = read(fd, elf_magic, sizeof(elf_magic));
	close(fd);
	if (amount == -1) {
		fprintf(stderr, "%s: error reading file %s: %d\n",
			argv[0], argv[1], errno);
		return EXIT_FAILURE;
	} else if (amount != sizeof(elf_magic)) {
		return EXIT_FAILURE;
	}

	return memcmp(elf_magic, ELFMAG, SELFMAG) ? EXIT_FAILURE : EXIT_SUCCESS;
}
