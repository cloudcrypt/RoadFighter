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
playerFuel: 	.int 	100
playerLives: 	.int 	3

winFlag: 	.byte 	0
loseFlag: 	.byte 	0