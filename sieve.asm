# Code adapted from http://www.marcell-dietl.de/downloads/eratosthenes.s
	
	.data			# the data segment to store global data
space:	.asciiz	" "		# whitespace to separate prime numbers

	.text			# the text segment to store instructions
	.globl 	main		# define main to be a global label
main:	li	$s0, 0x11	# initialize $s0 with ones
	li	$t9, 200	# find prime numbers from 2 to $t9
	addi	$s2, $sp, 0	# backup bottom of stack address in $s2
	li	$t0, 1		# reset counter variable to 1

outer:	addi  	$t0, $t0, 1	# increment counter variable (start at 2)
	sll  	$t1, $t0, 1	# multiply $t0 by 2 and save to $t1	
	bne 	$t1, $t9, check	
	j	print		# start printing prime numbers when $t1 > $t9

check:	addi	$t2, $s2, 0	# save the bottom of stack address to $t2
	addi	$t3, $t0, 1
	sub	$t2, $t2, $t3	# subtract them from bottom of stack address

	lb	$t3, 2($t2)	# load the content into $t3

	beq	$t3, $s0, outer	# only 1's? go back to the outer loop

inner:	addi	$t2, $s2, 0	# save the bottom of stack address to $t2
	addi 	$t3, $t1, 1
	sub	$t2, $t2, $t3	# subtract them from bottom of stack address
	
	sb	$s0, 2($t2)	# store 1's -> it's not a prime number!	

	add	$t1, $t1, $t0	# do this for every multiple of $t0
	blt	$t1, $t9, inner
	
	j	outer
	
print:	li	$t0, 2		# reset counter variable to 1

skip:	addi	$t2, $s2, 0	# save the bottom of stack address to $t2
	addi	$t3, $t0, 1
	sub	$t2, $t2, $t3	# subtract them from bottom of stack address
	addi	$t2, $t2, 2	# add 2 words - we started counting at 2!

	lb	$t3, ($t2)	# load the content into $t3	
	
	addi	$t0, $t0, 1	# increment counter
	beq	$t3, $s0, skip	# only 1's? go back to count loop	
	addi	$t3, $s2, 0	# save the bottom of stack address to $t3

	sub	$t3, $t3, $t2	# substract higher from lower address (= bytes)
	subi	$t3, $t3, 1	# divide by 4 (bytes) = distance in words
	addi	$t3, $t3, 2	# add 2 (words) = the final prime number!

	li	$v0, 1		# system code to print integer
	addi	$a0, $t3, 0	# the argument will be our prime number in $t3
	syscall			# print it!

	li	$v0, 4		# system code to print string
	la	$a0, space	# the argument will be a whitespace
	syscall			# print it!


	bne	$t0, $t9, skip	# repeat until $t0 = $t9

exit:	li	$v0, 10		# set up system call 10 (exit)
	syscall	