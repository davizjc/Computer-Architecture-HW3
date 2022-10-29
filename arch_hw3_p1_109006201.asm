

.data
str1:		.asciiz "input x: "
str2:		.asciiz "input y: "
str3:		.asciiz "input z: "
str4:		.asciiz "result = "
newline:		.asciiz "\n"
.text


addi $s0, $zero, 0		# set x to 0
addi $s1, $zero, 0		# set y to 0
addi $s2, $zero, 0		# set z to 0
addi $s3, $zero, 0		# set ans to 0

_Main:
	li $v0, 4	 		# ready to print string
	la $a0, str1	 	# load address of string to print
	syscall	         	# print 'input x: '
	
	li $v0, 5			# scanf
	syscall
	add $s0, $zero, $v0	# store input to x
	
	li $v0, 4	 		# ready to print string
	la $a0, str2	 	# load address of string to print
	syscall	         	# print 'input y: '
	
	li $v0, 5			# scanf
	syscall
	add $s1, $zero, $v0	# store input to y
	
	li $v0, 4	 		# ready to print string
	la $a0, str3	 	# load address of string to print
	syscall		        # print 'input z: '
	
	li $v0, 5			# scanf
	syscall
	add $s2, $zero, $v0	# store input to z
	
	add $a0, $zero, $s0	# move a to $a0 (argument)
	add $a1, $zero, $s1	# move b to $a1 (argument)
	jal _compare		# call procedure
	add $s7, $zero, $v0	# move result to s7 s7= compare result number 
	
	add $a0, $zero, $s7	# move _compare to $a0 (argument)
	add $a1, $zero, $s2	# move c to $a1 (argument)
	jal _smod			# call procedure
	add $s4, $zero, $v0	# move result to d  s4= q%4 or p%4
	
	add $a0, $zero, $v0	# pow of N
	jal _pow			# call procedure
	add $s5, $zero, $v0	# move result to d	s5 = DIVVVVVV
	
	add $a0, $zero, $s7	# move a to $a0 (argument)
	add $a1, $zero, $s2	# move z to $a0 (argument)
	jal _mul			# call procedure
	add $s6, $zero, $v0	# move result to d  s6 = DIVDDDD
	
	add $a0, $zero, $s5	# move a to $a0 (argument)	DIVVVVVVV
	add $a1, $zero, $s6	# move a to $a0 (argument)	DIVDDDD
	jal _divdrediv
	
	add $s3, $zero, $t3	# move result to d		s3 = ans
	
	li $v0, 4	 		# ready to print string
	la $a0, str4	 	# load address of string to print
	syscall	         	# print 'result = '
	
	li $v0, 1			# ready to print int
	move $a0, $s3
	syscall
	
	j _Exit


_divdrediv:
	div $a1, $a0		 # divide p by 4
	mfhi $t3			 # store remainder in $t2	
	add $v0, $zero, $t3	 # put return value in $v0
	jr $ra			     # return to caller

	
_compare:
	addi $sp, $sp, -8		# make space on stack
	sw $ra, 4($sp)			# save $ra on stack
	sw $s0, 0($sp)			# save $s0 on stack
	
	blt $a0,$a1,_bigger		# p < q then p+q
	jal _smaller         	# p > q then p
    	
    lw $s0, 0($sp)		    # restore $s0 from stack
    lw $ra, 4($sp)		    # restore $s0 from stack
	addi $sp, $sp, 8	    # deallocate stack space
	jr $ra			        # return to caller

_smaller: 
	add $s0, $zero, $a0		# return add p to v0
    add $v0, $zero, $s0	    # put return value in $v0
    jr $ra
    	
_bigger:
	add $s0, $a0, $a1		# return $s0 = p + q
    add $v0, $zero, $s0		# put return value in $v0
    jr $ra
	
_smod:
	addi $sp, $sp, -8		# make space on stack
	sw $ra, 4($sp)			# save $ra on stack
	sw $s0, 0($sp)			# save $s0 on stack
	
	bgt  $a0,$a1,_pisbigger #(p>q)
	jal _qisbigger 
			
	lw $s0, 0($sp)		    # restore $s0 from stack
    lw $ra, 4($sp)			# restore $ra from stack
	addi $sp, $sp, 8	    # deallocate stack space
	jr $ra	
	
_mul:	
	addi $sp, $sp, -8		# make space on stack
	sw $ra, 4($sp)			# save $ra on stack
	sw $s0, 0($sp)			# save $s0 on stack
	
	mul $a0,$a0,4        	# a0 = p*4
	add $s6,$a0,$a1         # move p*4+q to $v0
	add $v0, $zero, $s6	    # put return value in $v0		

	lw $s0, 0($sp)		    # restore $s0 from stack
    lw $ra, 4($sp)		    # restore $ra from stack
	addi $sp, $sp, 8	    # deallocate stack space
	jr $ra			        # return to caller


_pisbigger:					# p%4
	addi $t1, $zero, 4		# store 4 in $t1
	div $a0, $t1			# divide p by 4
	mfhi $t2				# store remainder in $t2	
	add $v0, $zero, $t2	    # put return value in $v0
	jr $ra			    	# return to caller
	
_qisbigger:					# q%4
	addi $t1, $zero, 4		# store 4 in $t1			
	div $a1, $t1			# divide q by 4	
	mfhi $t2		    	# store remainder in $t2		
	add $v0, $zero, $t2	    # put return value in $v0
	jr $ra			    	# return to caller

_pow:
	addi $sp, $sp, -4		# make space on stack
	sw $ra, 0($sp)			# save $ra on stack

	add $t5, $zero, $zero 	# times shifted
	addi $t4, $zero, 1		# initial number
	jal _loop
	
	add $s4, $zero, $v0		# move pow(2, (y%4)) to $s0
	beq $s4,$zero,_one   	#if t3 =0 return 1 because 2pow0 = 1 

	lw $ra, 0($sp)			# restore $ra from stack
	addi $sp, $sp, 4		# deallocate stack space
	jr $ra					# return to caller

_loop:						# for power of two
	beq $t5, $a0, _done		# see if number of times shifted = y%4
	sll $t4, $t4, 1			# shift left by one means $t4=$t4*2
	add $v0, $zero, $t4		# put return value in $v0
	addi $t5, $t5, 1		# shifted times +1
	j _loop
	
_one:
	li $v0,1
	jr $ra

_done:
	jr $ra					# return to caller
				
_Exit:
	li   $v0, 10
  	syscall
