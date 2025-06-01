/*
 * I/O to SSD1306 OLED display controller over I2C
 */
#include "i2clib.h"

int oledinit()
{
	i2cinit();
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
