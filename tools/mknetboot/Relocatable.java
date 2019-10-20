// Copyright (c) 2019 Douglas Miller <durgadas311@gmail.com>

public interface Relocatable {
	int getRes();
	int getByte(int adr);
	void putByte(int adr, int val);
	void relocOne(byte[] img, int off);
}
