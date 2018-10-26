# Converts a CP/M 3 build .SUB file into shell script,
# to be run with "thames" ISIS emulation environment.
#
# Assumes ISIS (thames) mapping:
# ISIS_F0=${PWD}
# ISIS_F1=~/git/intel80tools/itools/plm80_3.1
# ISIS_F2=~/git/intel80tools/itools/link_3.0
# ISIS_F3=~/git/intel80tools/itools/asm80_4.1
# ISIS_F4=~/git/intel80tools/itools/locate_3.0
# ISIS_F5=~/git/intel80tools/itools/isis_4.3
# 'obj2bin' is ~/git/intel80tools/toolsrc/obj2bin/obj2bin (built locally).
# "intel80tools" is from https://github.com/ogdenpm/intel80tools.git.
# Assumes all filenames were converted to lower case.
#
BEGIN{
	lastfn="";
	maps["plm80"]=":f1:";
	maps["link"]=":f2:";
	maps["locate"]=":f4:";
	maps["asm80"]=":f3:";
	cpm=0;
	isis=0;
}
FILENAME!=lastfn{
	file=FILENAME;
	sub(/\.sub/,".sh",file);
	sub(/.*\//,"",file);
	lastfn=FILENAME;
	print "#!/bin/bash" >file;
}
/^;/{
	cpm=0;
	isis=0;
	print "# " $0 >>file;
	next;
}
$1=="vax" || $1=="stat" || $1=="seteof"{
	print "# " $0 >>file;
	next;
}
$1=="cpm"{
	cpm=1;
	isis=0;
	print "# " $0 >>file;
	next;
}
$1=="is14"{
	cpm=0;
	isis=1;
	print "# " $0 >>file;
	next;
}
cpm==0 && isis==0{
	print "## " $0 >>file;
}
cpm!=0{
	if ($1=="objcpm") {
		print tolower("obj2bin " $2 " " $2 ".com") >>file;
	} else {
		print "# " $0 >>file;
	}
	next;
}
isis!=0{
	cmd=tolower($1);
	if (cmd=="era") {
		print "# " $0 >>file;
		next;
	}
	if (!(cmd in maps)) {
		print "ERROR: unknown command:",file ":",$0;
		print "#! " $0 >>file;
		next;
	}
	printf "thames %s%s", maps[cmd], cmd >>file;
	for (x = 2; x <= NF; ++x) {
		if ($(x)~/\(/) {
			printf " '%s'", tolower($(x)) >>file;
		} else {
			printf " %s", tolower($(x)) >>file;
		}
	}
	printf "\n" >>file;
	next;
}
