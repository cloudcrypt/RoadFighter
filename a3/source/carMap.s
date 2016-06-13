.section .text

.global	GenerateNewCars
GenerateNewCars:
	push	{r4-r5, lr}
	laneCtr	.req	r4
	car	.req	r5
	mov	laneCtr, #0

	laneLoop:

	mov	r0, laneCtr
	bl	CheckLane
	cmp	r0, #1
	beq	ignoreLane

	bl	RandomNumber

	mov	car, #0
	cmp	laneCtr, #10
	bgt	rightSide

	ldr	r1, =leftCarProb
	ldr	r1, [r1]
	cmp	r0, r1
	bge	ignoreLane

	mov	r0, #1
	bl	GetRandCar
	mov	car, r0
	
	b	placeCar

	rightSide:
	ldr	r1, =rightCarProb
	ldr	r1, [r1]
	cmp	r0, r1
	bge	ignoreLane

	mov	r0, #0
	bl	GetRandCar
	mov	car, r0

	placeCar:
	lsr	r0, car, #4
	ldr	r1, =cars
	ldr	r0, [r1, r0, lsl #2]
	ldr	r0, [r0]

	mov	r3, r0
	rsb	r2, r0, #4
	mov	r1, laneCtr
	mov	r0, car
	bl	SetCarCell

	ignoreLane:
	add	laneCtr, #1
	cmp	laneCtr, #22
	bne	laneLoop

	.unreq	laneCtr
	.unreq	car
	pop	{r4-r5, pc}

//Clears the entire car grid of all cars, can be used for reseting
.global ClearCarGrid
ClearCarGrid:
	
	push 	{r4,r5,lr}
	inc 	.req 	r4
	addrs 	.req 	r5

	ldr 	addrs, =carGrid
	mov 	inc, #0
	mov 	r0, #0
	ldr 	r1, =594
	
	clearLoop:
	strb 	r0, [addrs], #1
	
	add  	inc, #1
	cmp 	inc, r1
	bne 	clearLoop

	.unreq 	inc
	.unreq	addrs
	pop 	{r4,r5,pc}	

// Updates all of the cars in the car grid to a new position based on their speed.
// start shifting from bottom up
.global	ShiftCarGrid
ShiftCarGrid:
	push	{r4-r10, lr}
	row	.req	r4
	lane 	.req	r5
	car	.req	r6
	vel	.req	r7
	velCtr	.req	r8
	len	.req	r9
	lenCtr	.req	r10
	redrwCtr	.req	r11
	mov 	row, #26 	// start on bottom

	rowLoop:
	mov 	lane, #0

	laneLoop2:
	mov	r0, lane
	mov	r1, row
	//Load car cell and check to see if there is a car present. If not, skip
	bl	GetCarCell
	mov	car, r0
	cmp	car, #0
	beq	ignoreLane2

	// get velocity
	and	vel, car, #0b11
	// get alternate velocity
	and	r1, car, #0b1100
	lsr	r1, #2
	// swap vel and velAlt in car
	bic	car, #0b1111
	lsl	r0, vel, #2
	orr 	car, r0
	orr	car, r1

	//check vel for this shift cycle
	cmp	vel, #0
	bne 	hasVelocity

	//Reset car cell.
	lsr	r0, car, #4
	ldr	r1, =cars
	ldr	r0, [r1, r0, lsl #2]
	ldr	len, [r0]

	mov 	r0, car
	mov	r1, lane
	mov 	r2, row
	mov	r3, len
	bl 	SetCarCell

	//check if there is a car 
	mov	r0, lane
	add	r1, row, len
	bl	GetCarCell
	cmp	r0, #0
	bne 	ignoreLane2

	//Reset values in TileGrid
	add	r0, lane, #5
	sub	r1, row, #4
	add	r1, len
	push	{r0,r1}
	bl	ClearCar
	pop 	{r0,r1}
	bl 	ClearCollideable

	b 	ignoreLane2

	hasVelocity:
	// get car len 
	lsr	r0, car, #4
	ldr	r1, =cars
	ldr	r0, [r1, r0, lsl #2]
	ldr	len, [r0]

	// clear car from grid
	mov	r0, #0
	mov	r1, lane
	mov	r2, row
	mov	r3, len
	bl	SetCarCell

	// check if car is leaving rendered area of grid
	add	r0, row, vel
	cmp	r0, #26
	bgt	ignoreLane2

	// validate car's entire shift path for entire length of car
	mov	velCtr, #1

	// If this car "Collides with" another car
	velLoop:
	mov	lenCtr, #0

	lenLoop:
	mov	r0, lane
	add	r1, velCtr, lenCtr
	add	r1, row
	push	{r1}		// save potential victimCar row
	bl	GetCarCell
	pop	{r1}
	//Have we collided with another vehicle
	cmp	r0, #0
	bne	accidentHandler

	//Loop for the length and velocity
	add	lenCtr, #1
	cmp	lenCtr, len
	blt	lenLoop

	add	velCtr, #1
	cmp	velCtr, vel
	ble	velLoop

	// shift car by vel and set into grid
	mov	r0, car
	mov	r1, lane
	add	r2, row, vel
	mov	r3, len
	bl	SetCarCell

	//Update all of the tiles for this car
	mov	redrwCtr, #0
	redrawLoop:
	mov	r2, #3
	sub	r2, redrwCtr
	add	r0, lane, #5
	sub	r1, row, r2
	cmp 	r1, #23
	bgt 	underGrid
	cmp	r1, #0
	blgt	RenderMapTile

	add	redrwCtr, #1
	cmp	redrwCtr, len
	blt	redrawLoop

	//Rander the actual car
	underGrid:

	mov	r0, car
	add	r1, lane, #5
	sub	r2, row, #3
	add	r2, vel
	bl	RenderCar

	b	ignoreLane2

	//If this vehicle collided with another, reduce its speed to match that of the 
	//vehicle it collided with. 
	accidentHandler:
	// victimCar in r0, victimCar row in r1
	mov	r2, r1
	// set car velocity to victimCar velocity
	and	r0, #0b1111
	bic 	car, #0b1111
	orr 	car, r0
	// get row above victimCar and shift car to row - car len
	sub	r2, len
	mov	r0, car
	mov	r1, lane
	mov	r3, len
	push	{r2}
	bl	SetCarCell
	pop	{r2}

	//Render the car
	mov	r0, car
	add	r1, lane, #5
	sub	r2, #3
	bl	RenderCar

	
	ignoreLane2:
	add	lane, #1
	cmp	lane, #22
	bne	laneLoop2

	sub	row, #1
	cmp	row, #-1
	bne	rowLoop
	.unreq	row
	.unreq	lane
	.unreq	car
	.unreq	vel
	.unreq	velCtr
	.unreq	len
	.unreq	lenCtr
	pop	{r4-r10, pc}

//RemoveCarInGrid(Tilex, Tiley, Length)
//Takes a tile position and length, and removes the car values from the car grid
RemoveCarInGrid:
	
	push 	{lr}

	x	.req 	r0
	y 	.req 	r1
	len 	.req 	r2

	add 	x, #5
	sub 	y, #4
	add 	len, #1

	updateLoop:

	//If we are outside the grid, do not modify the grid
	cmp 	y, #0 		
	blt 	checkLoop
	cmp 	y, #23
	popge 	{pc}

	skipLen:

	//Clear the grid for each position in the car
	push 	{r0-r3}
	bl 	ClearCar
	pop 	{r0-r3}
	push 	{r0-r3}
	bl 	SetChanged
	pop 	{r0-r3}
	push 	{r0-r3}
	bl 	ClearCollideable
	pop 	{r0-r3}

	checkLoop:
	add 	y, #1
	sub 	len, #1
	cmp 	len, #0
	bne 	updateLoop

	finishUpdating:

	.unreq 	x
	.unreq 	y
	.unreq 	len

	pop 	{pc}

//AddCarInGrid (TileX, TileY, Length)
//Takes a tile position and length, and adds the car values to the tile grid
AddCarInGrid:

	push 	{lr}

	x	.req 	r0
	y 	.req 	r1
	len 	.req 	r2

	add 	x, #5
	sub 	y, #4

	updateLoop1:

	//If we are outside the grid, do not modify the grid
	cmp 	y, #0 		
	blt 	checkLoop1
	cmp 	y, #23
	popge 	{pc}

	//Set the grid for each position in the car
	push 	{r0-r3}
	bl 	SetCar
	pop 	{r0-r3}
	push 	{r0-r3}
	bl 	SetChanged
	pop 	{r0-r3}
	push 	{r0-r3}
	bl 	SetCollideable
	pop 	{r0-r3}

	checkLoop1:
	add 	y, #1
	sub 	len, #1
	cmp 	len, #0
	bne 	updateLoop1

	.unreq 	x
	.unreq 	y
	.unreq 	len

	pop 	{pc}

// GetCarCell(gridX, gridY) = r0
// Returns the car byte for a given cell
.global	GetCarCell
GetCarCell:
	cmp 	r1, #26
	movgt 	r0, #0
	bgt 	getCarCellEnd
	add	r0, r1, lsl #4
	add	r0, r1, lsl #2
	add	r0, r1, lsl #1
	ldr	r1, =carGrid
	ldrb	r0, [r1, r0]
	getCarCellEnd:
	bx	lr

// SetCarCell(car, gridX, gridY, len)
// Calls either RemoveCarInGrid or AddCarInGrid
// If car is 0, then Remove, otherwise add
.global	SetCarCell
SetCarCell:
	push	{r4, lr}
	len	.req	r4
	cmp	r2, #26
	bgt	setCarCellEnd
	mov	len, r3

	//Compare the car byte with 0 to see if we should add or remove
	cmp	r0, #0
	push	{r0-r2}
	mov	r0, r1
	mov	r1, r2
	mov	r2, len
	bleq	RemoveCarInGrid
	blne	AddCarInGrid
	pop	{r0-r2}

	add	r1, r2, lsl #4
	add	r1, r2, lsl #2
	add	r1, r2, lsl #1
	ldr	r2, =carGrid
	strb	r0, [r2, r1]
	setCarCellEnd:
	.unreq	len
	pop	{r4, pc}

// CheckLane(gridX)
// Returns either 0 or 1 denoting whether a lane is clear for generation
.global	CheckLane
CheckLane:
	push	{r4, lr}
	x	.req	r4
	mov	x, r0
	mov	r2, #0

	//Checks 1st, 2nd, 3rd, and 4th tile in carGrid
	mov	r0, x
	mov	r1, #0
	bl	GetCarCell
	cmp	r0, #0
	movne	r2, #1
	bne	checkLaneEnd

	mov	r0, x
	mov	r1, #1
	bl	GetCarCell
	cmp	r0, #0
	movne	r2, #1
	bne	checkLaneEnd

	mov	r0, x
	mov	r1, #2
	bl	GetCarCell
	cmp	r0, #0
	movne	r2, #1
	bne	checkLaneEnd

	mov	r0, x
	mov	r1, #3
	bl	GetCarCell
	cmp	r0, #0
	movne	r2, #1
	bne	checkLaneEnd

	checkLaneEnd:
	mov	r0, r2
	.unreq	x
	pop	{r4, pc}

// GetRandCar(dir (0 == normal, 1 == down)) = carByte
// GetRandCar(r0) = r0
// Returns a car byte representing the car to be generated
GetRandCar:
	push	{r4-r6, lr}
	dir	.req	r4
	car	.req	r5
	rand	.req	r6
	mov	dir, r0
	mov	car, #0

	bl	RandomNumber
	mov	rand, r0

	//Load and check probability of motorcyle
	ldr	r1, =oneProb
	ldr	r1, [r1]
	cmp	rand, r1
	movlt	car, #12
	blt	getRandCarEnd

	//Load and check probaboloty of large tanker truck
	ldr	r1, =fourProb
	ldr	r1, [r1]
	cmp	rand, r1
	movlt	car, #14
	blt	getRandCarEnd

	//Load and check probability of 3 tile vehicle
	ldr	r1, =threeProb
	ldr	r1, [r1]
	cmp	rand, r1
	bge	twoCar

	//Pick a 3 tile vehicle to return. (We have 2 choices)
	bl	RandomNumber
	cmp	r0, #32
	movlt	car, #8
	blt	getRandCarEnd
	mov	car, #10
	b	getRandCarEnd

	//otherwise generate 2 tile vehicle
	//Pick 1 of 3 different vehicles to return
	twoCar:
	bl	RandomNumber
	cmp	r0, #22
	movlt	car, #2
	blt	getRandCarEnd
	cmp	r0, #42
	movlt	car, #4
	blt	getRandCarEnd
	mov	car, #6

	//Take direction into account, and return
	getRandCarEnd:
	cmp	dir, #1
	addeq	car, #1
	lsl	car, #4
	mov	r0, dir
	bl	GetRandVelocity
	orr	r0, car, r0
	.unreq	dir
	.unreq	car
	.unreq	rand
	pop	{r4-r6, pc}

// GetRandVelocity(dir (0 == normal, 1 == down)) = altVel[3:2]vel[1:0]
// GetRandVelocity(r0) = r0
// Returns a random velocity based on the direction of the car
GetRandVelocity:
	push	{r4, lr}
	dir	.req	r4
	mov	dir, r0
	bl	RandomNumber
	mov	r1, r0
	mov	r0, #0
	cmp	dir, #1
	beq	getDownVel

	//Check for slowest right speed
	cmp	r1, #22
	movlt	r0, #0b0100
	blt	getRandVelocityEnd
	//Check for median right speed
	cmp	r1, #42
	movlt	r0, #0b0101
	blt	getRandVelocityEnd
	//Otherwise return fastest right speed
	mov	r0, #0b0110
	b	getRandVelocityEnd

	getDownVel:

	//Check for slowest left speed
	cmp	r1, #22
	movlt	r0, #0b1001
	blt	getRandVelocityEnd

	//Check for median left speed
	cmp	r1, #42
	movlt	r0, #0b1010
	blt	getRandVelocityEnd

	//otherwise return fastest left speed
	mov	r0, #0b1011

	getRandVelocityEnd:
	.unreq	dir
	pop	{r4, pc}


