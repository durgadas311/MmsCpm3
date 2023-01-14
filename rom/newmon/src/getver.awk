$1=="VERN"&&$2=="equ"{
	vern=$3;
	sub(/[Hh]/,"",vern);
	version=sprintf("%d.%d",vern/10,vern%10);
}
$1=="alpha"&&$2=="equ"{
	alpha=$3;
	if (alpha > 0) version=version "a" alpha;
}
$1=="beta"&&$2=="equ"{
	beta=$3;
	if (alpha == 0 && beta > 0) version=version "b" beta;
}
/maclib/{
	print version;
	exit;
}
