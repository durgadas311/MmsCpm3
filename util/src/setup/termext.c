/*
 * Provides termctrl when terminal definition is loaded from A:TERMINAL.SYS
 */
#include "terminal.h"
#include "term.h"
#include <fcntl.h>
#include <stdlib.h>

#define numrec 3*128	/* based on size of termctrl */

struct tcb termctrl;

void termload() {
	char *tcbuf;
	int fp;
	if ((fp = open("a:terminal.sys", O_RDONLY, 0)) == -1) {
		printf("Terminal control file not on drive A:.\n");
		exit(0);
	}
	tcbuf = (char *)&termctrl;
	if (read(fp, tcbuf, numrec) != numrec) {
		printf("Terminal control file incomplete.\n");
		exit(0);
	}
	close(fp);
}
