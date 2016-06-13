.section    .init
.globl     _start

_start:
    b       main
    
.section .text
	
main:
	mov     sp, #0x8000
	
	bl	EnableJTAG
	bl 	EnableL1Cache
	bl	InitFrameBuffer
	bl  	InitializeSNES

	menuFlag	.req	r5
	mov 	menuFlag, #1

	RestartGame:

	bl	InitializeMap
	bl 	ResetGameState
	bl 	ClearCarGrid
	bl 	RenderMap

	ldr 	r2, =playerPosX
	ldr 	r3, =playerPosY
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	bl 	SetCar
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	add 	r1, #1
	bl 	SetCar

	bl	InitializeScore

	bl	GenerateNextRow

 	cmp 	menuFlag, #1
 	bne 	startGame
 	bleq 	displayMenu
	mov 	r12, r0
	cmp 	r12, #1
	bleq 	ClearScreen
	cmp 	r12, #1
	beq 	haltLoop$	
	mov 	menuFlag, #0
	b 	RestartGame

	startGame:
	bl 	UpdatePlayerCar
	bl	WaitForButtonA
	cmp	r0, #1
	moveq	menuFlag, #1
	beq	RestartGame

	ldr	r0, =400000
	bl	Wait

	mainLoop:

	bl	ShiftMap
	bl 	ShiftCarGrid

	bl 	UpdateSNESInput
	bl 	UpdatePlayerCar

	//This is the Select button. Should go to main menu.
	ldr 	r0, =SNESInput
	ldr 	r0, [r0]
	mov 	r1, #0b100
	tst 	r0, r1
	moveq 	menuFlag, #1
	beq 	RestartGame

	//This is the start button. Should restart game.
	mov 	r1, #0b1000
	tst 	r0, r1
	beq 	RestartGame

	bl	RenderMap
	bl 	CheckForCollision

	bl	GenerateNextRow
	bl 	GenerateNewCars
	
	bl	UpdateGameState
	bl	VerifyGameState
	cmp	r0, #0
	bne	handleEndGame
	
	b 	mainLoop

	handleEndGame:

	cmp	r0, #1
	bleq	DisplayLose

	cmp	r0, #2
	bleq	DisplayWin

	bl	WaitForInput

	mov	menuFlag, #1
	b	RestartGame

haltLoop$:
	b	haltLoop$

// EnableL1Cache()
EnableL1Cache:
	push 	{lr}

	//Make everything go really fast!
	mrc 	p15, #0, r0, c1, c0, #0
	orr 	r0, #0x4
	orr 	r0, #0x800
	orr 	r0, #0x1000
	mcr 	p15, #0, r0, c1, c0, #0

	pop 	{pc}
