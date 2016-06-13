.section .text

/*
* Sets arguments and Draws the win screen
*/
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

/*
* Sets arguments and Draws the lose screen
*/
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

/*
* Iterates through each tile and calls another subroutine which decides whether to render 
* the tile or not. Really just a subroutine for looping through all the tiles.
*/
.global	RenderMap
RenderMap:
	
	push	{r4-r8, lr}
	x	.req	r5
	y	.req	r6
	addrs	.req	r7
	ldr	addrs, =grid
	mov	y, #1

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

/*
* Same functionality as RenderMap except it does not re-render the tiles that the main menu
* starts on. 
*/
.global	RenderMapMenu
RenderMapMenu:
	
	push	{r4-r8, lr}
	x	.req	r5
	y	.req	r6
	addrs	.req	r7
	ldr	addrs, =grid
	mov	y, #1

	yLoop5:
	mov	x, #0

	xLoop5:

	//Bounds checking to not draw over the main menu
	cmp 	y, #6
	blt 	drawNormal

	cmp 	y, #16
	bgt 	drawNormal

	cmp 	x, #5
	blt 	drawNormal

	cmp 	x, #26
	bgt 	drawNormal

	b 	skipDraw

	drawNormal:

	mov	r0, x
	mov	r1, y
	bl	RenderMapTile

	skipDraw:

	add	x, #1
	cmp	x, #32
	bne	xLoop5

	add	y, #1
	cmp	y, #24
	bne	yLoop5

	.unreq	x
	.unreq	y
	.unreq	addrs
	pop	{r4-r8, pc}

/*
* RenderMapTile(gridX, gridY)
* Checks the tile specified in arguments, and may or may not re-render it depending on
* its flags
*/
.global	RenderMapTile
RenderMapTile:
	push	{r4-r8, lr}
	x	.req	r5
	y	.req	r6
	addrs	.req	r7
	ldr	addrs, =grid
	mov	x, r0
	mov	y, r1

	//Get offset for tile and load it
	sub	r0, y, #1
	add	r0, x, r0, lsl #5
	ldrb	r1, [addrs, r0]

	//Check if this tile's changed bit is set. If not,do nothing
	mov	r2, #0b10
	tst	r1, r2
	beq	ignoreTile1

	//Check if this tile's car bit is set. If so, branch to the vehicle drawing method
	mov 	r2, #0b1
	tst 	r1, r2
	bne 	vehicleTile

	//Otherwise, render the tile normally.
	//Pass in x,y and the tile byte
	mov	r0, x
	mov	r2, r1
	mov	r1, y
	bl	RenderNormalTile

	b 	clearTile

	vehicleTile:

	//Render vehicle tile, pass in x,y and tile byte
	mov	r0, x
	mov	r2, r1
	mov	r1, y
	bl	RenderVehicleTile

	//Clear the changed bit so that it will not be rendered next iteration
	clearTile:
	mov	r0, x
	sub	r1, y, #1
	bl	ClearChanged

	ignoreTile1:
	.unreq	x
	.unreq	y
	.unreq	addrs
	pop	{r4-r8, pc}

