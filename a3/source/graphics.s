.arch armv6
.fpu neon
.syntax unified

 // GraphicsTest
 // *  r0 - x
 // *  r1 - y
 // *  r2 - color

.global GraphicsTest
GraphicsTest:

	
/*
	MRC p15, 0, r0, c1, c1, 2
	ORR r0, r0, #2_11<<10 ; enable fpu
	MCR p15, 0, r0, c1, c1, 2
	LDR r0, =(0xF << 20)
	MCR p15, 0, r0, c1, c0, 2
	MOV r3, #0x40000000 
	VMSR FPEXC, r3
*/	@ EnableVFP



stmfd     sp!, {r0 - r3}
  ldr       r3, =0x3f800000

  @ Clear registers
  vmov.f32  s0,  r0
  vmov.f32  s1,  r0
  vmov.f32  s2,  r0
  vmov.f32  s3,  r0
  vmov.f32  s4,  r0
  vmov.f32  s5,  r0
  vmov.f32  s6,  r0
  vmov.f32  s7,  r0
  vmov.f32  s8,  r0
  vmov.f32  s9,  r0
  vmov.f32  s10, r0
  vmov.f32  s11, r0
  vmov.f32  s12, r0
  vmov.f32  s13, r0
  vmov.f32  s14, r0
  vmov.f32  s15, r0

  @ Clear 8 pixels at once
  ldr       r0, =FrameBufferPointer
  mov       r2, #0
  ldr       r2, =1024 * 768
1:
  vstm.f32  r0!, {s0 - s15}
  subs      r2, r2, #16
  bne       1b

  ldmfd     sp!, {r0 - r3}
  mov       pc, lr

/* 



setup_gfx:
	  stmfd     sp!, {lr}

	  @ Request a framebuffer config
	  ldr       r0, =0x1
	  ldr       r1, =FrameBufferPointer
	  orr       r1, #0x40000000
	  bl        mbox_write
	  bl        mbox_read

	  ldmfd     sp!, {pc}

	   */