// Copyright (c) 2019 Douglas Miller <durgadas311@gmail.com>

import java.util.Arrays;
import java.util.Map;
import java.util.HashMap;
import java.util.Vector;
import java.io.*;

public class SysFile {
	File sys;
	Vector<SprFile> sprs;
	Map<Integer,Integer> drvs;
	int memTop = 0;	// page
	int resLen = 0;	// RES length, pages
	int resBase = 0; // page
	int bnkTop = 0;	// page, common memory boundary
	int bnkLen = 0;	// pages
	int bnkBase = 0; // page
	int entry = 0;
	boolean org0 = false;
	boolean lmsg = false;
	int com;

	Relocatable netmod;
	Relocatable bios;
	int cfgtbl = 0;
	int mixer = 0;
	byte[] buf;

	public SysFile(Vector<SprFile> sprs, Map<Integer,Integer> drvs,
			int top, int com, int ent, boolean org0, boolean lmsg) {
		this.sprs = sprs;
		this.drvs = drvs;
		this.org0 = org0;
		this.lmsg = lmsg;
		this.com = com;
		buf = new byte[128];
		// if 'top' is negative, use as base address...
		if (top < 0) {
			resBase = (-top) & 0xff;
			bnkBase = (-com) & 0xff;	// TODO: what here...
		} else {
			memTop = (top & 0xff);
			bnkTop = (com & 0xff);
		}
		for (int x = sprs.size() - 1; x >= 0; --x) {
			SprFile spr = sprs.get(x);
			if (top < 0) {
				spr.setRes((resBase + resLen) & 0xff);
				spr.setBnk((bnkBase + bnkLen) & 0xff);
			}
			resLen += spr.resPages();
			bnkLen += spr.bnkPages();
			if (top >= 0) {
				spr.setRes((memTop - resLen) & 0xff);
				spr.setBnk((bnkTop - bnkLen) & 0xff);
			}
			if (ent == x) {
				if (resLen > 0) {
					entry = spr.getRes() << 8;
				} else {
					entry = spr.getBnk() << 8;
				}
			}
		}
		if (top < 0) {
			memTop = (resBase + resLen) & 0xff;
			bnkTop = (bnkBase + bnkLen) & 0xff;
		} else {
			resBase = (memTop - resLen) & 0xff;
			bnkBase = (bnkTop - bnkLen) & 0xff;
		}
	}

	private void setCfgtbl() {
		int adr = (netmod.getRes() << 8) + 6; // CNFTBL entry
		if (netmod.getByte(adr) != 0xc3) { // 'JMP'?
			return;
		}
		adr = netmod.getByte(adr + 1) | (netmod.getByte(adr + 2) << 8);
		if (netmod.getByte(adr) != 0x21) { // 'LXI H,'?
			return;
		}
		cfgtbl = netmod.getByte(adr + 1) | (netmod.getByte(adr + 2) << 8);
	}

	private void setCfgtblNdos() {
		int adr = (netmod.getRes() << 8); // CFGTBL stuffed here...
		adr = netmod.getByte(adr) | (netmod.getByte(adr + 1) << 8);
		cfgtbl = adr;	// might be 0 (NULL), checked later
	}

	private void setMixer() {
		int adr = (bios.getRes() << 8) + 0x3c; // MIXER location
		// TODO: validate we have a mixer table?
		// TODO: initialize based on modules? can't...
		mixer = adr;
	}

	private void netDrive(int ld, int rd, int rs) {
		netmod.putByte(cfgtbl + (ld * 2) + 2, 0x80 + rd);
		netmod.putByte(cfgtbl + (ld * 2) + 3, rs);
	}

	private void phyDrive(int ld, int pd) {
		bios.putByte(mixer + ld, pd);
	}

	private void setDrives() {
		for (int d : drvs.keySet()) {
			int x = drvs.get(d);
			int rd = x >> 8;
			int rs = x & 0xff;
			if (rd == 0x80) {
				if (mixer == 0) {
					System.err.format("%c:=%d not compatible with image\n",
						(char)(d + 'A'), rs);
					continue;
				}
				phyDrive(d, rs);
			} else {
				if (cfgtbl == 0) {
					System.err.format("%c:=%c:%02X not compatible with image\n",
						(char)(d + 'A'), (char)(rd + 'A'), rs);
					continue;
				}
				netDrive(d, rd, rs);
			}
		}
	}

