.section .text

.global DisplayWin
DisplayWin:
	push 	{r4, lr}
	// actual win
	
	ldr 	r0, =win 
	mov 	r1, #160
	mov 	r2, #160
	mov 	r3, #704
	mov 	r4, #384
	push 	{r0-r4}
	bl 	DrawImage

	pop 	{r4, pc}

.global DisplayLose
DisplayLose:
	push 	{r4, lr}
	// actual print lose
	
	ldr 	r0, =gameOver 
	mov 	r1, #160
	mov 	r2, #160
	mov 	r3, #704
	mov 	r4, #384
	push 	{r0-r4}
	bl 	DrawImage

	pop 	{r4, pc}

.global	RenderMap
RenderMap:
	
	push	{r4-r8, lr}
	x	.req	r5
	y	.req	r6
	addrs	.req	r7
	ldr	addrs, =grid
	mov	y, #1

	//ldr 	r0, =100000 
	//bl 	Wait

	yLoop2:

	mov	x, #0

	xLoop2:

	mov	r0, x
	mov	r1, y
	bl	RenderMapTile

	add	x, #1
	cmp	x, #32
	bne	xLoop2

	add	y, #1
	cmp	y, #24
	bne	yLoop2

	.unreq	x
	.unreq	y
	.unreq	addrs
	pop	{r4-r8, pc}

.global	RenderMapTile
RenderMapTile:
	push	{r4-r8, lr}
	x	.req	r5
	y	.req	r6
	addrs	.req	r7
	ldr	addrs, =grid
	mov	x, r0
	mov	y, r1

	sub	r0, y, #1
	add	r0, x, r0, lsl #5
	ldrb	r1, [addrs, r0]

	mov	r2, #0b10
	tst	r1, r2
	beq	ignoreTile1

	mov 	r2, #0b1
	tst 	r1, r2
	bne 	vehicleTile

	mov	r0, x
	mov	r2, r1
	mov	r1, y
	bl	RenderNormalTile

	b 	clearTile

	vehicleTile:

	mov	r0, x
	mov	r2, r1
	mov	r1, y
	bl	RenderVehicleTile

	clearTile:
	mov	r0, x
	sub	r1, y, #1
	bl	ClearChanged

	ignoreTile1:
	.unreq	x
	.unreq	y
	.unreq	addrs
	pop	{r4-r8, pc}

