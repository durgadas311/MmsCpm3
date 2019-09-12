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

	SprFile snios;
	SprFile bios;
	int cfgtbl = 0;
	int mixer = 0;
	byte[] buf;

	public SysFile(Vector<SprFile> sprs, Map<Integer,Integer> drvs,
				int top, int com, int ent) {
		this.sprs = sprs;
		this.drvs = drvs;
		buf = new byte[128];
		memTop = (top & 0xff);
		bnkTop = (com & 0xff);
		for (int x = sprs.size() - 1; x >= 0; --x) {
			SprFile spr = sprs.get(x);
			resLen += spr.resPages();
			bnkLen += spr.bnkPages();
			spr.setRes((memTop - resLen) & 0xff);
			spr.setBnk((bnkTop - bnkLen) & 0xff);
			if (ent == x) {
				if (resLen > 0) {
					entry = spr.getRes() << 8;
				} else {
					entry = spr.getBnk() << 8;
				}
			}
		}
		resBase = (memTop - resLen) & 0xff;
		bnkBase = (bnkTop - bnkLen) & 0xff;
	}

	private void setCfgtbl() {
		int adr = (snios.getRes() << 8) + 6; // CNFTBL entry
		if (snios.getByte(adr) != 0xc3) { // 'JMP'?
			return;
		}
		adr = snios.getByte(adr + 1) | (snios.getByte(adr + 2) << 8);
		if (snios.getByte(adr) != 0x21) { // 'LXI H,'?
			return;
		}
		cfgtbl = snios.getByte(adr + 1) | (snios.getByte(adr + 2) << 8);
	}

	private void setMixer() {
		int adr = (bios.getRes() << 8) + 0x3c; // MIXER location
		// TODO: validate we have a mixer table?
		// TODO: initialize based on modules? can't...
		mixer = adr;
	}

	private void netDrive(int ld, int rd, int rs) {
		snios.putByte(cfgtbl + (ld * 2) + 2, 0x80 + rd);
		snios.putByte(cfgtbl + (ld * 2) + 3, rs);
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
		// TODO: make ORG0 optional...
		buf[16] = (byte)'C'; // mark for ORG0
	}

	private void setLoader() {
		String str = "";
		// print load map from top down...
		for (int x = sprs.size() - 1; x >= 0; --x) {
			SprFile spr = sprs.get(x);
			str += spr.loadMsg();
		}
		int tpa = resBase > 0 ? resBase << 8 : bnkBase << 8;
		str += String.format("\n%3dK TPA", tpa / 1024);
		System.err.format("\n%s\n", str);
		str += '$';
		byte[] stb = str.replace("\n", "\r\n").getBytes();
		int n = stb.length;
		if (n > 128) {
			stb[127] = '$';
			n = 128;
			Arrays.fill(buf, (byte)0);
		}
		System.arraycopy(stb, 0, buf, 0, n);
	}

	public void combine() {
		for (int x = 0; x < sprs.size(); ++x) {
			SprFile spr = sprs.get(x);
			spr.relocRes();
			spr.relocBnk();
		}
		snios = SprFile.getSpcl("snios");
		bios = SprFile.getSpcl("bios");
		if (snios != null) {
			setCfgtbl();
		}
		if (bios != null) {
			setMixer();
		}
		if (drvs.size() > 0) {
			setDrives();
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
