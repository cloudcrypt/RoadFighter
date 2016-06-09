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

/*	ldr 	r0, =grass
	ldr 	r1, =car1
	add 	r1, #4	
	mov 	r2, #16
	mov 	r3, #11
	mov 	r4, #0
	mov 	r5, #57
	push 	{r0-r5}
	bl 	DrawPreciseAroundVehicle

	ldr 	r0, =grass
	ldr 	r1, =car1
	add 	r1, #4	
	mov 	r2, #16
	mov 	r3, #12
	mov 	r4, #1
	mov 	r5, #57
	push 	{r0-r5}
	bl 	DrawPreciseAroundVehicle

//Can use for testing
testLoop: 
	
	//
	b	testLoop*/

	ldr 	r2, =playerPosX
	ldr 	r3, =playerPosY
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	bl 	SetCar
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	add 	r1, #1
	bl 	SetCar

	//bl	InitialRenderMap
	bl 	RenderMap

	ldr	r0, =testString
	mov	r1, #0
	mov	r2, #0
	bl	DrawString

	bl	GenerateNextRow

	/*mov 	r0, #0b0100
	mov 	r1, #4
	mov 	r2, #2
	bl 	SetCarCell	*/
	//bl 	GenerateNewCars

	// mov 	r0, #0b0001
	// mov 	r1, #16
	// mov 	r2, #4
	// mov	r3, #2
	// bl 	SetCarCell

	// mov 	r0, #0b0001
	// mov 	r1, #16
	// mov 	r2, #2
	// mov	r3, #2
	// bl 	SetCarCell

	//ldr	r0, =1000000
	//bl	Wait

inputloop:
mainLoop:

	ldr 	r0, =100000
	bl 	Wait

	//bl	GenerateNextRow

	// ldr 	r2, =playerPosX
	// ldr 	r3, =playerPosY
	// ldr 	r0, [r2]
	// add	r0, #1
	// ldr 	r1, [r3]
	// sub	r1, #1
	// bl	SetChanged

	ldr 	r2, =playerPosX
	ldr 	r3, =playerPosY
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	bl 	ClearCar
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	add 	r1, #1
	bl 	ClearCar

	bl	ShiftMap
	bl 	ShiftCarGrid

	ldr 	r2, =playerPosX
	ldr 	r3, =playerPosY
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	bl 	SetCar
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	add 	r1, #1
	bl 	SetCar

break2:
	bl	RenderMap

	//b	mainLoop

	bl 	UpdateSNESInput

	mov 	r4, r0


	bl	GenerateNextRow
	bl 	GenerateNewCars
	
	ldr	r1, =0xFFFF
	cmp	r0, r1
	beq	noChange
break:
	ldr 	r2, =playerPosX
	ldr 	r3, =playerPosY
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	//cmp	r1, #0
	//beq	setChangedInNextRow
	sub	r1, #1
	bl	SetChanged
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	bl	SetChanged
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	sub	r1, #1
	bl	ClearCar
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	bl	ClearCar


	// setChangedInNextRow:
	// ldr 	r1, [r3]
	// cmp	r1, #0
	// ldreq 	r1, [r2]
	// ldreq	r5, =nextRow
	// ldreqb	r0, [r5, r1]

	// //mov	r2, #0b10
	// orreq	r0, #0b10
	// streqb	r0, [r5, r1]

	// ldr 	r0, [r2]
	// ldr 	r1, [r3]
	// add	r1, #1
	// bl	SetChanged
	noChange:
	mov	r0, r4

	tst	r0, #1
	ldreq 	r1, =playerPosY
	ldreq 	r2, [r1]
	addeq 	r2, #1
	streq 	r2, [r1]  

	ldr 	r1, =0x100
	tst	r0, r1
	ldreq 	r1, =playerPosY
	ldreq 	r2, [r1]
	subeq 	r2, #1
	streq 	r2, [r1] 

	ldr 	r1, =0x80
	tst	r0, r1
	ldreq 	r1, =playerPosX
	ldreq 	r2, [r1]
	addeq 	r2, #1
	streq 	r2, [r1] 

	ldr 	r1, =0x40
	tst	r0, r1
	ldreq 	r1, =playerPosX
	ldreq 	r2, [r1]
	subeq 	r2, #1
	streq 	r2, [r1] 

	ldr	r0, =car
	ldr	r1, =playerPosX
	ldr 	r2, =playerPosY
	ldr	r1, [r1]
	ldr 	r2, [r2]
	add 	r2, #1
	mov	r3, #32
	mov	r4, #57
	push	{r0, r1, r2, r3, r4}
	bl	DrawTileImage

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
	//mov	r3, #32
	//mov	r4, #32
	//push	{r0, r1, r2, r3, r4}
	bl	DrawPreciseImageMod

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
	
	push	{r4-r8, lr}
	x	.req	r5
	y	.req	r6
	addrs	.req	r7
	ldr	addrs, =grid
	mov	y, #1

	ldr 	r0, =100000 
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
	bl	DrawPreciseImageMod

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
	mov 	r0, r7
	mov 	r5, #57
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
	add 	r0, #4
	sub 	r1, originalY, y	//This is the tile offset

	.unreq 	x
	.unreq 	y
	.unreq 	originalY
	
	pop 	{r4-r10, pc}

//Modified draw precise image so that it only needs the new tile, 
//and reads the framebuffer for comparison
//does not call draw pixel, contains that functionality
//DrawPreciseImageMod(imgAddress1, startTX, startTY)
DrawPreciseImageMod:
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
	bl 	DrawPixel
	pop 	{r3}

	yesVehicle:

	add 	vehImgAddrs, #2
	add 	tileImgAddrs, #2

	add 	x, #1
	cmp 	x, #32
	bne 	xLoop4

	sub 	vehicleRows, #1
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
// DrawTileImage(imgAddrs, startTX, startTY, dimX, dimY)
.global DrawTileImage
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