RenderNormalTile:
	push	{r4-r5, lr}
	x	.req	r4
	y	.req	r5
	mov	x, r0
	mov	y, r1
	mov	r1, r2

	lsr	r1, #3
	ldr 	r3, =tiles
	ldr 	r0, [r3, r1, lsl #2]
	mov	r1, x
	mov	r2, y
	bl	DrawPreciseImage

	.unreq	x
	.unreq	y
	pop	{r4-r5, pc}

RenderVehicleTile:
	push	{r4-r7, lr}
	x	.req	r5
	y	.req	r6
	mov	x, r0
	mov	y, r1
	mov	r1, r2

	lsr	r1, #3
	ldr 	r3, =tiles
	ldr 	r7, [r3, r1, lsl #2]
	
	mov 	r0, x
	sub 	r1, y, #1
	bl	GetTileVehicle
	// DrawPreciseAroundVehicle
	// (tileImgAddrs, vehicleAddrs, startTX, startTY, vehicleTileOffset, vehiclePixelEnd)
	afterGetTileVehicle:
	push 	{x} 
	mov 	r4, r1
	mov 	r1, r0
	mov 	r2, x
	mov 	r3, y
	ldr	r5, [r0, #-4]
	mov 	r0, r7
	push 	{r0-r5}
	bl 	DrawPreciseAroundVehicle
	pop 	{x}

	.unreq	x
	.unreq	y
	pop	{r4-r7, pc}

//Call this if a grid element contains a car. This will find the car, and return required
//information. Returns car information: Address in array in r0, tile offset in r1
GetTileVehicle:
	push 	{r4-r10, lr}

	x 	.req 	r4
	y 	.req 	r5
	originalY	.req 	r6

	ldr 	r2, =carGrid
	sub 	x, r0, #5
	add 	y, r1, #4
	mov 	originalY, y

	//First, check if it is the players car
	ldr 	r3, =playerPosX
	ldr 	r3, [r3]
	cmp 	r0, r3
	bne 	aiCar
	ldr 	r3, =playerPosY
	ldr 	r3, [r3]
	//sub 	r1, #1
	cmp 	r1, r3
	moveq 	r0, #0
	moveq 	y, #0
	moveq 	originalY, #0
	beq 	interpretByte
	sub 	r1, #1
	cmp 	r1, r3
	moveq 	r0, #0
	moveq 	y, #0
	moveq 	originalY, #1
	beq 	interpretByte

	aiCar:

	mov 	r0, x
	mov 	r1, y
	bl 	GetCarCell
	cmp 	r0, #0
	bne 	interpretByte
	subeq 	y, #1
	beq 	aiCar 	


	interpretByte:

	lsr 	r0, #4
	ldr 	r2, =cars
	add 	r2, r0, lsl #2
	ldr 	r0, [r2]
	add 	r0, #8
	sub 	r1, originalY, y	//This is the tile offset

	.unreq 	x
	.unreq 	y
	.unreq 	originalY
	
	pop 	{r4-r10, pc}

//Modified draw precise image so that it only needs the new tile, 
//and reads the framebuffer for comparison
//does not call draw pixel, contains that functionality
//DrawPreciseImage(imgAddress1, startTX, startTY)
DrawPreciseImage:
	push 	{r4-r10, lr}

	x 		.req 	r4
	y 		.req 	r5
	imgAddrs1 	.req 	r6
	frameBuffer 	.req 	r7
	xOffset		.req 	r8
	yOffset		.req 	r9

	mov 	imgAddrs1, r0
	ldr 	frameBuffer, =FrameBufferPointer 	//Get pointer
	ldr 	frameBuffer, [frameBuffer]		//load pointer
	lsl 	xOffset,  r1, #6 
	lsl 	yOffset, r2, #6

	add 	frameBuffer, xOffset
	add 	frameBuffer, yOffset, lsl #10

	mov 	y, #0

	outLoop1:
	mov 	x, #0

	inLoop1:

	ldrh 	r2, [imgAddrs1], #2
	lsl	r3, x, #1
	ldrh 	r1, [frameBuffer, r3]
	
	cmp 	r1, r2
	beq 	equalColour

	add 	r0, xOffset, x
	add 	r1, yOffset, y
	
	cmp	r2, #0
	lslne	r3, x, #1
	strneh	r2, [framebuffer, r3]

	equalColour:

	add 	x, #1
	cmp 	x, #32
	bne 	inLoop1

	add 	y, #1
	add 	frameBuffer, #2048
	cmp 	y, #32
	bne 	outLoop1

	.unreq 	x
	.unreq 	y
	.unreq 	imgAddrs1
	.unreq 	frameBuffer
	.unreq 	xOffset
	.unreq 	yOffset

	pop 	{r4-r10, pc}

//This method can be called to draw a tile under a car! (So as not to make the car flicker!!!)
// DrawPreciseAroundVehicle(tileAddrs, vehicleAddrs, startTX, startTY, vehicleTileOffset, vehiclePixelEnd)
// vehicleTileOffset is the offset of the tile from the top of the vehicle
// vehiclePixelEnd is the height of the vehicle. I.E. player car is 57
DrawPreciseAroundVehicle:
	pop	{r0-r5}
	push 	{r4-r10, lr}

	vehicleTile	.req 	r4
	vehicleRows 	.req 	r5
	tileImgAddrs 	.req 	r6
	vehImgAddrs 	.req 	r7
	x		.req 	r8
	y		.req 	r9
	xOffset 	.req 	r10
	yOffset 	.req	r3

	mov 	tileImgAddrs, r0
	mov 	vehImgAddrs, r1
	mov 	xOffset, r2, lsl #5
	mov 	yOffset, r3, lsl #5
	lsl 	r0, vehicleTile, #11		//Start down X tiles in the vehicle image address
	sub 	vehicleRows, vehicleTile, lsl #5
	add 	vehImgAddrs, r0 		//Offset the address

	mov 	y, #0

	yLoop4:

	mov 	x, #0
	xLoop4:

	cmp 	vehicleRows, #0
	beq 	noVehicle

	ldrh 	r0, [vehImgAddrs]
	cmp 	r0, #0
	bne 	yesVehicle 		

	noVehicle:

	push 	{r3}
	add 	r0, x, xOffset
	add 	r1, y, yOffset	
	ldrh 	r2, [tileImgAddrs]
	//cmp	r2, #0
	bl 	DrawPixel
	pop 	{r3}

	yesVehicle:

	add 	vehImgAddrs, #2
	add 	tileImgAddrs, #2

	add 	x, #1
	cmp 	x, #32
	bne 	xLoop4

	cmp 	vehicleRows, #0
	subne 	vehicleRows, #1
	add 	y, #1
	cmp 	y, #32
	bne 	yLoop4	

	.unreq 	x
	.unreq 	y
	.unreq 	vehicleTile
	.unreq 	vehicleRows
	.unreq 	xOffset
	.unreq 	yOffset
	.unreq 	tileImgAddrs
	.unreq 	vehImgAddrs
	pop 	{r4-r10, pc}

.global DrawTileImage
// DrawTileImage(imgAddrs, startTX, startTY, dimX, dimY)
DrawTileImage:
	pop	{r0, r1, r2, r3, r4}
	push	{lr}
	mov	r1, r1, lsl #5
	mov	r2, r2, lsl #5
	push	{r0, r1, r2, r3, r4}
	bl	DrawImage
	pop	{pc}

.global	DrawHeaderImage
// DrawImage(imgAddrs, startX, dimX, dimY)
DrawHeaderImage:
	push	{r4-r9, lr}

	x		.req	r4
	y		.req	r5
	imgAddrs	.req	r6
	startX		.req	r7
	dimX		.req	r8
	dimY		.req	r9

	mov	imgAddrs, r0
	add	dimX, r3, r1
	add	dimY, #32
	mov	startX, r1
	mov	y, #0

	1:
	cmp	y, #32
	beq	1f
	mov	x, startX

	2:
	mov	r0, x
	mov	r1, y
	ldrh	r2, [imgAddrs], #2
	cmp	r2, #0
	blne	DrawPixel

	add	x, #1
	cmp	x, dimX
	bne	2b

	add	y, #1
	cmp	y, dimY
	bne	1b

	1:
	.unreq	x
	.unreq	y
	.unreq	imgAddrs
	.unreq	startX
	.unreq	dimX
	.unreq	dimY
	pop	{r4-r9, pc}

.global	DrawImage
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
	cmp	y, #32
	addlt	imgAddrs, #64
	blt	ignoreRow
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

	ignoreRow:
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
 .global DrawPixel
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
