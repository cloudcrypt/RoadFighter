.section .text
.global 	InitializeSNES
.global 	UpdateSNESInput
InitializeSNES:
	
	// GPIO 9 (LAT) is on GPIOFSEL0
	ldr		r0, =0x3F200000
	ldr		r1, [r0]
	
	// clear bits 27-29 and set them to 001 (Output)
	bic		r1, #0x38000000
	orr		r1, #0x08000000

	// write back to GPIOFSEL0
	str		r1, [r0]

	// GPIO 10 & 10 are on GPIOFSEL1
	ldr		r0, =0x3F200004
	ldr		r1, [r0]

	// clear bits 0-2 (GPIO 10) and 3-5 (GPIO 11), set 0-2 to 000 (Input) and 3-5 to 001 (Output)
	bic		r1, #0x0000003F
	orr		r1, #0x00000008

	// write back to GPIOFSEL1
	str		r1, [r0]

	// return
	bx		lr

UpdateSNESInput:

	push 	{lr}
	mov 	r0, #1				//Set clock high
	bl 		Write_Clock

	mov 	r0, #1				//Set latch high
	bl 		Write_Latch

	mov 	r0, #12				//Wait 12 micros
	bl 		Wait

	mov 	r0, #0				//set latch low
	bl 		Write_Latch

	bl 		Read_SNES			//Read input
	ldr 	r1, =SNESInput
	str 	r0, [r1]
	pop 	{pc}

//Writes value to latch
//r0: value to write to latch
Write_Latch:
	
	mov 	r1, #9				//latch line
	ldr 	r2, =0x3F200000		//base address
	mov 	r3, #1				//bit for operation
	lsl 	r3, r1				//Shift to proper position

	cmp 	r0, #0
	streq 	r3, [r2, #40]		//gpfclr 
	strne 	r3, [r2, #28]		//gpfset 

	mov 	pc, lr				//return

//Writes value to clock
//r0: value to write to clock
Write_Clock:
	
	mov 	r1, #11				//clock line
	ldr 	r2, =0x3F200000		//base address
	mov 	r3, #1				//bit for operation
	lsl 	r3, r1				//Shift to proper position

	teq 	r0, #0
	streq 	r3, [r2, #40]		//gpfclr
	strne 	r3, [r2, #28]		//gpfset 

	mov 	pc, lr				//return

//Read the input from the snes controller
//Returns the binary input bit in lsb of r0
Read_Data:
	
	mov 	r0, #10				//data line
	ldr 	r2, =0x3F200000		//base gpf register
	ldr 	r1, [r2, #52]		//gpdlev0

	mov 	r3, #1				//mask
	lsl 	r3, r0				//shift
	and 	r1, r3				//apply and to get data

	teq 	r1, #0				
	moveq	r0, #0				//Read 0
	movne 	r0, #1				//Read 1
	
	mov 	pc, lr				//return

//Waits for specified time in micro seconds
//r0: micros to wait
.global Wait
Wait:
	
	ldr 	r3, =0x3F003004		//Clock addr
	ldr 	r1, [r3]			//get current time
	add 	r1, r0				//add offset time to current time
	
wait_loop:						//loop until current time is greater than wait time
	ldr 	r2, [r3]			//get current time
	cmp 	r1, r2				//Branch if higher
	bhi 	wait_loop

	mov 	pc, lr				//return

//Read sns gets all of the buttons snes controller
//Returns 16 bits in lower part of r0 representing button presses
.globl Read_SNES
Read_SNES:				

	push 	{r4-r5,lr}
	
	mov 	r5, #0				//will contain final result
	mov 	r4, #0				//counter for bit mask offset

read_loop:

	mov 	r0, #6				//Wait for 6 micros
	bl 		Wait 

	mov 	r0, #0				//Write low to clock
	bl 		Write_Clock

	mov 	r0, #6				//Wait for 6 micros
	bl 		Wait 

	bl 		Read_Data			//Get next bit from snes

	lsl 	r0, r4				//bit in r0, shift to correct position
	orr 	r5, r0				//or it into r5
	add 	r4, #1				//increment shifter

	mov 	r0, #1				//Write high to clock
	bl 		Write_Clock

	cmp 	r4, #16				//If we have looped 16 times, break
	blt 	read_loop
	mov 	r0, r5				//Set return value

	pop 	{r4-r5,pc}

.section .data
.global SNESInput
.align 	4
SNESInput: 	.word 	0
