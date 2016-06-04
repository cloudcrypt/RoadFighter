.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
	mov     sp, #0x8000
	
	bl	EnableJTAG
	bl 	EnableL1Cache

	bl	InitFrameBuffer
	bl  	InitializeSNES

	bl	InitializeMap

	bl	InitialRenderMap

	ldr	r0, =testString
	mov	r1, #0
	mov	r2, #0
	bl	DrawString

	//ldr	r0, =1000000
	//bl	Wait

inputloop:
mainLoop:
	// this is not working?????????
	// or maybe I'm doing something wrong,
	// but, I'm not getting a sequence of random
	// numbers!
	// mov	r1, #1
	// mov	r2, #10
	// bl	RandomNumber

	ldr 	r0, =100000 
	bl 	Wait

	bl	GenerateNextRow

	bl	ShiftMap

	bl	RenderMap

	//ldr	r0, =2000000
	//bl	Wait

	//b	mainLoop

	bl 	UpdateSNESInput

	tst	r0, #1
	ldreq r1, =playerPosY
	ldreq r2, [r1]
	addeq r2, #1
	streq r2, [r1]  

	ldr r1, =0x100
	tst	r0, r1
	ldreq r1, =playerPosY
	ldreq r2, [r1]
	subeq r2, #1
	streq r2, [r1] 

	ldr r1, =0x80
	tst	r0, r1
	ldreq r1, =playerPosX
	ldreq r2, [r1]
	addeq r2, #1
	streq r2, [r1] 

	ldr r1, =0x40
	tst	r0, r1
	ldreq r1, =playerPosX
	ldreq r2, [r1]
	subeq r2, #1
	streq r2, [r1] 

	ldr	r0, =car
	ldr	r1, =playerPosX
	ldr r2, =playerPosY
	ldr	r1, [r1]
	ldr r2, [r2]
	mov	r3, #32
	mov	r4, #57
	push	{r0, r1, r2, r3, r4}
	bl	DrawTileImage

	//ldr r0, =200000
	//bl 	Wait

	b 	inputloop


	// x	.req	r4
	// y	.req	r5
	// imgAddrs	.req	r6
	// ldr	imgAddrs, =img
	// mov	y, #100

	// yLoop:
	// mov	x, #100

	// xLoop:

	// mov	r0, x
	// mov	r1, y
	// ldrh	r2, [imgAddrs], #2
	// bl	DrawPixel

	// add	x, #1
	// cmp	x, #800
	// bne	xLoop

	// add	y, #1
	// cmp	y, #700
	// bne	yLoop


    
haltLoop$:
	b	haltLoop$

