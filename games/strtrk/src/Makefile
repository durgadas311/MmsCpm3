all: st-h19.com st-kp.com st-xt.com

termh19.o: termh19.c termh19.h
	zcc +cpm -c -o $@ $<

termkp.o: termkp.c termkp.h
	zcc +cpm -c -o $@ $<

termxt.o: termxt.c termxt.h
	zcc +cpm -c -o $@ $<

oscpm.o: oscpm.c
	zcc +cpm -c -o $@ $<

st-h19.o: strtrk.c termh19.h
	zcc +cpm -D_H19_ -c -o $@ $<

st-h19.com: st-h19.o termh19.o oscpm.o
	zcc +cpm -o $@ $^

st-kp.o: strtrk.c termkp.h
	zcc +cpm -D_KP_ -c -o $@ $<

st-kp.com: st-kp.o termkp.o oscpm.o
	zcc +cpm -o $@ $^

st-xt.o: strtrk.c termxt.h
	zcc +cpm -D_XT_ -c -o $@ $<

st-xt.com: st-xt.o termxt.o oscpm.o
	zcc +cpm -o $@ $^
