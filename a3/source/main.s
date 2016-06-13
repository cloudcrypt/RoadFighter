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

	//Used as a semi global variable, never leaves main
	menuFlag	.req	r5
	mov 	menuFlag, #1

	//Used to reset everything and siplay the main menu
	RestartGame:

	//setup everything
	bl	InitializeMap
	bl 	ResetGameState
	bl 	ClearCarGrid
	bl 	RenderMap

	//Setup player car
	ldr 	r2, =playerPosX
	ldr 	r3, =playerPosY
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	bl 	SetCar
	ldr 	r0, [r2]
	ldr 	r1, [r3]
	add 	r1, #1
	bl 	SetCar

	//Setup intial scores
	bl	InitializeScore
	bl	GenerateNextRow

	//Do we want to diplay the main menu
 	cmp 	menuFlag, #1
 	bne 	startGame
 	bleq 	displayMenu

 	//Check result from display menu
	mov 	r12, r0
	//Did we quit
	cmp 	r12, #1
	bleq 	ClearScreen
	cmp 	r12, #1
	beq 	haltLoop$
	//otherwise start a new game	
	mov 	menuFlag, #0
	b 	RestartGame


	// Draws player car and waits for initial A press to start
	startGame:
	bl 	UpdatePlayerCar
	bl	WaitForButtonA

	//If player pressed select, go back to main menu
	cmp	r0, #1
	moveq	menuFlag, #1
	beq	RestartGame

	//Wait just before we start
	ldr	r0, =400000
	bl	Wait

	mainLoop:

	//Shift eveyrthing down
	bl	ShiftMap
	bl 	ShiftCarGrid

	//Update the player car with new input
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

	//Render the map
	bl	RenderMap

	//Check for collisions
	bl 	CheckForCollision

	//Precedurally Generate the next row
	bl	GenerateNextRow
	bl 	GenerateNewCars
	
	//Update and check the game state. 
	bl	UpdateGameState
	bl	VerifyGameState
	//Check result from verify to see if the game is over
	cmp	r0, #0
	bne	handleEndGame
	
	b 	mainLoop

	//Check if we won or lost the game
	handleEndGame:

	cmp	r0, #1	
	bleq	DisplayLose

	cmp	r0, #2
	bleq	DisplayWin

	//Stay on screen until player hits any button
	bl	WaitForInput

	//Go back to main menu when the player presses any button
	mov	menuFlag, #1
	b	RestartGame

haltLoop$:
	b	haltLoop$

// EnableL1Cache()
// Turns on branch prediction, L1 caching, and instruction caching. 
EnableL1Cache:
	push 	{lr}

	//Make everything go really fast!
	mrc 	p15, #0, r0, c1, c0, #0
	orr 	r0, #0x4
	orr 	r0, #0x800
	orr 	r0, #0x1000
	mcr 	p15, #0, r0, c1, c0, #0

	pop 	{pc}
