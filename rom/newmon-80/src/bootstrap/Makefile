all: cfhdos.cim

ram.lib core.lib setup.lib:
	ln -s ../../../newmon/src/$@ $@

%.cim: %.asm ram.lib
	zmac --dri -i -8 -c -s -n --od . --oo lst,cim $<
