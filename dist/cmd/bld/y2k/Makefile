export ISIS_F0 = $(PWD)
export ISIS_F1 = $(HOME)/git/intel80tools/itools/plm80_3.1
export ISIS_F2 = $(HOME)/git/intel80tools/itools/link_3.0
export ISIS_F3 = $(HOME)/git/intel80tools/itools/asm80_4.1
export ISIS_F4 = $(HOME)/git/intel80tools/itools/locate_3.0
export ISIS_F5 = $(HOME)/git/intel80tools/itools/isis_4.3
export ISIS_F6 = $(HOME)/git/intel80tools/itools/plm80_3.0

export CPMDrive_D = $(PWD)
export CPMDefault = d:

MODS = $(wildcard *.mod)
NOTYPES = $(subst .mod,,$(MODS))

all:	setdef.com date.com show.com dir.com

%.obj: %.asm
	thames :f3:asm80 $? debug

%.obj: %.plm
	thames :f1:plm80 $? debug optimize

%: %.mod
	thames :f4:locate $? 'code(0100h)' 'stacksize(100)'

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

#
# NOTE: conflict btw DATE.ASM and DATE.PLM, for DATE.OBJ
# (DATE.ASM used for CCP - removed for now)
#

setdef.mod: mcd80a.obj setdef.obj plm80.lib
	thames :f2:link mcd80a.obj,setdef.obj,plm80.lib to setdef.mod

date.mod: mcd80b.obj date.obj plm80.lib
	thames :f2:link mcd80b.obj,date.obj,plm80.lib to date.mod

show.mod: mcd80a.obj show.obj plm80.lib
	thames :f2:link mcd80a.obj,show.obj,plm80.lib to show.mod

dir.mod: mcd80b.obj main80.obj scan.obj search.obj sort.obj disp.obj util.obj dpb80.obj timest.obj plm80.lib
	thames :f2:link mcd80b.obj,main80.obj,scan.obj,search.obj,sort.obj,disp.obj,util.obj,dpb80.obj,timest.obj,plm80.lib to dir.mod

setdef.com: setdef
date.com: date
show.com: show
dir.com: dir

dir: dir.mod
	thames :f4:locate $? 'code(0100h)' 'stacksize(50)'

date.obj: date.plm
	thames :f6:plm80 $? debug optimize

__FRC__:
