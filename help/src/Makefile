VPATH = drm cpnet mms

# Also: help.raw => 0:HELP.DAT, "HELP [C]", to re-create HELP.HLP if 'makehelp'
# doesn't produce a working HELP.HLP file.
#
# Paragraphs may be justified using "par j".

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

CPNET12 = \
	cpnet12.help \
	cpnetsts.help \
	dskreset.help \
	endlist.help \
	help.help \
	local.help \
	login.help \
	logoff.help \
	netdown.help \
	netstat.help \
	network.help \
	rdate.help \
	srvstat.help \
	tpa.help \
	tr.help

all: makehelp ../bin/help.hlp

cpnet: makehelp ../bin/cpnet3.hlp ../bin/cpnet12.hlp

../bin/help.hlp: $(HELPS)
	cat $^ | unix2dos >help.raw
	./makehelp help.raw >$@
	@rm help.raw

../bin/cpnet3.hlp: $(CPNET3)
	cat $^ | unix2dos >cpnet.raw
	./makehelp cpnet.raw >$@
	@rm cpnet.raw

../bin/cpnet12.hlp: $(CPNET12)
	cat $^ | unix2dos >cpnet.raw
	./makehelp cpnet.raw >$@
	@rm cpnet.raw

makehelp: makehelp.c
	$(CC) -o $@ $^
