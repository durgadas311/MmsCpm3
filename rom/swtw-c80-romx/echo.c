/* test program for gets() */
/* each line typed will be echoed. empy line ends program. */

char buf[128];

main(argc, argv)
int argc;
char **argv;
{
	while (gets(buf) && buf[0]) {
		putchar('\n');
		puts(buf);
	}
}
