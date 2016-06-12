.section .text
.global InitializeMap
InitializeMap:
	push	{r4-r10, lr}
	x		.req	r4
	y		.req	r5
	addrs		.req	r6
	leftEdge 	.req	r7
	rightEdge 	.req	r8
	dashType	.req	r9
	tileType	.req	r10
	ldr	addrs, =grid
	ldr	r0, =leftEdgeSize
	ldr	leftEdge, [r0]
	ldr	r0, =rightEdgeSize
	ldr	rightEdge, [r0]
	rsb	rightEdge, #32
	mov	dashType, #0
	mov	y, #0

	yLoop:

	mov	x, #0

	xLoop:
	mov	tileType, #0

	cmp	x, rightEdge
	movlt	tileType, #1

	cmp	x, leftEdge
	movlt	tileType, #0
	moveq	tileType, #6

	cmp	tileType, #0
	bne	notGrass
	mov	r0, #1
	bl	GetRandomBush
	mov	tileType, r0

	notGrass:
	cmp	x, #15
	moveq	tileType, #2

	cmp	x, #16
	moveq	tileType, #3

	sub 	r2, rightEdge, #1
	cmp 	x, r2
	moveq	tileType, #7

	cmp	x, #9
	cmpne	x, #21
	bne	prepareTile

	cmp	dashType, #0
	beq	evenRow

	cmp	x, #9
	moveq	tileType, #4
	cmp	x, #21
	moveq	tileType, #5
	b	prepareTile

	evenRow:
	cmp	x, #9
	moveq	tileType, #5
	cmp	x, #21
	moveq	tileType, #4

	prepareTile:
	mov	r0, tileType
	lsl	tileType, #3
	cmp	r0, #0
	orreq	tileType, #0b100
	//If bush set to collide
	cmp	r0, #8
	blt 	noBush
	cmp 	r0, #15
	bgt 	noBush

	orr	tileType, #0b100

	noBush:

	strb	tileType, [addrs], #1

	mov	r0, x
	mov	r1, y
	bl	SetChanged

	add	x, #1
	cmp	x, #32
	bne	xLoop

	// alternate dashType between 0 and 1
	cmp	dashType, #0
	moveq	dashType, #1
	movne	dashType, #0

	add	y, #1
	cmp	y, #23
	bne	yLoop

	.unreq	x
	.unreq	y
	.unreq	addrs
	.unreq	leftEdge
	.unreq	rightEdge
	.unreq	dashType
	.unreq	tileType
	pop	{r4-r10, pc}

.global	GenerateFinishLine
GenerateFinishLine:
	push	{r4-r9, lr}
	x		.req	r4
	y		.req	r5
	addrs		.req	r6
	leftEdge 	.req	r7
	rightEdge 	.req	r8
	tileType	.req	r9
	ldr	addrs, =nextRow
	ldr	r0, =leftEdgeSize
	ldr	leftEdge, [r0]
	ldr	r0, =rightEdgeSize
	ldr	rightEdge, [r0]
	rsb	rightEdge, #32
	mov	x, #0

	finishLineRowLoop2:
	mov	tileType, #16

	cmp	x, rightEdge
	movlt	tileType, #16

	cmp	x, leftEdge
	movlt	tileType, #16
	moveq	tileType, #16

	cmp	tileType, #0
	bne	finishLineNotGrass2
	mov	r0, #1
	bl	GetRandomBush
	mov	tileType, r0

	finishLineNotGrass2:
	cmp	x, #15
	moveq	tileType, #16

	cmp	x, #16
	moveq	tileType, #16

	sub 	r2, rightEdge, #1
	cmp 	x, r2
	moveq	tileType, #16

	cmp	x, #9
	cmpne	x, #21
	bne	finishLinePrepareTile2	

	ldrb	r2, [addrs]
	lsr	r2, #3
	cmp 	r2, #0
	bne	finishLineNotFirstGeneration

	cmp 	x, #9
	moveq	tileType, #16
	cmp 	x, #21
	moveq 	tileType, #16
	b 	finishLinePrepareTile2

	finishLineNotFirstGeneration:
	cmp	r2, #5
	moveq	tileType, #16
	movne	tileType, #16	

	finishLinePrepareTile2:
	lsl	tileType, #3

	strb	tileType, [addrs], #1

	add	x, #1
	cmp	x, #32
	bne	finishLineRowLoop2

	.unreq	x
	.unreq	y
	.unreq	addrs
	.unreq	leftEdge
	.unreq	rightEdge
	.unreq	tileType
	pop	{r4-r9, pc}

