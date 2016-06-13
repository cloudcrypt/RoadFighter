.section .text
.global UpdatePlayerCar
/*
* Updates the position of the player car based on current SNES input
*/
UpdatePlayerCar:

	push 	{r4-r6, lr}

	ldr 	r2, =playerPosX
	ldr 	r3, =playerPosY
	ldr 	r0, [r2]
	ldr 	r1, [r3]

	//Remove the car from the grid and order redraws
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

	//Get snes input and interpret it
	ldr	r0, =SNESInput
	ldr	r0, [r0]
	bl 	InterpretInput

	//Render the player car
	mov	r0, #0
	ldr	r1, =playerPosX
	ldr 	r2, =playerPosY
	ldr	r1, [r1]
	ldr 	r2, [r2]
	add	r2, #1
	bl	RenderCar

	//Set the car back into the grid
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

	//Render where the car used to be to ensure those tiles are updated
	mov 	r0, r5
	mov 	r1, r6
	add 	r1, #1
	bl 	RenderMapTile

	mov 	r0, r5
	mov 	r1, r6
	add 	r1, #2
	bl 	RenderMapTile

	//Re-render where the car is now
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


// r0 is the snes input passed as an argument
// Interprets the SNES input and moves the car
InterpretInput:

	push 	{lr}

	//Is anything pressed
	ldr	r1, =0xFFFF
	cmp	r0, r1
	beq	noChange

	//Check for B
	tst	r0, #1
	bne 	skip1
	ldr 	r1, =playerPosY
	ldr 	r2, [r1]
	cmp 	r2, #20
	addlt 	r2, #1
	strlt 	r2, [r1]  

	skip1:

	//Check for A
	ldr 	r1, =0x100
	tst	r0, r1
	bne 	skip2
	ldr 	r1, =playerPosY
	ldr 	r2, [r1]
	cmp 	r2, #0
	subgt 	r2, #1
	strgt 	r2, [r1] 

	skip2:
	//Check for RIGHT on D pad
	ldr 	r1, =0x80
	tst	r0, r1
	ldreq 	r1, =playerPosX
	ldreq 	r2, [r1]
	addeq 	r2, #1
	streq 	r2, [r1] 

	//Check for LEFT on D pad
	ldr 	r1, =0x40
	tst	r0, r1
	ldreq 	r1, =playerPosX
	ldreq 	r2, [r1]
	subeq 	r2, #1
	streq 	r2, [r1] 

	noChange:

	pop 	{pc}

.global CheckForCollision
/*
* Checks to see if the car has collided with something
*/
CheckForCollision:

	push 	{r4,r5,lr}

	ldr	r0, =playerPosX
	ldr 	r1, =playerPosY
	ldr	r0, [r0]
	ldr 	r1, [r1]

	//load the tiles the car is on
	// offset = (y * 32) + x
	add	r4, r0, r1, lsl #5
	add 	r1, #1
	add 	r5, r0, r1, lsl #5

	//Check to see if the collision bit is set
	ldr	r1, =grid
	ldrb	r0, [r1, r4]
	mov 	r2, #0b100
	tst	r2, r0
	bne 	collision

	//Check to see if the collision bit is set
	ldr	r1, =grid
	ldrb 	r1, [r1, r5] 
	mov 	r2, #0b100
	tst	r2, r1
	bne 	collision

	b 	otherCheck

	//If there was a collision, handle it, then return
	collision:
	bl 	HandlePlayerCollision
	b 	checkForCollisionEnd

	otherCheck:

	//Is this finish line, top of car
	lsr	r0, #3
	cmp	r0, #16
	ldreq	r1, =winFlag
	moveq	r2, #1
	streqb	r2, [r1]
	beq	checkForCollisionEnd

	//Is this finish line, bottom of car
	ldr	r1, =grid
	ldrb 	r1, [r1, r5] 
	lsr 	r1, #3
	cmp 	r1, #16
	ldreq	r1, =winFlag
	moveq	r2, #1
	streqb	r2, [r1]
	beq	checkForCollisionEnd

	//Is this fuel, top of car
	cmp 	r0, #17
	bne 	nextCheck

	//Update the fuel if we got fuel
	ldr 	r3, =playerFuel
	ldr 	r0, [r3]
	add 	r0, #10
	cmp 	r0, #100
	movgt	r0, #101 	
	str 	r0, [r3]

	//Reset fuel tile
	mov 	r0, #8
	ldr 	r3, =grid
	ldrb 	r2, [r3, r4]
	and 	r2, #0b111
	orr 	r0, r2
	strb 	r0, [r3, r4]

	//Is this fuel, bottom of car
	nextCheck:
	ldr	r1, =grid
	ldrb 	r1, [r1, r5] 
	lsr 	r1, #3
	cmp 	r1, #17
	bne 	checkForCollisionEnd

	//Update the fuel if we got fuel
	ldr 	r3, =playerFuel
	ldr 	r0, [r3]
	add 	r0, #10
	cmp 	r0, #100
	movgt	r0, #101 
	str 	r0, [r3]

	//Reset fuel tile
	mov 	r0,#8
	ldr 	r3,=grid
	ldrb 	r2, [r3, r5]
	and 	r2, #0b111
	orr 	r0, r2
	strb 	r0, [r3, r5]

	checkForCollisionEnd:
	pop 	{r4,r5,pc}

