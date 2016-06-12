.section .text
.global	IncrementTickCounter
// IncrementTickCounter()
IncrementTickCounter:
	ldr	r0, =tickCounter
	ldr	r1, [r0]
	add	r1, #1
	str	r1, [r0]
	bx	lr

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
playerDefaultX:	.int	18
playerDefaultY:	.int	18
playerPosX:		.int 	18
playerPosY: 	.int	18
mapShiftWait:	.int	20
mapShiftCtr:	.int	0
playerFuel: 	.int  	100
playerLives: 	.int 	3
tickCounter:	.int	0
finishThreshold:	.int	200

winFlag: 	.byte 	0
loseFlag: 	.byte 	0

.global	leftCarProb
.global	rightCarProb
.global	oneProb
.global	fourProb
.global	threeProb
.global	twoProb
.align	4
leftCarProb:	.int	4
rightCarProb:	.int	2
oneProb:		.int	7	
fourProb:		.int	8
threeProb:		.int	15
twoProb:		.int	64