	private void setHeader() {
		buf[0] = (byte)memTop;
		buf[1] = (byte)resLen;
		buf[2] = (byte)bnkTop;
		buf[3] = (byte)bnkLen;
		buf[4] = (byte)entry;
		buf[5] = (byte)(entry >> 8);
		if (cfgtbl != 0) {
			buf[6] = (byte)cfgtbl;
			buf[7] = (byte)(cfgtbl >> 8);
		}
		if (org0) {
			buf[16] = (byte)'C'; // mark for ORG0
		} else {
			buf[16] = (byte)'U';
		}
	}

	private void setLoader() {
		Arrays.fill(buf, (byte)0);
		if (!lmsg) {
			buf[0] = '$';
			return;
		}
		String str = "";
		// print load map from top down...
		for (int x = sprs.size() - 1; x >= 0; --x) {
			SprFile spr = sprs.get(x);
			str += spr.loadMsg();
		}
		int tpa = resBase > 0 ? resBase << 8 : bnkBase << 8;
		str += String.format("\n%2dK TPA", tpa / 1024);
		System.err.format("\n%s\n", str);
		str += '$';
		byte[] stb = str.replace("\n", "\r\n").getBytes();
		int n = stb.length;
		if (n > 128) {
			stb[127] = '$';
			n = 128;
		}
		System.arraycopy(stb, 0, buf, 0, n);
	}

	private void gencpm(Relocatable scb) {
		// need to fudge the "bdosbase" address...
		scb.putByte(-3, resBase);	// make NDOS3 the "real bdos"
		// TODO: make these configurable
		scb.putByte(0x13, 0);	// drive A: default
		scb.putByte(0x1a, 79);	// console width
		scb.putByte(0x1c, 23);	// console width
		scb.putByte(0x2e, 0);	// Backspace echoes
		scb.putByte(0x2f, 1);	// Rubout echoes
		scb.putByte(0x58, 0x12);	// Default time/date
		scb.putByte(0x59, 0x07);	//
		scb.putByte(0x5a, 0x00);	//
		scb.putByte(0x5b, 0x00);	//
		scb.putByte(0x5c, 0x00);	//
		int cfg = scb.getByte(0x57);
		cfg &= 0b01111111;	// short error msgs
		cfg &= 0b10111111;	// banked always
		scb.putByte(0x57, cfg);	// sys bits...
		scb.putByte(0x5e, com);	// com page
	}

	public void combine() {
		for (int x = 0; x < sprs.size(); ++x) {
			SprFile spr = sprs.get(x);
			spr.relocRes();
			spr.relocBnk();
		}
		netmod = SprFile.getSpcl("snios");
		if (netmod != null) {
			setCfgtbl();
		} else {
			netmod = SprFile.getSpcl("ndos");
			if (netmod != null) {
				setCfgtblNdos();
			}
		}
		bios = SprFile.getSpcl("bios");
		if (bios != null) {
			setMixer();
		}
		if (drvs.size() > 0) {
			setDrives();
		}
		Relocatable scb = SprFile.getSpcl(SprFile.R_SCB);
		if (scb != null) {
			gencpm(scb);
		}
	}

	public boolean writeSys(File sys) {
		try {
			FileOutputStream f = new FileOutputStream(sys);
			setHeader();
			f.write(buf);
			setLoader();
			f.write(buf);
			for (int x = sprs.size() - 1; x >= 0; --x) {
				SprFile spr = sprs.get(x);
				spr.resWriteSys(f);
			}
			for (int x = sprs.size() - 1; x >= 0; --x) {
				SprFile spr = sprs.get(x);
				spr.bnkWriteSys(f);
			}
			f.close();
		} catch (Exception ee) {
			ee.printStackTrace();
			return false;
		}
		return true;
	}
}
