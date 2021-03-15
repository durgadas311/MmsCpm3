VPATH = drm cpnet mms

# If 'makehelp' doesn't produce a working HELP.HLP file, use HELP.COM:
#	* copy help.raw => 0:HELP.DAT on a CP/M system
#	* the CP/M command "HELP [C]" will re-create HELP.HLP
#	* NOTE: overwrites existing HELP.HLP
#
# Paragraphs may be justified using "par j".
#
# Topics in lists need to be in alphabetical order.

# For MMS H89 CP/M 3 with CP/NET3
HELPS = commands.help \
	cntrlchars.help \
	copysys.help \
	cpnet3.help \
	cpnetsts.help \
	date.help \
	device.help \
	dir.help \
	drives.help \
	dskreset.help \
	dump.help \
	ed.help \
	endlist.help \
	erase.help \
	filespec.help \
	format.help \
	gencom.help \
	get.help \
	help.help \
	hexcom.help \
	initdir.help \
	lib.help \
	link.help \
	local.help \
	login.help \
	logoff.help \
	mac.help \
	mode.help \
	modules.help \
	netstat.help \
	network.help \
	ntpdate.help \
	patch.help \
	pip.help \
	put.help \
	rename.help \
	rmac.help \
	rsxrm.help \
	save.help \
	set.help \
	setdef.help \
	setup.help \
	show.help \
	sid.help \
	srvstat.help \
	submit.help \
	tpa.help \
	tr.help \
	type.help \
	user.help \
	wizcfg.help \
	xref.help

# For Generic CP/M 3
CPM3 = commands.help \
	cntrlchars.help \
	date.help \
	device.help \
	dir.help \
	dump.help \
	ed.help \
	erase.help \
	filespec.help \
	gencom.help \
	get.help \
	help.help \
	hexcom.help \
	initdir.help \
	lib.help \
	link.help \
	mac.help \
	patch.help \
	pip.help \
	put.help \
	rename.help \
	rmac.help \
	save.help \
	set.help \
	setdef.help \
	show.help \
	sid.help \
	submit.help \
	type.help \
	user.help \
	xref.help

# For Generic CP/M 3 with CP/NET3
CPM3NET = commands.help \
	cntrlchars.help \
	cpnet3.help \
	cpnetsts.help \
	date.help \
	device.help \
	dir.help \
	dskreset.help \
	dump.help \
	ed.help \
	endlist.help \
	erase.help \
	filespec.help \
	gencom.help \
	get.help \
	help.help \
	hexcom.help \
	initdir.help \
	lib.help \
	link.help \
	local.help \
	login.help \
	logoff.help \
	mac.help \
	netstat.help \
	network.help \
	ntpdate.help \
	patch.help \
	pip.help \
	put.help \
	rename.help \
	rmac.help \
	rsxrm.help \
	save.help \
	set.help \
	setdef.help \
	show.help \
	sid.help \
	srvstat.help \
	submit.help \
	tpa.help \
	tr.help \
	type.help \
	user.help \
	wizcfg.help \
	xref.help

# For Generic CP/M 2.2
CPM2 = asm2.help \
	commands2.help \
	cntrlchars2.help \
	ddt2.help \
	dir2.help \
	dump.help \
	ed.help \
	era2.help \
	filespec2.help \
	help.help \
	load2.help \
	pip2.help \
	ren2.help \
	save2.help \
	stat2.help \
	submit2.help \
	type2.help \
	user2.help

# For Generic CP/M 2.2 with CP/NET 1.2
CPM2NET = asm2.help \
	commands2.help \
	cntrlchars2.help \
	cpnet12.help \
	cpnboot.help \
	cpnetldr.help \
	cpnetsts.help \
	ddt2.help \
	dir2.help \
	dskreset.help \
	dump.help \
	ed.help \
	endlist.help \
	era2.help \
	filespec2.help \
	help.help \
	load2.help \
	local.help \
	login.help \
	logoff.help \
	netboot.help \
	netdown.help \
	netstat.help \
	network.help \
	pip2.help \
	rdate.help \
	ren2.help \
	save2.help \
	srvstat.help \
	stat2.help \
	submit2.help \
	tpa.help \
	tr.help \
	type2.help \
	user2.help

# Generic CP/NET3 only
CPNET3 = \
	cpnet3.help \
	cpnetsts.help \
	dskreset.help \
	endlist.help \
	help.help \
	local.help \
	login.help \
	logoff.help \
	netstat.help \
	network.help \
	ntpdate.help \
	rsxrm.help \
	srvstat.help \
	tpa.help \
	tr.help \
	wizcfg.help

# Generic CP/NET 1.2 only
CPNET12 = \
	cpnet12.help \
	cpnboot.help \
	cpnetldr.help \
	cpnetsts.help \
	dskreset.help \
	endlist.help \
	help.help \
	local.help \
	login.help \
	logoff.help \
	netboot.help \
	netdown.help \
	netstat.help \
	network.help \
	rdate.help \
	srvstat.help \
	tpa.help \
	tr.help

all: makehelp ../bin/help.hlp

everything: makehelp ../bin/help.hlp ../bin/cpnet3.hlp ../bin/cpnet12.hlp \
	../bin/cpm3net.hlp ../bin/cpm2net.hlp \
	../bin/cpm3.hlp ../bin/cpm2.hlp

cpnet: makehelp ../bin/cpnet3.hlp ../bin/cpnet12.hlp

../bin/cpm2.hlp: $(CPM2)
	cat $^ | unix2dos >cpnet.raw
	./makehelp cpnet.raw >$@
	@rm cpnet.raw

../bin/cpm3.hlp: $(CPM3)
	cat $^ | unix2dos >cpnet.raw
	./makehelp cpnet.raw >$@
	@rm cpnet.raw

../bin/help.hlp: $(HELPS)
	cat $^ | unix2dos >help.raw
	./makehelp help.raw >$@
	@rm help.raw

../bin/cpnet3.hlp: $(CPNET3)
	cat $^ | unix2dos >cpnet.raw
	./makehelp cpnet.raw >$@
	@rm cpnet.raw

../bin/cpm3net.hlp: $(CPM3NET)
	cat $^ | unix2dos >cpnet.raw
	./makehelp cpnet.raw >$@
	@rm cpnet.raw

../bin/cpnet12.hlp: $(CPNET12)
	cat $^ | unix2dos >cpnet.raw
	./makehelp cpnet.raw >$@
	@rm cpnet.raw

../bin/cpm2net.hlp: $(CPM2NET)
	cat $^ | unix2dos >cpnet.raw
	./makehelp cpnet.raw >$@
	@rm cpnet.raw

makehelp: makehelp.c
	$(CC) -o $@ $^
