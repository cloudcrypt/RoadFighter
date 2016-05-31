.section .text

.globl InitFrameBuffer
/* Initialize the FrameBuffer using the FrameBufferInit structure
 * Returns:
 *	r0 - 0 on failure, framebuffer pointer on success
 */
InitFrameBuffer:
	// load the address of the mailbox interface
	mbox	.req	r2
	ldr		mbox,	=0x3F00B880

	// load the address of the framebuffer init structure
	fbinit	.req	r3
	ldr		fbinit,	=FrameBufferInit

mBoxFullLoop$:
	// load the value of the mailbox status register
	ldr		r0,		[mbox, #0x18]

	// loop while bit 31 (Full) is set
	tst		r0,		#0x80000000
	bne		mBoxFullLoop$

	// add 0x40000000 to address of framebuffer init struct, store in r0
	add		r0, 	fbinit,	#0x40000000

	// or with the framebuffer channel (1)
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
	
	ldr		r0,	=FrameBufferInit
	ldr		r1,	[r0, #0x04]	//load the request/response word from buffer
	teq		r1,	#0x80000000	//test is the request was successful
	beq		pointerWaitLoop$	
	movne		r0, 	#0		//return 0 if the request failed
	bxne		lr	

pointerWaitLoop$:
	ldr	r0, 	=FrameBuffer 
	ldr	r0, 	[r0]
	teq	r0,	#0	//test if framebuffer pointer has been set
	
	beq	pointerWaitLoop$
	
	ldr 	r3, =FrameBufferPointer
	str	r0, [r3]

	.unreq	mbox
	.unreq	fbinit

	bx	lr

.section .data

.align 4
FrameBufferInit:

	.int 	22 * 4			//Buffer size in bytes
	.int	0			//Indicates a request to GPU
	.int	0x00048003		//Set Physical Display width and height
	.int	8			//size of buffer
	.int	8			//length of value
	.int	1024			//horizontal resolution
	.int	768			//vertical resolution

	.int	0x00048004		//Set Virtual Display width and height
	.int	8			//size of buffer
	.int	8			//length of value
	.int 	1024			//same as physical display width and height
	.int 	768

	.int	0x00048005		//Set bits per pixel
	.int 	4			//size of value buffer
	.int	4			//length of value
	.int	16			//bits per pixel value

	.int	0x00040001		//Allocate framebuffer
	.int	8			//size of value buffer
	.int	8			//length of value
FrameBuffer:
	.int	0			//value will be set to framebuffer pointer
	.int	0			//value will be set to framebuffer size			

	.int	0			//end tag, indicates the end of the buffer

.align 4
.globl FrameBufferPointer
FrameBufferPointer:
	.int	0


