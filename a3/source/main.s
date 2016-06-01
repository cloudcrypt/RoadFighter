.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
	mov     sp, #0x8000
	
	bl	EnableJTAG
	bl	InitFrameBuffer


	bl	initializeGameMap

	bl	DisplayMap

	ldr	r0, =car
	mov	r1, #5
	mov	r2, #0
	mov	r3, #32
	mov	r4, #57
	push	{r0, r1, r2, r3, r4}
	bl	DrawTileImage

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

DisplayMap:
	push	{r4-r7, lr}
	x	.req	r5
	y	.req	r6
	addrs	.req	r7
	ldr	addrs, =grid
	mov	y, #0

	yLoop1:

	mov	x, #0

	xLoop1:

	ldrb	r0, [addrs], #1
	cmp	r0, #1
	ldreq	r0, =road
	ldrne	r0, =grass
	mov	r1, x, lsl #5
	mov	r2, y, lsl #5
	mov	r3, #32
	mov	r4, #32
	push	{r0, r1, r2, r3, r4}
	bl	DrawImage

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