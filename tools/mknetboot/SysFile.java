// Copyright (c) 2019 Douglas Miller <durgadas311@gmail.com>

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
	byte[] buf;

	public SysFile(Vector<SprFile> sprs, int top, int com, int ent) {
		this.sprs = sprs;
		buf = new byte[128];
		memTop = (top & 0xff);
		bnkTop = (com & 0xff);
		for (int x = 0; x < sprs.size(); ++x) {
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
	}

	private void setHeader() {
		buf[0] = (byte)memTop;
		buf[1] = (byte)resLen;
		buf[2] = (byte)bnkTop;
		buf[3] = (byte)bnkLen;
		buf[4] = (byte)entry;
		buf[5] = (byte)(entry >> 8);
		buf[16] = (byte)'C'; // mark for ORG0
		// TODO: make ORG0 optional...
	}

	private void setLoader() {
		String str = "";
		// print load map from top down...
		for (int x = sprs.size() - 1; x >= 0; --x) {
			SprFile spr = sprs.get(x);
			str += spr.loadMsg() + '\n';
		}
		int tpa = resBase > 0 ? resBase << 8 : bnkBase << 8;
		str += '\n';
		str += String.format("%3dK TPA\n$", tpa / 1024);
		byte[] stb = str.getBytes();
		if (stb.length > 128) stb[127] = '$';
		System.arraycopy(stb, 0, buf, 0, 128);
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
