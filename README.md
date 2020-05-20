# MmsCpm3
## MMS CP/M 3 Source, Binaries, and related code.

Subdirectories "src" and "bin" are for source and binary files,
respectively. Top-level directories are:

**sys:**
-   CP/M 3 System components, required to build CPM3.SYS

**doc:**
-   Documentation, OpenOffice, PDF, text.

**help:**
-   CP/M 3 HELP source files and build scripts.

**util:**
-   CP/M 3 non-standard utilities, MMS and modern.

**net:**
-   CP/NET remnants, network boot support.

**defsasi3:**
-   DEFSASI3 files.

**dist:**
-   Standard DRI CP/M 3 distribution files

**img:**
-   Pre-built (and possibly pre-used) bootable images.
    Subdirectories organize images by system config.

**3p**
-   Third-party software, source where available.
    -   cc80 - Software Toolworks C compiler
    -   swtw-c80 - Another vintage of Software Toolworks C compiler
    -   magicwand - Magic Wand word processing

**rom**
-   H89/H8 monitor ROM software

**cpm2**
-   MMS CP/M 2.2 software (sys, util subdirectories)

**tools**
-   A place for host tools - run on modern PCs not CP/M

All source/text files are in Linux/Unix format - no CR or Ctrl-Z characters.
Use "unix2dos" ("dos2unix" package) or equivalent to convert to CP/M format.
Or TR.COM may be used in CP/M to translate line endings.