/*
* RenderNormalTile(x,y,TileByte)
* Sets up arguments for precise image draw.
*/
RenderNormalTile:
	push	{r4-r5, lr}
	x	.req	r4
	y	.req	r5
	mov	x, r0
	mov	y, r1
	mov	r1, r2

	//Get offset of image, set into r0 for function call
	lsr	r1, #3
	ldr 	r3, =tiles
	ldr 	r0, [r3, r1, lsl #2]

	//move x and y to argument positions
	mov	r1, x
	mov	r2, y
	bl	DrawPreciseImage

	.unreq	x
	.unreq	y
	pop	{r4-r5, pc}

/*
* RenderVehicleTile(x,y,TileByte)
* Sets up arguments for precise around vehicle draw.
*/
RenderVehicleTile:
	push	{r4-r7, lr}
	x	.req	r5
	y	.req	r6
	mov	x, r0
	mov	y, r1
	mov	r1, r2

	//Calculate offset and load image address
	lsr	r1, #3
	ldr 	r3, =tiles
	ldr 	r7, [r3, r1, lsl #2]
	
	//Find the vehicle that we need to draw around. Pass in x and y
	mov 	r0, x
	sub 	r1, y, #1
	bl	GetTileVehicle
	// DrawPreciseAroundVehicle. Call this to only update pixels around vehicle
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
/*
* GetTileVehicle(x,y)
* Call this if a grid element contains a car. This will find the car, and return required
* information. 
* Returns following information: Address in array in r0, tile offset in r1
* Tile offset = are we on the front, middle, or end of vehicle. Used for drawing.
*/
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
	
	//Compare to player car
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

	//If we arent a player car, then find the ai car
	aiCar:

	mov 	r0, x
	mov 	r1, y
	bl 	GetCarCell
	cmp 	r0, #0
	bne 	interpretByte
	subeq 	y, #1
	beq 	aiCar 	

	//Extract needed information from car and setup return
	interpretByte:

	lsr 	r0, #4
	ldr 	r2, =cars
	add 	r2, r0, lsl #2
	ldr 	r0, [r2]
	add 	r0, #8
	sub 	r1, originalY, y	//This is the tile offset. (Where we are in the car)

	.unreq 	x
	.unreq 	y
	.unreq 	originalY
	
	pop 	{r4-r10, pc}

/* 
* DrawPreciseImage(imgAddress1, startTX, startTY)
* Modified draw precise image so that it only needs the new tile, 
* and reads the framebuffer for comparison
* does not call draw pixel, contains that functionality
*/
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

	//load pixels for comparison
	ldrh 	r2, [imgAddrs1], #2
	lsl	r3, x, #1
	ldrh 	r1, [frameBuffer, r3]
	
	//Compare pixels
	cmp 	r1, r2
	beq 	equalColour

	//If not equal, overwrite buffer
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

/*
* DrawPreciseAroundVehicle(tileAddrs, vehicleAddrs, startTX, startTY, vehicleTileOffset, vehiclePixelEnd)
* This method can be called to draw a tile under a car! (So as not to make the car flicker!!!)
* vehicleTileOffset is the offset of the tile from the top of the vehicle
* vehiclePixelEnd is the height of the vehicle. I.E. player car is 57
* Essentially if we are outside the car, draw the pixels, but as soon as we are inside the car,
* do not update the pixels.
*/
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

	//Are we under the car
	cmp 	vehicleRows, #0
	beq 	noVehicle

	//Load pixel from vehicle and compare to 0. 0 denotes no car. (Yes this is also black)
	ldrh 	r0, [vehImgAddrs]
	cmp 	r0, #0
	bne 	yesVehicle 		

	//If not vehicle, draw the pixel from tile
	noVehicle:

	push 	{r3}
	add 	r0, x, xOffset
	add 	r1, y, yOffset	
	ldrh 	r2, [tileImgAddrs]
	bl 	DrawPixel
	pop 	{r3}

	//If a vehicle, do nothing, increment addresses
	//This also runs if there is no vehicle.
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
// DrawTileImage(imgAddrs, startTX, startTY, dimX, dimY)\
// Same as DrawImage but takes Starting position in tile coordinates
DrawTileImage:
	pop	{r0, r1, r2, r3, r4}
	push	{lr}
	mov	r1, r1, lsl #5
	mov	r2, r2, lsl #5
	push	{r0, r1, r2, r3, r4}
	bl	DrawImage
	pop	{pc}

.global	DrawHeaderImage
// DrawHeaderImage(imgAddrs, startX, dimX, dimY)
// Used to draw into the top row of the screen. The regular draw function
// prevents all draws to the top of the screen.
// Prevents all drawing below the top row of the screen
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

	//If we are at 32, return, do not draw
	1:
	cmp	y, #32
	beq	1f
	mov	x, startX

	//otherwise draw pixel and loop again
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
// Draws an image of arbitrary size to the screen. Does not draw into the top row
// All arguments are in pixel coordinates
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
	//Ensure we draw in bounds
	cmp	y, #32
	addlt	imgAddrs, #64
	blt	ignoreRow
	cmp	y, #768
	beq	drawImageEnd
	mov	x, startX

	xLoop:
	//Load address and draw pixel
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

// RenderCar(car, startTileX, startTileY)
.global RenderCar
RenderCar:
	push	{r4-r7, lr}
	x	.req	r5
	y	.req	r6
	struct	.req	r7
	mov	x, r1
	mov	y, r2

	lsr	r0, #4
	ldr	struct, =cars
	ldr	struct, [struct, r0, lsl #2]

	add	r0, struct, #8
	mov	r1, x
	mov 	r2, y
	mov	r3, #32
	ldr	r4, [struct, #4]
	push	{r0, r1, r2, r3, r4}
	bl	DrawTileImage

	.unreq	x
	.unreq	y
	.unreq	struct
	pop	{r4-r7, pc}

