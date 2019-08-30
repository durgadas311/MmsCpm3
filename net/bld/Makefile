# Assumes PWD = CPMDrive_D

export CPMDrive_D = $(HOME)/CpmDev/net	# a.k.a. $(PWD)
export CPMDefault = d:

SRCS = $(wildcard *.asm)
RELS = $(subst .asm,.rel,$(SRCS))

all:	ndos3-u.com ntpdt-u.com \
	ndos3-w.com ntpdt-w.com \
	ndos3-m.com ntpdt-m.com \
	netstat.com wizcfg.com

%.rel: %.asm
	vcpm rmac "$?" '$$SZLA'

%.com: %.asm
	vcpm mac "$?" '$$SZLA'
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
	vcpm mac netstat.asm '$$SZLA'
	vcpm hexcom netstat

wizcfg.com: wizcfg.asm
	vcpm mac wizcfg.asm '$$SZLA'
	vcpm hexcom wizcfg

wizdbg.com: wizdbg.asm
	vcpm mac wizdbg.asm '$$SZLA'
	vcpm hexcom wizdbg

snios-w.spr: snioswiz.rel snios12.rel
	vcpm link "snios-w=snios12.rel,snioswiz.rel[os,nr]"

wiz: wizcfg.com wizdbg.com ntpdt-w.com ndos3-w.com snios-w.spr

usb: ntpdt-u.com ndos3-u.com

mms: ntpdt-m.com ndos3-m.com

# There are run from dev dir, e.g. ~/CpmDev/net
# push built files back into repo... new files must be manually copied
syncup:
	rsync -Wurv --existing . ~/git/MmsCpm3/net/bin/.
	rsync -Wurv --existing . ~/git/MmsCpm3/net/prn/.

# pull source files down from repo...
syncdown:
	unix2cpm -s ~/git/MmsCpm3/net/src/*.asm .

# These are run from git/MmsCpm3/net/bld

CPNET_UTLS = cpnetsts.com dskreset.com endlist.com local.com \
	login.com logoff.com mail.com network.com

CPN12_UTLS = $(CPNET_UTLS) ndos.spr ccp.spr xsubnet.com

NET_UTLS = wizcfg.com wizdbg.com netstat.com

NET3_UTLS = $(NET_UTLS) ndos3-w.com ntpdt-w.com
NET12_UTLS = $(NET_UTLS) snios-w.spr cpnldr-w.com

CP3_UTLS = nvram.com rsxrm.com tr.com
CP2_UTLS = nvram.com tr.com

CPNET_DOC = CPNET-WIZ850io.pdf dri-cpnet.pdf H8x-SPI-OP.pdf

ship: cpnet3.tgz cpnet12.tgz cpnetdocs.tgz

# Warning: --xform might have unintended consequences

cpnet3.tgz: __FRC__
	tar -czf cpnet3.tgz --xform='s/ntpdt-w/ntpdate/' --xform='s/-w//' \
		-C ../dist/bin $(CPNET_UTLS) \
		-C ../../bin $(NET3_UTLS) \
		-C ../../util/bin $(CP3_UTLS)

# TODO: change cpnetldr.com to cpnldr-w.com with --xform='s/cpnldr-w/cpnetldr/'
cpnet12.tgz: __FRC__
	tar -czf cpnet12.tgz --xform='s/cpnldr-w/cpnetldr/' --xform='s/-w//' \
		-C ../dist/bin $(CPN12_UTLS) \
		-C ../../bin $(NET12_UTLS) \
		-C ../../util/bin $(CP2_UTLS)

cpnetdocs.tgz: __FRC__
	tar -czf cpnetdocs.tgz -C ../../doc $(CPNET_DOC)

publish: ship
	rsync -Wuv wiznet.htaccess durgadas.com:/http/durgadas.com/sebhc/mms89/wiz850io/.htaccess
	rsync -Wuv *.tgz ../../doc/CPNET-WIZ850io.pdf durgadas.com:/http/durgadas.com/sebhc/mms89/wiz850io

__FRC__:
