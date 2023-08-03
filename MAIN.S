* SENIOR DADS GEM DESKTOP EMULATOR!!!!
; The ultimate fake demo!

* This was released on the 8th of April 1998, concurrently with Mono-Mental, at
* the 1998 Alt-Party in Helsinki, Finland. 

* This is an *intentionally* fake demo, which "emulates" the GEM desktop on the 
* Atari ST. (Guess how!!) It was done as a sort of "indignant" response to people
* calling the Senior Dads a "fake demo crew". 

* Things to note:
*	; We're using the same chip music player routines that we used in Mono-Mental. In
	; that demo, we played the music from the timer D interrupt, rather then VBL as is
	; usual, since the music is meant to be played at 50Hz, but the Atari mono monitor
	; goes as at 70Hz, and the music would have sounded too fast if it was played from
	; the VBL interrupt. So when we were putting this together, we realised that this 
	; would also apply if the demo was being viewed on a VGA monitor, which displays
	; 60Hz. So we decided to play the music from the timer D interrupt again. The routine
	; is based on code we saw on the Megatizer disk for re-playing Digi-drums.
* 	; In contrast to Mono-Mental, which used Atomix 3.5 compressed Dega PI1 files, this
	; demo uses PC1 files for it's pictures. Someone asked us if we knew how to decompress
	; PC1 files. We didn't, but we looked up the file format, and knocked up the code you
	; see in "includes/PC1LOAD.S". Then, when we were putting this demo together, we
	; thought: "Why bother converting all the PC1 files to PI1, and then compressing them,
	; when now we can just use the PC1 files directly?".

* All new comments are preceded by '<-'.

* ## Assembly information ##
* Assembly format: Devpac 3 (VASM compatible)
* Target processor: Motorola 68000
* Exectuable format: Atari TOS .PRG
* Minimum hardware: Atari STFM with 512K RAM

	;opt	d-

	include	includes\genmacro.s
	include	includes\musmac.s

random macro
	move.w	old_random,\1
	mulu.w	#$3141,\1
	subq.l	#1,\1
	move.w	\1,old_random
	endm

	pea		main
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	clr		-(sp)
	trap	#1

main:
	getphys		oldphys
	getlog		oldlog
	getrez_st	oldrez
	setrez_st	#0,#-1,#-1
	lea			senior_music,a0
	bsr			start_music
	move.w		timer.w,d0
.loop	
	cmp.w		timer.w,d0
	beq.s		.loop

	lea			intro_pic,a0
	move.l		$44e.w,a1
	lea			c16regs.w,a2
	lea			colour_cycles,a3
	bsr			depack_pc1
	wait_clicks	#(320*2)-1

	move.l		#screen,d0
	clr.b		d0
	lea			gem_pic,a0
	move.l		d0,a1
	lea			colour_palette,a2
	lea			colour_cycles,a3
	bsr			depack_pc1

	set_vidaddr	a1
	set_clicks	#100
	lea			16regs.w,a0
.flash1	
	random		d0
	move.w		d0,(a0)+
	cmpa.l		#$ffff8260,a0
	blt.s		.no_reset
	lea			c16regs.w,a0
.no_reset
	if_not_endclicks.s	.flash1

	bsr			go_palette
	wait_clicks	#5
	move.w		(a0),4(a0)
	move.w		2(a0),6(a0)
	wait_clicks	#200

	bsr			go_palette
	wait_clicks	#25
	move.w	(a0),2(a0)
	move.w	4(a0),6(a0)
	wait_clicks	#250

	bsr			go_palette
	wait_clicks	#5
	clr.l		2(a0)
	clr.l		6(a0)
	wait_clicks	#5

	bsr			stop_music
	setrez_st	oldrez,oldphys,oldlog
	rts

go_palette:
	lea			c16regs.w,a0
	movem.l		colour_palette,d0-d7
	movem.l		d0-d7,(a0)
	rts

	include	includes/musplay.s
	include	includes/pc1load.s

	even
intro_pic		incbin	graphics/senior1.pc1		; <- The Senior Dads logo by Jackson Pollock
	even
gem_pic			incbin	graphics/gem.pc1			; <- "GEM Desktop Emulator" title screen (Also by JP)
	even
senior_music	incbin	sound/senior.thk			; <- "Senior Dads Fanfare" by Dame Vera Lynn
	even
old_random		dc.w	$f7f7						; Seed of "random" numbers

	bss
oldrez			ds.w	1
oldphys			ds.l	1
oldlog			ds.l	1
colour_cycles	ds.w	16
colour_palette	ds.w	16

	ds.b	256
	even
screen	ds.b	32000

* End of code.