// HandlePlayerCollision()
/* 
* Updates the player fuel and lives, and makes the car flicker while
*/
HandlePlayerCollision:
	push	{r4-r11, lr}
	defaultX	.req	r5
	defaultY	.req	r6
	flashCtr	.req	r7
	playerX		.req	r8
	playerY		.req	r9
	len		.req	r10
	ctr		.req	r11

	//Load the default player location
	ldr	r1, =playerDefaultX
	ldr	defaultX, [r1]
	ldr	r1, =playerDefaultY
	ldr	defaultY, [r1]

	//load the current player location
	ldr	r0, =playerPosX
	ldr	playerX, [r0]
	str	defaultX, [r0]
	ldr	r0, =playerPosY
	ldr	playerY, [r0]
	str	defaultY, [r0]

	//Player car explodes
	ldr 	r0, =tiles
	add 	r0, #84
	mov 	r1, #6
	mov 	r2, playerX
	add 	r3, playerY, #1
	bl 		Animate

	ldr 	r0, =tiles
	add 	r0, #84
	mov 	r1, #6
	mov 	r2, playerX
	add 	r3, playerY, #2
	bl 		Animate

	//Wait for a second. 
	ldr	r0, =1000000
	bl	Wait
	mov 	r4, #1

	//Subtract 20 from the player fuel
	ldr 	r0, =playerFuel
	ldr 	r1, [r0]
	sub 	r1, #20
	cmp 	r1, #0
	movlt 	r1, #0
	str 	r1, [r0]
	cmp 	r1, #0
	moveq 	r4, r1

	//subtract 1 from the player lives
	ldr 	r0, =playerLives
	ldr 	r1, [r0]
	sub 	r1, #1
	str 	r1, [r0]
	cmp 	r1, #0
	moveq	r4, r1

	//Update the fuel and lives for the player
	bl 	PrintFuel
	bl	PrintLives

	//If the player has no more lives or fuel, dont let them move around
	cmp	r4, #0
	ble	handlePlayerCollisionEnd

	// check if collided with grass:
	cmp	playerX, #26
	bgt	clearPlayerCar
	cmple	playerX, #4
	ble	clearPlayerCar

	mov	ctr, #-1
	searchLoop:

	//If we collided with a car, find it so it can be removed
	sub	r0, playerX, #5
	add	r1, playerY, #4
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
	ldr	len, [r0]

	// clear victim car and player car:
	mov	r0, #0
	sub	r1, playerX, #5
	add	r2, r3, #4
	add	r3, len, #1
	bl	SetCarCell

	//Remove the player car from the screen
	clearPlayerCar:
	mov	r0, playerX
	mov	r1, playerY
	bl	SetChanged
	mov	r0, playerX
	add	r1, playerY, #1
	bl	SetChanged
	mov	r0, playerX
	mov	r1, playerY
	bl	ClearCar
	mov	r0, playerX
	add	r1, playerY, #1
	bl	ClearCar

	// clear default spawn location:
	mov	r0, defaultX
	mov	r1, defaultY
	bl	SetChanged
	mov	r0, defaultX
	add	r1, defaultY, #1
	bl	SetChanged
	mov	r0, defaultX
	mov	r1, defaultY
	bl	ClearCar
	mov	r0, defaultX
	add	r1, defaultY, #1
	bl	ClearCar

	// execute changes:
	bl	RenderMap

	mov	flashCtr, #0
	flashCar:
	ldr	r0, =playerPosX
	ldr	playerX, [r0]
	ldr	r0, =playerPosY
	ldr	playerY, [r0]

	//Allows the player to move around while flashing in invicibility mode
	//before everything start again
	mov	r0, playerX
	mov	r1, playerY
	bl	SetChanged
	mov	r0, playerX
	add	r1, playerY, #1
	bl	SetChanged

	mov	r0, playerX
	add	r1, playerY, #1
	bl	RenderMapTile
	mov	r0, playerX
	add	r1, playerY, #2
	bl	RenderMapTile

	//Get movement and move car
	bl 	UpdateSNESInput
	bl 	InterpretInput

	ldr	r0, =150000
	bl	Wait

	//Render the player car
	mov	r0, #0
	ldr	r1, =playerPosX
	ldr 	r2, =playerPosY
	ldr	r1, [r1]
	ldr 	r2, [r2]
	add	r2, #1
	bl	RenderCar

	ldr	r0, =150000
	bl	Wait

	//Flash 10 times before restarting
	add	flashCtr, #1
	cmp	flashCtr, #10
	bne	flashCar

	handlePlayerCollisionEnd:
	.unreq	defaultX
	.unreq	defaultY
	.unreq	flashCtr
	.unreq	playerX
	.unreq	playerY
	.unreq	len
	.unreq	ctr
	pop	{r4-r11, pc}
