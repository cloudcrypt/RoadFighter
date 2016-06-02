// xorshift random


// random (seed, start, end)
// random (r0, r1, r2)
// return (r0)
.globl RandomNumber
RandomNumber:
	push 	{lr}

	eor 	r0, r0, lsr #12
	eor 	r0, r0, lsl #25
	eor 	r0, r0, lsr #27	

	sub 	r3, r2, r1 // difference in r1 to r2 makes range 0 to r3
	udiv 	r2, r0, r3 // modulo operation
	mls  	r0, r3, r2, r0
	add 	r0, r3

	return:
	pop 	{pc}