/* Dump an ISIS .OBJ file (.LIB) */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

/* Record types */
#define R_MODHDR 2
#define R_MODEND 4
#define R_MODDAT 6
#define R_LINNUM 8
#define R_MODEOF 0xE
#define R_ANCEST 0x10
#define R_LOCDEF 0x12
#define R_PUBDEF 0x16
#define R_EXTNAM 0x18
#define R_FIXEXT 0x20
#define R_FIXLOC 0x22
#define R_FIXSEG 0x24
#define R_LIBLOC 0x26
#define R_LIBNAM 0x28
#define R_LIBDIC 0x2A
#define R_LIBHDR 0x2C
#define R_COMDEF 0x2E

/* Segments */
#define SABS    0
#define SCODE   1
#define SDATA   2
#define SSTACK  3
#define SMEMORY 4
#define SRESERVED   5
#define SNAMED  6   /* through 254 */
#define SBLANK  255

/* Alignments  & Flags*/
#define AMASK   0xf
#define AABS    0
#define AUNKNOWN    0
#define AINPAGE 1
#define APAGE   2
#define ABYTE   3
#define ANONE   255
#define FHASADDR    0x80
#define FWRAP0  0x40
#define FSEGSEEN    0x10

/* Fixup type */
#define FLOW    1
#define FHIGH   2
#define FBOTH   3

char *types[256] = {
[R_MODHDR] = "MODHDR",
[R_MODEND] = "MODEND",
[R_MODDAT] = "MODDAT",
[R_LINNUM] = "LINNUM",
[R_MODEOF] = "MODEOF",
[R_ANCEST] = "ANCEST",
[R_LOCDEF] = "LOCDEF",
[R_PUBDEF] = "PUBDEF",
[R_EXTNAM] = "EXTNAM",
[R_FIXEXT] = "FIXEXT",
[R_FIXLOC] = "FIXLOC",
[R_FIXSEG] = "FIXSEG",
[R_LIBLOC] = "LIBLOC",
[R_LIBNAM] = "LIBNAM",
[R_LIBDIC] = "LIBDIC",
[R_LIBHDR] = "LIBHDR",
[R_COMDEF] = "COMDEF",
};
char *segs[256] = {
[SABS] = "SABS",
[SCODE] = "SCODE",
[SDATA] = "SDATA",
[SSTACK] = "SSTACK",
[SMEMORY] = "SMEMORY",
[SRESERVED] = "SRESERVED",
/* define SNAMED  6 through 254 */
[SBLANK] = "SBLANK",
};

uint8_t *obj = NULL;
int ptr;
char buf[128];

static void dump_raw(int col, int cur, int lst) {
	while (cur < lst) {
		printf(" %02x", obj[cur++]);
		col += 3;
		if (col > 78) {
			col = 0;
			printf("\n");
		}
	}
	if (col) printf("\n");
}

static void dump_libhdr(int col, int cur, int lst) {
	uint16_t p1, p2, p3;
	p1 = obj[cur++];
	p1 |= (obj[cur++] << 8);
	p2 = obj[cur++];
	p2 |= (obj[cur++] << 8);
	p3 = obj[cur++];
	p3 |= (obj[cur++] << 8);
	printf(" %04x %04x:%04x\n", p1, p2, p3);
}

static void dump_libnam(int col, int cur, int lst) {
	int ix = 0;
	int len;
	--lst; // drop CRC
	printf("\n");
	while (cur < lst) {
		len = obj[cur++];
		printf("    %2d: \"%.*s\"\n", ix++, len, obj + cur);
		cur += len;
	}
}

static void dump_libloc(int col, int cur, int lst) {
	int ix = 0;
	uint16_t p1, p2;
	--lst; // drop CRC
	printf("\n");
	while (cur < lst) {
		p1 = obj[cur++];
		p1 |= (obj[cur++] << 8);
		p2 = obj[cur++];
		p2 |= (obj[cur++] << 8);
		printf("    %2d: %04x:%04x\n", ix++, p1, p2);
	}
}

