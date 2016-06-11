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
