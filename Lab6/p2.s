.text

# void matrix_mult(int *matr_a, int *matr_b, int *output, unsigned int width) {
#     for (int i = 0; i < width; i++) {
#         for (int j = 0; j < width; j++) {
#             output[i*width + j] = 0;
#             for (int k = 0; k < width; k++) {
#                 output[i*width + j] += matr_a[i*width + k] * matr_b[k*width + j];
#             }i*width + j
#         }
#     }
# }
#
# // a0: int *matr_a
# // a1: int *matr_b
# // a2: int *output
# // a3: unsigned int width

.globl matrix_mult
matrix_mult:
	li $t0 0			# i = 0
	li $t1 0			# j = 0
	li $t2 0			# k = 0
	li $t3 0			# 4(i*width + j) = 0
	li $t4 0			# 4(i*width + k) = 0
	li $t5 0			# 4(k*width + j) = 0
	li $t6 0			# matr_a*martr_b = 0
	li $t7 0			# $t6 + $t3

for_1:
	bge $t0, $a3, end			# !(i < width)
	j for_2

for_2:
	bge $t1, $a3, for_1_inc			# !(j < width)

	mul $t3, $t0, $a3						# t3 = i*width
	add $t3, $t3, $t1						# t3 = i*width + j
	add $t3, $t3, $t3						# t3 = 2*t3
	add $t3, $t3, $t3						# t3 = 2*t3 = 4(i*width+j)

	add $t3, $t3, $a2						# t3 = &output[0] + t3

	sw $0, 0($t3)										# output[i*width+j] = 0

	j for_3

for_3:
	bge $t2, $a3, for_2_inc			# !(k < width)

	mul $t4, $t0, $a3						# t4 = i*width
	add $t4, $t4, $t2						# t4 = t4 + k = i*width + k
	add $t4, $t4, $t4						# t4 *= 2
	add $t4, $t4, $t4						# t4 = 2*t4 = 4(i*width + k)
	add $t4, $t4, $a0						# t4 = &matr_a[0] + t4

	mul $t5, $t2, $a3						# t5 = k*width
	add $t5, $t5, $t1						# t5 = t4 + j = k*width + j
	add $t5, $t5, $t5						# t5 *= 2
	add $t5, $t5, $t5						# t5 = 2*t5 = 4(k*width + j)
	add $t5, $t5, $a1						# t5 = &matr_b[0] + t5

	lw $t6, 0($t4)
	lw $t7, 0($t5)

	mul $t6, $t6, $t7						# t6 = matr_a[i*width+k]*matr_b[k*width + j]
	lw $t7, 0($t3)

	add $t6, $t6, $t7						# t7 = t6 + output[i*width+j]
	sw $t6, 0($t3)							# output[i*width+j] = t7

	j for_3_inc

for_1_inc:
	li $t1 0			# j = 0
	addi	$t0, $t0, 1			# i += 1
	j	for_1				# jump to for_1

for_2_inc:
	li $t2 0			# k = 0
	addi $t1, $t1, 1			# j += 1
	j for_2

for_3_inc:
	addi $t2 $t2 1			# k += 1
	j for_3

end:
	jr	$ra


# #define MAX_WIDTH 100
# int working_matrix[MAX_WIDTH*MAX_WIDTH];

# void markov_chain(int *state, int *transitions, unsigned int width, int times) {
#     for (int i = 0; i < times; i++) {
#         matrix_mult(state, transitions, working_matrix, width);
#         copy(state, working_matrix);
#     }
# }
#
# // a0: int *state
# // a1: int *transitions
# // a2: unsigned int width
# // a3: int times

.globl markov_chain
markov_chain:
	sub $sp $sp 20					# allocate stack size 20
	sw $ra, 0($sp)					# store givens and ra in stack pointer
	sw $s0, 4($sp)
	move $s0, $a0
	sw $s1, 8($sp)
	move $s1, $a1
	sw $s2, 12($sp)
	move $s2, $a2
	sw $s4, 16($sp)					# store i in stack pointer
	li $s4, 0								# initialize i to 0

	move $s3, $a3						# store width in s3

markov_for:
	bge $s4, $s3, markov_end	# if i < width continue
	move $a0, $s0							# store state
	move $a1, $s1							# store transition
	la $a2, working_matrix		# load address of output matrix
	move $a3, $s2							# store width
	jal matrix_mult

	move $a0, $s0							# store state
	la $a1, working_matrix		# load address of output matrix
	move $a2, $s2							# store width
	jal copy

markov_for_incr:
	add $s4, $s4, 1		# i++
	j markov_for

markov_end:
	lw $ra, 0($sp)              # reset stack
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s4, 16($sp)
	add $sp, $sp, 20            # reset pointer
	jr	$ra
