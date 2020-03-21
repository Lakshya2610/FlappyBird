
.data
	displayAddress:	.word	0x10008000
.text
	lw $t0, displayAddress	# $t0 stores the base address for display
	li $t1, 0x99ccff	# $t1 stores the sky colour code
	li $t2, 0xffd000	# $t2 stores the bird colour
	add $t3, $zero, $zero 	#counter variable
	li $t4, 0x008900	#pipe colors
	add $t6, $zero, $zero 	#used for animation
	
	
loop:	beq $t3, 4096, middle 	#this makes the screen blue
	sw $t1, 0($t0)
	add $t0, $t0, 4
	add $t3, $t3, 4
	j loop

middle:	lw $t0, displayAddress
	add $t0, $t0, 1920

	
bird: 	sw $t2, 0($t0)		#this makes the bird
	sw $t2, -128($t0)
	sw $t2, 128($t0)
	sw $t2, 4($t0)
	sw $t2, 8($t0)
	sw $t2, -120($t0)
	sw $t2, 136($t0)
	sw $t2, 12($t0)

	lw $t0, displayAddress
	add $t0, $t0, 92
topPipe:
	#sw $t4, 100($t0)
	#sw $t4, 96($t0)
	#sw $t4, 92($t0)
	#sw $t4, 228($t0)
	#sw $t4, 224($t0)
	#sw $t4, 220($t0)
	
	li $t3, 0
	
Outer:	beq $t3, 10, lowerPipe
		li $t5, 0
Inner:		beq $t5, 3, Incre
			sw $t4, 0($t0)
			add $t5, $t5, 1
			add $t0, $t0, 4
			j Inner
Incre:		add $t0, $t0, 116
		add $t3, $t3, 1
		j Outer
	

lowerPipe:
	add $t0, $t0, 768
	li $t3, 0
	
OuterLower:	beq $t3, 16, Exit
		li $t5, 0
InnerLower:		beq $t5, 3, IncreLower
			sw $t4, 0($t0)
			add $t5, $t5, 1
			add $t0, $t0, 4
			j InnerLower
IncreLower:		add $t0, $t0, 116
		add $t3, $t3, 1
		j OuterLower
	
animation: 
		li $t3, 0
		lw $t0, displayAddress
		beq $t3, $t6, nothing
			add $t3, $t3, 1
			add $t0, $t0, -4
		jr $ra

nothing: 	jr $ra

Exit:
	li $v0, 10 # terminate the program gracefully
	syscall

main: 
	j loop
	add $t6, $t6, 1
	addi $a0, $zero, 1000
	addi $v0, $zero, 32
	syscall
	j loop
	
	
