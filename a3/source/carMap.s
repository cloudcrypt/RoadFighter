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
	cmp	r0, #5
	bge	ignoreLane

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
	orr	car, #0b1	


	placeCar:
	lsr	r0, car, #4
	ldr	r1, =cars
	ldr	r0, [r1, r0, lsl #2]
	ldr	r0, [r0]

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

	// check vel for this shift cycle
	cmp	vel, #0
	beq	ignoreLane2

	// clear car from grid
	mov	r0, #0
	mov	r1, lane
	mov	r2, row
	bl	SetCarCell
	
	// check if car is leaving rendered area of grid
	add	r0, row, vel
	cmp	r0, #26
	bgt	ignoreLane2

	// get car len
	lsr	r0, car, #4
	ldr	r1, =cars
	ldr	r0, [r1, r0, lsl #2]
	ldr	len, [r0]

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
	bl	SetCarCell
	b	ignoreLane2

	accidentHandler:
	// victimCar in r0, victimCar row in r1
	mov	r2, r1
	// set victimCar velocity to 0101 (1/1)
	bic	r0, #0b1111
	orr	r0, #0b0101
	mov	r1, lane
	push	{r2}		// save victimCar row
	bl	SetCarCell
	pop	{r2}

	// get row above victimCar and shift car to row - car len
	sub	r2, len
	mov	r0, car
	mov	r1, lane
	bl	SetCarCell

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



.global	SetCollisions
UpdateCollisions:

// GetCarCell(gridX, gridY) = r0
.global	GetCarCell
GetCarCell:
	add	r0, r1, lsl #4
	add	r0, r1, lsl #2
	add	r0, r1, lsl #1
	ldr	r1, =carGrid
	ldrb	r0, [r1, r0]
	bx	lr

// SetCarCell(car, gridX, gridY)
.global	SetCarCell
SetCarCell:
	add	r1, r2, lsl #4
	add	r1, r2, lsl #2
	add	r1, r2, lsl #1
	ldr	r2, =carGrid
	strb	r0, [r2, r1]
	bx	lr

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