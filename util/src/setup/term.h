extern int initial();
extern int deinit();
extern ushort getkey();
extern ushort inchar();
extern void puts(char *buf);
extern void outchr(char c);
extern int printf(char *format, ...);
extern void putctl(char *buf);
extern void putnul(char c);
extern void cursor(int position);
extern int getwidth();
extern int getlength();
extern char *getterm();
extern void clrscr();
extern void curhome();
extern void curleft();
extern void curright();
extern void curup();
extern void curdown();
extern void clreel();
extern void clreop();
extern void curoff();
extern void curon();
extern void invon();
extern void invoff();
extern void bell();
