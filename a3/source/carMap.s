.section .text
.global ClearCarGrid
ClearCarGrid:
	push	{lr}
	// clear the carGrid yo.
	pop		{pc}

.global	GenerateNewCars
GenerateNewCars:
	push	{r4-r10, lr}
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
	pop	{r4-r10, pc}

// start shifting from bottom up
.global	ShiftCarGrid
ShiftCarGrid:

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
.global	carGrid
carGrid:	
	.rept	594
	.byte	0
	.endr
	.align