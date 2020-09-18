.text

# // part 1 p1.s
# unsigned char find_payment(TreeNode* trav) {
# 	// Base case
# 	if (trav == NULL) {
# 		return 0;
# 	}
# 	// Recurse once for each child
# 	unsigned char payment_left = find_payment(trav->left);
# 	unsigned char payment_center = find_payment(trav->center);
# 	unsigned char payment_right = find_payment(trav->right);
# 	unsigned char value = payment_left + payment_center + payment_right + trav->value;
# 	return value / 2;
# }

.globl find_payment
find_payment:
	beq $a0, $zero, null_check			# if trav is null go to null_check

setup_payment:
	sub $sp, $sp, 36								# allocate memory necessary with stack pointer
																	# store all necessary save registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	move $s0, $a0										# let s0 store contents of trav
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)

start_payment:
	li $s5, 0												# set future v0 to 0

	lw $s1, 0($s0)									# store trav->left into s1
	move $a0, $s1										# store trav->left into argument
	jal find_payment								# recursive call with trav->left

	add $s5, $s5, $v0								# add return value from above call to s5
	lw $s2, 4($s0)									# store trav->current into s2
	move $a0, $s2										# store trav->current into argument
	jal find_payment								# recursive call with trav->current

	add $s5, $s5, $v0								# same thing
	lw $s3, 8($s0)
	move $a0, $s3
	jal find_payment

	add $s5, $s5, $v0
	lb $s4, 12($s0)									# store trav->value into s4
	add $s5, $s5, $s4								# add trav->value to s5

	div $s5, $s5, 2									# divide s5 by 2
	move $v0, $s5										# store s5 (ans) into v0 (return register)

finish_payment:
	lw $ra, 0($sp)									# reallocate memory by loading back every register
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 36
	jr $ra

null_check:
	li $v0, 0
	jr $ra				# return 0 and go to return address
