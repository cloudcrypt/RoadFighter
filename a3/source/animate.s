.section .text
.global Animate
/*
* Animate(tileArrayAddress, NumAnimationTiles, TileX, TileY)
*/
Animate:
	push 	{r4-r8, lr}
	numTiles	.req	r5
	tile 		.req 	r6
	xTile 		.req 	r7
	yTile		.req 	r8

	mov 	tile, r0 
	mov	numTiles, r1
	mov 	xTile, r2
	mov	yTile, r3

	animation:
	cmp 	numTiles, #0
	beq 	animationDone

	mov 	r0, tile
	ldr 	r0, [r0]
	mov 	r1, xTile
	mov 	r2, yTile
	mov 	r3, #32
	mov 	r4, #32

	push 	{r0-r4}
	// DrawTileImage(imgAddrs, startTX, startTY, dimX, dimY)
	bl 	DrawTileImage
	add 	tile, #4
	sub 	numTiles, #1
	ldr 	r0, =100000
	bl 	Wait
	b 	animation

	animationDone:
	.unreq 	numTiles
	.unreq 	tile
	.unreq 	xTile
	.unreq  yTile

	pop	{r4-r8, pc}