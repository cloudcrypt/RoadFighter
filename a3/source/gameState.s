.section .text

.section .data
.global playerPosX
.global playerPosY
.global	playerDefaultX
.global	playerDefaultY
.global playerFuel
.global playerLives
playerDefaultX:	.int	18
playerDefaultY:	.int	18
playerPosX:		.int 	18
playerPosY: 	.int	18
mapShiftWait:	.int	20
mapShiftCtr:	.int	0
playerFuel: 	.int  	100
playerLives: 	.int 	3

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
.align	4
rightCarProb:	.int	2
.align	4
oneProb:		.int	7	
.align	4
fourProb:		.int	8
.align	4
threeProb:		.int	15
.align	4
twoProb:		.int	64
.align	4