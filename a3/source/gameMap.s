.section .text
.global InitializeMap
InitializeMap:
	push	{r4-r11, lr}
	x		.req	r4
	y		.req	r5
	addrs		.req	r6
	leftEdge 	.req	r7
	rightEdge 	.req	r8
	dashType	.req	r9
	baseType	.req	r10
	tileType	.req	r11
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
	mov	baseType, #0
	mov	tileType, #0

	cmp	x, rightEdge
	movlt	baseType, #1

	cmp	x, leftEdge
	movlt	baseType, #0
	moveq	tileType, #5

	cmp	baseType, #0
	bne	notGrass
	mov	r0, #7
	mov	r1, #0
	bl	RandomizeTileType
	mov	tileType, r0

	notGrass:
	cmp	x, #15
	moveq	tileType, #1

	cmp	x, #16
	moveq	tileType, #2

	sub 	r2, rightEdge, #1
	cmp 	x, r2
	moveq	tileType, #6

	cmp	x, #10
	cmpne	x, #21
	bne	prepareTileType

	cmp	dashType, #0
	beq	evenRow

	cmp	x, #10
	moveq	tileType, #3
	cmp	x, #21
	moveq	tileType, #4
	b	prepareTileType

	evenRow:
	cmp	x, #10
	moveq	tileType, #4
	cmp	x, #21
	moveq	tileType, #3

	prepareTileType:
	lsl	tileType, #3
	orr	baseType, tileType

	strb	baseType, [addrs], #1

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
	cmp	y, #24
	bne	yLoop

	.unreq	x
	.unreq	y
	.unreq	addrs
	.unreq	leftEdge
	.unreq	rightEdge
	.unreq	dashType
	.unreq	baseType
	.unreq	tileType
	pop	{r4-r11, pc}

.global	GenerateNextRow
GenerateNextRow:
	push	{r4-r8, lr}
	x		.req	r4
	y		.req	r5
	addrs		.req	r6
	leftEdge 	.req	r7
	rightEdge 	.req	r8
	baseType	.req	r9
	tileType	.req	r10
	ldr	addrs, =nextRow
	ldr	r0, =leftEdgeSize
	ldr	leftEdge, [r0]
	ldr	r0, =rightEdgeSize
	ldr	rightEdge, [r0]
	rsb	rightEdge, #32
	mov	x, #0

	rowLoop2:
	mov	baseType, #0
	mov	tileType, #0

	cmp	x, rightEdge
	movlt	baseType, #1

	cmp	x, leftEdge
	movlt	baseType, #0
	moveq	tileType, #5

	cmp	baseType, #0
	bne	notGrass2
	mov	r0, #7
	mov	r1, #1
	bl	RandomizeTileType
	mov	tileType, r0

	notGrass2:
	cmp	x, #15
	moveq	tileType, #1

	cmp	x, #16
	moveq	tileType, #2

	sub 	r2, rightEdge, #1
	cmp 	x, r2
	moveq	tileType, #6

	cmp	x, #10
	cmpne	x, #21
	bne	prepareTileType2	

	ldrb	r2, [addrs]
	lsr	r2, #3
	cmp 	r2, #0
	bne	notFirstGeneration

	cmp 	x, #10
	moveq	tileType, #3
	cmp 	x, #21
	moveq 	tileType, #4
	b 	prepareTileType2

	notFirstGeneration:
	cmp	r2, #4
	moveq	tileType, #3
	movne	tileType, #4	

	prepareTileType2:
	lsl	tileType, #3
	orr	baseType, tileType

	strb	baseType, [addrs], #1

	add	x, #1
	cmp	x, #32
	bne	rowLoop2

	.unreq	x
	.unreq	y
	.unreq	addrs
	.unreq	leftEdge
	.unreq	rightEdge
	.unreq	baseType
	.unreq	tileType
	pop	{r4-r8, pc}

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
	mov	row, #23

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
	mov	r0, #0xFF
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

.global	RandomizeTile
// RandomizeTile(value, chance)
// RandomizeTile(r0, r1)
// return(r0)
RandomizeTileType:
	push	{r4-r5, lr}
	mov	r4, r0
	mov	r5, r1

	bl	RandomNumber

	cmp	r0, r5
	movge	r0, #0
	movlt	r0, r4	

	pop	{r4-r5, pc}

.global SetChanged
// setChanged(gridX, gridY)
SetChanged:
	push	{r4, r5, lr}
	// offset = (y * 32) + x
	add	r4, r0, r1, lsl #5

	ldr	r5, =grid
	ldrb	r0, [r5, r4]

	mov	r1, #0b10
	orr	r0, r1

	strb	r0, [r5, r4]

	pop	{r4, r5, pc}

.global ClearChanged
// clearChanged(gridX, gridY)
ClearChanged:
	push	{r4, r5, lr}
	// offset = (y * 32) + x
	add	r4, r0, r1, lsl #5

	ldr	r5, =grid
	ldrb	r0, [r5, r4]

	mov	r1, #0b10
	bic	r0, r1

	strb	r0, [r5, r4]

	pop	{r4, r5, pc}

		
// setValue(register, type)
setType:

	


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
grid:	.rept	768
	.byte	0
	.endr
	.align
.global	nextRow
nextRow:
	.rept	32
	.byte	0
	.endr
	.align