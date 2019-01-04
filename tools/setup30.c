/*
 * SETUP.COM equivalent for host PCs
 *
 * Usage: setup30 [options] <bnkbios3.spr>
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>

#define BIOS_START	0x100	// skip SPR header

// Relative to BIOS_START:
#define LOGPHYPTR	BIOS_START + 0x65	// pointer to logical-physical drive table
#define	THRDSTR		BIOS_START + 0x67	// pointer to start of linked modules
#define	MEMSTR		BIOS_START + 0x84	// pointer to memory/rtc modules strings
#define	DEFSRC		BIOS_START + 0x7e	// drive search order (path)
#define	TMPDRV		BIOS_START + 0x82	// temp drive
#define	SCRTYP		BIOS_START + 0x83	// type search (.com/.sub)

// Relative to driver start (thread)
#define PHYDEVNUM	2
#define NUMDEV		3

// Disk I/O drivers:
#define	DSKSTRADR	0x10	// module description string(s)
#define	MODEADR		0x14	// drive modes table
// Char I/O drivers:
#define	CHRSTRADR	0x13	// module description string(s)

// Drive/Media common modes, relative to byte
#define MD_DS	0x40
#define MD_DT	0x20
#define MD_DD	0x10
// absolute position
#define MD_STEP	0x0c00

static int steps[2][4] = {
	{  6, 12, 20, 30 },
	{  3,  6, 10, 15 },
};

static char *get_string(uint8_t *spr, int str) {
	static char buf[128];
	int x;
	for (x = 0; x < sizeof(buf) && spr[str] != '$'; ++x) {
		buf[x] = (char)spr[str++];
		if (!buf[x]) --x;
	}
	buf[x++] = '\0';
	return buf;
}

static int get_module(uint8_t *spr, uint8_t pdrv) {
	int x;
	int thrd = spr[THRDSTR];
	thrd |= spr[THRDSTR + 1] << 8;
	while (thrd != 0) {
		thrd += BIOS_START;
		int nxt = spr[thrd];
		nxt |= spr[thrd + 1] << 8;
		if (nxt == 0) {
			break;
		}
		uint8_t pbas = spr[thrd + PHYDEVNUM];
		uint8_t pnum = spr[thrd + NUMDEV];
		if (pbas < 200 && pdrv >= pbas && pdrv < pbas + pnum) {
			return thrd;
		}
		thrd = nxt;
	}
	return 0;
}

static char *get_driver(uint8_t *spr, uint8_t pdrv) {
	static char buf[128];
	int mod = get_module(spr, pdrv);
	if (mod) {
		int str = spr[mod + DSKSTRADR];
		str |= spr[mod + DSKSTRADR + 1] << 8;
		str += BIOS_START;
		return get_string(spr, str);
	}
	return "No Driver";
}

static void dump_path(uint8_t *spr) {
	int i;
	int c = ' ';
	int d;
	printf("Drive Search Order =");
	for (i = 0; i < 4; ++i) {
		d = spr[DEFSRC + i];
		if (d == 255) {
			break;
		}
		if (d == 0) {
			printf("%cDef", c);
		} else {
			printf("%c%c:", c, d + 'A' - 1);
		}
		c = ',';
	}
	d = spr[TMPDRV];
	printf(" Temporary Drive = ");
	if (d == 0) {
		printf("Def");
	} else {
		printf("%c:", d + 'A' - 1);
	}
	printf("\n");
}

static void dump_modules(uint8_t *spr) {
	int str;
	printf("Modules Linked:\n");
	str = spr[MEMSTR];
	str |= spr[MEMSTR + 1] << 8;
	str += BIOS_START;
	printf("    %s\n", get_string(spr, str));
	str = spr[MEMSTR + 2];
	str |= spr[MEMSTR + 3] << 8;
	if (str != 0) {
		str += BIOS_START;
		printf("    %s\n", get_string(spr, str));
	}
	int thrd = spr[THRDSTR];
	thrd |= spr[THRDSTR + 1] << 8;
	while (thrd != 0) {
		thrd += BIOS_START;
		int nxt = spr[thrd];
		nxt |= spr[thrd + 1] << 8;
		if (nxt == 0) {
			break;
		}
		uint8_t pbas = spr[thrd + PHYDEVNUM];
		uint8_t pnum = spr[thrd + NUMDEV];
		if (pbas < 200) {
			str = spr[thrd + DSKSTRADR];
			str |= spr[thrd + DSKSTRADR + 1] << 8;
		} else {
			str = spr[thrd + CHRSTRADR];
			str |= spr[thrd + CHRSTRADR + 1] << 8;
		}
		str += BIOS_START;
		printf("    %s\n", get_string(spr, str));
		thrd = nxt;
	}
}

static void dump_modes(uint8_t *spr) {
	int d;
	int thrd = spr[THRDSTR];
	thrd |= spr[THRDSTR + 1] << 8;
	printf("Drive Modes:\n");
	while (thrd != 0) {
		thrd += BIOS_START;
		int nxt = spr[thrd];
		nxt |= spr[thrd + 1] << 8;
		if (nxt == 0) {
			break;
		}
		uint8_t pbas = spr[thrd + PHYDEVNUM];
		uint8_t pnum = spr[thrd + NUMDEV];
		if (pbas >= 200) {
			thrd = nxt;
			continue;
		}
		int modes = spr[thrd + MODEADR];
		modes |= spr[thrd + MODEADR + 1] << 8;
		modes += BIOS_START;
		for (d = 0; d < pnum; ++d) {
			if ((spr[modes] & 0x80) != 0) {
				continue;	// hard disk
			}
			printf("    %3d ", d + pbas);
			int mode = spr[modes + 2];
			if ((mode & 0x80) != 0) {
				printf("8\" ");
			} else {
				printf("5\" ");
			}
			if ((mode & 0x20) != 0) {
				printf("DDT ");
			} else {
				printf("DST ");
			}
			if ((mode & 0x40) != 0) {
				printf("DDS ");
			} else {
				printf("DSS ");
			}
			if ((mode & 0x10) != 0) {
				printf("DDD ");
			} else {
				printf("DSD ");
			}
			printf ("%2dmS ", steps[(mode & 0x80) != 0][(mode & 0x0c) >> 2]);
			mode = spr[modes + 3];
			if ((mode & 0x20) != 0) {
				printf("MDT ");
			} else {
				printf("MST ");
			}
			if ((mode & 0x40) != 0) {
				printf("MDS ");
			} else {
				printf("MSS ");
			}
			if ((mode & 0x10) != 0) {
				printf("MDD ");
			} else {
				printf("MSD ");
			}
			printf("\n");
			modes += 8;
		}
		thrd = nxt;
	}
}

static void dump_lptbl(uint8_t *spr) {
	int d;
	int p;
	int j;
	int lptbl = spr[LOGPHYPTR];
	lptbl |= spr[LOGPHYPTR + 1] << 8;
	lptbl += BIOS_START;
	printf("Logical/Physical Drives:\n");
	for (d = 0; d < 16; ++d) {
		p = spr[lptbl + d];
		if (p == 255) {
			printf("    %c: = Unassigned\n", d + 'A');
		} else {
			printf("    %c: = %3d %s", d + 'A', p,
				get_driver(spr, p));
			for (j = 0; j < 16; ++j) {
				if (j == d) continue;
				if (spr[lptbl + j] == p) {
					printf("\t!Duplicate!");
					break;
				}
			}
			printf("\n");
		}
	}
}

static int parse_lpent(char *s, char **e, int *d, int *p) {
	char *t = s;
	char *u;
	long l;
	while (*t && *t != ',') ++t;
	*e = t;
	int c = toupper(*s++);
	if (c < 'A' || c > 'P') {
		return 1;
	}
	*d = c - 'A';
	if (*s == ':') {
		++s;
	}
	if (*s == '=') {
		++s;
	}
	l = strtol(s, &u, 10);
	if (u != t || l > 255 || l < 0) {
		return 1;
	}
	*p = (int)l;
	return 0;	// no error
}

static void erase_lptbl(uint8_t *spr) {
	int d;
	int lptbl = spr[LOGPHYPTR];
	lptbl |= spr[LOGPHYPTR + 1] << 8;
	lptbl += BIOS_START;
	for (d = 0; d < 16; ++d) {
		spr[lptbl + d] = 255;
	}
}

static int change_lptbl(uint8_t *spr, char *args) {
	int d, p;
	char *s = args;
	char *e;
	int lptbl = spr[LOGPHYPTR];
	lptbl |= spr[LOGPHYPTR + 1] << 8;
	lptbl += BIOS_START;
	while (*s) {
		if (parse_lpent(s, &e, &d, &p)) {
			fprintf(stderr, "Invalid log/phy drive spec \"%.*s\"\n",
					(int)(e - s), s);
			return 1;
		}
		spr[lptbl + d] = (uint8_t)p;
		s = e;
		if (*s == ',') ++s;
	}
	return 0;	// no error
}

static int parse_modes(uint8_t *spr, char *s, char **e, int *ma, int *p, int *m, int *k) {
	char *t = s;
	char *u;
	long l;
	int c;
	int tm;
	int sh;
	*m = 0;
	*k = 0;
	while (*t && *t != ';') ++t;
	*e = t;
	l = strtol(s, &u, 10);
	if (*u != '=' || l >= 200 || l < 0) {
		return 1;
	}
	s = ++u;
	*p = (int)l;
	int mod = get_module(spr, *p);
	if (!mod) {
		return 1;
	}
	int modes = spr[mod + MODEADR];
	modes |= spr[mod + MODEADR + 1] << 8;
	modes += BIOS_START;
	modes += (*p - spr[mod + PHYDEVNUM]) * 8;
	*ma = modes;
	// parse comma-separated list of modes...
	while (s < t) {
		if (isdigit(*s)) { // step rate
			// TODO: allow for "mS" suffix?
			l = strtol(s, &u, 10);
			if (*u && *u != ',' || l < 0) {
				return 1;
			}
			int z = ((spr[modes + 2] & 0x80) != 0);
			for (int x = 3; x >= 0; --x) {
				if (l >= steps[z][x]) {
					*m |= (x << 10);
					break;
				}
			}
			*k |= MD_STEP;
			s = u;
			if (*s == ',') {
				++s;
			}
			continue;
		}
		c = toupper(*s++);
		if (c == 'D') {		// Drive flags
			sh = 8;
		} else if (c == 'M') {	// Media flags
			sh = 0;
		} else {
			return 1;
		}
		c = toupper(*s++);
		if (c == 'D') {		// Double something
			tm = 1;
		} else if (c == 'S') {	// Single something
			tm = 0;
		} else {
			return 1;
		}
		c = toupper(*s++);
		if (c == 'D') {		// Density
			tm = (tm ? MD_DD : 0);
			*k |= (MD_DD << sh);
		} else if (c == 'S') {	// Sides
			tm = (tm ? MD_DS : 0);
			*k |= (MD_DS << sh);
		} else if (c == 'T') {	// Tracks
			tm = (tm ? MD_DT : 0);
			*k |= (MD_DT << sh);
		} else {
			return 1;
		}
		*m |= (tm << sh);
		if (*s == ',') {
			++s;
		}
	}
	return 0;	// no error
}

static int change_modes(uint8_t *spr, char *args) {
	int p;
	int m;	// bytes 2,3 as 16-bit word, big-endian
	int ma;
	int msk;
	char *s = args;
	char *e;
	while (*s) {
		if (parse_modes(spr, s, &e, &ma, &p, &m, &msk)) {
			fprintf(stderr, "Invalid mode spec \"%.*s\"\n",
					(int)(e - s), s);
			return 1;
		}
		if (msk) {	// something to change...
			int mode = spr[ma + 2] << 8;
			mode |= spr[ma + 3];
			mode &= ~msk;
			mode |= m;
			spr[ma + 2] = (uint8_t)(mode >> 8);
			spr[ma + 3] = (uint8_t)(mode);
		}
		s = e;
		if (*s == ';') ++s;
	}
	return 0;	// no error
}

static int parse_path(char *s, char **e, int *p) {
	char *t = s;
	char *u;
	while (*t && *t != ',') ++t;
	*e = t;
	// might be "def", or "d:"...
	int c = toupper(*s++);
	if (c < 'A' || c > 'P') {
		return 1;
	}
	if (*s == ':') {
		*p = (c - 'A' + 1);
		++s;
	} else {
		c = toupper(*s++);
		if (c != 'E') {
			return 1;
		}
		c = toupper(*s++);
		if (c != 'F') {
			return 1;
		}
		*p = 0;
	}
	if (*s && *s != ',') {
		return 1;
	}
	return 0;	// no error
}

static int change_path(uint8_t *spr, char *args) {
	int x = 0;
	int p;
	char *s = args;
	char *e;
	while (*s) {
		if (parse_path(s, &e, &p)) {
			fprintf(stderr, "Invalid search order spec \"%.*s\"\n",
					(int)(e - s), s);
			return 1;
		}
		if (x < 4) {
			spr[DEFSRC + x++] = p;
		} else {
			fprintf(stderr, "Ignoring excess search order spec \"%.*s\"\n",
					(int)(e - s), s);
		}
		s = e;
		if (*s == ',') ++s;
	}
	while (x < 4) {
		spr[DEFSRC + x++] = 255;
	}
	return 0;	// no error
}

static int change_temp(uint8_t *spr, char *args) {
	int p;
	char *s = args;
	char *e;
	if (parse_path(s, &e, &p)) {
		fprintf(stderr, "Invalid temp drive spec \"%.*s\"\n",
				(int)(e - s), s);
		return 1;
	}
	if (*e) {
		fprintf(stderr, "Extra temp drive spec \"%s\"\n", args);
		return 1;
	}
	spr[TMPDRV] = p;
	return 0;	// no error
}

static void add_string(char **var, char *str, char *c) {
	int n = strlen(str);
	if (*var == NULL) {
		*var = malloc(n + 1);
		strcpy(*var, str);
	} else {
		char *old = *var;
		int o = strlen(old);
		*var = malloc(n + o + 2);
		strcpy(*var, old);
		strcat(*var, c);
		strcat(*var, str);
		free(old);
	}
}

int main(int argc, char **argv) {
	int x;
	int fd;
	struct stat stb;
	uint8_t *spr;
	int change = 0;
	int Mopt = 0;
	int Dopt = 0;
	int Eopt = 0;
	int Lopt = 0;
	int Popt = 0;
	int anyopt = 0;
	char *dopt = NULL;
	char *mopt = NULL;
	char *popt = NULL;
	char *topt = NULL;

	extern int optind;
	extern char *optarg;
	// TODO: set temp drive? .com/.sub?
	while ((x = getopt(argc, argv, "d:m:p:t:DELMP")) != EOF) {
		++anyopt;
		switch(x) {
		case 'd':	// log/phy drive
			++Dopt;	// show what changed
			add_string(&dopt, optarg, ",");
			++change;
			break;
		case 'm':	// drive modes
			++Mopt;	// show what changed
			add_string(&mopt, optarg, ";");
			++change;
			break;
		case 'p':	// drive search path
			++Popt;	// show what changed
			add_string(&popt, optarg, ",");
			++change;
			break;
		case 't':	// drive search path
			++Popt;	// show what changed
			add_string(&topt, optarg, ",");
			++change;
			break;
		case 'D':
			++Dopt;
			break;
		case 'E':
			++Eopt;
			++Dopt;	// show what changed
			++change;
			break;
		case 'L':
			++Lopt;
			break;
		case 'M':
			++Mopt;
			break;
		case 'P':
			++Popt;
			break;
		}
	}
	if (argc - optind != 1) {
		fprintf(stderr,
			"Usage: %s [options] <bnkbios3.spr>\n"
			"Options:\n"
			"    -D       Show logical/physical drive table\n"
			"    -L       Show linked modules\n"
			"    -M       Show drive modes\n"
			"    -P       Show drive search order/temp drive\n"
			"    -E       Erase logical/physical table first\n"
			"    -d dspec Set logical/physical drive\n"
			"    -m mspec Set drive modes\n"
			"    -p pspec Set drive search order\n"
			"    -t pspec Set temp drive\n"
			"dspec:  d:=n {d: A..P}, n:phy or 255\n"
			"mspec:  n=m.. n:phy, {m: DDS,MDS,...}\n"
			"pspec:  d:.. {d: A..P,def}\n"
			, argv[0]);
		exit(1);
	}
	if (!anyopt) {
		++Dopt;
		++Lopt;
		++Mopt;
		++Popt;
	}

	fd = open(argv[optind], O_RDONLY);
	if (fd < 0) {
		perror(argv[optind]);
		exit(1);
	}
	fstat(fd, &stb);
	spr = malloc(stb.st_size);
	if (spr == NULL) {
		perror("malloc");
		close(fd);
		exit(1);
	}
	if (read(fd, spr, stb.st_size) != stb.st_size) {
		perror(argv[optind]);
		close(fd);
		exit(1);
	}
	close(fd);
	if (change) {
		if (Eopt) {
			erase_lptbl(spr);
		}
		if (dopt && change_lptbl(spr, dopt)) {
			exit(1);
		}
		if (mopt && change_modes(spr, mopt)) {
			exit(1);
		}
		if (popt && change_path(spr, popt)) {
			exit(1);
		}
		if (topt && change_temp(spr, topt)) {
			exit(1);
		}
		fd = open(argv[optind], O_WRONLY);
		if (fd < 0) {
			perror(argv[optind]);
			exit(1);
		}
		if (write(fd, spr, stb.st_size) != stb.st_size) {
			perror(argv[optind]);
			close(fd);
			exit(1);
		}
		if (close(fd) < 0) {
			perror(argv[optind]);
			exit(1);
		}
	}
	if (Dopt) {
		dump_lptbl(spr);
	}
	if (Popt) {
		dump_path(spr);
	}
	if (Mopt) {
		dump_modes(spr);
	}
	if (Lopt) {
		dump_modules(spr);
	}
	return 0;
}
