extern void setchario(CHARTABL *mainchr, char *filename);
extern void cpychr(CHARTABL *chr1, CHARTABL *chr2);
extern void reinitio(CHARTABL *chrentry);
extern void prtchd(CHARTABL *chrentry, bool confg);
extern void prtcvar(CHARTABL *chrentry, bool confg);
extern int getfld(CHARTABL *chrentry, bool confg);
extern void prtcmsg(CHARTABL *chrentry, bool confg);
extern void inhdmsg();
extern void outhdmsg();
extern void initfld(CHARTABL *chrentry);
extern void baudfld(CHARTABL *chrentry);
extern void parfld(CHARTABL *chrentry);
extern void stopfld(CHARTABL *chrentry);
extern void wlenfld(CHARTABL *chrentry);
extern void sftpfld(CHARTABL *chrentry);
extern void inhdfld(CHARTABL *chrentry);
extern void outhdfld(CHARTABL *chrentry);
extern void prtdce(CHARTABL *chrentry);
extern void prtbasept(CHARTABL *chrentry);
extern void prtinitflg(CHARTABL *chrentry);
extern void prtbaudrt(CHARTABL *chrentry);
extern void prtparity(CHARTABL *chrentry);
extern void prtstop(CHARTABL *chrentry);
extern void prtwlen(CHARTABL *chrentry);
extern void prtsft(CHARTABL *chrentry);
extern void prtinhand(CHARTABL *chrentry);
extern void prtouthand(CHARTABL *chrentry);
extern void prtpinnum(CHARTABL *chrentry);
extern void prtpin(short pos, char *s);
extern void prtpind(short pos, char *s);
extern int setnode(CHARTABL *chrentry, char *filename);
extern void prtndhd(CHARTABL *chrentry);
extern void prtnd(byte ndnum);