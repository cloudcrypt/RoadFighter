.section .text
.global UpdatePlayerCar
UpdatePlayerCar:

	push 	{r4-r6, lr}
break2:
	ldr 	r2, =playerPosX
	ldr 	r3, =playerPosY
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	mov 	r5, r0
	mov 	r6, r1
	add 	r1, #1
	bl 	ClearCar
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	add 	r1, #2
	bl 	ClearCar
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	bl 	SetChanged
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	add 	r1, #1
	bl 	SetChanged


	bl 	UpdateSNESInput
	bl 	InterpretInput

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
break:
	ldr 	r2, =playerPosX
	ldr 	r3, =playerPosY
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	bl 	SetCar
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	add 	r1, #1
	bl 	SetCar
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	bl 	SetChanged
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	add 	r1, #1
	bl 	SetChanged

	mov 	r0, r5
	mov 	r1, r6
	add 	r1, #1
	bl 	RenderMapTile

	mov 	r0, r5
	mov 	r1, r6
	add 	r1, #2
	bl 	RenderMapTile

	ldr 	r2, =playerPosX
	ldr 	r3, =playerPosY
	ldr 	r5, [r2]
	ldr 	r6, [r3]


	mov 	r0, r5
	mov 	r1, r6
	bl 	RenderMapTile

	mov 	r0, r5
	mov 	r1, r6
	add 	r1, #1
	bl 	RenderMapTile


	pop	{r4-r6, pc}
//r0 is the snes input passed as an argument
InterpretInput:

	push 	{lr}

	ldr	r1, =0xFFFF
	cmp	r0, r1
	beq	noChange

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

	noChange:

	pop 	{pc}

.global CheckForCollision
CheckForCollision:

	push 	{lr}

	ldr	r0, =playerPosX
	ldr 	r1, =playerPosY
	ldr	r0, [r0]
	ldr 	r1, [r1]

	// offset = (y * 32) + x
	add	r2, r0, r1, lsl #5
	add 	r1, #1
	add 	r3, r0, r1, lsl #5

	ldr	r1, =grid
	ldrb	r0, [r1, r2]
	ldrb 	r1, [r1, r3] 

	mov 	r2, #0b100
	tst	r2, r0
	movne	r0, #0
	bne 	HandlePlayerCollision

	tst	r2, r1
	movne	r0, #1
	bne 	HandlePlayerCollision

	pop 	{pc}

// HandlePlayerCollision(victimDir)
// HandlePlayerCollision(r0)
HandlePlayerCollision:
	push	{r4-r11, lr}
	defaultX	.req	r5
	defaultY	.req	r6
	flashCtr	.req	r7
	playerX		.req	r8
	playerY		.req	r9
	len		.req	r10
	ctr		.req	r11
	//mov	victimDir, r0
	ldr	r1, =playerDefaultX
	ldr	defaultX, [r1]
	ldr	r1, =playerDefaultY
	ldr	defaultY, [r1]

	ldr	r0, =playerPosX
	ldr	playerX, [r0]
	str	defaultX, [r0]
	ldr	r0, =playerPosY
	ldr	playerY, [r0]
	str	defaultY, [r0]

	ldr	r0, =1000000
	bl	Wait

	//cmp	victimDir, #0
	//bne	searchDown

	mov	ctr, #-1
	searchLoop:

	sub	r0, playerX, #5
	add	r1, playerY, #4		// add 4 and add 1 (to compensate for top row)
	sub	r1, ctr
	bl	GetCarCell
	cmp	r0, #0
	bne	carFound

	add	ctr, #1
	cmp	ctr, #4
	bne	searchLoop
	searchDown:
	carFound:
	// save victimCar Y coord into r3 (in grid coords):
	sub	r3, playerY, ctr
	// get car length:
	lsr	r0, #4
	ldr	r1, =cars
	ldr	r0, [r1, r0, lsl #2]
lenb:
	ldr	len, [r0]

	// clear victim car and player car:
	mov	r0, #0
	sub	r1, playerX, #5
	add	r2, r3, #4
	add	r3, len, #1
	bl	SetCarCell

	mov	r0, playerX
	mov	r1, playerY
	bl	SetChanged
	mov	r0, playerX
	mov	r1, playerY
	bl	ClearCar

	// execute changes:
	bl	RenderMap

	mov	flashCtr, #0
	flashCar:
	mov	r0, defaultX
	mov	r1, defaultY
	bl	SetChanged
	mov	r0, defaultX
	add	r1, defaultY, #1
	bl	SetChanged
	mov	r0, defaultX
	add	r1, defaultY, #2
	bl	SetChanged

	mov	r0, defaultX
	add	r1, defaultY, #1
	bl	RenderMapTile
	mov	r0, defaultX
	add	r1, defaultY, #2
	bl	RenderMapTile

	ldr	r0, =250000
	bl	Wait

	ldr	r0, =car
	mov	r1, defaultX
	add 	r2, defaultY, #1
	mov	r3, #32
	mov	r4, #57
	push	{r0, r1, r2, r3, r4}
	bl	DrawTileImage

	ldr	r0, =250000
	bl	Wait

	add	flashCtr, #1
	cmp	flashCtr, #5
	bne	flashCar

	b	inputLoop

	b	haltLoop$
	.unreq	defaultX
	.unreq	defaultY
	.unreq	flashCtr
	.unreq	playerX
	.unreq	playerY
	.unreq	len
	.unreq	ctr
	pop	{r4-r11, pc}
