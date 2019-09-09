JAVAS = $(wildcard *.java)
CLASSES = $(subst .java,.class,$(JAVAS))

all: $(CLASSES)

jar: mknetboot.jar

%.class: %.java
	javac $?

mknetboot.jar: all
	echo "Main-Class: mknetboot" >Manifest.txt
	jar -cfm $@ $(CLASSES)
