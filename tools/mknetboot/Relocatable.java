// Copyright (c) 2019 Douglas Miller <durgadas311@gmail.com>

public interface Relocatable {
	int getRes();
	int getByte(int adr);
	void putByte(int adr, int val);
	void relocResOne(byte[] img, int off);
	void relocBnkOne(byte[] img, int off);
}

