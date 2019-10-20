JAVAS = $(wildcard *.java)
CLASSES = $(subst .java,.class,$(JAVAS))

all: $(CLASSES)

jar: mknetboot.jar sysdump.jar

%.class: %.java
	javac $?

mknetboot.jar: all
	echo "Main-Class: mknetboot" >Manifest.txt
	jar -cmf Manifest.txt $@ $(CLASSES)

sysdump.jar: sysdump.class
	echo "Main-Class: sysdump" >Manifest2.txt
	jar -cmf Manifest2.txt $@ sysdump.class
