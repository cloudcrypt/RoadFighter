.section .text

.section .data
.global playerPosX
.global playerPosY
.global playerFuel
.global playerLives
playerPosX:		.int 	16
playerPosY: 	.int	12
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
leftCarProb:	.int	2
rightCarProb:	.int	1
oneProb:		.int	5	
fourProb:		.int	10	
threeProb:		.int	20
twoProb:		.int	32