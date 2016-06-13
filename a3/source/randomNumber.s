// xorshift random
// self seeded with CLO register
// returns a number between 0 and 63
// return (r0)
.globl RandomNumber
RandomNumber:
	push 	{lr}

	// this ensures the system clock has changed between random numbers
	mov 	r0, #4
	bl 	Wait

	ldr 	r0, =0x3F003004 // seed from CLO register
	ldr 	r0, [r0]

	eor 	r0, r0, lsr #12
	eor 	r0, r0, lsl #25
	eor 	r0, r0, lsr #27	

	ldr 	r1, =0x3F
	and 	r0, r1	

	pop 	{pc}