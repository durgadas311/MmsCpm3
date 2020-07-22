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
	btconv.o \
	biosfile.o \
	caller.o

all: setup.com

%.o: %.c
	zcc +cpm -c -o $@ $<

objs: $(LINKS)

setup.com: $(LINKS)
	zcc +cpm -o $@ $(LINKS)
