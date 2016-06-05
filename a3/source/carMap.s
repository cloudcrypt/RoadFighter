.section .text
.global ClearCarGrid
ClearCarGrid:
	push	{lr}
	// clear the carGrid yo.
	pop		{pc}

.global	GenerateNewCars
GenerateNewCars:


.section .data
.global	carGrid
carGrid:	
	.rept	594
	.byte	0
	.endr
	.align