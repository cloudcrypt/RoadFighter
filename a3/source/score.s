.section .text

.global InitializeScore
// InitializeScore()
InitializeScore:
	push	{lr}

	ldr	r0, =fuelString
	mov	r1, #0
	mov	r2, #0
	ldr 	r3, =0xFFFF
	bl	DrawString

	ldr 	r0, =livesString
	mov 	r1, #200
	mov 	r2, #0
	ldr 	r3, =0xFFFF
	bl 	DrawString
	
	bl 	PrintLives
	bl	PrintFuel

	pop	{pc}


.global PrintFuel
PrintFuel:
	push 	{r4-r5, lr}


	ldr 	r4, =playerFuel
	ldr 	r4, [r4]
	ldr 	r0, =fuelAmountString

	cmp 	r4, #100
	blt 	doubleDigitFuel
	ldr 	r5, =0x15A0 // green
	// print 100
	mov 	r1, #49
	strb 	r1, [r0]
	mov 	r1, #48
	strb 	r1, [r0, #1]
	strb 	r1, [r0, #2]
	mov 	r1, #0
	strb 	r1, [r0, #3]
	b 	displayFuel

	// print double digit fuel
	doubleDigitFuel:
	cmp 	r4, #10
	blt 	singleDigitFuel

	mov 	r1, #0
	numTens:
	add 	r1, #1
	sub 	r4, #10
	cmp 	r4, #10
	bge 	numTens

	cmp	r1, #7
	ldrge 	r5, =0x9700// green 
	bge 	loadFuelToMem
	cmp 	r1, #5
	ldrge 	r5, =0xffa1 // green yellow
	bge 	loadFuelToMem
	ldr 	r5, =0xfe00 // yellow

	loadFuelToMem:
	add 	r1, #48
	strb 	r1, [r0]
	add 	r4, #48
	strb 	r4, [r0, #1]
	mov 	r1, #0
	strb 	r1, [r0, #2]

	b 	displayFuel

	singleDigitFuel:
	add 	r4, #48
	strb 	r4, [r0]
	mov 	r1, #0
	strb 	r1, [r0, #1]
	ldr 	r5, =0xf800 // red

	displayFuel:

	mov 	r0, #80
	mov 	r1, #0
	mov 	r2, #100
	mov 	r3, #32
	bl 	ClearArea


	ldr 	r0, =fuelAmountString
	mov 	r3, r5 	// set colour
	mov 	r1, #40 // x 
	mov 	r2, #0 // y
	bl 	DrawString

	pop 	{r4-r5, pc}

.global PrintLives
PrintLives:
	lives 	.req 	r5
	posX 	.req 	r6
	push 	{r4-r6, lr}

	ldr 	r0, =playerLives
	ldr 	lives, [r0]
	mov 	posX, #512

	mov 	r0, #512
	mov 	r1, #0
	mov 	r2, #96
	mov 	r3, #32
	bl 	ClearArea

	1:
	cmp 	lives, #0
	ble 	1f
	ldr 	r0, =tiles
	add 	r0, #72
	ldr	r0, [r0] // img addr
	mov 	r1, posX // x
	mov 	r2, #32  // width
	mov 	r3, #32  // height
	bl 	DrawHeaderImage

	add 	posX, #32
	sub 	lives, #1
	b 	1b

	1:
	// animate life going away > probably could loop it
	ldr 	r0, =playerLives
	ldr 	r0, [r0]
	cmp 	r0, #3
	beq 	endPrintLives	

	ldr 	r0, =tiles
	add 	r0, #76
	ldr 	r0, [r0]
	mov 	r1, posX // x
	mov 	r2, #32  // width
	mov 	r3, #32  // height
	bl 	DrawHeaderImage

	ldr 	r0, =100000
	bl 	Wait

	mov 	r0, posX
	mov 	r1, #0
	mov 	r2, #32
	mov 	r3, #32
	bl 	ClearArea

	ldr 	r0, =tiles
	add 	r0, #80
	ldr 	r0, [r0]
	mov 	r1, posX // x
	mov 	r2, #32  // width
	mov 	r3, #32  // height
	bl 	DrawHeaderImage

	ldr 	r0, =100000
	bl 	Wait

	mov 	r0, posX
	mov 	r1, #0
	mov 	r2, #32
	mov 	r3, #32
	bl 	ClearArea

	endPrintLives:
	.unreq 	lives
	.unreq  posX

	pop 	{r4-r6, pc}

.section .data
.align 4
fuelString:
	.asciz	"Fuel:"

livesString:
	.asciz "Lives:"
	
fuelAmountString:
	.int 	0	
	.asciz 	""
