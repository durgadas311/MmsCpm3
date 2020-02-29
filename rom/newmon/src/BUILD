How To Build H8 Monitor 2.0 for the 28C256/27C256
Douglas Miller <durgadas311@gmail.com>

This document assumes you have cloned the GIT repository from
https://github.com/durgadas311/MmsCpm3.git and that your current
working directory is rom/newmon/src.

The current build uses:

	* 'make' (tested on GNU Make 4.1)
	* 'zmac' (zmac version 20jan2019 http://48k.ca/zmac.html)
	* standard Linux/Unix utilities (cp, sed, awk, ...)
	* ../../../tools/cksum - a C program, built in the typical way

Building the stand-alone programs ('sys' target) requires additionally:

	* dos2unix - standard package of utilties for converting text files
	* VirtualCPM environment (../../../tools/vcpm/VirtualCpm.jar), see below
	* mknetboot (../../../tools/mknetboot/mknetboot.jar), see below

NOTE: The 'ship' target is probably not usable outside of my own environment.

SETUP

	1. Build ../../../tools/cksum, if not already done:
		From the tools directory, type "make cksum"
		(default make rules should suffice).
	2. Copy, or symlink, "z80.lib" and "z180.lib" from
	   ../../../sys/src.

BUILDING

Building the two ROM versions (H8-Z80-CPU v3.2, H8-Z180-CPU)
requires running the command "make".


STAND-ALONE PROGRAMS

Stand-alone programs are generally booted (run) off a USB flash drive
via the VDIP1 controller. However, they are also compatible with
network boot via the WizNet controller.

SETUP

	1. Install the dos2unix package, providing the command 'unix2dos'.

	2. Setup a script-let or alias for 'mknetboot' to the
	   mknetboot jar. The effective command should be:

		java -jar /path/to/git/repo/tools/mknetboot/mknetboot.jar "${@}"

	   mknetboot combines CP/M "SPR" files into a SYS image. This is
	   the same format as the CPM3.SYS file, with some extensions
	   for CP/NET and network booting.

	3. Setup a script-let or alias for 'vcpm' to the VirtualCPM jar.
	   The effective command should be (bourne shell parlance):

		java -jar /path/to/git/repo/tools/vcpm/VirtualCpm.jar "${@}"

	   vcpm is used to run CP/M utilities on files in the native
	   filesystems of the host computer.

	4. Setup a properties file for 'vcpm', in ${HOME}/.vcpmrc:

		vcpm_root_dir = /path/to/VCPM
		silent

	   Where the root dir is a path you choose to contain the vcpm
	   native CP/M files. If running on windows, add the 'vcpm_nosys'
	   property (flag).

	5. Create the root dir path chosen in (4), and create a subdirectory
	   named 'a' (for drive A:). In this 'a' subdirectory, copy
	   (minimally) RMAC.COM and LINK.COM from a CP/M distribution
	   or other source.

	   NOTE! files copied into vcpm directories must have lower-case
	   file names!

Addition information on vcpm is available in the file:

	../../../tools/vcpm/README

NOTE: vcpm runs actual CP/M programs, and as such - just like CP/M -
requires text files to be formatted with CR-LF line endings.
RMAC is unable to assemble files with Linux/Unix line endings,
and may not produce errors directly. Check the output of the
'make' to confirm that RMAC was successful.
