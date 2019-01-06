export ISIS_F0 = $(PWD)
export ISIS_F1 = $(HOME)/git/intel80tools/itools/plm80_3.1
export ISIS_F2 = $(HOME)/git/intel80tools/itools/link_3.0
export ISIS_F3 = $(HOME)/git/intel80tools/itools/asm80_4.1
export ISIS_F4 = $(HOME)/git/intel80tools/itools/locate_3.0
export ISIS_F5 = $(HOME)/git/intel80tools/itools/isis_4.3

export CPMDrive_D = $(PWD)
export CPMDefault = d:

all:	hexcom.com save.com \
	gencpm.com pip.com help.com erase.com type.com setdef.com \
	date.com ed.com gencom.com show.com put.com submit.com \
	set.com get.com dir.com dump.com patch.com rename.com \
	initdir.com sid.com

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
	rm -f *.obj *.hex *.rel *.mod *.com *.lst *.prn *.rsx

#
# NOTE: conflict btw DATE.ASM and DATE.PLM, for DATE.OBJ
# (DATE.ASM used for CCP - removed for now)
#

save.com: save.rel
	vcpm link save.rsx=save'[op,nr]'
	@rm -f save.com
	vcpm gencom save '[null]'

gencpm.mod: mcd80f.obj gencpm.obj setbuf.obj getdef.obj crdef.obj ldrlwr.obj datmod.obj plm80.lib
	thames :f2:link mcd80f.obj,gencpm.obj,setbuf.obj,getdef.obj,crdef.obj,ldrlwr.obj,datmod.obj,plm80.lib to gencpm.mod

pip.mod: mcd80f.obj inpout.obj pip.obj plm80.lib
	thames :f2:link mcd80f.obj,inpout.obj,pip.obj,plm80.lib to pip.mod

help.mod: mcd80h.obj help.obj plm80.lib
	thames :f2:link mcd80h.obj,help.obj,plm80.lib to help.mod

erase.mod: mcd80a.obj erase.obj parse.obj plm80.lib
	thames :f2:link mcd80a.obj,erase.obj,parse.obj,plm80.lib to erase.mod

type.mod: mcd80a.obj type.obj parse.obj plm80.lib
	thames :f2:link mcd80a.obj,type.obj,parse.obj,plm80.lib to type.mod

setdef.mod: mcd80a.obj setdef.obj plm80.lib
	thames :f2:link mcd80a.obj,setdef.obj,plm80.lib to setdef.mod

date.mod: mcd80d.obj date.obj plm80.lib
	thames :f2:link mcd80d.obj,date.obj,plm80.lib to date.mod

ed.mod: mcd80a.obj ed.obj plm80.lib
	thames :f2:link mcd80a.obj,ed.obj,plm80.lib to ed.mod

gencom.mod: mcd80a.obj parse.obj gencom.obj plm80.lib
	thames :f2:link mcd80a.obj,parse.obj,gencom.obj,plm80.lib to gencom.mod

show.mod: mcd80a.obj show.obj plm80.lib
	thames :f2:link mcd80a.obj,show.obj,plm80.lib to show.mod

set.mod: mcd80a.obj parse.obj set.obj plm80.lib
	thames :f2:link mcd80a.obj,parse.obj,set.obj,plm80.lib to set.mod

get.mod: mcd80a.obj get.obj parse.obj getf.obj plm80.lib
	thames :f2:link mcd80a.obj,get.obj,parse.obj,getf.obj,plm80.lib to get.mod

put.mod: mcd80a.obj put.obj parse.obj putf.obj plm80.lib
	thames :f2:link mcd80a.obj,put.obj,parse.obj,putf.obj,plm80.lib to put.mod

submit.mod: mcd80a.obj submit.obj parse.obj getf.obj plm80.lib
	thames :f2:link mcd80a.obj,submit.obj,parse.obj,getf.obj,plm80.lib to submit.mod

dir.mod: mcd80a.obj main80.obj scan.obj search.obj sort.obj disp.obj util.obj dpb80.obj timest.obj plm80.lib
	thames :f2:link mcd80a.obj,main80.obj,scan.obj,search.obj,sort.obj,disp.obj,util.obj,dpb80.obj,timest.obj,plm80.lib to dir.mod

device.mod: mcd80a.obj device.obj plm80.lib
	thames :f2:link mcd80a.obj,device.obj,plm80.lib to device.mod

initdir.com: mcd80d.rel initdir.rel plidio.rel plibios3.rel plilib.irl
	vcpm link initdir=mcd80d,initdir,plidio,plibios3'[a,nr]'

rename.mod: mcd80a.obj rename.obj parse.obj plm80.lib
	thames :f2:link mcd80a.obj,rename.obj,parse.obj,plm80.lib to rename.mod

initdir.rel: initdir.pli plibios.dcl
	CPMDefault=a: vcpm pli d:initdir '$$dl'

gencpm.com: gencpm
pip.com: pip
help.com: help
type.com: type
erase.com: erase
setdef.com: setdef
date.com: date
ed.com: ed
gencom.com: gencom
show.com: show
set.com: set
get.com: get
put.com: put
dir.com: dir
device.com: device
rename.com: rename

submit.com: submit subrsx.rel
	vcpm link sub.rsx=subrsx'[op,nr]'
	obj2bin submit submit.com
	vcpm gencom submit sub.rsx

ccp.com: ccp3.hex loader3.prl datestr.hex ccp3.sub
	vcpm ccp3.sub

sid.com: prs1asm.asm prs2mon.asm prs0mov.asm
	vcpm mac prs0mov.asm '$$SZ'
	vcpm mac prs1asm.asm '$$SZ'
	vcpm mac prs2mon.asm '$$SZ'
	mv prs1asm.hex prs1asm0.hex
	mv prs2mon.hex prs2mon0.hex
	vcpm mac prs1asm.asm '$$SZ+R'
	vcpm mac prs2mon.asm '$$SZ+R'
	mv prs1asm.hex prs1asm1.hex
	mv prs2mon.hex prs2mon1.hex
	vcpm pip relprsid.hex=prs1asm0.hex[i],prs2mon0.hex,prs1asm1.hex[i],prs2mon1.hex
	vcpm genmod relprsid.hex relprsid.com
	vcpm mksid.sub
