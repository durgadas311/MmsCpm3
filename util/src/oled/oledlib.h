/*
 * Routines for accessing SSD1306-based OLED displays.
 */

/* control bytes for command/data */
#define OLED_CMD	0x00
#define OLED_DAT	0x40

extern int oledinit();
extern int oledbuf(); /* (char *buf, int len, char ctl) */
