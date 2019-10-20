// Copyright (c) 2019 Douglas Miller <durgadas311@gmail.com>

import java.util.Map;
import java.util.HashMap;
import java.util.Vector;
import java.io.*;

public class mknetboot {
	Vector<SprFile> files;
	Map<Integer,Integer> drvs;
	boolean banked = false;
	boolean entry = false;
	boolean scb = false;
	boolean org0 = false;
	boolean lmsg = true;
	int type = 0;
	int ent = -1;
	int top = 0x00; // TODO: configurable...
	int com = 0xc0; // TODO: configurable...
	String outfile = "out.sys";

	private void help() {
		System.err.format(
			"Usage: mknetboot [options] <spr-file>...\n"+
			"Options:\n" +
			"    -t <adr> = Use <adr> as memtop\n" +
			"    -b <adr> = Use <adr> as base\n" +
			"    -k       = next spr-file is BNK instead of RES\n" +
			"    -e       = next spr-file is entry for sys\n" +
			"    -s       = next spr-file contains SCB\n" +
			"    -<type>  = next spr-file is <type>\n" +
			"               { \"bios\", \"bdos\", \"snios\", \"ndos\" }\n" +
			"    -o file  = output file name, else first spr-file.sys\n" +
			"    -g       = output needs ORG0\n" +
			"    -x       = suppress load message\n"
			);
		System.exit(1);
	}

	public static void main(String[] args) {
		new mknetboot(args);
	}

	private void parseDrive(String arg) {
		if (arg.equals("X:=X:")) {
			// Special case for CP/NOS... map all remote
			for (int x = 0; x < 16; ++x) {
				drvs.put(x, (x << 8) | 0xff);
			}
		} else if (arg.matches("[A-P]:=[A-P]:[0-9A-F]*")) {
			int d = arg.charAt(0) - 'A';
			int rd = arg.charAt(3) - 'A';
			int rs = 0xff;
			if (arg.length() > 5) {
				rs = Integer.valueOf(arg.substring(5), 16);
			}
			drvs.put(d, (rd << 8) | rs);
		} else if (arg.matches("[A-P]:=[0-9]+")) {
			int d = arg.charAt(0) - 'A';
			int rs = Integer.valueOf(arg.substring(3));
			drvs.put(d, 0x80 | rs);
		} else {
			System.err.format("Invalid drive specifier \"%s\"\n", arg);
		}
	}

	private mknetboot(String[] args) {
		files = new Vector<SprFile>();
		drvs = new HashMap<Integer,Integer>();	// value is drive:server
							// or 0x80:phydisk
		int x = 0;
		for (; x < args.length; ++x) {
			if (args[x].equals("-k")) {
				banked = true;
			} else if (args[x].equals("-g")) {
				org0 = true;
			} else if (args[x].equals("-x")) {
				lmsg = false;
			} else if (args[x].equals("-e")) {
				entry = true;
			} else if (args[x].equals("-s")) {
				scb = true;
			} else if (args[x].equals("-t")) {
				++x;
				if (x < args.length) {
					top = Integer.decode(args[x]) >> 8;
				}
			} else if (args[x].equals("-b")) {
				++x;
				if (x < args.length) {
					top = -(Integer.decode(args[x]) >> 8);
				}
			} else if (args[x].equals("-o")) {
				++x;
				if (x < args.length) {
					outfile = args[x];
				}
			} else if (args[x].startsWith("-")) {
				if (SprFile.isReloc(args[x].substring(1))) {
					type = SprFile.getReloc(args[x].substring(1));
				} else {
					System.err.format("Unrecognized option: %s\n",
						args[x]);
				}
			} else if (args[x].indexOf('=') > 0) {
				parseDrive(args[x].toUpperCase());
			} else {
				File f = new File(args[x]);
				if (!f.exists() || f.isDirectory()) {
					System.err.format("No file \"%s\"\n", f.getAbsolutePath());
					System.exit(1);
				}
				SprFile spr = new SprFile(f, banked, scb, type);
				if (entry) {
					ent = files.size();
				}
				files.add(spr);
				banked = false;
				entry = false;
				scb = false;
				type = 0;
			}
		}
		if (files.size() == 0) {
			help(); // does not return
		}
		if (ent == -1) {
			ent = files.size() - 1;
		}
		SysFile sys = new SysFile(files, drvs, top, com, ent, org0, lmsg);
		// TODO: check failure...
		sys.combine();
		if (sys.writeSys(new File(outfile))) {
			System.err.format("Wrote file \"%s\"\n", outfile);
		} else {
			System.exit(1);
		}
	}
}
