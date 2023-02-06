#include "fprintf.h"

char buf[128];

main(argc, argv)
int argc;
char **argv;
{
	long cap;
	float kb;
	char un;

	cap = 8027712;	/* Norberto's 4G CF */
	kb = cap / 2.0;
	un = 'K';
	if (kb >= 1024.0) {
		kb = kb / 1024.0;
		un = 'M';
	}
	if (kb >= 1024.0) {
		kb = kb / 1024.0;
		un = 'G';
	}
	printf("Capacity: %ld (%.2f %c)\n", cap, kb, un);
}
