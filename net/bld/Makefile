# Assumes PWD = CPMDrive_D

export CPMDrive_D = $(HOME)/CpmDev/net	# a.k.a. $(PWD)
export CPMDrive_O = $(HOME)/CpmDev/netprn
export CPMDefault = d:

SRCS = $(wildcard *.asm)
RELS = $(subst .asm,.rel,$(SRCS))

all:	ndos3-u.com ntpdt-u.com \
	ndos3-w.com ntpdt-w.com \
	ndos3-m.com ntpdt-m.com \
	netstat.com wizcfg.com

%.rel: %.asm
	vcpm rmac "$?" '$$SZLAPO'

%.com: %.asm
	vcpm mac "$?" '$$SZLAPO'
	vcpm hexcom "$*"

ndos3-u.com: ndos3.rel sniosusb.rel
	vcpm link "ndos3-u.rsx=ndos3,sniosusb[op,nr]"
	@rm -f ndos3-u.com
	vcpm gencom ndos3-u "[null]"

ntpdt-u.com: ntpdate.rel sniosusb.rel
	vcpm link "ntpdt-u=ntpdate,sniosusb[oc,nr]"

ndos3-w.com: ndos3.rel snioswiz.rel ndos3wiz.com
	vcpm link "ndos3-w.rsx=ndos3,snioswiz[op,nr]"
	@rm -f ndos3-w.com
	@cp ndos3wiz.com ndos3-w.com
	vcpm gencom ndos3-w.com ndos3-w.rsx

ntpdt-w.com: ntpdate.rel snioswiz.rel
	vcpm link "ntpdt-w=ntpdate,snioswiz[oc,nr]"

ndos3-m.com: ndos3.rel snios422.rel
	vcpm link "ndos3-m.rsx=ndos3,snios422[op,nr]"
	@rm -f ndos3-m.com
	vcpm gencom ndos3-m "[null]"

ntpdt-m.com: ntpdate.rel snios422.rel
	vcpm link "ntpdt-m=ntpdate,snios422[oc,nr]"

netstat.com: netstat.asm
	vcpm mac netstat.asm '$$SZLAPO'
	vcpm hexcom netstat

wizcfg.com: wizcfg.asm
	vcpm mac wizcfg.asm '$$SZLAPO'
	vcpm hexcom wizcfg

wizdbg.com: wizdbg.asm
	vcpm mac wizdbg.asm '$$SZLAPO'
	vcpm hexcom wizdbg

snios-w.spr: snioswiz.rel snios12.rel
	vcpm link "snios-w=snios12.rel,snioswiz.rel[os,nr]"

wiz: wizcfg.com wizdbg.com ntpdt-w.com ndos3-w.com snios-w.spr

usb: ntpdt-u.com ndos3-u.com

mms: ntpdt-m.com ndos3-m.com

# These are run from git/MmsCpm3/net/bld

CPNET_UTLS = cpnetsts.com dskreset.com endlist.com local.com \
	login.com logoff.com mail.com network.com xsubnet.com

WIZ_UTLS = wizcfg.com wizdbg.com netstat.com

NV_UTLS = nvram.com rsxrm.com tr.com

CPNET_DOC = CPNET-WIZ850io.pdf dri-cpnet.pdf H8x-SPI-OP.pdf

ship: cpnet3.tgz cpnet12.tgz cpnetdocs.tgz

cpnet3.tgz: __FRC__
	tar -czf cpnet3.tgz -C ../dist/bin $(CPNET_UTLS) \
		-C ../../bin $(WIZ_UTLS) --xform='s/-w//' ndos3-w.com \
		-C ../../util/bin $(NV_UTLS)

# TODO: change cpnetldr.com to cpnldr-w.com with --xform='s/cpnldr-w/cpnetldr/'
cpnet12.tgz: __FRC__
	tar -czf cpnet12.tgz -C ../dist/bin $(CPNET_UTLS) ndos.spr \
		-C ../../bin $(WIZ_UTLS) --xform='s/cpnldr-w/cpnetldr/' --xform='s/-w//' \
			snios-w.spr cpnldr-w.com \
		-C ../../util/bin $(NV_UTLS)

cpnetdocs.tgz: __FRC__
	tar -czf cpnetdocs.tgz -C ../../doc $(CPNET_DOC)

publish: ship
	rsync -Wuv wiznet.htaccess durgadas.com:/http/durgadas.com/sebhc/mms89/wiz850io/.htaccess
	rsync -Wuv *.tgz durgadas.com:/http/durgadas.com/sebhc/mms89/wiz850io

__FRC__:
