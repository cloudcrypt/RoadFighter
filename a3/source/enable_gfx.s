.arch armv6
.fpu neon
.syntax unified

.global EnableFPU
EnableFPU:
	push 	{lr}

	LDR 	r0, =(0xF << 20)
	MCR 	p15, 0, r0, c1, c0, 2
	MOV 	r3, #0x40000000 
	VMSR 	FPEXC, r3

	pop	{pc}