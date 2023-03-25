# read two (small) HEX files, and compares the relevant portions to create a bitmap.
# since MMS CP/M 2 modules contain the (old) bitmap, that is part of the
# compare and should be discarded.
# input comes from "paste %0.hex %1.hex"...
BEGIN { c = 0; }
/^:10....00/{
	y = 0;
	if (c == 0) printf(" DB ");
	for (x = 10; x < 42; x += 2) {
		a=substr($1,x,2);
		b=substr($2,x,2);
		if (a == b) printf("0");
		else printf("1");
		if (++y >= 8) {
			printf("B,");
			y = 0;
		}
	}
	if (++c >= 4) {
		printf("\n");
		c = 0;
	}
}
END{ printf("\n"); }
