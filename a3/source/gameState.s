.section .text
.global	IncrementTickCounter
// IncrementTickCounter()
IncrementTickCounter:
	push	{lr}
	ldr	r0, =tickCounter
	ldr	r1, [r0]
	add	r1, #1
	str	r1, [r0]

	ldr	r0, =finishThreshold
	ldr	r0, [r0]
	cmp	r1, r0
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
	pop	{pc}

.global ResetGame
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
	str 	r0, [r1]
	str 	r1, [r2]

	ldr 	r0, =playerFuel
	mov 	r1, #100
	str 	r1, [r0]

	ldr 	r0, =playerLives
	mov 	r1, #3
	str 	r1, [r0]

	ldr 	r0, =tickCounter
	mov 	r1, #0
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
.global	finishModeFlag
.global fuelTickAmt
.global fuelTickCtr
playerDefaultX:	.int	18 //
playerDefaultY:	.int	18 //
playerPosX:	.int 	18 //
playerPosY: 	.int	18 //
fuelTickAmt:	.int	20
fuelTickCtr:	.int	0
playerFuel: 	.int  	100	//
playerLives: 	.int 	3	//
tickCounter:	.int	0	//
finishThreshold:.int	50	//
finishModeFlag:	.byte	0	//


winFlag: 	.byte 	0 //
loseFlag: 	.byte 	0 //

.global	leftCarProb
.global	rightCarProb
.global	oneProb
.global	fourProb
.global	threeProb
.global	twoProb
.align	4
leftCarProb:	.int	2
rightCarProb:	.int	1
oneProb:		.int	7	
fourProb:		.int	8
threeProb:		.int	15
twoProb:		.int	64

.global	leftEdgeSize
.global	rightEdgeSize
leftEdgeSize:	.int	5
rightEdgeSize:	.int	5