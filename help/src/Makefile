VPATH = drm cpnet mms

HELPS = commands.help \
	cntrlchars.help \
	copysys.help \
	cpnet.help \
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
	submit.help \
	tpa.help \
	tr.help \
	type.help \
	user.help \
	xref.help

all: makehelp ../bin/help.hlp

../bin/help.hlp: $(HELPS)
	cat $^ | unix2dos >help.raw
	./makehelp help.raw >$@
	@rm help.raw

makehelp: makehelp.c
	$(CC) -o $@ $^
