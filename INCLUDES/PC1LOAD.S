; Degas PC1 Code starts here ====================================

* Depack Lo-res Degas Elite Compressed file (PC1)
; a0 = source pic
; a1 = dest bitmap store   (32000 bytes)
; a2 = pic pallete         (16 words)
; a3 = colour anim tables  (4x4 = 16 words)

compressed_flag	equ	%1000000000000000
lo_res_value	equ	0
pic_height		equ	200
pic_bytewidth	equ	160
bitplanes		equ	4

depack_pc1:
	movem.l	d0-a6,-(sp)
	move.w	(a0)+,d0							; Get compressed/res flag
	cmpi.w	#compressed_flag|lo_res_value,d0
	bne.s	.exit								; If not lo res or compressed, abort
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a2)							; Get the palette
	move.w	#pic_height-1,d0					; For each scanline do...
.scanline
	lea		scanline_buffer,a4					;   Get the scanline buffer ready
	move.w	#bitplanes-1,d1						;   For each bitplane do...
.bitplane
	move.w	#(pic_bytewidth/4),d4				;     For a max of one plane scanline do...
.bytes	
	tst.w	d4
	beq.s	.next_bitplane
	moveq	#0,d2
	move.b	(a0)+,d2							;     Get control byte
	tst.b	d2
	bmi.s	.compressed							;     If it's negative it's a "I'm compressed" control byte!
.not_compressed
	move.b	(a0)+,(a4)+							;     Otherwise just copy it
	subq.l	#1,d4
	dbf		d2,.not_compressed
	bra.s	.bytes
.compressed
	ext.w	d2
	neg.w	d2									;     For -(d2)+1 bytes...
	move.b	(a0)+,d3							;       Copy the next byte!
.copy	
	move.b	d3,(a4)+							;       Copy it!
	subq.l	#1,d4
	dbf		d2,.copy
	bra.s	.bytes
.next_bitplane
	dbf		d1,.bitplane
	lea		scanline_buffer,a4
	move.w	#((pic_bytewidth/4)/2)-1,d1			;   Now we convert it to interleaved bitmaps for the screen
.interleave
	move.w	(a4),(a1)
	move.w	(pic_bytewidth/4)(a4),2(a1)
	move.w	((pic_bytewidth/4)*2)(a4),4(a1)
	move.w	((pic_bytewidth/4)*3)(a4),6(a1)
	addq.l	#2,a4
	addq.l	#8,a1
	dbf	d1,.interleave
	dbf	d0,.scanline
	moveq.l	#32-1,d0
.anim_cols
	move.b	(a0)+,(a3)+
	dbf	d0,.anim_cols
.exit
	movem.l	(sp)+,d0-a6
	rts

	even
scanline_buffer	
	ds.b	pic_bytewidth
	even

; End of Degas PC1 code ======================================

