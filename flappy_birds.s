
.data
	displayAddress:	.word	0x10008000
.text
	lw $t0, displayAddress	# $t0 stores the base address for display
	li $t1, 0x99ccff	# $t1 stores the sky colour code
	li $t2, 0xffd000	# $t2 stores the bird colour
	add $t3, $zero, $zero 	#counter variable
	li $t4, 0x008900	#pipe colors
	add $t6, $zero, $t0 	#this is the actual address use
	add $t7, $zero, $t6
	add $t7, $t7, 1920
main: 
	jal loop
	li $a0, 3000
	li $v0, 32
	syscall
	
	lw $t0, displayAddress
	add $t6, $zero, $t0
	add $t6, $t6, 90
	
	j topPipe
	
	
loop:	beq $t3, 4096, middle 	#this makes the screen blue
	sw $t1, 0($t0)
	add $t0, $t0, 4
	add $t3, $t3, 4
	j loop

middle:	#lw $t0, displayAddress
	#add $t0, $t0, 1920
	#add $t6, $t6, 1920
	
bird: 	sw $t2, 0($t7)		#this makes the bird
	sw $t2, -128($t7)
	sw $t2, 128($t7)
	sw $t2, 4($t7)
	sw $t2, 8($t7)
	sw $t2, -120($t7)
	sw $t2, 136($t7)
	sw $t2, 12($t7)

	lw $t0, displayAddress
	add $t6, $zero, $t0
	add $t6, $t6, 92
	
topPipe:
	li $t3, 0
	
Outer:	beq $t3, 10, lowerPipe
		li $t5, 0
Inner:		beq $t5, 3, Incre
			sw $t4, 0($t6)
			add $t5, $t5, 1
			add $t6, $t6, 4
			j Inner
Incre:		add $t6, $t6, 116
		add $t3, $t3, 1
		j Outer
	

lowerPipe:
	add $t6, $t6, 768
	li $t3, 0
	
OuterLower:	beq $t3, 16, Exit
		li $t5, 0
InnerLower:		beq $t5, 3, IncreLower
			sw $t4, 0($t6)
			add $t5, $t5, 1
			add $t6, $t6, 4
			j InnerLower
IncreLower:		add $t6, $t6, 116
		add $t3, $t3, 1
		j OuterLower


Exit:
	li $v0, 10 # terminate the program gracefully
	syscall