static void dump_libdic(int col, int cur, int lst) {
	int ix = 0;
	int len;
	uint8_t seg;
	--lst; // drop CRC
	printf("\n");
	while (cur < lst) {
		len = obj[cur++];
		if (!len) {
			seg = 0;
		} else {
			seg = obj[cur + len];
		}
		printf("    %2d: \"%.*s\" %02x\n", ix++, len, obj + cur, seg);
		cur += len + 1;
	}
}

static void dump_linnum(int col, int cur, int lst) {
	uint8_t seg;
	uint16_t p1, p2;
	--lst; // drop CRC
	seg = obj[cur++];
	printf(" %02x", seg);
	col += 3;
	while (cur < lst) {
		p1 = obj[cur++];
		p1 |= (obj[cur++] << 8);
		p2 = obj[cur++];
		p2 |= (obj[cur++] << 8);
		printf(" %04x=%d", p1, p2);
		col += 9;
		if (col > 75) {
			col = 0;
			printf("\n");
		}
	}
	if (col) printf("\n");
}

static void dump_fixloc(int col, int cur, int lst) {
	uint8_t unk;
	uint16_t val;
	--lst; // drop CRC
	unk = obj[cur++];
	printf(" %02x", unk);
	col += 3;
	while (cur < lst) {
		val = obj[cur++];
		val |= (obj[cur++] << 8);
		printf(" %04x", val);
		col += 5;
		if (col > 75) {
			col = 0;
			printf("\n");
		}
	}
	if (col) printf("\n");
}

static void dump_fixseg(int col, int cur, int lst) {
	uint8_t seg;
	uint8_t unk;
	uint16_t val;
	--lst; // drop CRC
	seg = obj[cur++];
	unk = obj[cur++];
	printf(" %s %02x", segs[seg], unk);
	col += strlen(segs[seg]) + 4;
	while (cur < lst) {
		val = obj[cur++];
		val |= (obj[cur++] << 8);
		printf(" %04x", val);
		col += 5;
		if (col > 75) {
			col = 0;
			printf("\n");
		}
	}
	if (col) printf("\n");
}

static void dump_extnam(int col, int cur, int lst) {
	uint8_t seg;
	int len;
	--lst; // drop CRC
	printf("\n");
	while (cur < lst) {
		len = obj[cur++];
		seg = obj[cur + len];
		printf("    \"%.*s\" %02x\n", len, obj + cur, seg);
		cur += len + 1;
	}
}

static void dump_locdef(int col, int cur, int lst) {
	uint8_t seg;
	uint8_t p1;
	uint16_t val;
	int len;
	--lst; // drop CRC
	seg = obj[cur++];
	printf(" %s:\n", segs[seg]);
	while (cur < lst) {
		val = obj[cur++];
		val |= (obj[cur++] << 8);
		len = obj[cur++];
		seg = obj[cur + len];
		printf("    %04x \"%.*s\" %02x\n", val, len, obj + cur, seg);
		cur += len + 1;
	}
}

static void dump_fixext(int col, int cur, int lst) {
	uint16_t p1, p2;
	uint8_t co = obj[cur++];
	printf(" %02x", co);
	col += 3;
	--lst; // drop CRC
	while (cur < lst) {
		p1 = obj[cur++];	// symbol id
		p1 |= (obj[cur++] << 8);
		p2 = obj[cur++];	// offset
		p2 |= (obj[cur++] << 8);
		printf(" %d:%04x", p1, p2);
		col += 8;
		if (col > 75) {
			col = 0;
			printf("\n");
		}
	}
	if (col) printf("\n");
}

static void dump_modhdr(int col, int cur, int lst) {
	int len = obj[cur++];
	uint8_t ti = obj[cur + len];
	uint8_t tv = obj[cur + len + 1];
	uint16_t sl;
	printf(" \"%.*s\" %02x %02x", len, obj + cur, ti, tv);
	col += len + 9;
	cur += len + 2;
	--lst; // drop CRC
	while (cur < lst) {
		ti = obj[cur++];
		sl = obj[cur++];
		sl |= (obj[cur++] << 8);
		tv = obj[cur++];
		printf(" %s,%04x,%02x", segs[ti], sl, tv);
		col += strlen(segs[ti]) + 9;
		if (col > 75) {
			col = 0;
			printf("\n");
		}
	}
	if (col) printf("\n");
}

