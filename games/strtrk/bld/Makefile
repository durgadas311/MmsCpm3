# Assumes PWD = CPMDrive_D

export CPMDrive_D = $(PWD)
export CPMDefault = d:

all: strtrk-kp.com strtrk-h19.com

%.rel: %.c
	vcpm c $*.c
	vcpm rmac $*.asm '$$SZPZ'

st-kp.rel: strtrk.c termkp.h
	cp -f termkp.h keybd.h
	vcpm c strtrk.c
	vcpm rmac strtrk.asm '$$SZPZ'
	mv -f strtrk.rel $@

st-h19.rel: strtrk.c termkp.h
	cp -f termh19.h keybd.h
	vcpm c strtrk.c
	vcpm rmac strtrk.asm '$$SZPZ'
	mv -f strtrk.rel $@

strtrk-kp.com: st-kp.rel kpcpm.rel termkp.rel termkp.h
	vcpm link strtrk=st-kp,kpcpm,termkp,a:clibrary,a:stdlib,a:c80ilib.irl'[s,oc,nr]'
	mv strtrk.com $@

strtrk-h19.com: st-h19.rel kpcpm.rel termh19.rel termh19.h
	cp -f termh19.h keybd.h
	vcpm link strtrk=st-h19,kpcpm,termh19,a:clibrary,a:stdlib,a:c80ilib.irl'[s,oc,nr]'
	mv strtrk.com $@

clean:
	rm -f *.asm *.rel

# There are run from dev dir, e.g. ~/CpmDev/strtrk
# push built files back into repo... new files must be manually copied
syncup:
	rsync -Wurv --existing . ~/git/MmsCpm3/games/strtrk/bin/.

# pull source files down from repo...
syncdown:
	unix2cpm -s ~/git/MmsCpm3/games/strtrk/src/*.[ch] .
