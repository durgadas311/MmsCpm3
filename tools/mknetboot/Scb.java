// Copyright (c) 2019 Douglas Miller <durgadas311@gmail.com>

// NOTE: The SCB exists only in RES memory. BNK refs should never happen.
public class Scb implements Relocatable {
	static final int scbhi = 0x05;	// fixed offset of SCB in RESBDOS3
	static final int scblo = 0x9c;	// fixed offset of SCB in RESBDOS3
	static final int scba = (scbhi << 8) | scblo;
	SprFile org;

	public Scb(SprFile org) {
		this.org = org;
		// TODO: compute 'scb' as end-1 pages?
	}
	public int getRes() { return org.getRes() + scbhi; }
	public int getBnk() { return org.getBnk(); }

	// These two will only work for RES
	public int getByte(int adr) {
		adr += scblo + (getRes() << 8);
		return org.getByte(adr);
	}
	public void putByte(int adr, int val) {
		adr += scblo + (getRes() << 8);
		//System.err.format("SCB %04x = %02x\n", adr, val);
		org.putByte(adr, val);
	}

	public void relocOne(byte[] img, int off) {
		img[off - 1] += (byte)scblo;
		img[off] = (byte)(org.getRes() + scbhi);
	}
}

