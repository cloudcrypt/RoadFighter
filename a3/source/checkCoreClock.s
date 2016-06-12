.section 	.text
.global CheckCoreClock
.align 4
CheckCoreClock:

	// load the address of the mailbox interface
	mbox	.req	r2
	ldr		mbox,	=0x3F00B880

	// load the address of the turbo init structure
	turboInit	.req	r3
	ldr		turboInit,	=CheckCoreStruct

mBoxFullLoop$:
	// load the value of the mailbox status register
	ldr		r0,		[mbox, #0x18]

	// loop while bit 31 (Full) is set
	tst		r0,		#0x80000000
	bne		mBoxFullLoop$

	// add 0x40000000 to address of framebuffer init struct, store in r0
	add		r0, 	turboInit,	#0x40000000

	// or with the framebuffer channel (8)
	orr		r0, 	#0b1000

	// write this value to the mailbox write register
	str		r0,		[mbox, #0x20]

mBoxEmptyLoop$:
	// load the value of the mailbox status register
	ldr		r0,		[mbox, #0x18]

	// loop while bit 30 (Empty) is set
	tst		r0,		#0x40000000
	bne		mBoxEmptyLoop$

	// read the response from the mailbox read register
	ldr		r0,		[mbox, #0x00]

	// and-mask out the channel information (lowest 4 bits)
	and		r1,		r0, #0xF

	// test if this message is for the framebuffer channel (1)
	teq		r1,		#0b1000

	// if not, we need to read another message from the mailbox
	bne		mBoxEmptyLoop$
	endCheckCore:

	ldr		r0,	=CheckCoreStruct
	ldr		r1,	[r0, #0x04]	//load the request/response word from buffer
	teq		r1,	#0x80000000	//test is the request was successful
	movne		r0, 	#0		//return 0 if the request failed
	moveq 		r0, 	r1
	.unreq 		turboInit
	bx			lr	

.section .data

.align 4
CheckCoreStruct:

	.int	0x00000020	//Tag
	.int	0			//Stuff
	.int 	0x00030002
	.int 	8
	.int 	0
	.int 	0x00000004
	.int 	0
	.int 	0