static void dump_pubdef(int col, int cur, int lst) {
	uint8_t seg;
	int len;
	uint16_t val;
	--lst; // drop CRC
	seg = obj[cur++];
	printf(" %s:\n", segs[seg]);
	while (cur < lst) {
		val = obj[cur++];
		val |= (obj[cur++] << 8);
		len = obj[cur++];
		seg = obj[cur + len];
		printf("    %04x \"%.*s\" %02x\n", val, len, obj + cur, seg);
		cur += len + 1;
	}
}

static void dump_rec(int col, uint8_t typ, int cur, int lst) {
	uint8_t seg;
	uint16_t val;
	int len;
	switch (typ) {
	case R_LOCDEF:
		dump_locdef(col, cur, lst);
		break;
	case R_PUBDEF:
		dump_pubdef(col, cur, lst);
		break;
	case R_LIBHDR:
		dump_libhdr(col, cur, lst);
		break;
	case R_LIBNAM:
		dump_libnam(col, cur, lst);
		break;
	case R_LIBLOC:
		dump_libloc(col, cur, lst);
		break;
	case R_LIBDIC:
		dump_libdic(col, cur, lst);
		break;
	case R_LINNUM:
		dump_linnum(col, cur, lst);
		break;
	case R_EXTNAM:
		dump_extnam(col, cur, lst);
		break;
	case R_FIXLOC:
		dump_fixloc(col, cur, lst);
		break;
	case R_FIXEXT:
		dump_fixext(col, cur, lst);
		break;
	case R_FIXSEG:
		dump_fixseg(col, cur, lst);
		break;
	case R_ANCEST:
		len = obj[cur++];
		printf(" \"%.*s\"\n", len, obj + cur);
		break;
	case R_MODDAT:
		seg = obj[cur++];
		val = obj[cur++];
		val |= (obj[cur++] << 8);
		printf(" %s %04x\n", segs[seg], val);
		dump_raw(0, cur, lst);
		break;
	case R_MODHDR:
		dump_modhdr(col, cur, lst);
		break;
	default:
		dump_raw(col, cur, lst);
		break;
	}
}

static void dump_obj(int len) {
	int col;
	ptr = 0;
	uint8_t typ;
	uint16_t siz;
	int nxt;
	while (ptr < len) {
		typ = obj[ptr++];
		siz = obj[ptr++];
		siz |= (obj[ptr++] << 8);
		char *t = types[typ];
		if (t == NULL) {
			col = sprintf(buf, "UNK %02x (%d)", typ, siz);
		} else {
			col = sprintf(buf, "%s (%d)", t, siz);
		}
		nxt = ptr + siz;
		printf("%s", buf);
		dump_rec(col, typ, ptr, nxt);
		ptr = nxt;
	}
}

static void dump_file(char *file) {
	struct stat stb;
	if (obj) {
		free(obj);
		obj = NULL;
	}
	int fd = open(file, O_RDONLY);
	if (fd < 0) {
		perror(file);
		return;
	}
	fstat(fd, &stb);
	obj = malloc(stb.st_size);
	if (obj == NULL) {
		perror("malloc");
		close(fd);
		return;
	}
	if (read(fd, obj, stb.st_size) != stb.st_size) {
		perror(file);
		close(fd);
		return;
	}
	close(fd);
	dump_obj(stb.st_size);
}

int main(int argc, char **argv) {
	int x;
	// initialize segs[] array fully...
	for (x = 0; x < 256; ++x) {
		if (segs[x] != NULL) {
			continue;
		}
		sprintf(buf, "(named)%02x", x);
		segs[x] = strdup(buf);
	}
	for (x = 1; x < argc; ++x) {
		dump_file(argv[x]);
	}
	return 0;
}
