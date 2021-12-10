export ISIS_F0 = $(PWD)
export ISIS_F1 = $(HOME)/git/intel80tools/itools/plm80_3.1
export ISIS_F2 = $(HOME)/git/intel80tools/itools/link_3.0
export ISIS_F3 = $(HOME)/git/intel80tools/itools/asm80_4.1
export ISIS_F4 = $(HOME)/git/intel80tools/itools/locate_3.0
export ISIS_F5 = $(HOME)/git/intel80tools/itools/isis_4.3

export CPMDrive_D = $(PWD)
export CPMDefault = d:

# Files required to build "all"
SRC_ALL = da.plm dm.plm dp.plm dse.plm dsh.plm dso.plm dts.plm \
	mschd.plm show.plm sn.plm tod.plm \
	copyrt.lit proces.lit queue.lit xdos.lit \
	genmod.asm x0100.asm x0200.asm

MODS = $(wildcard *.mod)
NOTYPES = $(subst .mod,,$(MODS))

# Also might require newer GENMOD.COM...
all: sched.prl sdir.prl show.prl tod.prl

%.obj: %.asm
	thames :f3:asm80 $? debug

%.obj: %.plm
	thames :f1:plm80 $? debug

#%: %.mod
#	thames :f4:locate $? 'code(0100h)' 'stacksize(100)'

%: %.plm
	thames :f1:plm80 $? 'object($*)' debug

%1.hex: %.obj x0100.obj
	thames :f2:link $*.obj,x0100.obj,plm80.lib to $*.mod
	thames :f4:locate $*.mod 'code(0100h)' 'stacksize(100)'
	thames :f5:objhex $* to $@

%2.hex: %.obj x0200.obj
	thames :f2:link $*.obj,x0200.obj,plm80.lib to $*.mod
	thames :f4:locate $*.mod 'code(0200h)' 'stacksize(100)'
	thames :f5:objhex $* to $@

d1.hex: x0100.obj dm sn dse dso dsh dp da dts
	thames :f2:link x0100.obj,dm,sn,dse,dso,dsh,dp,da,dts,plm80.lib to d1.mod
	thames :f4:locate d1.mod 'code(0100h)' 'stacksize(100)'
	thames :f5:objhex d1 to $@

d2.hex: x0200.obj dm sn dse dso dsh dp da dts
	thames :f2:link x0200.obj,dm,sn,dse,dso,dsh,dp,da,dts,plm80.lib to d2.mod
	thames :f4:locate d2.mod 'code(0200h)' 'stacksize(100)'
	thames :f5:objhex d2 to $@

%.com: %
	obj2bin $? $@
	seteof $@

%.hex: %.asm
	vcpm mac $? '$$SZ'

%.com: %.hex
	vcpm hexcom $*

%.rel: %.asm
	vcpm rmac $? '$$SZ'

%.prl: %.rel
	vcpm link $*'[op,nr]'

clobber:
	rm -f *.obj *.hex *.rel *.mod *.com *.lst *.prn *.rsx $(NOTYPES)

%-patch: __FRC__
	vcpm ./$@

#tod.mod: tod.obj x0100.obj
#	thames :f2:link tod.obj,x0100.obj,plm80.lib to tod.mod

%.prl: %1.hex %2.hex
	vcpm pip $*.hex=$*1.hex,$*2.hex
	vcpm genmod $*.hex $*.prl

sdir.prl: d1.hex d2.hex
	vcpm pip sdir.hex=d1.hex,d2.hex
	vcpm genmod sdir.hex $@

sched.prl: mschd1.hex mschd2.hex
	vcpm pip mschd.hex=mschd1.hex,mschd2.hex
	vcpm genmod mschd.hex $@

syncdown: $(SRC_ALL)
# TODO:
#	unix2cpm -q -s $(HOME)/git/MmsCpm3/dist/mpm2/cmd/src/...

%: $(HOME)/git/MmsCpm3/dist/mpm2/cmd/src/%
	@unix2cpm $< .

__FRC__:
