/*
 * I/O to SSD1306 OLED display controller over I2C
 */
#include "i2clib.h"
#include "oledlib.h"

static char init[] = {
	0xae, 0x20,0, 0xc8, 0x40, 0x81,0x7f, 0xa1,
	0xa6, 0xa8,0x3f, 0xd3,0, 0xd5,0x80, 0xd9,0x22,
	0xda,0x12, 0xdb,0x20, 0x8d,0x14, 0xa4, 0xaf,
/* now reset address */
	0x21,0,127,0x22,0,7
};

int oledinit()
{
	i2cinit();
	return oledbuf(init, sizeof(init), OLED_CMD);
}

/*
 * Send buffer full of data or commands to SSD1306.
 * Does START if not already done, always does STOP.
 * ctl = 0x00: command(s) in buf
 * ctl = 0x40: data (for screen)
 */
int oledbuf(buf, len, ctl)
char *buf;
int len;
char ctl;
{
	int e;

	i2cstart();	/* START if not already */
	e = i2cput(0x78);		/* I2C adr of SSD1306 */
	if (!e) e = i2cput(ctl);	/* select commands or data */
	while (!e && len-- > 0) {
		e = i2cput(*buf++);
	}
	i2cstop();
	return e;
}
