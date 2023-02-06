/* Program to test linking and using routines from stdlib.rel */
#include "printf.h"

main(argc, argv)
int argc;
char **argv;
{
	int x;
	int i;
	i = -1;
	for (x = 1; x < argc; ++x) {
		if (strcmp(argv[x], "-i") == 0) {
			if (x + 1 < argc) {
				i = atoi(argv[++x]);
			}
		} else if (argv[x][0] == '-' && argv[x][1] == 'i') {
			if (*(argv[x] + 2) != '\0') {
				i = atoi(argv[x] + 2);
			}
		}
	}
	printf("i = %d\n", i);
}
