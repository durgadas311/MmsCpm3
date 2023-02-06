#include "printf.h"

main(argc, argv)
int argc;
char **argv;
{
	int x;
	for (x = 0; x < argc; ++x) {
		printf("[%d] = \"%s\"\n", x, argv[x]);
	}
}
