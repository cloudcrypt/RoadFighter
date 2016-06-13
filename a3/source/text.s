.section .text

.global	DrawString
/*
* DrawString(stringAddrs, startX, startY, colour)
* Draw a series of characters at a specific X/Y coordinate, in colour
*/
DrawString:
	push	{r4-r8, lr}
	string	.req	r4
	startX	.req	r5
	startY	.req	r6
	charCtr	.req	r7
	colour	.req 	r8
	mov	string, r0
	mov	startX, r1
	mov	startY, r2
	mov 	colour, r3
	mov	charCtr, #0
	charLoop:
	// increment through the string and check for the null terminator
	ldrb	r0, [string, charCtr]
	cmp	r0, #0
	beq	drawStringEnd

	// offset each character by an amount to add spaces between the characters
	add	r1, startX, charCtr, lsl #3
	mov	r2, startY
	mov 	r3, colour
	bl	DrawChar

	add	charCtr, #1
	b	charLoop

	bne	charLoop
	drawStringEnd:
	.unreq	string
	.unreq	startX
	.unreq	startY
	.unreq	charCtr
	pop	{r4-r8, pc}

/*
* DrawString(charAddrs, startX, startY, colour)
* Draw a scaled character an a specific X/Y coordinate, in colour
*/
DrawChar:
	push	{r4-r10, lr}
	char	.req	r4
	startX	.req	r5
	startY	.req	r6
	fontAd	.req	r7
	byteCtr	.req	r8
	bitCtr	.req	r9
	byte	.req	r10
	mov	char, r0
	mov	startX, r1
	mov	startY, r2
	ldr	fontAd, =font
	mov	byteCtr, #0

	// loop through the bytes in the character from the font definitions file
	byteLoop:
	add	r0, fontAd, byteCtr
	ldrb	byte, [r0, char, lsl #4]
	mov	bitCtr, #0

	bitLoop:
	// for each pixel that would be in the font character
	// draw an extra 3 pixels around it, to scale the character font size
	mov	r0, #0b1
	lsl	r0, bitCtr
	tst	byte, r0
	beq	ignoreBit

	add	r0, startX, bitCtr
	lsl	r0, #1
	add	r1, startY, byteCtr
	lsl	r1, #1
	mov	r2, r3
	push 	{r3}
	bl	DrawPixel
	pop 	{r3}

	add	r0, startX, bitCtr
	lsl	r0, #1
	add	r0, #1
	add	r1, startY, byteCtr
	lsl	r1, #1
	mov	r2, r3
	push 	{r3}
	bl	DrawPixel
	pop 	{r3}

	add	r0, startX, bitCtr
	lsl	r0, #1
	add	r1, startY, byteCtr
	lsl	r1, #1
	add	r1, #1
	mov	r2, r3
	push 	{r3}
	bl	DrawPixel
	pop 	{r3}

	add	r0, startX, bitCtr
	lsl	r0, #1
	add	r0, #1
	add	r1, startY, byteCtr
	lsl	r1, #1
	add	r1, #1
	mov	r2, r3
	push 	{r3}
	bl	DrawPixel
	pop 	{r3}

	ignoreBit:
	add	bitCtr, #1
	cmp	bitCtr, #8
	bne	bitLoop

	add	byteCtr, #1
	cmp	byteCtr, #16
	bne	byteLoop

	.unreq	char
	.unreq	startX
	.unreq	startY
	.unreq	fontAd
	.unreq	byteCtr
	.unreq	bitCtr
	.unreq	byte
	pop	{r4-r10, pc}

.section .data
.align 4
font:	.incbin	"font.bin"