# Assumes PWD = CPMDrive_D

export CPMDrive_D = $(HOME)/CpmDev/net	# a.k.a. $(PWD)
export CPMDefault = d:

all:	wizdate.com sokstat.com \
	sokopen.com sokconn.com sokdisc.com sokclose.com sokkeep.com

%.rel: %.asm
	vcpm rmac "$?" '$$SZ'

%.com: %.asm
	vcpm mac "$?" '$$SZ'
	vcpm hexcom "$*"

sokopen.com sokconn.com sokdisc.com sokclose.com sokkeep.com : sokcmd.asm
	echo 'comnd equ $(subst sok,,$(basename $@))\r' >sokcmd.lib
	vcpm mac sokcmd.asm '$$SZ'
	vcpm hexcom "sokcmd"
	mv sokcmd.com $@

rdate.com: rdate.rel snioswiz.rel
	vcpm link "rdate=rdate,snioswiz[oc,nr]"

# There are run from dev dir, e.g. ~/CpmDev/net
# push built files back into repo... new files must be manually copied
#syncup:
#	rsync -Wurv --existing . ~/git/MmsCpm3/net/bin/.
#	rsync -Wurv --existing . ~/git/MmsCpm3/net/prn/.

# pull source files down from repo...
syncdown:
	unix2cpm -s ~/git/MmsCpm3/net/wiz/dbg/src/*.asm .

__FRC__:
