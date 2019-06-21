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

ndos3-u.com: ndos3.rel sniosusb.rel
	vcpm link "ndos3-u.rsx=ndos3,sniosusb[op,nr]"
	@rm -f ndos3-u.com
	vcpm gencom ndos3-u "[null]"

ntpdt-u.com: ntpdate.rel sniosusb.rel
	vcpm link "ntpdt-u=ntpdate,sniosusb[oc,nr]"

ndos3-w.com: ndos3.rel snioswiz.rel
	vcpm link "ndos3-w.rsx=ndos3,snioswiz[op,nr]"
	@rm -f ndos3-w.com
	vcpm gencom ndos3-w "[null]"

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