InitialRenderMap:
	push	{r4-r7, lr}
	x	.req	r5
	y	.req	r6
	addrs	.req	r7
	ldr	addrs, =grid
	mov	y, #1

	yLoop1:

	mov	x, #0

	xLoop1:

	ldrb	r1, [addrs], #1

	mov	r2, #0b10
	tst	r1, r2
	beq	ignoreTile

	lsr	r1, #3

	ldr 	r0, =tiles
	ldr 	r0, [r0, r1, lsl #2]

	mov	r1, x
	mov	r2, y
	mov	r3, #32
	mov	r4, #32
	push	{r0, r1, r2, r3, r4}
	bl	DrawTileImage

	mov	r0, x
	sub	r1, y, #1
	bl	ClearChanged

	ignoreTile:
	add	x, #1
	cmp	x, #32
	bne	xLoop1

	add	y, #1
	cmp	y, #24
	bne	yLoop1
	
	.unreq	x
	.unreq	y
	.unreq	addrs
	pop	{r4-r7, pc}

RenderMap:
	
	push	{r4-r7, lr}
	x	.req	r5
	y	.req	r6
	addrs	.req	r7
	ldr	addrs, =grid
	mov	y, #1

	yLoop2:

	mov	x, #0

	xLoop2:

	ldrb	r1, [addrs], #1

	mov	r2, #0b10
	tst	r1, r2
	beq	ignoreTile1

	lsr	r1, #3

	ldr 	r3, =tiles
	ldr 	r0, [r3, r1, lsl #2]

	cmp 	y, #23
	beq 	drawFullTile
	ldrneb 	r1, [addrs, #31]
	lsrne	r1, #3
	ldrne 	r1, [r3, r1, lsl #2]
	movne	r2, x
	movne	r3, y
	blne	DrawPreciseImage
	b 	doneDraw

	drawFullTile:
	moveq	r1, x
	moveq	r2, y
	moveq	r3, #32
	moveq	r4, #32
	pusheq	{r0, r1, r2, r3, r4}
	bleq	DrawTileImage

	doneDraw:

	mov	r0, x
	sub	r1, y, #1
	bl	ClearChanged

	ignoreTile1:
	add	x, #1
	cmp	x, #32
	bne	xLoop2

	add	y, #1
	cmp	y, #24
	bne	yLoop2

	.unreq	x
	.unreq	y
	.unreq	addrs
	pop	{r4-r7, pc}

//DrawPreciseImage(imgAddress1, imgAddress2, startTX, startTY)
//Can only be used to draw tiles! Cannot use to draw cars!
DrawPreciseImage:
	push 	{r4-r10, lr}

	x 		.req 	r4
	y 		.req 	r5
	imgAddrs1 	.req 	r6
	imgAddrs2 	.req 	r7
	xOffset		.req 	r8
	yOffset		.req 	r9

	mov 	imgAddrs1, r0
	mov 	imgAddrs2, r1 	
	lsl 	xOffset,  r2, #5 
	lsl 	yOffset, r3, #5

	mov 	y, #0

	outLoop:
	mov 	x, #0

	inLoop:

	ldrh 	r2, [imgAddrs1], #2
	ldrh 	r1, [imgAddrs2], #2
	
	cmp 	r1, r2
	beq 	equal

	add 	r0, xOffset, x
	add 	r1, yOffset, y
	
	cmp	r2, #0
	blne	DrawPixel

	equal:

	add 	x, #1
	cmp 	x, #32
	bne 	inLoop

	add 	y, #1
	cmp 	y, #32
	bne 	outLoop

	pop 	{r4-r10, pc}

// DrawTileImage(imgAddrs, startTX, startTY, dimX, dimY)
DrawTileImage:
	pop	{r0, r1, r2, r3, r4}
	push	{lr}
	mov	r1, r1, lsl #5
	mov	r2, r2, lsl #5
	push	{r0, r1, r2, r3, r4}
	bl	DrawImage
	pop	{pc}


// DrawImage(imgAddrs, startX, startY, dimX, dimY)
DrawImage:
	pop	{r0, r1, r2, r3, r4}
	push	{r4, r5, r6, r7, r8, r9, lr}

	x		.req	r4
	y		.req	r5
	imgAddrs	.req	r6
	startX		.req	r7
	dimX		.req	r8
	dimY		.req	r9
	mov	imgAddrs, r0
	add	dimX, r3, r1
	add	dimY, r4, r2
	mov	startX, r1
	mov	y, r2

	yLoop:
	cmp	y, #768
	beq	drawImageEnd
	mov	x, startX

	xLoop:

	mov	r0, x
	mov	r1, y
	ldrh	r2, [imgAddrs], #2
	cmp	r2, #0
	blne	DrawPixel

	add	x, #1
	cmp	x, dimX
	bne	xLoop

	add	y, #1
	cmp	y, dimY
	bne	yLoop

	drawImageEnd:
	.unreq	x
	.unreq	y
	.unreq	imgAddrs
	.unreq	startX
	.unreq	dimX
	.unreq	dimY
	pop	{r4, r5, r6, r7, r8, r9, pc}

ClearScreen:
	push	{r4, r5, lr}

	x		.req	r4
	y		.req	r5
	mov	y, #0

	yLoop3:
	mov	x, #0

	xLoop3:

	mov	r0, x
	mov	r1, y
	mov	r2, #0
	bl	DrawPixel

	add	x, #1
	cmp	x, #1024
	bne	xLoop3

	add	y, #1
	cmp	y, #768
	bne	yLoop3

	clearScreenEnd:
	.unreq	x
	.unreq	y
	pop	{r4, r5, pc}





/* Draw Pixel
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */
DrawPixel:
	push	{r4}

	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add	offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl	offset, #1

	// store the colour (half word) at framebuffer pointer + offset
	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	.unreq	offset
	pop	{r4}
	bx	lr

EnableL1Cache:
	push 	{lr}

	//Make everything go really fast!
	mrc 	p15, #0, r0, c1, c0, #0
	orr 	r0, #0x4
	orr 	r0, #0x800
	orr 	r0, #0x1000
	mcr 	p15, #0, r0, c1, c0, #0

	pop 	{pc}

DrawString:
	push	{r4-r7, lr}
	string	.req	r4
	startX	.req	r5
	startY	.req	r6
	charCtr	.req	r7
	mov	string, r0
	mov	startX, r1
	mov	startY, r2
	mov	charCtr, #0
	charLoop:
	ldrb	r0, [string, charCtr]
	cmp	r0, #0
	beq	drawStringEnd

	add	r1, startX, charCtr, lsl #3
	mov	r2, startY
	bl	DrawChar

	add	charCtr, #1
	b	charLoop

	bne	charLoop
	drawStringEnd:
	.unreq	string
	.unreq	startX
	.unreq	startY
	.unreq	charCtr
	pop	{r4-r7, pc}

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

	byteLoop:
	add	r0, fontAd, byteCtr
	ldrb	byte, [r0, char, lsl #4]
	mov	bitCtr, #0

	bitLoop:
	mov	r0, #0b1
	lsl	r0, bitCtr
	tst	byte, r0
	beq	ignoreBit

	add	r0, startX, bitCtr
	lsl	r0, #1
	add	r1, startY, byteCtr
	lsl	r1, #1
	ldr	r2, =0xFFFF
	bl	DrawPixel

	add	r0, startX, bitCtr
	lsl	r0, #1
	add	r0, #1
	add	r1, startY, byteCtr
	lsl	r1, #1
	ldr	r2, =0xFFFF
	bl	DrawPixel

	add	r0, startX, bitCtr
	lsl	r0, #1
	add	r1, startY, byteCtr
	lsl	r1, #1
	add	r1, #1
	ldr	r2, =0xFFFF
	bl	DrawPixel

	add	r0, startX, bitCtr
	lsl	r0, #1
	add	r0, #1
	add	r1, startY, byteCtr
	lsl	r1, #1
	add	r1, #1
	ldr	r2, =0xFFFF
	bl	DrawPixel

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
testString:
	.asciz	"Fuel: 100       Lives: 3"

