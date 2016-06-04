.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
	mov     sp, #0x8000
	
	bl	EnableJTAG
	bl	InitFrameBuffer
	bl  	InitializeSNES

	bl	InitializeMap

	bl	RenderMap

	mov	r0, #'T'
	mov	r1, #0
	mov	r2, #0
	bl	DrawChar

	mov	r0, #'e'
	mov	r1, #8
	mov	r2, #0
	bl	DrawChar

	mov	r0, #'s'
	mov	r1, #16
	mov	r2, #0
	bl	DrawChar

	mov	r0, #'t'
	mov	r1, #24
	mov	r2, #0
	bl	DrawChar

	mov	r0, #' '
	mov	r1, #42
	mov	r2, #0
	bl	DrawChar

	mov	r0, #'!'
	mov	r1, #40
	mov	r2, #0
	bl	DrawChar

inf:	
	b	inf

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

RenderMap:
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

	mov	r1, x, lsl #5
	mov	r2, y, lsl #5
	mov	r3, #32
	mov	r4, #32
	push	{r0, r1, r2, r3, r4}
	bl	DrawImage

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

	yLoop2:
	mov	x, #0

	xLoop2:

	mov	r0, x
	mov	r1, y
	mov	r2, #0
	bl	DrawPixel

	add	x, #1
	cmp	x, #1024
	bne	xLoop2

	add	y, #1
	cmp	y, #768
	bne	yLoop2

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


	// cmp	y, #0
	// moveq	r0, x
	// moveq	r1, y
	// ldreq	r2, =0xF000
	// bleq	DrawPixel

	// ldr	r0, =767
	// cmp	y, r0
	// moveq	r0, x
	// moveq	r1, y
	// ldreq	r2, =0xF000
	// bleq	DrawPixel

	// cmp	x, #0
	// moveq	r0, x
	// moveq	r1, y
	// ldreq	r2, =0xF000
	// bleq	DrawPixel

	// ldr	r0, =1023
	// cmp	x, r0
	// moveq	r0, x
	// moveq	r1, y
	// ldreq	r2, =0xF000
	// bleq	DrawPixel

	// cmp	x, y
	// moveq	r0, x
	// moveq	r1, y
	// ldreq	r2, =0xF000
	// bleq	DrawPixel