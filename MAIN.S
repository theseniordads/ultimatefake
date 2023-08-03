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
*  	; Notice we don't save the VBL. That's because we don't need to use it! That has an
	; interesting side effect: try moving the mouse around the screen while the demo is
	; still running...

* All new comments are preceded by '<-'.

* ## Assembly information ##
* Assembly format: Devpac 3 (VASM compatible)
* Target processor: Motorola 68000
* Exectuable format: Atari TOS .PRG
* Minimum hardware: Atari STFM with 512K RAM

	;opt	d-

	include	includes\genmacro.s
	include	includes\musmac.s

random macro							; <- Interesting! It appears we have a pseudo-random number generator!
	move.w	old_random,\1
	mulu.w	#$3141,\1
	subq.l	#1,\1
	move.w	\1,old_random
	endm

	pea		main						; <- We run the "main" routine in supervisor mode.
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	clr		-(sp)
	trap	#1

main:
	getphys		oldphys					; <- Save the current screen addresses.
	getlog		oldlog
	getrez_st	oldrez					; <- Save the current screen resolution.
	setrez_st	#0,#-1,#-1				; <- Set the screen resolution to ST-low.
	lea			senior_music,a0			; <- Start up the Senior Dads fanfare!
	bsr			start_music
	move.w		timer.w,d0				; Wait a VBL (?).
.loop	
	cmp.w		timer.w,d0
	beq.s		.loop

	lea			intro_pic,a0			; <- Load the "Senior Dads present..." screen PC1 file.
	move.l		$44e.w,a1				; <- Get the address of the screen.
	lea			c16regs.w,a2			; <- Get the address of the colour registers.
	lea			colour_cycles,a3		; <- Where to save the colour cycles. (Err, we don't use them!)
	bsr			depack_pc1				; <- Decompress the PC1 file AND set the colours!
	wait_clicks	#(320*2)-1				; <- Wait for a bit. (Each 'click' is 1/50th of a second, in timing with the music.)

	move.l		#screen,d0				; <- We set our own screen in the memory above this code.
	clr.b		d0						; <- ... However on the ST, the address of the screen needs to be on a 256 byte boundry. (We add 256 bytes *before* that address so the screen doesn't overwrite our code!)
	lea			gem_pic,a0				; <- Load the "GEM" screen PC1 file.
	move.l		d0,a1					; <- Set our screen as the destination.
	lea			colour_palette,a2		; <- Set the colour palette to go to our buffer. We'll use this later!
	lea			colour_cycles,a3		; <- Where to save the colour cycles. (Err, still don't use them!)
	bsr			depack_pc1				; <- Decompress the PC1 file to where our new screen is.

	set_vidaddr	a1						; <- Set the screen address to our new screen.
	set_clicks	#100					; <- Set the number of clicks to wait to 100. (2 seconds)
	lea			16regs.w,a0				; <- Now we're going to mess with the colour registers!
.flash1	
	random		d0						; <- Get a "random" number.
	move.w		d0,(a0)+				; <- Set the register for the current colour to that number, and move onto the next colour!
	cmpa.l		#$ffff8260,a0			; <- If we've not reached the end of the colour registers...
	blt.s		.no_reset				; <- ... continue the loop, ...
	lea			c16regs.w,a0			; <- ... otherwise, reset the pointer to the start of the colour registers.
.no_reset
	if_not_endclicks.s	.flash1			; <- Keep the loop going until we've waited 2 seconds.

	bsr			go_palette				; <- Change the colours to the colour pallette from the "GEM" screen.
	wait_clicks	#5						; <- Wait for just long enough for a quick-witted person to there's TWO titles onscreen!
	move.w		(a0),4(a0)				; <- Change the colour registers so that there's only the pre-title onscreen. (Remember a0 still points to the colour registers!)
	move.w		2(a0),6(a0)
	wait_clicks	#200					; <- Wait for 4 seconds.

	bsr			go_palette				; <- Change the colours back to the "GEM" screen colours. (Two titles onscreen again!)
	wait_clicks	#25						; <- Wait for half a second (So the user can see the two titles!)
	move.w	(a0),2(a0)					; <- Change the colour registers so that there's only the main title onscreen.
	move.w	4(a0),6(a0)
	wait_clicks	#250

	bsr			go_palette				; <- Change the colours back to the "GEM" screen colours. (Two titles again!)
	wait_clicks	#5						; <- Wait for a tenth of a second. (Did the user spot this one?)
	clr.l		2(a0)					; <- Set the two titles to black.
	clr.l		6(a0)
	wait_clicks	#5						; <- Wait for a bit.

	bsr			stop_music				; <- Stop the music.
	setrez_st	oldrez,oldphys,oldlog	; <- Restore the screen resolution.
	rts									; <- Return to the "emulated" desktop. (Albiet with different colours!)

* <- This sets the colour registers to the palette from the "GEM" screen.
go_palette:
	lea			c16regs.w,a0			; <- We don't actually need to do this, as a0 still points to the colour registers anyway!
	movem.l		colour_palette,d0-d7
	movem.l		d0-d7,(a0)
	rts

* <- Here, we include the code for the music player and the PC1 decompressor.

	include	includes/musplay.s
	include	includes/pc1load.s

	even
intro_pic		incbin	graphics/senior1.pc1		; <- The Senior Dads logo by Jackson Pollock
	even											; <- (Have to do this after each PC1 file, as there's no guarantee that the file will be an even number of bytes!)
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

	ds.b	256					; <- We need to add 256 bytes before the start of the screen address so that it can start on a 256 byte boundry, but not overwrite our code.
	even
screen	ds.b	32000			; <- The screen buffer. (320x200 in 4 bitplanes = ~32K)
	even

* End of code.
