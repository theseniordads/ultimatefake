# The Ultimate Fake

Full assembler source for the "The Ultimate Fake" demo by The Senior Dads, which was released on the Atari 16 bit platform on the 8th April 1998.

## Specifications

* An Atari ST with at least 1 megabyte of memory, at least TOS 1.04, and an internal hard drive.
* ... Alternatively, a decent emulator like Hatari, configured as above.
* Devpac 3 to assemble the code.
* Atomix packer or better to pack the executable.

## How to assemble on an Atari

* Load "MAIN.S" into Devpac 3.
* Make sure settings are set to assemble to Motorola 68000.
* Assemble to executable file "MAIN.PRG".
* Rename exectuable to "FAKE.PRG".
* Pack "FAKE.PRG" with packer. (**NOTE**: Atomix packer v3.6 is not compatible with the Atari Falcon.)
* Run "FAKE.PRG".

## How to assemble on modern systems

This requires [VASM](http://sun.hasenbraten.de/vasm/https:/) and [Vlink](http://www.compilers.de/vlink.html), which you can get for most modern systems.

To compile the source:

`vasmm68k_mot main.s build/main.o -m68000 -Felf -noesc -quiet -no-opt`

To turn the compiled binary to an Atari executable:

`vlink build/main.o build/FAKE.PRG -bataritos`

## Folders

* `COMPILED` - Original compiled demo and accompanying [README](https://github.com/theseniordads/ultimatefake/blob/main/COMPILED/README.TXT).
* `GRAPHICS` - Graphics, in Degas Elite `.PC1` files.
  * `GEM.PC1` - combined title card and pre-title card (On a seperate bitplane).
  * `SENIOR1.PC1` - "Senior Dads present..." title page.
* `INCLUDES` - Various macro and helpers code.
  * `GENMACROS.S` - General macros.
  * `MUSMAC.S` - Music player macros.
  * `MUSPLAY.S` - VBL-independent music player code.
  *`PC1LOAD.S` - Degas Elite `PC1` image decompessing code.
* `SOUND` - `.THK` files are chip tune music.
  * `SENIOR.THK` - Senior Dads Fanfare.
