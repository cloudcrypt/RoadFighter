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
	
	bl drawMenu


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





EnableL1Cache:
	push 	{lr}

	//Make everything go really fast!
	mrc 	p15, #0, r0, c1, c0, #0
	orr 	r0, #0x4
	orr 	r0, #0x800
	orr 	r0, #0x1000
	mcr 	p15, #0, r0, c1, c0, #0

	pop 	{pc}




.section .data
.align 4
testString:
	.asciz	"Fuel: 100       Lives: 3"

