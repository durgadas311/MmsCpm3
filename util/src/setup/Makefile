# Makefile for building SETUP30 using zcc

# aparent link order:
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

all: setup.com

%.o: %.c
	zcc +cpm -c -o $@ -DAMALLOC -DAMALLOC3 $<

objs: $(LINKS)

setup.com: $(LINKS)
	zcc +cpm -o $@ $(LINKS)

clean:
	rm -f *.o
