.section .text
.global initializeGameMap
initializeGameMap:
	push	{r4-r8}
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
	movlt	r0, #1

	cmp	x, leftEdge
	movlt	r0, #0

	strb	r0, [addrs], #1

	add	x, #1
	cmp	x, #32
	bne	xLoop

	add	y, #1
	cmp	y, #24
	bne	yLoop

	pop	{r4-r8}
	.unreq	x
	.unreq	y
	.unreq	addrs
	.unreq	leftEdge
	.unreq	rightEdge
	bx	lr

.section .data
.global fuel
fuel:	.int	100
.global	lives
lives:	.int	3
.global	leftEdgeSize
leftEdgeSize:
	.int	11
.global	rightEdgeSize
rightEdgeSize:
	.int	11
.global	grid
grid:	.rept	768
	.byte	0
	.endr
	.align