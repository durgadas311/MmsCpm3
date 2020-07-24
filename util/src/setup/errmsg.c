static char *errors[] = {
	"EOK  0",
	"EACCES  1",
	"EBADF  2",
	"EBDFD  3",
	"EDOM  4",
	"EFBIG  5",
	"EINVAL  6",
	"EMFILE  7",
	"ENFILE  8",
	"ENOLCK  9",
	"ENOMEM  10",
	"ENOTSUP  11",
	"EOVERFLOW  12",
	"ANGE  13",
	"ESTAT  14",
	"EAGAIN  15",
};

char *errmsg(int err) {
	return errors[err & 15];
}
