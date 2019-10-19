// Copyright (c) 2019 Douglas Miller <durgadas311@gmail.com>

// NOTE: The SCB exists only in RES memory. BNK refs should never happen.
public class ScbAbs implements Relocatable {
	static final int scb = 0x05;	// fixed offset of SCB in RESBDOS3
	SprFile org;

	public ScbAbs(SprFile org) {
		this.org = org;
		// TODO: compute 'scb' as end-1 pages?
	}
	public int getRes() { return org.getRes() + scb; }
	public int getBnk() { return org.getBnk(); }
	public int getByte(int adr) { return org.getByte(adr + scb); }
	public void putByte(int adr, int val) { org.putByte(adr + scb, val); }
	public void relocResOne(byte[] img, int off) {
		img[off] = (byte)(org.getRes() + scb);
	}
	public void relocBnkOne(byte[] img, int off) {
		img[off] = (byte)org.getBnk();
	}
}

