/*
 * buildhost.c - guess the build host name
 *
 * Copyright (C) 2013 Aaro Koskinen <aaro.koskinen@iki.fi>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/utsname.h>

int main (void)
{
	struct utsname uts;

	if (uname(&uts) == -1)
		return EXIT_FAILURE;
	if (strncmp(uts.machine, "arm", 3) == 0)
		printf("arm-build-linux-gnueabi\n");
	else if (strncmp(uts.machine, "mips", 4) == 0)
#if defined(__MIPSEL__)
		printf("%sel-build-linux-gnu\n", uts.machine);
#else /* __MIPSEL__ */
		printf("%s-build-linux-gnu\n", uts.machine);
#endif /* __MIPSEL__ */
	else if (strncmp(uts.machine, "ppc", 3) == 0)
		printf("powerpc%s-build-linux-gnu\n", uts.machine + 3);
	else
		printf("%s-build-linux-gnu\n", uts.machine);
	return 0;
}
