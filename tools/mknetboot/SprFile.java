// Copyright (c) 2019 Douglas Miller <durgadas311@gmail.com>

import java.util.Vector;
import java.io.*;

public class SprFile {
	File spr;
	byte[] img;
	int resStart = 0;
	int resLen = 0;
	int resBase = 0;
	int resReloc = 0;
	int bnkStart = 0;
	int bnkLen = 0;
	int bnkBase = 0;
	int bnkReloc = 0;
	static byte[] zero = new byte[128];

	public SprFile(File f, boolean k) {
		try {
			FileInputStream fi = new FileInputStream(f);
			img = new byte[fi.available()];
			fi.read(img);
			fi.close();
			spr = f;
		} catch (Exception ee) {
			ee.printStackTrace();
			spr = null;
			return;
		}
		int o = 0x0100;
		int n = (img[1] & 0xff) | ((img[2] & 0xff) << 8);
		int r = (img[10] & 0xff) | ((img[11] & 0xff) << 8);
		int b = 0;
		if (r == 0) {
			if (k) {
				b = n;
			} else {
				r = n;
			}
		} else {
			b = n - r;
		}
		if (r != 0) {
			resStart = o;
			resLen = r;
			o += r;
		}
		if (b != 0) {
			bnkStart = o;
			bnkLen = b;
			o += b;
		}
		if (r != 0) {
			resReloc = o;
			o += ((r + 7) / 8);
		}
		if (b != 0) {
			bnkReloc = o;
			o += ((b + 7) / 8);
		}
	}

	public int resPages() { return (resLen + 0xff) >> 8; }
	public int bnkPages() { return (bnkLen + 0xff) >> 8; }

	public String loadMsg() {
		String str = "";
		if (resBase > 0) {
			str += String.format("  %12s  %04X  %04X\n",
				spr.getName().toUpperCase(), resBase << 8, resLen << 8);
		}
		if (bnkBase > 0) {
			str += String.format("  %12s  %04X  %04X\n",
				spr.getName().toUpperCase(), bnkBase << 8, bnkLen << 8);
		}
		return str;
	}

	public void relocRes(int pg) {
		if (resStart == 0) {
			return;
		}
		resBase = pg << 8;
		for (int x = 0; x < resLen; ++x) {
			int bit = (x & 7);
			int byt = (x >> 3);
			if (img[resReloc + byt] == 0) {
				x += 7;
				continue;
			}
			if (((img[resReloc + byt] << bit) & 0x80) == 0) {
				continue;
			}
			img[resStart + x] = (byte)(img[resStart + x] + pg);
		}
	}

	public void relocBnk(int pg) {
		if (bnkStart == 0) {
			return;
		}
		bnkBase = pg << 8;
		for (int x = 0; x < bnkLen; ++x) {
			int bit = (x & 7);
			int byt = (x >> 3);
			if (img[bnkReloc + byt] == 0) {
				x += 7;
				continue;
			}
			if (((img[bnkReloc + byt] << bit) & 0x80) == 0) {
				continue;
			}
			img[bnkStart + x] = (byte)(img[bnkStart + x] + pg);
		}
	}

	// Write records backwards, fill to even page...
	public void resWriteSys(OutputStream fo) throws Exception {
		if (resStart == 0) {
			return;
		}
		int part = resLen & 0xff;
		int off = resLen & 0x7f;
		int rec = resStart + (resLen - 128);
		try {
			if (part > off) {
				fo.write(zero);
			}
			if (off > 0) {
				rec = resStart + (resLen & ~0x7f);
				fo.write(img, rec, off);
				fo.write(zero, 0, 128 - off);
				rec -= 128;
			}
			while (rec >= resStart) {
				fo.write(img, rec, 128);
				rec -= 128;
			}
		} catch (Exception ee) {
			ee.printStackTrace();
		}
	}

	public void bnkWriteSys(OutputStream fo) throws Exception {
		if (bnkStart == 0) {
			return;
		}
		int part = bnkLen & 0xff;
		int off = bnkLen & 0x7f;
		int rec = bnkStart + (bnkLen - 128);
		try {
			if (part > off) {
				fo.write(zero);
			}
			if (off > 0) {
				rec = bnkStart + (bnkLen & ~0x7f);
				fo.write(img, rec, off);
				fo.write(zero, 0, 128 - off);
				rec -= 128;
			}
			while (rec >= bnkStart) {
				fo.write(img, rec, 128);
				rec -= 128;
			}
		} catch (Exception ee) {
			ee.printStackTrace();
		}
	}
}
