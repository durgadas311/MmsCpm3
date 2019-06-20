/*
 * pseudo-code (modern C) equivalent of SNIOSWIZ.ASM
 */

extern void outp(char p, char v);
extern char inp(char p);
extern void outir(char p, char *b, int len);
extern void inir(char p, char *b, int len);

#define WIZDAT	0x40	/* data port for SPI */
#define WIZCTL	0x41	/* ctrl port for SPI */

#define SCS	0x01	/* our /SCS bit in WIZCTL */

#define NSOCKS	8
#define SOCK0	0b00001000	/* base for socket regs BSB */
#define SOCKN	0b00100000	/* incrementer for socket BSB */
#define TXBUF0	0b00010100	/* base for TX buff BSB, w/WRITE */
#define RXBUF0	0b00011000	/* base for RX buff BSB */

/* common registers */
#define PMAGIC	29

/* socket registers */
#define SN_CR		1
#define SN_IR		2
#define SN_SR		3
#define SN_PRT		4
#define SN_TXWR		36
#define SN_RXRSR	38
#define SN_RXRD		40

/* socket SR bits */
#define RECV_RDY	0b00000100
#define SEND_OK		0b00010000

/* socket commands */
#define OPEN	0x01
#define CONNECT	0x04
#define SEND	0x20
#define RECV	0x40

/* socket statuses */
#define INIT		0x13
#define ESTABLISHED	0x17

/* cfgtbl_t.netsts bits */
#define STS_ACTIVE	0x10
#define STS_RCVERR	0x02
#define STS_SNDERR	0x01

/* netdev_t.map bits */
#define MAP_NETWORK	0x80	/* device is networked, not local */
#define MAP_DEVMSK	0x0f	/* remote device number */

typedef struct netdev_s {
	char	map;	/* MAP_xxx */
	char	sid;	/* server node ID */
} netdev_t;

typedef struct cpnhdr_s {
	char	fmt;
	char	did;	/* dest node ID */
	char	sid;	/* src node ID */
	char	fnc;	/* BDOS function code */
	char	len;	/* payload length - 1 */
	/* payload follows here: */
	char	msg[];
} cpnhdr_t;

typedef struct cfgtbl_s {
	char	netsts;	/* STS_xxx */
	char	nid;	/* slave node ID */
	netdev_t drvs[16]; /* A: thru P: */
	netdev_t con;	/* not used in CP/M 3 */
	netdev_t lst;	/* LST: */
	char	lstidx;
	cpnhdr_t lsthdr;
	char	_res[128 + 1]; /* space for payload */
} cfgtbl_t;

static cfgtbl_t CFGTBL = {
.netsts = 0,
.lsthdr.fmt = 0,
.lsthdr.sid = 0xff,	/* set in SNDMSG */
.lsthdr.fnc = 5,
};

static char srvtbl[NSOCKS];	/* SID, per socket */

static char cursok;	/* current socket select patn */
static int curptr;	/* into chip mem */
static char *msgptr;
static int msglen;
static int totlen;

static int serr() {
	CFGTBL.netsts |= STS_SNDERR;
	return -1;
}

static int rerr() {
	CFGTBL.netsts |= STS_RCVERR;
	return -1;
}

static char getwiz1(char bsb, char off) {
	char ret;
	outp(WIZCTL, SCS);
	outp(WIZDAT, 0);
	outp(WIZDAT, off);
	outp(WIZDAT, bsb);
	inp(WIZDAT);	/* prime MISO */
	ret = inp(WIZDAT);
	outp(WIZCTL, 0);	/* clear SCS */
	return ret;
}

static void putwiz1(char bsb, char off, char val) {
	outp(WIZCTL, SCS);
	outp(WIZDAT, 0);
	outp(WIZDAT, off);
	outp(WIZDAT, bsb | 0b00000100);
	outp(WIZDAT, val);
	outp(WIZCTL, 0);	/* clear SCS */
}

static int getwiz2(char bsb, char off) {
	int ret;
	outp(WIZCTL, SCS);
	outp(WIZDAT, 0);
	outp(WIZDAT, off);
	outp(WIZDAT, bsb);
	inp(WIZDAT);	/* prime MISO */
	ret = inp(WIZDAT) << 8;
	ret |= inp(WIZDAT);
	outp(WIZCTL, 0);	/* clear SCS */
	return ret;
}

static void putwiz2(char bsb, char off, int val) {
	outp(WIZCTL, SCS);
	outp(WIZDAT, 0);
	outp(WIZDAT, off);
	outp(WIZDAT, bsb | 0b00000100);
	outp(WIZDAT, (val >> 8) & 0xff);
	outp(WIZDAT, val & 0xff);
	outp(WIZCTL, 0);	/* clear SCS */
}

static int wizsts(char sok, char bits) {
	char s = getwiz1(sok, SN_IR);
	if ((s & bits) == bits) {
		/* don't reset if not set (could race) */
		putwiz1(sok, SN_IR, bits);
	}
	return s;
}

