// Copyright (c) 2019 Douglas Miller <durgadas311@gmail.com>

import java.util.Map;
import java.util.HashMap;
import java.util.Vector;
import java.io.*;

public class SprFile implements Relocatable {
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

	static final int R_BIOS = 0xff;
	static final int R_SCB = 0xfe;
	static final int R_BDOS = 0xfd;
	static final int R_BNKBDOS = 0xfc;
	static final int R_SCBABS = 0xfb;
	static final int R_SNIOS = 0xfa;
	static final int R_NDOS = 0xf9;
	static final int R_EXT = 0xf0;	// base for external relocations

	static Map<Integer,Relocatable> spcl = new HashMap<Integer,Relocatable>();

	static Map<String,Integer> rels = new HashMap<String,Integer>();
	static {
		rels.put("bios", R_BIOS);
		rels.put("bdos", R_BDOS);
		rels.put("bnkbdos", R_BNKBDOS);
		rels.put("snios", R_SNIOS);
		rels.put("ndos", R_NDOS);
	}
	static boolean isReloc(String k) { return rels.containsKey(k); }
	static int getReloc(String k) { return rels.get(k); }
	static Relocatable getSpcl(String k) {
		if (!rels.containsKey(k)) {
			return null;
		}
		return spcl.get(rels.get(k));
	}

	public SprFile(File f, boolean k, int t) {
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
		if (rels.containsValue(t)) {
			spcl.put(t, this);
			if (t == R_BDOS) {
				// not all BDOS's have SCB, but should be ok
				spcl.put(R_SCB, new Scb(this));
				spcl.put(R_SCBABS, new ScbAbs(this));
			}
		}
	}

	public int resPages() { return (resLen + 0xff) >> 8; }
	public int bnkPages() { return (bnkLen + 0xff) >> 8; }

	// Must only be called after relocation
	public int getByte(int adr) {
		if (adr >= resBase && adr < resBase + resLen) {
			return img[(adr - resBase) + resStart] & 0xff;
		}
		if (adr >= bnkBase && adr < bnkBase + bnkLen) {
			return img[(adr - bnkBase) + bnkStart] & 0xff;
		}
		return 0;
	}

	public void putByte(int adr, int val) {
		if (adr >= resBase && adr < resBase + resLen) {
			img[(adr - resBase) + resStart] = (byte)val;
		} else if (adr >= bnkBase && adr < bnkBase + bnkLen) {
			img[(adr - bnkBase) + bnkStart] = (byte)val;
		}
	}

	public String loadMsg() {
		String str = "";
		int a = 0;
		int n = 0;
		String[] fn = spr.getName().toUpperCase().split("\\.");
		if (resLen > 0) {
			a = getRes() << 8;
			n = resPages() << 8;
		}
		if (bnkLen > 0) {
			a = getBnk() << 8;
			n = bnkPages() << 8;
		}
		if (n == 0) {
			return str;
		}
		str += String.format("  %-8s %-3s  %04X  %04X\n",
			fn[0], fn[1], a, n);
		return str;
	}

	public int getRes() { return (resBase >> 8) & 0xff; }
	public int getBnk() { return (bnkBase >> 8) & 0xff; }
	public void setRes(int pg) { resBase = pg << 8; }
	public void setBnk(int pg) { bnkBase = pg << 8; }
	public void relocResOne(byte[] img, int off) { img[off] = (byte)getRes(); }
	public void relocBnkOne(byte[] img, int off) { img[off] = (byte)getBnk(); }

	public void relocRes() {
		if (resStart == 0) {
			return;
		}
		int pg = getRes();
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
			int hi = img[resStart + x] & 0xff;
			if (spcl.containsKey(hi)) {
				spcl.get(hi).relocResOne(img, resStart + x);
			} else if (hi >= R_EXT) {
				System.err.format("%s: unhandled ext reloc at %04x\n",
						spr.getName(), resStart + x);
			} else {
				img[resStart + x] += (byte)(hi + pg);
			}
		}
	}

	public void relocBnk() {
		if (bnkStart == 0) {
			return;
		}
		int pg = getBnk();
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
			int hi = img[bnkStart + x] & 0xff;
			if (spcl.containsKey(hi)) {
				spcl.get(hi).relocBnkOne(img, bnkStart + x);
			} else if (hi >= R_EXT) {
				System.err.format("%s: unhandled ext reloc at %04x\n",
						spr.getName(), bnkStart + x);
			} else {
				img[bnkStart + x] += (byte)(hi + pg);
			}
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
			if (part != 0 && part == off) {
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
