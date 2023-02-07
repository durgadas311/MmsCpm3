/* test program for gets() */
/* each line typed will be echoed. empy line ends program. */

char buf[128];

main(argc, argv)
int argc;
char **argv;
{
	int n;
	while ((n = gets(buf)) > 0) {
		puts(buf);
	}
}
