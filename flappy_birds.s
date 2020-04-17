#####################################################################
#
# CSC258H5S Winter 2020 Assembly Programming Project
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
#####################################################################


.data
	displayAddress:	.word	0x10008000
	startingPipeOffset: .word 96
	initTopPipeHeight: .word 6
	initBottomPipeHeight: .word 20
	ad1:	.word 	0xffff0000
	ad2:	.word 	0xffff0004
.globl main
.text

lw $t8, startingPipeOffset # Initial offset that would be updated per frame
lw $s5, initTopPipeHeight
lw $s6, initBottomPipeHeight
li $a3, 1920

main:
	# Initialize registers for render
	lw $t0, displayAddress	# $t0 stores the base address for display
	li $t1, 0x99ccff	    # $t1 stores the sky colour code
	li $s1, 0xffd000	    # $t2 stores the bird colour
	add $t3, $zero, $zero 	# counter variable
	li $t4, 0x008900	    # pipe colors
	add $t6, $zero, $t0 	# this is the actual address use
	lw $t7, displayAddress
	add $t7, $t7, $a3       # init bird position
	
	jal UPDATE_HORIZONTAL_OFFSET		# update offset
	jal USER_INPUT
	jal BIRD_FLY	# update bird postion	
	jal CHECK_COLLISION
	beq	$v1, 1, EXIT	# if $v1 == 1 then collision => Exit
	li $v0, 0
	
	

	# push display addr & move stack ptr to new top
	addi $sp, $sp, -4
	sw $t6, 0($sp)
	# render background and pipes
	jal DRAW_SCREEN
	lw $t6, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $t7, 0($sp)
	# render bird
	jal RENDER_BIRD
	lw $t7, 0($sp)
	addi $sp, $sp, 4
	
	# sleep for 100 ms
	li $v0, 32
	li $a0, 33
	syscall
	
	j main
	j EXIT

UPDATE_HORIZONTAL_OFFSET:
	subi $t8, $t8, 4
	blt	$t8, 0, wrapOffset	# if $t8 < $t1 then wrapOffset
	j TERMINATE_FUNC
	
	wrapOffset:
		li $t8, 124

		# store return address onto the stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal GENERATE_RANDOM_HEIGHT
		# load the return addr back from original func call from main
		lw $ra, 0($sp)
		addi $sp, $sp, 4

		j TERMINATE_FUNC
	

CHECK_COLLISION:
	move $a2, $a3
	addi $a2, $a2, 8

	li $s2, 128
	div	$t8, $s2 # $t8 / 128
	mfhi $s7     # $s7 = $t8 mod $t1 

	move $v1, $a2
	div $v1, $s2
	mfhi $v1
	
	bgt	$s7, $v1, collisionFalse	# if $s7 > bird: false
	addi $s7, $s7, 12
	blt	$s7, $v1, collisionFalse	# if $s7 + 3 pixels < bird then false

	li $t9, 128
	mult $s5, $t9 # h * 128
	mflo $s7
	add $t9, $t8, $s7
	addi $t9, $t9, 12

	bgt	$t9, $a2, collisionTrue	# if bottomRightTopPipe >= bird then true
	
	add $t9, $t9, 768
	move $s7, $a2
	bgt $s7, $t9, collisionTrue # if bird >= topLeftBottomPipe then true

	j collisionFalse
	
	
	collisionTrue:
		li $v1, 1
		j TERMINATE_FUNC
	
	collisionFalse:
		li $v1, 0
		j TERMINATE_FUNC


BIRD_FLY:
	beq $v1, 0, goDown
	
	goUp:
		ble $a3, 128, boundryExit
		subi $a3, $a3, 384
		j TERMINATE_FUNC
	
	goDown:
		bge	$a3, 3968, boundryExit	# if $t7 >= $t1 then target
		addi $a3, $a3, 128
		j TERMINATE_FUNC
	
	boundryExit:
		j TERMINATE_FUNC

TERMINATE_FUNC:
	jr $ra

GENERATE_RANDOM_HEIGHT:
	addi $a1, $zero, 27
	li $v0, 42
	syscall
	
	add $s5, $zero, $a0

	li $s6, 32
	sub $s6, $s6, $s5	# bottom half of pipe
	j TERMINATE_FUNC


PIPE_DRAW_LOOP:	
	# load argument from stack
	lw $a1, 0($sp)
	addi $sp, $sp, 4

	mainLoop:
		beq $t3, $a1, TERMINATE_FUNC
		li $t5, 0

	innerLoop:
		beq $t5, 3, incrementVars
		sw $t4, 0($t6)
		add $t5, $t5, 1
		add $t6, $t6, 4
		j innerLoop
		
	incrementVars:
		add $t6, $t6, 116
		add $t3, $t3, 1
		j mainLoop

	
RENDER_BIRD: 	
	lw $t7, 0($sp)
	addi $sp, $sp, 4
	
	sw $s1, 0($t7)		# this makes the bird
	sw $s1, -128($t7)
	sw $s1, 128($t7)
	sw $s1, 4($t7)
	sw $s1, 8($t7)
	sw $s1, -120($t7)
	sw $s1, 136($t7)
	sw $s1, 12($t7)
	
	addi $sp, $sp, -4
	lw $t7, 0($sp)
	
	jr $ra
	
DRAW_SCREEN:	
	lw $t6, 0($sp)
	addi $sp, $sp, 4
	
	beq $t3, 4096, DRAW_TOP_PIPE
 	# this makes the screen blue
	sw $t1, 0($t0)
	add $t0, $t0, 4
	add $t3, $t3, 4

	addi $sp, $sp, -4
	sw $t6, 0($sp)
	j DRAW_SCREEN

DRAW_TOP_PIPE:
	# store return addr for original func call to stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $t0, displayAddress
	add $t6, $zero, $t0
	# starting point for pipe (92 initally)
	add $t6, $t6, $t8 # t8 is offset for pipes for each frame
	
	li $t3, 0
	# save top pipe height on stack for func call
	move $a1, $s5

	addi $sp, $sp, -4
	sw $a1, 0($sp)

	jal PIPE_DRAW_LOOP  # jump to PIPE_DRAW_LOOP and save position to $ra


DRAW_BOTTOM_PIPE:
	add $t6, $t6, 768
	li $t3, 0

	# save bottom pipe height on stack for draw func call
	move $a1, $s6
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	
	jal	PIPE_DRAW_LOOP	# jump to PIPE_DRAW_LOOP and save position to $ra


RETURN:
	# load the return addr back from original func call from main
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	addi $sp, $sp, -4
	sw $t6, 0($sp)
	jr $ra


# Handle User Input
USER_INPUT:
	lw $s2, 0xffff0000
	bne $s2, 0, secondRegisterCheck
	li $v1, 0
	j TERMINATE_FUNC
	
	secondRegisterCheck: 
		lw $s3, 0xffff0004
		beq $s3, 102, setValue
		li $v1, 0
		j TERMINATE_FUNC
	setValue:	
		li $v1, 1
		j TERMINATE_FUNC

EXIT:
	li $v0, 10 # terminate the program gracefully
	syscall
