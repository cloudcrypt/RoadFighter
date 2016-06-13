/*
 * (x, y, startTile, numTiles)
 */

.global Animate
Animate:
	push 	{lr}
	numTiles	.req	r5


	push 	{r0, r4}
	bl 	DrawImage

	.unreq 	numTiles

	pop	{pc}	