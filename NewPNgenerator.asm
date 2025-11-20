; Xorshift32 for ATtiny13A

.cseg
                                        
	ldi	r23,0x1F
	out	ddrb,R23						; Initialize GPIO pins

	ldi	r23,0x00
	OUT	portb,R23							                                      
	
	ldi	r23, 0x80	
	out	acsr,R23                		; no analog comparator

; ****************************************************************************************
;
; Legacy code for 31 bit Maximal lengthe sequence generator with taps at the 
; 31st and 28th registers connected to a single Xor  gate and fed back to the input,
;
;	ldi		r16,	0x01
;	clr		r17
;	clr		r18
;	clr		r19
;
;	ldi		r21, 0xFF
;
;LOOP:
;
;	out		portb,	r16

;	clr	r20

;	rol		r16
;	rol		r17
;	rol		r18
;	rol		r19
;
;	bst		r19,	4					; tap x28
;	bld		r20,	7					; tap x31
;	eor		r20,	r19
;	andi	r20,	0x80
;	add		r20,	r21
;
;	rjmp	LOOP
;
; ***************************************************************************************	
	
	
	
; xorshift32 code. see https://en.wikipedia.org/wiki/Xorshift

; initialize a 32-bit register to a random, non-zero value:
	
	ldi		r16,	0xAA	; bits_7-0
	ldi		r17,	0xAA	; bits_15-8
	ldi		r18,	0xAA	; bits_23-16
	ldi		r19,	0xAA	; bits_31-24

; Registers r29:r26 will be used to store bit-shifted copies of r19:r16. 
; r29:r26 will be exclusive or'd with r19:r16 and the result stored in r19:r16.
; r30 is sometimes used for temporary storage.
; Bit 0 of r16 will be the single bit output of the noise generator.

LOOP:

; << 13 zeros:	
; copy register r19:r16, left-shift 13 zeros into the copy, and store the results in r29:r26.
; do this by effectively left shifting by 16 bits, then by right-shifting 3 times bit by bit:
	
	; effective 16-bit left shift:

	mov	r30,	r18		
	mov	r29,	r17
	mov	r28,	r16
	clr	r27				; Nothing to copy - it's all zeros 

	; right shift three times bit by bit:

	ror	r30
	ror	r29
	ror	r28
	ror	r27

	ror	r30
	ror	r29
	ror	r28
	ror	r27

	ror	r30
	ror	r29
	ror	r28
	ror	r27

	; exclusive or the original with the shifted copy and store result in original register:

	eor	r19,	r29
	eor	r18,	r28
	eor	r17,	r27
	; r16:		with 13 left shifted zeros, r27 would have been 0x00. Xor r16 with 0x00 -> r16 unchanged.




; >> 17
; copy register r19:r16, right-shift 17 zeros into the copy, and store the results in r29:r26.
; do this by effectively right shifting by 16 bits, then by right-shifting one time bit by bit:

	; effective 16-bit right shift:
	
	; r29 is all zeroes
	; r28 is all zeroes
	mov	r27,	r19
	mov	r26,	r18

	; right shift once bit by bit: 

	clc			; prepare to right-shift a zero
	ror	r27
	ror	r26

	; exclusive or the original with the shifted copy and store the result in the original register:

	eor	r17,	r27
	eor	r16,	r26
	; with r28 and r29 all zeros, Xor of them with r18 and with r19 would leave the r18 and r19 unchanged.




; << 5
; copy register r19:r16, left-shift 5 zeros into the copy, and store the results in r29:r26.
; do this by effectively left shifting by 8 bits, then by right-shifting 3 times bit by bit:

	mov	r30,	r19
	mov	r29,	r18
	mov	r28,	r17
	mov	r27,	r16
	clr	r26

	ror	r30
	ror	r29
	ror	r28
	ror	r27
	ror	r26

	ror	r30
	ror	r29
	ror	r28
	ror	r27
	ror	r26

	ror	r30
	ror	r29
	ror	r28
	ror	r27
	ror	r26

	; exclusive or the original with the shifted copy and store the result in the original register:

	eor	r19,	r29
	eor	r18,	r28
	eor	r17,	r27
	eor	r16,	r26

	out	portb,	r16		; I used PB0 as the output.

	rjmp		LOOP