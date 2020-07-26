# Makefile for building SETUP30 using zcc (z88dk)
# Terminal definition may be built-in or loaded from A:TERMINAL.SYS,
# determined at link time.

CC = zcc
CFLAGS = +cpm -set-r2l-by-default
CLIBS =

# Core modules to link
LINKS = \
	setup30.o \
	setlptbl.o \
	ioredir.o \
	ftsord.o \
	chario.o \
	diskio.o \
	display.o \
	term.o \
	serdp.o \
	getdrvtb.o \
	putdrvtb.o \
	btconv.o \
	tbconv.o \
	biosfile.o \
	errmsg.o \
	caller.o

all: setup.com setuph19.com setupkp.com h19.sys kaypro.sys

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs: $(LINKS)

# "normal" version, uses A:TERMINAL.SYS for term def.
setup.com: $(LINKS) termext.o
	$(CC) $(CFLAGS) -o $@ $(LINKS) termext.o $(CLIBS)

# H19 version, builtin term def.
setuph19.com: $(LINKS) termint.o h19.o
	$(CC) $(CFLAGS) -o $@ $(LINKS) termint.o h19.o $(CLIBS)

# Kaypro Magic Wand keypad version, builtin term def.
setupkp.com: $(LINKS) termint.o kaypro.o
	$(CC) $(CFLAGS) -o $@ $(LINKS) termint.o kaypro.o $(CLIBS)

clean:
	rm -f *.o

# TERMINAL.SYS file images
%.sys: %.o
	$(CC) $(CFLAGS) -o $@ --no-crt $^

.PRECIOUS: %.o
