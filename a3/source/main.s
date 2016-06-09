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
	ldr 	r3, =0xFFFF
	bl	DrawString

	// draw100:
	// bl 	PrintFuel
	// ldr 	r0, =playerFuel
	// ldr 	r1, [r0]
	// sub 	r1, #1
	// str 	r1, [r0]
	// ldr 	r0, =333000
	// bl 	Wait
	// b 	draw100	

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

	// ldr 	r0, =100000 
	// bl 	Wait

	bl 	RandomNumber
	cmp 	r0, #16
	blge  	GenerateFinishLine
	bllt	GenerateNextRow

	bl	ShiftMap

	bl	RenderMap

	// ldr	r0, =100000
	// bl	Wait

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
	push 	{lr}
	mov 	r0, #0
	mov 	r1, #0
	mov 	r2, #1024
	mov 	r3, #768
	bl 	ClearArea
	pop 	{pc}

// r0 - pos x
// r1 - pos y
// r2 - width
// r3 - height
ClearArea:
	push	{r4-r9, lr}

	x		.req	r4
	y		.req	r5
	endX 		.req 	r6
	endY 		.req 	r7
	startX 		.req 	r8
	startY 		.req 	r9
	
	mov 	startX, r0
	mov 	startY, r1
	add 	endX, r0, r2
	add 	endY, r1, r3

	mov	y, startY

	yLoop3:
	mov	x, startX

	xLoop3:

	mov	r0, x
	mov	r1, y
	mov	r2, #0
	bl	DrawPixel

	add	x, #1
	cmp	x, endX
	bne	xLoop3

	add	y, #1
	cmp	y, endY
	bne	yLoop3

	clearScreenEnd:
	.unreq	x
	.unreq	y
	.unreq	endX
	.unreq 	endY
	.unreq 	startX
	.unreq 	startY
	pop	{r4-r9, pc}





/* Draw Pixel
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */
DrawPixel:
	push	{r4, lr}

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

	pop	{r4, pc}

EnableL1Cache:
	push 	{lr}

	//Make everything go really fast!
	mrc 	p15, #0, r0, c1, c0, #0
	orr 	r0, #0x4
	orr 	r0, #0x800
	orr 	r0, #0x1000
	mcr 	p15, #0, r0, c1, c0, #0

	pop 	{pc}

PrintFuel:
	push 	{r4-r5, lr}


	ldr 	r4, =playerFuel
	ldr 	r4, [r4]
	ldr 	r0, =fuelAmount

	cmp 	r4, #100
	blt 	doubleDigitFuel
	ldr 	r5, =0x15A0 // green
	// print 100
	mov 	r1, #49
	strb 	r1, [r0]
	mov 	r1, #48
	strb 	r1, [r0, #1]
	strb 	r1, [r0, #2]
	mov 	r1, #0
	strb 	r1, [r0, #3]
	b 	displayFuel

	// print double digit fuel
	doubleDigitFuel:
	cmp 	r4, #10
	blt 	singleDigitFuel

	mov 	r1, #0
	numTens:
	add 	r1, #1
	sub 	r4, #10
	cmp 	r4, #10
	bge 	numTens

	cmp	r1, #7
	ldrge 	r5, =0x9700// green 
	bge 	loadFuelToMem
	cmp 	r1, #5
	ldrge 	r5, =0xffa1 // green yellow
	bge 	loadFuelToMem
	ldr 	r5, =0xfe00 // yellow

	loadFuelToMem:
	add 	r1, #48
	strb 	r1, [r0]
	add 	r4, #48
	strb 	r4, [r0, #1]
	mov 	r1, #0
	strb 	r1, [r0, #2]

	b 	displayFuel

	singleDigitFuel:
	add 	r4, #48
	strb 	r4, [r0]
	mov 	r1, #0
	strb 	r1, [r0, #1]
	ldr 	r5, =0xf800 // red

	displayFuel:

	mov 	r0, #80
	mov 	r1, #0
	mov 	r2, #100
	mov 	r3, #32
	bl 	ClearArea


	ldr 	r0, =fuelAmount
	mov 	r3, r5 	// set colour
	mov 	r1, #40 // x 
	mov 	r2, #0 // y
	bl 	DrawString

	pop 	{r4-r5, pc}


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
	ldrb	r0, [string, charCtr]
	cmp	r0, #0
	beq	drawStringEnd

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
testString:
	.asciz	"Fuel:"
.align 1
clearFuel:
	.asciz "   "
fuelAmount:
	.int 	3	
	.asciz 	""

	
