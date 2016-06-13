// returns r0 - 
// 0 = start
// 1 = quit
.globl 	displayMenu
displayMenu:
	push {r4, lr}

	//Draw the menu background
	ldr 	r0, =menuScreen
	mov 	r1, #160 
	mov 	r2, #192
	mov 	r3, #704
	mov 	r4, #352
	push 	{r0-r4}
	bl 	DrawImage	
	
	mov 	r4, #0 // 0 denotes start, 1 denotes quit
	ldr 	r0, =menuStart
	bl 	menuSelection

	awaitSelection:

		//Controls the refresh rate of the background
		ldr 	r0, =100000
		bl 	Wait

		//Move the map behind the menu for cool effects!
		bl	ShiftMap
		bl	GenerateNextRow
		bl 	RenderMapMenu

		bl 	UpdateSNESInput

		// check if A was pressed
		ldr		r2, =0xfeff
		teq 	r0, r2 // #0b100000000	
		beq 	optionSelected

		// check if up was pressed
		ldr		r2, =0xffef// #0b10000
		teq		r0, r2 
		bne 	checkDownButton
		cmp 	r4, #0
		moveq 	r4, #1
		movne	r4, #0
		ldreq 	r0, =menuQuit
		ldrne 	r0, =menuStart
		bl 		menuSelection
		ldr 	r0, =10000 // delay to make selection easier
		bl 		Wait
		b 		awaitSelection

		

		checkDownButton:
		//check if down was pressed
		ldr		r2, =0xff5f
		teq 	r0, r2 // #0b100000
		bne 	awaitSelection
		cmp 	r4, #0
		moveq 	r4, #1
		movne	r4, #0
		ldreq 	r0, =menuQuit
		ldrne 	r0, =menuStart
		bl 		menuSelection	
		ldr 	r0, =10000 // delay to make selection easier
		bl 		Wait
		b 		awaitSelection

		

	optionSelected:
	mov 	r0, r4
	pop 	{r4, pc}

/*
* menuSelection(imgAddress)
* Draws the selected menu.
*/
menuSelection:
	push {r4, lr}

	ldr r1, =352
	ldr r2, =379
	mov r3, #244
	mov r4, #78
	push {r0-r4}
	bl DrawImage

	pop {r4, pc}


.section .data
.align 4	
