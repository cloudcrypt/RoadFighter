.section .text
.global ClearCarGrid
ClearCarGrid:
	push	{lr}
	// clear the carGrid yo.
	pop		{pc}

.global	GenerateNewCars
GenerateNewCars:
	push	{r4-r5, lr}
	laneCtr	.req	r4
	car	.req	r5
	mov	laneCtr, #0

	laneLoop:

	mov	r0, laneCtr
	bl	CheckLane
	cmp	r0, #1
	beq	ignoreLane

	bl	RandomNumber
	cmp	r0, #2
	bge	ignoreLane
	/*bl	RandomNumber
	cmp	r0, #1
	bge	ignoreLane*/

	mov	car, #0
	cmp	laneCtr, #10
	bgt	rightSide

	// pick a car, any car!
	mov	r0, #0
	mov	car, r0, lsl #4
	// generate rand velocity
	orr	car, #0b1010

	b	placeCar

	rightSide:

	// pick a car
	mov	r0, #0
	mov	car, r0, lsl #4
	// generate rand velocity
	orr	car, #0b0100	


	placeCar:
	lsr	r0, car, #4
	ldr	r1, =cars
	ldr	r0, [r1, r0, lsl #2]
	ldr	r0, [r0]

	mov	r3, r0
	rsb	r2, r0, #4
	mov	r1, laneCtr
	mov	r0, car
	bl	SetCarCell

	ignoreLane:
	add	laneCtr, #1
	cmp	laneCtr, #22
	bne	laneLoop

	.unreq	laneCtr
	.unreq	car
	pop	{r4-r5, pc}

// start shifting from bottom up
.global	ShiftCarGrid
ShiftCarGrid:
	push	{r4-r10, lr}
	row	.req	r4
	lane 	.req	r5
	car	.req	r6
	vel	.req	r7
	velCtr	.req	r8
	len	.req	r9
	lenCtr	.req	r10
	redrwCtr	.req	r11
	mov 	row, #26

	rowLoop:
	mov 	lane, #0

	laneLoop2:
	mov	r0, lane
	mov	r1, row
	bl	GetCarCell
	mov	car, r0
	cmp	car, #0
	beq	ignoreLane2

	// vel
	and	vel, car, #0b11
	// velAlt
	and	r1, car, #0b1100
	lsr	r1, #2
	// swap vel and velAlt in car
	bic	car, #0b1111
	lsl	r0, vel, #2
	orr 	car, r0
	orr	car, r1

	//check vel for this shift cycle
	cmp	vel, #0
	bne 	hasVelocity

	//Reset car cell.
	lsr	r0, car, #4
	ldr	r1, =cars
	ldr	r0, [r1, r0, lsl #2]
	ldr	len, [r0]

	mov 	r0, car
	mov	r1, lane
	mov 	r2, row
	mov	r3, len
	bl 	SetCarCell

	add	r0, lane, #5
	sub	r1, row, #2
	bl 	ClearCar


	// mov 	r0, #0
	// mov	r1, lane
	// mov 	r2, row
	// add	r2, #1
	// mov	r3, len
	// bl 	SetCarCell

	b 	ignoreLane2
	hasVelocity:

	// get car len
	lsr	r0, car, #4
	ldr	r1, =cars
	ldr	r0, [r1, r0, lsl #2]
	ldr	len, [r0]

	// clear car from grid
	mov	r0, #0
	mov	r1, lane
	mov	r2, row
	mov	r3, len
	bl	SetCarCell

	mov	redrwCtr, #0
	redrawLoop:
	mov	r2, #3
	sub	r2, redrwCtr
	add	r0, lane, #5
	sub	r1, row, r2
	cmp	r1, #0
	blgt	RenderMapTile

	add	redrwCtr, #1
	cmp	redrwCtr, len
	blt	redrawLoop
	
	// check if car is leaving rendered area of grid
	add	r0, row, vel
	cmp	r0, #26
	bgt	ignoreLane2

	// validate car's entire shift path for entire length of car
	mov	velCtr, #1

	velLoop:
	mov	lenCtr, #0

	lenLoop:
	mov	r0, lane
	add	r1, velCtr, lenCtr
	add	r1, row
	push	{r1}		// save potential victimCar row
	bl	GetCarCell
	pop	{r1}
	cmp	r0, #0
	bne	accidentHandler

	add	lenCtr, #1
	cmp	lenCtr, len
	blt	lenLoop

	add	velCtr, #1
	cmp	velCtr, vel
	ble	velLoop

	// shift car by vel and set into grid
	mov	r0, car
	mov	r1, lane
	add	r2, row, vel
	mov	r3, len
	bl	SetCarCell

	push 	{r0-r4}
	ldr	r0, =car
	add	r1, lane, #5
	sub 	r2, row, #3
	add 	r2, vel
	mov	r3, #32
	mov	r4, #57
	push	{r0, r1, r2, r3, r4}
	bl	DrawTileImage
	pop 	{r0-r4}

	b	ignoreLane2

	accidentHandler:
	// victimCar in r0, victimCar row in r1
	mov	r2, r1
	// get victimCar velocity
	and	r0, #0b1111

	// set victimCar velocity to 0101 (1/1)
	//bic	r0, #0b1111
	//orr	r0, #0b0101
	//mov	r1, lane
	//push	{r2}		// save victimCar row
	//bl	SetCarCell
	//pop	{r2}

	// get row above victimCar and shift car to row - car len
	bic 	car, #0b1111
	orr 	car, r0
	sub	r2, len
	mov	r0, car
	mov	r1, lane
	mov	r3, len
	push	{r2}
	bl	SetCarCell
	pop	{r2}

	push 	{r0-r4}
	ldr	r0, =car
	add	r1, lane, #5
	sub 	r2, #3
	mov	r3, #32
	mov	r4, #57
	push	{r0, r1, r2, r3, r4}
	bl	DrawTileImage
	pop 	{r0-r4}

	ignoreLane2:
	add	lane, #1
	cmp	lane, #22
	bne	laneLoop2

	sub	row, #1
	cmp	row, #-1
	bne	rowLoop
	.unreq	row
	.unreq	lane
	.unreq	car
	.unreq	vel
	.unreq	velCtr
	.unreq	len
	.unreq	lenCtr
	pop	{r4-r10, pc}

//Takes a tile position and length, and removes the car values from the car grid
RemoveCarInGrid:
	
	push 	{lr}

	x	.req 	r0
	y 	.req 	r1
	len 	.req 	r2

	add 	x, #5
	sub 	y, #4

	updateLoop:

	//If we are outside the grid, do not modify the grid
	cmp 	y, #0 		
	blt 	checkLoop
	cmp 	y, #31
	popge 	{pc}

	push 	{r0-r3}
	bl 	ClearCar
	pop 	{r0-r3}
	push 	{r0-r3}
	bl 	SetChanged
	pop 	{r0-r3}

	checkLoop:
	add 	y, #1
	sub 	len, #1
	cmp 	len, #0
	bne 	updateLoop

	.unreq 	x
	.unreq 	y
	.unreq 	len

	pop 	{pc}

//Takes a tile position and length, and adds the car values to the tile grid
AddCarInGrid:

	push 	{lr}

	x	.req 	r0
	y 	.req 	r1
	len 	.req 	r2

	add 	x, #5
	sub 	y, #4

	updateLoop1:

	//If we are outside the grid, do not modify the grid
	cmp 	y, #0 		
	blt 	checkLoop1
	cmp 	y, #31
	popge 	{pc}

	push 	{r0-r3}
	bl 	SetCar
	pop 	{r0-r3}
	push 	{r0-r3}
	bl 	SetChanged
	pop 	{r0-r3}

	checkLoop1:
	add 	y, #1
	sub 	len, #1
	cmp 	len, #0
	bne 	updateLoop1

	.unreq 	x
	.unreq 	y
	.unreq 	len

	pop 	{pc}

.global	SetCollisions
UpdateCollisions:

// GetCarCell(gridX, gridY) = r0
.global	GetCarCell
GetCarCell:
	cmp 	r1, #26
	movgt 	r0, #0
	bgt 	getCarCellEnd
	add	r0, r1, lsl #4
	add	r0, r1, lsl #2
	add	r0, r1, lsl #1
	ldr	r1, =carGrid
	ldrb	r0, [r1, r0]
	getCarCellEnd:
	bx	lr

// SetCarCell(car, gridX, gridY, len)
.global	SetCarCell
SetCarCell:
	push	{r4, lr}
	len	.req	r4
	cmp	r2, #26
	bgt	setCarCellEnd
	mov	len, r3

	cmp	r0, #0
	push	{r0-r2}
	mov	r0, r1
	mov	r1, r2
	mov	r2, len
	bleq	RemoveCarInGrid
	blne	AddCarInGrid
	pop	{r0-r2}

	add	r1, r2, lsl #4
	add	r1, r2, lsl #2
	add	r1, r2, lsl #1
	ldr	r2, =carGrid
	strb	r0, [r2, r1]
	setCarCellEnd:
	.unreq	len
	pop	{r4, pc}

// CheckLane(gridX)
.global	CheckLane
CheckLane:
	push	{r4, lr}
	x	.req	r4
	mov	x, r0
	mov	r2, #0

	mov	r0, x
	mov	r1, #0
	bl	GetCarCell
	cmp	r0, #0
	movne	r2, #1
	bne	checkLaneEnd

	mov	r0, x
	mov	r1, #1
	bl	GetCarCell
	cmp	r0, #0
	movne	r2, #1
	bne	checkLaneEnd

	mov	r0, x
	mov	r1, #2
	bl	GetCarCell
	cmp	r0, #0
	movne	r2, #1
	bne	checkLaneEnd

	mov	r0, x
	mov	r1, #3
	bl	GetCarCell
	cmp	r0, #0
	movne	r2, #1
	bne	checkLaneEnd

	checkLaneEnd:
	mov	r0, r2
	.unreq	x
	pop	{r4, pc}


.section .data
// 22x27 Grid (topExt + cars)
.global	carGrid
carGrid:	
	.rept	594
	.byte	0
	.endr
	.align
// safetyBuffer:
// 	.rept	66
// 	.byte 	0
// 	.endr
// 	.align