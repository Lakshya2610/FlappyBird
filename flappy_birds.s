.data
	displayAddress:	.word	0x10008000
.text
	lw $t0, displayAddress	# $t0 stores the base address for display
	li $t1, 0x99ccff	    # $t1 stores the sky colour code
	li $t2, 0xffd000	    # $t2 stores the bird colour
	add $t3, $zero, $zero 	# counter variable
	li $t4, 0x008900	    # pipe colors
	add $t6, $zero, $t0 	# this is the actual address use
	add $t7, $zero, $t6
	add $t7, $t7, 1920 	    # for bird
	
main: 
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
	
	li $v0, 32
	li $a0, 1000
	syscall
	
	
	j main
	j EXIT

TERMINATE_FUNC:
	jr $ra



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
	
	sw $t2, 0($t7)		# this makes the bird
	sw $t2, -128($t7)
	sw $t2, 128($t7)
	sw $t2, 4($t7)
	sw $t2, 8($t7)
	sw $t2, -120($t7)
	sw $t2, 136($t7)
	sw $t2, 12($t7)
	
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
	j DRAW_SCREEN

DRAW_TOP_PIPE:
	# store return addr for original func call to stack
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $t0, displayAddress
	add $t6, $zero, $t0
	# starting point for pipe (92 initally)
	add $t6, $t6, 92
	li $t3, 0

	# save 10 on stack for func call
	li $a1, 10
	addi $sp, $sp, -4
	sw $a1, 0($sp)

	jal PIPE_DRAW_LOOP  # jump to PIPE_DRAW_LOOP and save position to $ra


DRAW_BOTTOM_PIPE:
	add $t6, $t6, 768
	li $t3, 0

	# save 16 on stack for draw func call
	li $a1, 16
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


EXIT:
	li $v0, 10 # terminate the program gracefully
	syscall