.global	GenerateNextRow
GenerateNextRow:
	push	{r4-r9, lr}
	x		.req	r4
	y		.req	r5
	addrs		.req	r6
	leftEdge 	.req	r7
	rightEdge 	.req	r8
	tileType	.req	r9
	ldr	addrs, =nextRow
	ldr	r0, =leftEdgeSize
	ldr	leftEdge, [r0]
	ldr	r0, =rightEdgeSize
	ldr	rightEdge, [r0]
	rsb	rightEdge, #32
	mov	x, #0

	rowLoop2:
	mov	tileType, #0

	cmp	x, rightEdge
	movlt	tileType, #1

	bge 	skipFuel
	//////////////////// FUEL RANDOM /////////////////////////////
	// add random  fuel
	bl 	RandomNumber
	cmp 	r0, #1
	movlt 	tileType, #17

////////////////// end of fuel random //////////////////////
	skipFuel:
	cmp	x, leftEdge
	movlt	tileType, #0
	moveq	tileType, #6

	cmp	tileType, #0
	bne	notGrass2
	mov	r0, #1
	bl	GetRandomBush
	mov	tileType, r0

	notGrass2:
	cmp	x, #15
	moveq	tileType, #2

	cmp	x, #16
	moveq	tileType, #3

	sub 	r2, rightEdge, #1
	cmp 	x, r2
	moveq	tileType, #7

	cmp	x, #9
	cmpne	x, #21
	bne	prepareTile2	

	ldrb	r2, [addrs]
	lsr	r2, #3
	cmp 	r2, #0
	bne	notFirstGeneration

	cmp 	x, #9
	moveq	tileType, #4
	cmp 	x, #21
	moveq 	tileType, #5
	b 	prepareTile2

	notFirstGeneration:
	cmp	r2, #5
	moveq	tileType, #4
	movne	tileType, #5	

	prepareTile2:
	lsl	tileType, #3

	strb	tileType, [addrs], #1

	add	x, #1
	cmp	x, #32
	bne	rowLoop2

	.unreq	x
	.unreq	y
	.unreq	addrs
	.unreq	leftEdge
	.unreq	rightEdge
	.unreq	tileType
	pop	{r4-r9, pc}

.global	ShiftMap
ShiftMap:
	push	{r4-r10, lr}
	addrs	.req	r4
	row	.req	r5
	col	.req	r6
	wordCtr	.req	r7
	byteCtr	.req	r8
	currentRow	.req	r9
	higherRow	.req	r10
	ldr	addrs, =grid
	mov	row, #22

	rowLoop:
	mov	wordCtr, #7
	wordLoop:
	lsl	r0, row, #5
	lsl	r1, wordCtr, #2
	add	r0, r1
	ldr	currentRow, [addrs, r0]
	cmp	row, #0
	subne	r0, row, #1
	addne	r0, r1, r0, lsl #5
	ldrne	higherRow, [addrs, r0]
	ldreq	r0, =nextRow
	ldreq	higherRow, [r0, r1]

	mov	byteCtr, #0
	byteLoop:
	lsl	r1, byteCtr, #3
	mov	r0, #0xF8
	lsl	r0, r1
	and	r2, currentRow, r0
	and	r3, higherRow, r0	

	cmp	r2, r3
	beq	noChange
	mov	r0, #0b10
	lsl	r1, byteCtr, #3
	lsl	r0, r1
	orr	higherRow, r0

	noChange:
	add	byteCtr, #1
	cmp	byteCtr, #4
	bne	byteLoop

	lsl	r0, row, #5
	lsl	r1, wordCtr, #2
	add	r0, r1
	str	higherRow, [addrs, r0]

	sub	wordCtr, #1
	cmp	wordCtr, #-1
	bne	wordLoop

	sub	row, #1
	cmp	row, #-1
	bne	rowLoop

	.unreq	addrs
	.unreq	row
	.unreq	col
	.unreq	wordCtr
	.unreq	byteCtr
	.unreq	currentRow
	.unreq	higherRow
	pop	{r4-r10, pc}

// .global	RandomizeTile
// // RandomizeTile(value, chance)
// // RandomizeTile(r0, r1)
// // return(r0)
// RandomizeTileType:
// 	push	{r4-r5, lr}
// 	mov	r4, r0
// 	mov	r5, r1

// 	bl	RandomNumber

// 	cmp	r0, r5
// 	movge	r0, #0
// 	movlt	r0, r4	

// 	pop	{r4-r5, pc}


