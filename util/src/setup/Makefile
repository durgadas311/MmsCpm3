# Makefile for building SETUP30 using zcc (z88dk)
# Terminal definition may be built-in or loaded from A:TERMINAL.SYS,
# determined at link time.

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
	zcc +cpm -c -o $@ -DAMALLOC -DAMALLOC3 $<

objs: $(LINKS)

# "normal" version, uses A:TERMINAL.SYS for term def.
setup.com: $(LINKS) termext.o
	zcc +cpm -o $@ $(LINKS) termext.o

# H19 version, builtin term def.
setuph19.com: $(LINKS) termint.o h19.o
	zcc +cpm -o $@ $(LINKS) termint.o h19.o

# Kaypro Magic Wand keypad version, builtin term def.
setupkp.com: $(LINKS) termint.o kaypro.o
	zcc +cpm -o $@ $(LINKS) termint.o kaypro.o

clean:
	rm -f *.o

# TERMINAL.SYS file images
%.sys: %.o
	zcc +cpm -o $@ --no-crt $^

.PRECIOUS: %.o
