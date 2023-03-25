# Makefile for MMS CP/M 2.24 linkable modules

BOOTS = b320.hex bz17.hex bz37.hex b5316.hex
MODULES = m320.hex z17.hex z37.hex m316.hex

all: $(addprefix ../bin/,$(BOOTS) $(MODULES))

../bin/%.hex: %.asm
	zmac --dri -i -8 -c -s -n $<
	cp zout/$*.hex $@
	cp zout/$*.lst ../prn

%0.hex: %.asm
	zmac --dri -i -8 -c -s -n --od . -o $@ $<

%1.hex: %.asm
	zmac -DBUMP --dri -i -8 -c -s -n --od . -o $@ $<
