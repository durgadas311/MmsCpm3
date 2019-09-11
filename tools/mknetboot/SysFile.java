// Copyright (c) 2019 Douglas Miller <durgadas311@gmail.com>

import java.util.Arrays;
import java.util.Vector;
import java.io.*;

public class SysFile {
	File sys;
	Vector<SprFile> sprs;
	int memTop = 0;	// page
	int resLen = 0;	// RES length, pages
	int resBase = 0; // page
	int bnkTop = 0;	// page, common memory boundary
	int bnkLen = 0;	// pages
	int bnkBase = 0; // page
	int entry = 0;
	int cfgtbl = 0;
	byte[] buf;

	public SysFile(Vector<SprFile> sprs, int top, int com, int ent) {
		this.sprs = sprs;
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

	public void combine() {
		for (int x = 0; x < sprs.size(); ++x) {
			SprFile spr = sprs.get(x);
			spr.relocRes();
			spr.relocBnk();
		}
		SprFile snios = SprFile.getSpcl("snios");
		if (snios == null) {
			return;
		}
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
		str += '\n';
		str += String.format("%3dK TPA\n", tpa / 1024);
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