// input: r0 - chance
// return: r0 - tile offset or 0 if no bush
.global GetRandomBush
GetRandomBush:
	chance 	.req 	r4

	push 	{r4, lr}
	mov 	chance, r0

	bl 	RandomNumber
	cmp 	r0, chance
	movge 	r0, #0
	bge 	EndGetRandomBush

	bl  	RandomNumber
	
	BushSelect:
	cmp 	r0, #8
	blt 	ReturnBush
	sub 	r0, #8
	b 	BushSelect
	
	ReturnBush:
	add 	r0, #8

	EndGetRandomBush:

	.unreq 	chance

	pop	{r4, pc}


.global SetChanged
// setChanged(gridX, gridY)
SetChanged:
	push	{r4, r5, lr}
	cmp	r1, #0
	blt	setChangedInNextRow
	cmp 	r1, #23
	bgt 	setChangedEnd
	// offset = (y * 32) + x
	add	r4, r0, r1, lsl #5

	ldr	r5, =grid
	ldrb	r0, [r5, r4]

	mov	r1, #0b10
	orr	r0, r1

	strb	r0, [r5, r4]
	b	setChangedEnd

	setChangedInNextRow:
	mov	r4, r0
	ldr	r5, =nextRow
	ldrb	r0, [r5, r4]

	orr	r0, #0b10
	strb	r0, [r5, r4]

	setChangedEnd:
	pop	{r4, r5, pc}

.global ClearChanged
// clearChanged(gridX, gridY)
ClearChanged:
	push	{r4, r5, lr}
	cmp	r1, #0
	blt	clearChangedEnd
	cmp 	r1, #23
	bgt 	clearChangedEnd
	// offset = (y * 32) + x
	add	r4, r0, r1, lsl #5

	ldr	r5, =grid
	ldrb	r0, [r5, r4]

	mov	r1, #0b10
	bic	r0, r1

	strb	r0, [r5, r4]

	clearChangedEnd:
	pop	{r4, r5, pc}

.global SetCar
//takes x and y tile values
SetCar:	
	push	{r4, r5, lr}
	cmp	r1, #0
	blt	setCarEnd
	cmp 	r1, #23
	bgt 	setCarEnd
	// offset = (y * 32) + x
	add	r4, r0, r1, lsl #5

	ldr	r5, =grid
	ldrb	r0, [r5, r4]

	mov	r1, #0b1
	orr	r0, r1

	strb	r0, [r5, r4]

	setCarEnd:
	pop	{r4, r5, pc}


.global ClearCar
//takes x and y tiles values
ClearCar:
	push	{r4, r5, lr}
	cmp	r1, #0
	blt	clearCarEnd
	cmp 	r1, #23
	bgt 	clearCarEnd
	// offset = (y * 32) + x
	add	r4, r0, r1, lsl #5

	ldr	r5, =grid
	ldrb	r0, [r5, r4]

	mov	r1, #0b1
	bic	r0, r1

	strb	r0, [r5, r4]

	clearCarEnd:
	pop	{r4, r5, pc}

// SetCollideable(gridX, gridY)
.global	SetCollideable
SetCollideable:

	push	{r4, r5, lr}
	cmp	r1, #0
	blt	setCollideableEnd
	cmp 	r1, #23
	bgt 	setCollideableEnd

	// offset = (y * 32) + x
	add	r4, r0, r1, lsl #5

	ldr	r5, =grid
	ldrb	r0, [r5, r4]

	mov	r1, #0b100
	orr	r0, r1

	strb	r0, [r5, r4]

	setCollideableEnd:
	pop	{r4, r5, pc}

// ClearCollideable(gridX, gridY)
.global	ClearCollideable
ClearCollideable:

	push	{r4, r5, lr}
	cmp	r1, #0
	blt	clearCollideableEnd
	cmp 	r1, #23
	bgt 	clearCollideableEnd

	// offset = (y * 32) + x
	add	r4, r0, r1, lsl #5

	ldr	r5, =grid
	ldrb	r0, [r5, r4]

	mov	r1, #0b100
	bic	r0, r1

	strb	r0, [r5, r4]

	clearCollideableEnd:
	pop	{r4, r5, pc}


.section .data
.global fuel
fuel:	.int	100
.global	lives
lives:	.int	3
.global	leftEdgeSize
leftEdgeSize:
	.int	5
.global	rightEdgeSize
rightEdgeSize:
	.int	5

.global	grid
grid:	.rept	736
	.byte	0
	.endr
	.align
bsbuf1:	.rept	128
	.byte	0
	.endr
	.align
.global	nextRow
nextRow:
	.rept	32
	.byte	0
	.endr
	.align