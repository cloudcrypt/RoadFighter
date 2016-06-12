.global ClearScreen
.global ClearArea
.section .text
.align 4
ClearScreen:
	push 	{lr}

	mov 	r0, #0
	mov 	r1, #0
	mov 	r2, #1024
	mov 	r3, #768
	bl 	ClearArea

	pop 	{pc}

// r0 - pos x
// r1 - pos y
// r2 - width
// r3 - height
ClearArea:
	push	{r4-r9, lr}

	x		.req	r4
	y		.req	r5
	endX 		.req 	r6
	endY 		.req 	r7
	startX 		.req 	r8
	startY 		.req 	r9
	
	mov 	startX, r0
	mov 	startY, r1
	add 	endX, r0, r2
	add 	endY, r1, r3

	mov	y, startY

	yLoop3:
	mov	x, startX

	xLoop3:

	mov	r0, x
	mov	r1, y
	mov	r2, #0
	bl	DrawPixel

	add	x, #1
	cmp	x, endX
	blt	xLoop3

	add	y, #1
	cmp	y, endY
	blt	yLoop3

	.unreq	x
	.unreq	y
	.unreq	endX
	.unreq 	endY
	.unreq 	startX
	.unreq 	startY
	pop	{r4-r9, pc}
