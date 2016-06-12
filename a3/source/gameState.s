.section .text
.global	UpdateGameState
// UpdateGameState()
UpdateGameState:
	push	{r4, lr}
	tickAmt	.req	r4
	ldr	r0, =tickCounter
	ldr	tickAmt, [r0]
	add	tickAmt, #1
	str	tickAmt, [r0]

	// Update playerFuel
	ldr	r0, =fuelTickCtr
	ldr	r1, =fuelTickAmt
	ldr	r2, [r0]
	ldr	r3, [r1]
	cmp	r2, r3
	moveq	r2, #0
	addne	r2, #1
	str	r2, [r0]
	ldreq	r0, =playerFuel
	ldreq	r1, [r0]
	subeq	r1, #1
	streq	r1, [r0]
	bleq	PrintFuel

	// Verify playerFuel
	ldr	r0, =playerFuel
	ldr	r0, [r0]
	cmp	r0, #0
	bgt	notLoseState
	// Verify playerLives
	ldr	r0, =playerLives
	ldr	r0, [r0]
	cmp	r0, #0
	bgt	notLoseState

	ldr	r0, =loseFlag
	ldrb	r1, [r0]
	mov	r1, #1
	strb	r1, [r0]

	notLoseState:
	ldr	r0, =finishThreshold
	ldr	r0, [r0]
	cmp	tickAmt, r0
	blt	incrementTickCounterEnd

	bl	RandomNumber
	cmp	r0, #1
	bge	incrementTickCounterEnd
	bl	RandomNumber
	cmp	r0, #32
	bge	incrementTickCounterEnd
	
	ldr	r1, =finishModeFlag
	ldrb	r0, [r1]
	cmp	r0, #2
	beq	incrementTickCounterEnd

	mov	r0, #1
	strb	r0, [r1]
	
	ldr	r0, =leftCarProb
	mov	r1, #0
	str	r1, [r0]
	ldr	r0, =rightCarProb
	mov	r1, #0
	str	r1, [r0]

	incrementTickCounterEnd:
	.unreq	tickAmt
	pop	{r4, pc}

.global	VerifyGameState
// VerifyGameState() = 0, 1, or 2
VerifyGameState:
	ldr	r0, =loseFlag
	ldrb	r0, [r0]
	cmp	r0, #1
	beq	verifyGameStateEnd

	ldr	r0, =winFlag
	ldrb	r0, [r0]
	cmp	r0, #1
	moveq	r0, #2

	verifyGameStateEnd:
	bx	lr


.global ResetGameState
ResetGameState:

	//Reset player position
	ldr 	r0, =playerDefaultX 
	ldr	r0, [r0]
	ldr	r1, =playerPosX
	str 	r0, [r1]

	ldr 	r0, =playerDefaultY 
	ldr	r0, [r0]
	ldr	r1, =playerPosY
	str 	r0, [r1]

	//Reset flags
	mov 	r0, #0
	ldr 	r1, =winFlag
	ldr 	r2, =loseFlag
	ldr 	r3, =finishModeFlag
	strb 	r0, [r1]
	strb 	r0, [r2]
	strb 	r0, [r3]

	//Reset player and lives
	ldr 	r0, =playerFuel
	mov 	r1, #100
	str 	r1, [r0]

	ldr 	r0, =playerLives
	mov 	r1, #3
	str 	r1, [r0]

	//Reset tick count, and fuel decrement variables
	ldr 	r0, =tickCounter
	mov 	r1, #0
	str 	r1, [r0]

	ldr 	r0, =fuelTickAmt
	mov 	r1, #2
	str 	r1, [r0]

	ldr 	r0, =fuelTickCtr
	mov 	r1, #0
	str 	r1, [r0]

	//Reset finish threshold value, as well as car generation probabilities
	ldr 	r0, =finishThreshold
	mov 	r1, #50
	str 	r1, [r0]

	ldr 	r0, =leftCarProb
	mov 	r1, #2
	str 	r1, [r0]

	ldr 	r0, =rightCarProb
	mov 	r1, #1
	str 	r1, [r0]

	bx 	lr

.section .data
.global playerPosX
.global playerPosY
.global	playerDefaultX
.global	playerDefaultY
.global playerFuel
.global playerLives
.global	refreshCounter
.global	tickCounter
.global	finishThreshold
.global fuelTickAmt
.global fuelTickCtr
playerDefaultX:	.int	18 
playerDefaultY:	.int	18
playerPosX:	.int 	18 
playerPosY: 	.int	18 
fuelTickAmt:	.int	2	
fuelTickCtr:	.int	0	
playerFuel: 	.int  	100	
playerLives: 	.int 	3	
tickCounter:	.int	0	
finishThreshold:.int	50	

.global	finishModeFlag
.global	winFlag
.global	loseFlag
finishModeFlag:	.byte	0	
winFlag: 	.byte 	0 
loseFlag: 	.byte 	0 

.global	leftCarProb
.global	rightCarProb
.global	oneProb
.global	fourProb
.global	threeProb
.global	twoProb
.align	4
leftCarProb:	.int	2
rightCarProb:	.int	1
oneProb:	.int	7	
fourProb:	.int	8
threeProb:	.int	15
twoProb:	.int	64

.global	leftEdgeSize
.global	rightEdgeSize
leftEdgeSize:	.int	5
rightEdgeSize:	.int	5