/*
 * Program to dump Kaypro disks to AUX: device, in Intel HEX format.
 * Hard-coded to 10x512 sectors per track, and BIOS settrk that
 * uses 0-79 for double-sided disks and 0-39 for single-sided.
 *
 * Usage: xd [S] { A | B }
 * Where: S = single sided (default double)
 *        A|B = drive to dump from
 * Prompts before starting the dump.
 * Repeats indefinitely.
 */

#include <stdio.h>

void
memset(s, c, n)
char *s;
char c;
int n;
{
	while (n-- > 0) *s++ = c;
}

char	*_auxout,
	*_auxin,
	*_seldsk,
	*_settrk,
	*_setsec,
	*_setdma,
	*_bread;

bdos(c,de)
int c;
int de;
{
	c;
#asm
	mov c,l
#endasm
	de;
#asm
	mov e,l
	mov d,h
	call 5
#endasm
}

init_bios() {
#asm
	lhld 1
	lxi b,15
	dad b
	shld ?auxout
	lxi b,3
	dad b
	shld ?auxin
	dad b
	dad b
	shld ?seldsk
	dad b
	shld ?settrk
	dad b
	shld ?setsec
	dad b
	shld ?setdma
	dad b
	shld ?bread
#endasm
}

c_pchl() {
#asm
	pchl
#endasm
}

auxout(c)
char c;
{
	c;
#asm
	mov c,l
	lhld ?auxout
	pchl
#endasm
}

seldsk(d)
char d;
{
	d;
#asm
	mov c,l
	mvi e,0
	lhld ?seldsk
	pchl
#endasm
}

settrk(t)
int t;
{
	t;
#asm
	mov c,l
	mov b,h
	lhld ?settrk
	pchl
#endasm
}

setsec(s)
int s;
{
	s;
#asm
	mov c,l
	mov b,h
	lhld ?setsec
	pchl
#endasm
}

setdma(dma)
char *dma;
{
	dma;
#asm
	mov c,l
	mov b,h
	lhld ?setdma
	pchl
#endasm
}

bread() {
#asm
	lhld ?bread
	call c?pchl
	mov l,a
	mvi h,0
#endasm
}

char hex  [] = { "0123456789abcdef" };

int sum;

hexout(h)
char h;
{
	auxout(hex  [(h & 0xf0) >> 4]);
	auxout(hex  [h & 0x0f]);
	sum += h;
}

hexword(w)
int w;
{
	hexout((w & 0xff00) >> 8);
	hexout(w & 0x00ff);
}

hexline(b,n,a)
char *b;
int n;
int a;
{
	int x;
	int y;
	do {
		x = (n > 16 ? 16 : n);
		y = x;
		auxout(':');
		sum = 0;
		hexout(x);
		hexword(a);
		hexout(0);
		while (x > 0) {
			hexout(*b);
			++b;
			--x;
		}
		hexout(sum);
		auxout('\n');
		n -= y;
		a += y;
	} while (n > 0);
}

char dmabuf[5120];

main(argc, argv)
int argc;
char **argv;
{
	char q, c, x, y ,z, dsk, side;
	char *bufp, *s;
	int sum;
	int adr;

	init_bios();

	dsk = 1;
	side = 2;
	for (x = 1; x < argc; ++x) {
		switch(argv[x][0] & 0x5f) {
		case 'A':
			dsk = 0;
			break;
		case 'B':
			dsk = 1;
			break;
		case 'S':
			side = 1;
			break;
		}
	}

	seldsk(dsk);
while (1) {
	bdos(9,"\nPress return $");
	bdos(1,NULL); /* wait for any key press */
	adr = 0;
	for (x = 0; x < 40 * side; ++x) {
		bdos(2,'.');
	       bufp = dmabuf;
	       for (y = 0; y < 40; ++y) {
			settrk(x);
			setsec(y);
			setdma(bufp);
			z = bread();
			if (z != 0) {
				printf("read error trk %d sec %d\n",
					x, y);
/*
				auxout(0x04);
				exit(1);
*/
				memset(bufp, '?', 128);
			}
			bufp += 128;
		}
		bufp = dmabuf;
		for (y = 0; y < 10; ++y) {
		for (q = 0; q < 4; ++q) {
			hexline(bufp,128,adr);
			adr += 128;
			bufp += 128;
		} }
	}
	hexline(bufp,0,0);
}
	exit(0);
}
