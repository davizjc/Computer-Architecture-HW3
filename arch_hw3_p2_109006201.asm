.data
str1:		.asciiz "input x: "
str2:		.asciiz "input y: "
str3:		.asciiz "result = "
newline:		.asciiz "\n"
.text



addi $s0, $zero, 0			# set x to 0
addi $s1, $zero, 0			# set y to 0
addi $s2, $zero, 0			# set ans to 0

_Main:
	li $v0, 4	 			# ready to print string
	la $a0, str1	 		# load address of string to print
	syscall	         		# print 'input x: '
	
	li $v0, 5				# scanf
	syscall
	add $s0, $zero, $v0		# store input to x
	
	li $v0, 4	 			# ready to print string
	la $a0, str2	 		# load address of string to print
	syscall	         		# print 'input y: '
	
	li $v0, 5				# scanf
	syscall
	add $s1, $zero, $v0		# store input to y
	
	add $a0, $zero, $s0		# move x to $a0 (argument)						
	jal _fib				# call procedure
	
	add $a0, $zero, $v0		# move fib(x) to $a0 (argument)
	add $a1, $zero, $s1		# move y to $a1 (argument)
	jal _re		    		# call procedure
	add $s3, $zero, $v0		# move result to s3, ans = re(fib(x),y);
	
	li $v0, 4	 	    	# ready to print string
	la $a0, str3	 		# load address of string to print
	syscall	         		# print 'result = '
	
	li $v0, 1		    	# ready to print int
	move $a0, $s3
	syscall
	j _Exit
	
_fib:
# Compute and return fibonacci number
	beqz $a0,_zero   #if n=0 return 0
	beq $a0,1,_one   #if n=1 return 1

					#Calling fib(n-1)
	sub $sp,$sp,4   #storing return address on stack
	sw $ra,0($sp)

	sub $a0,$a0,1   #n-1
	jal _fib     	#fib(n-1)
	add $a0,$a0,1

	lw $ra,0($sp)   #restoring return address from stack
	add $sp,$sp,4


	sub $sp,$sp,4   #Push return value to stack
	sw $v0,0($sp)
	
					#Calling fib(n-2)
	sub $sp,$sp,4   #storing return address on stack
	sw $ra,0($sp)

	sub $a0,$a0,2   #n-2
	jal _fib     #fib(n-2)
	add $a0,$a0,2

	lw $ra,0($sp)   #restoring return address from stack
	add $sp,$sp,4
	#---------------
	lw $s7,0($sp)   #Pop return value from stack
	add $sp,$sp,4

	add $v0,$v0,$s7 # f(n - 2)+fib(n-1)
	jr $ra # decrement/next in stack

_zero:
	li $v0,0
	jr $ra
_one:
	li $v0,1
	jr $ra
	
_re:
	ble $a1,$zero,_zero      # if y<=0, return 0
	ble $a0,$zero,_one       # if x<=0, return 1
	
	addi $sp, $sp, -16		# make space on stack
	sw $ra, 12($sp)			# save $ra on stack
	sw $s2, 8($sp)			# save $s2 on stack
	sw $s1, 4($sp)			# save $s1 on stack
	sw $s0, 0($sp)			# save $s0 on stack
	
	add $s0, $zero, $a0		# store x in $s0
	add $s1, $zero, $a1		# store y in $s1

	add $a0, $zero, $s0		# store x in $a1
	add $a1, $s1, -2		# store y-2 in $a0
	jal _re
	
	add $s2, $zero, $v0		# store value returned by fn(x-1,y) in $s2
	
	addi $a0, $s0, -5		# store x-5 in $a1
	add $a1, $zero, $s1		# store y in $a1
	jal _re
	
	add $s2, $s2, $v0		# add value returned by fn(x,y+2) 
	add $v0, $zero, $s2		# store return value in $v0
	
	lw $s0, 0($sp)			# restore $s0 from stack
	lw $s1, 4($sp)			# restore $s1 from stack
	lw $s2, 8($sp)			# restore $s2 from stack
	lw $ra, 12($sp)			# restore $ra from stack
	addi $sp, $sp, 16		# deallocate stack space
	jr $ra				    # return to caller
		
_Exit:
	li   $v0, 10
  	syscall