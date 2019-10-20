// Copyright (c) 2019 Douglas Miller <durgadas311@gmail.com>

import java.io.*;

// dump a cpm3.sys file (or netboot image)
public class sysdump {
	static sysdump that;
	byte[] mem;
	int memtop;
	int comlen;
	int bnktop;
	int bnklen;
	int entry;
	int cfgtbl;
	boolean org0;

	private void loadCore(File img) {
		InputStream fi;
		try {
			fi = new FileInputStream(img);
			int len = fi.available();
			mem = new byte[len];
			fi.read(mem, 0, len);
			fi.close();
		} catch (Exception ee) {
			ee.printStackTrace();
			System.exit(1);
		}
		memtop = (mem[0] & 0xff) << 8;	// 0000 means 10000
		comlen = (mem[1] & 0xff) << 8;
		bnktop = (mem[2] & 0xff) << 8;
		bnklen = (mem[3] & 0xff) << 8;
		entry = (mem[4] & 0xff) | ((mem[5] & 0xff) << 8);
		cfgtbl = (mem[6] & 0xff) | ((mem[7] & 0xff) << 8);
		org0 = (mem[16] == 'C');
	}

	public int read(boolean rom, int bank, int address) {
		return read((bank << 16) | address);
	}
	public int read(int address) {
		return mem[address] & 0xff;
	}
	public void write(int address, int value) {}
	public void reset() {}
	public void dumpCore(String file) {}

	public int size() { return mem.length; }

	public void dumpLine(int adr, int ref) {
		String str;
		str = String.format("%05x:", ref);
		//str = String.format("%04x %05x:", adr, ref);
		int x;
		for (x = 0; x < 16 && adr + x < mem.length; ++x) {
			int c;
			c = mem[adr + x] & 0xff;
			str += String.format(" %02x", c);
		}
		while (x < 16) {
			str += "   ";
			++x;
		}
		str += "  ";
		for (x = 0; x < 16 && adr + x < mem.length; ++x) {
			int c;
			c = mem[adr + x] & 0xff;
			if (c < ' ' || c > '~') {
				c = '.';
			}
			str += String.format("%c", (char)c);
		}
		System.out.println(str);
	}

	public void dumpRecord(int base, int ref) {
		int top = base + 128;
		for (int adr = base; adr < top;) {
			that.dumpLine(adr, ref);
			adr += 16;
			ref += 16;
		}
	}

	public void dumpSection(String sec, int base, int top, int ref) {
		System.out.format("// %s section:\n", sec);
		for (int adr = top - 128; adr >= base;) {
			that.dumpRecord(adr, ref);
			adr -= 128;
			ref += 128;
		}
	}

	public sysdump(File sys) {
		loadCore(sys);
	}

	public static void main(String[] args) {
		File core = null;
		boolean usage = false;
		int base;
		int top;
		int ref;

		for (String arg : args) {
			File f = new File(arg);
			if (f.exists()) {
				core = f;
				continue;
			}
			System.err.format("Unrecognized arg: \"%s\"\n", arg);
			usage = true;
		}
		if (usage || core == null) {
			System.err.format("Usage: sysdump <sys-file>\n");
			System.exit(1);
		}
		that = new sysdump(core);
		that.dumpRecord(0, 0);
		that.dumpRecord(128, 128);
		if (that.org0) {
			System.out.println("// ORG0");
		}
		if (that.entry > 0) {
			System.out.format("// Entry %04x\n", that.entry);
		}
		if (that.cfgtbl > 0) {
			System.out.format("// Net Cfg Tbl %04x\n", that.cfgtbl);
		}
		if (that.comlen > 0) {
			base = 0x100;
			top = base + that.comlen;
			ref = (that.memtop - that.comlen) & 0xffff;
			that.dumpSection("Resident", base, top, ref);
		}
		if (that.bnklen > 0) {
			base = 0x100 + that.comlen;
			top = base + that.bnklen;
			ref = (that.bnktop - that.bnklen) & 0xffff;
			that.dumpSection("Banked", base, top, ref);
		}
	}
}
