# Code adapted from http://www.marcell-dietl.de/downloads/eratosthenes.s
	
	.data			# the data segment to store global data
space:	.asciiz	" "		# whitespace to separate prime numbers

	.text			# the text segment to store instructions
	.globl 	main		# define main to be a global label
main:	li	$s0, 0x11111111	# initialize $s0 with ones
	li	$s1, 0x00000000	# initialize $s1 with zeroes
	li	$t9, 200	# find prime numbers from 2 to $t9
	addi	$s2, $sp, 0	# backup bottom of stack address in $s2
	li	$t0, 1		# reset counter variable to 1

outer:	addi  	$t0, $t0, 1	# increment counter variable (start at 2)
	#mul	$t1, $t0, 2	# multiply $t0 by 2 and save to $t1
	sll  	$t1, $t0, 1
	blt 	$t1, $t9, check
	#bgt	$t1, $t9, print	# start printing prime numbers when $t1 > $t9
	j	print

check:	addi	$t2, $s2, 0	# save the bottom of stack address to $t2
	#mul	$t3, $t0, 4	# calculate the number of bytes to jump over
	sll	$t3, $t0, 2
	sub	$t2, $t2, $t3	# subtract them from bottom of stack address
	addi	$t2, $t2, 8	# add 2 words - we started counting at 2!

	lw	$t3, ($t2)	# load the content into $t3

	beq	$t3, $s0, outer	# only 1's? go back to the outer loop

inner:	addi	$t2, $s2, 0	# save the bottom of stack address to $t2
	#mul	$t3, $t1, 4	# calculate the number of bytes to jump over
	sll 	$t3, $t1, 2
	sub	$t2, $t2, $t3	# subtract them from bottom of stack address
	addi	$t2, $t2, 8	# add 2 words - we started counting at 2!


	sw 	$s0, ($t2)	# store 1's -> it's not a prime number!	

	add	$t1, $t1, $t0	# do this for every multiple of $t0
	#bgt	$t1, $t9, outer	# every multiple done? go back to outer loop
	blt	$t1, $t9, inner
	
	#b	inner		# some multiples left? go back to inner loop
	j	outer
	
print:	li	$t0, 1		# reset counter variable to 1
count:	addi	$t0, $t0, 1	# increment counter variable (start at 2)

	blt	$t0, $t9, skip	# make sure to exit when all numbers are done
	
	li	$v0,10		# set up system call 10 (exit)
	syscall	

skip:	addi	$t2, $s2, 0	# save the bottom of stack address to $t2
	#mul	$t3, $t0, 4	# calculate the number of bytes to jump over
	sll	$t3, $t0, 2
	sub	$t2, $t2, $t3	# subtract them from bottom of stack address
	addi	$t2, $t2, 8	# add 2 words - we started counting at 2!

	lw	$t3, ($t2)	# load the content into $t3
	beq	$t3, $s0, count	# only 1's? go back to count loop

	addi	$t3, $s2, 0	# save the bottom of stack address to $t3

	sub	$t3, $t3, $t2	# substract higher from lower address (= bytes)
	srl	$t3, $t3, 2	# divide by 4 (bytes) = distance in words
	addi	$t3, $t3, 2	# add 2 (words) = the final prime number!

	li	$v0, 1		# system code to print integer
	addi	$a0, $t3, 0	# the argument will be our prime number in $t3
	syscall			# print it!

	li	$v0, 4		# system code to print string
	la	$a0, space	# the argument will be a whitespace
	syscall			# print it!

	#ble	$t0, $t9, count	# take loop while $t0 <= $t9
	j 	count

#exit:	li	$v0,10		# set up system call 10 (exit)
#	syscall	
