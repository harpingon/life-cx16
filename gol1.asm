zr = $20          ;get zome zero page vars to work with

z_hl = zr         ;hl Pair
z_l  = zr
z_h  = zr+1

z_de = zr+4       ;de pair
z_e  = zr+4
z_d  = zr+5

z_as = zr+6       ;hold a

CursorX = zr+7
CursorY = zr+8
Character = zr+9
Colour = zr+10

ach = zr+12



!src "vera.inc"
*=$0801			; Assembled code should start at $0801
			; (where BASIC programs start)
			; The real program starts at $0810 = 2064
!byte $0C,$08		; $080C - pointer to next line of BASIC code
!byte $0A,$00		; 2-byte line number ($000A = 10)
!byte $9E		; SYS BASIC token
!byte $20		; [space]
!byte $32,$30,$36,$34	; $32="2",$30="0",$36="6",$34="4"
			; (ASCII encoded nums for dec starting addr)
!byte $00		; End of Line
!byte $00,$00		; This is address $080C containing
			; 2-byte pointer to next line of BASIC code
			; ($0000 = end of program)
*=$0810			; Here starts the real program
+video_init
+vset $00000 | AUTO_INC_1 ; VRAM bank 0

CHROUT=$FFD2		; CHROUT outputs a character (C64 Kernal API)
CHRIN=$FFCF		; CHRIN read from default input
CURRENT=$0

top:
	ldx #0
	ldy #9 
	stx CursorX
	sty CursorY
	lda #$2A 	; star
	sta Character
	lda #3		; light blue
	sta Colour
	jsr veraprint
	ldx #39
	ldy #9
	stx CursorX
	sty CursorY
	jsr veraprint
	ldx #0
	ldy #1
	stx CursorX
	sty CursorY
	jsr veraprint
	jsr readlist
	rts

	ldx	#0	; X register is used to index the string
loop:
	lda	.string,x ; Load character from string into A reg
	beq	end	; If the character was 0, jump to end label
	jsr	CHROUT	; Output character stored in A register
	inx		; Increment X register
	jmp	loop	; Jump back to loop label to print next char
end:
	jsr	CHRIN	; Read input until Enter/Return is pressed

	lda #32 	; space
	sta Character
	lda #3		; light blue
	sta Colour
	jsr fullscreen

	lda #$2A 	; star
	sta Character
	jsr fullscreen

	lda #32 	; space
	sta Character
	lda #3		; light blue
	sta Colour
	jsr fullscreen

	lda #$2A 	; star
	sta Character

	jsr	CHRIN	; Read input until Enter/Return is pressed
	jsr	CHRIN	; Read input until Enter/Return is pressed

	jsr readlist

	jsr	CHRIN	; Read input until Enter/Return is pressed
	jsr	CHRIN	; Read input until Enter/Return is pressed

	rts

readlist:
	lda .actions
	ldy #0
readloop:
	lda .actions,y
	cmp #255
	bne outputaction
	rts
outputaction:
	lda .actions,y
	sta verahi
	iny
	lda .actions,y
	sta veramid
	iny
	lda .actions,y
	sta veralo
	lda Character
	sta veradat
	iny
	jmp readloop
	
fullscreen:
	lda #79
	sta CursorX
	lda #59
	sta CursorY
goleft:
	jsr column
	dec CursorX
	bne goleft
	jsr column
	rts		; Return to caller

column:
	jsr veraprint
	dec CursorY
	bne column
	jsr veraprint
	lda #59
	sta CursorY
	rts
	

veraprint:
	pha
	phy
	phx
	; set the memory addr
	jsr sexy
	; send the char to VERA at x y
	ldy Character
	sty veradat
	ldy Colour
	sty veradat
	plx
	ply
	pla
	rts

SetVeraADDR:             
                        
		; A contains vera Hi addr,
		; Y contains vera mid
		; X contains vera lo

		; -- comment - could I use X and Y regs directly
		; -- instead of my Zero page surrogates? Hmm

                sta verahi
                sty veramid
                stx veralo
		rts

sexy:

                stz z_d                     
                lda CursorY     
                clc
                adc z_e                         ;Add carry to M byte
                tay
                lda z_d
                adc #0                          ;Add carry to H byte
                sta z_d
                stz z_e
                lda CursorX     
                asl
                rol z_e
                tax                        
                tya                       
                adc z_e
                tay                      
                lda z_d                 
                adc #$10               

                jsr SetVeraADDR        
		rts

.string !pet	"testing x y coords - waiting for enter...",13,0
!src "grid.inc"
