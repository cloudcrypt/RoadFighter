.section .text
.global initializeGameMap
initializeGameMap:
	push	{r4-r6}
	x	.req	r4
	y	.req	r5
	addrs	.req	r6
	ldr	addrs, =grid
	mov	y, #0

	yLoop:

	mov	x, #0

	xLoop:

	mov	r0, #0

	cmp	x, #27
	movlt	r0, #1

	cmp	x, #5
	movlt	r0, #0

	strb	r0, [addrs], #1

	add	x, #1
	cmp	x, #32
	bne	xLoop

	add	y, #1
	cmp	y, #24
	bne	yLoop

	pop	{r4-r6}
	.unreq	x
	.unreq	y
	.unreq	addrs
	bx	lr

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