static char wizcmd(char sok, char cmd) {
	outp(WIZCTL, SCS);
	outp(WIZDAT, 0);
	outp(WIZDAT, SN_CR);
	outp(WIZDAT, sok | 0b00000100);
	outp(WIZDAT, cmd);
	outp(WIZCTL, 0);	/* clear SCS */
	while (getwiz1(sok, SN_CR) != 0);
	return getwiz1(sok, SN_SR);
}

static void cpsetup(char bsb, int ptr) {
	outp(WIZCTL, SCS);
	outp(WIZDAT, (ptr >> 8) & 0xff);
	outp(WIZDAT, ptr & 0xff);
	outp(WIZDAT, bsb | cursok);
}

static void cpyin(int ptr, int len) {
	cpsetup(RXBUF0, ptr);
	inp(WIZDAT);	/* prime MISO */
	inir(WIZDAT, msgptr, len);
	msgptr += len;
	outp(WIZCTL, 0);	/* clear SCS */
}

static void cpyout(int ptr, int len) {
	cpsetup(TXBUF0, ptr);
	outir(WIZDAT, msgptr, len);
	msgptr += len;
	outp(WIZCTL, 0);	/* clear SCS */
}

static int getsrv(char nid) {
	int b;
	for (b = 0; b < NSOCKS; ++b) {
		if (srvtbl[b] == nid) goto got;
	}
	return -1;
got:
	b <<= 5;
	cursok = b;
	b |= SOCK0;
	int s = getwiz1(b, SN_SR);
	if (s == ESTABLISHED) {
		return b;
	}
	if (s != INIT) {
		s = wizcmd(b, INIT);
	}
	if (s == INIT) {
		s = wizcmd(b, CONNECT);
	}
	if (s != ESTABLISHED) {
		return -1;
	}
	return 0;
}

static int check() {
	int to;
	/* first, make sure at least one is active */
	int sok = SOCK0;
	for (int b = 0; b < NSOCKS; ++b) {
		if (getwiz1(sok, SN_SR) == ESTABLISHED) {
			goto gotone;
		}
		sok += SOCKN;
	}
	return -1;
gotone:
	/* now wait for data to be received, but not forever */
	to = 32000;
	while (to-- > 0) {
		sok = SOCK0;
		for (int b = 0; b < NSOCKS; ++b) {
			if ((wizsts(sok, RECV_RDY) & RECV_RDY)) {
				/* cursok = sok & 0b11100000; ???! */
				return sok;
			}
			sok += SOCKN;
		}
	}
	return -1;
}

static int ntwkbt0() {
	int p;
	/* load socket server IDs based on W5500 current config */
	int sok = SOCK0;
	for (int b = 0; b < NSOCKS; ++b) {
		p = getwiz2(sok, SN_PRT);
		srvtbl[b] = ((p & 0xff00) != 0x3100 ? 0xff : p & 0xff);
		sok += SOCKN;
	}
	return 0;
}

int NTWKIN() {
	char nid = getwiz1(0, PMAGIC);
	if (nid == 0) {
		return -1;
	}
	CFGTBL.nid = nid;
	CFGTBL.netsts = STS_ACTIVE;
	CFGTBL.lsthdr.len = 0;
	return ntwkbt0();
}

int NTWKBT() {
	if ((CFGTBL.netsts & STS_ACTIVE) == 0) {
		return NTWKIN();
	}
	return ntwkbt0();
}

int NTWKST() {
	int ret = CFGTBL.netsts;
	CFGTBL.netsts &= ~(STS_RCVERR | STS_SNDERR);
	return ret;
}

void NTWKER() {
	/* nothing to do? */
}

cfgtbl_t *CNFTBL() {
	return &CFGTBL;
}

int SNDMSG(cpnhdr_t *msg) {
	msgptr = (char *)msg;
	int sok = getsrv(msg->did);
	if (sok < 0) {
		return serr();
	}
	msg->sid = CFGTBL.nid;
	msglen = msg->len + sizeof(*msg) + 1;
	curptr = getwiz2(sok, SN_TXWR);
	putwiz2(sok, SN_TXWR, msglen + curptr);
	cpyout(curptr, msglen);
	wizcmd(sok, SEND);
	if (!(wizsts(sok, SEND_OK) & SEND_OK)) {
		return serr();
	}
	return 0;
}

int RCVMSG(cpnhdr_t *msg) {
	msgptr = (char *)msg;
	int sok = check();
	if (sok < 0) {
		return rerr();
	}
	totlen = 0;
	for (;;) {
		int hl = getwiz2(sok, SN_RXRSR);
		if (hl == 0) continue;
		msglen = hl;
		curptr = getwiz2(sok, SN_RXRD);
		totlen -= msglen;
		putwiz2(sok, SN_RXRD, msglen + curptr);
		cpyin(curptr, msglen);
		wizcmd(sok, RECV);
		if (totlen < 0) {
			/* must be msg hdr - first recv */
			totlen += msg->len + sizeof(*msg) + 1;
			if (totlen < 0) { /* something wrong */
				return rerr();
			}
		}
		if (totlen == 0) break;
	}
	return 0;
}
