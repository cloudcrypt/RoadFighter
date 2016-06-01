.section .text
.global initializeGameMap
initializeGameMap:
	push	{r4-r8, lr}
	x		.req	r4
	y		.req	r5
	addrs		.req	r6
	leftEdge 	.req	r7
	rightEdge 	.req	r8
	ldr	addrs, =grid
	ldr	r0, =leftEdgeSize
	ldr	leftEdge, [r0]
	ldr	r0, =rightEdgeSize
	ldr	rightEdge, [r0]
	rsb	rightEdge, #32
	mov	y, #0

	yLoop:

	mov	x, #0

	xLoop:

	mov	r0, #0

	cmp	x, rightEdge
	// init to grass tile:
	movlt	r0, #1

	cmp	x, leftEdge
	movlt	r0, #0

	strb	r0, [addrs], #1

	mov	r0, x
	mov	r1, y
	bl	setChanged

	add	x, #1
	cmp	x, #32
	bne	xLoop

	add	y, #1
	cmp	y, #24
	bne	yLoop

	.unreq	x
	.unreq	y
	.unreq	addrs
	.unreq	leftEdge
	.unreq	rightEdge
	pop	{r4-r8, pc}

.global setChanged
// setChanged(gridX, gridY)
setChanged:
	push	{r4, r5, lr}
	// offset = (y * 32) + x
	add	r4, r0, r1, lsl #5

	ldr	r5, =grid
	ldrb	r0, [r5, r4]

	mov	r1, #0b10
	orr	r0, r1

	strb	r0, [r5, r4]

	pop	{r4, r5, pc}

.global clearChanged
// clearChanged(gridX, gridY)
clearChanged:
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