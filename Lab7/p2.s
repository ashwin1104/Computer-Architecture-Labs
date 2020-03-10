.text

# void toggle_light(int row, int col, LightsOut* puzzle, int action_num){
#     int num_rows = puzzle->num_rows;
#     int num_cols = puzzle->num_cols;
#     int num_colors = puzzle->num_colors;
#     unsigned char* board = (puzzle-> board);
#     board[row*num_cols + col] = (board[row*num_cols + col] + action_num) % num_colors;
#     if (row > 0){
#         board[(row-1)*num_cols + col] = (board[(row-1)*num_cols + col] + action_num) % num_colors;
#     }
#     if (col > 0){
#         board[(row)*num_cols + col-1] = (board[(row)*num_cols + col-1] + action_num) % num_colors;
#     }
#
#     if (row < num_rows - 1){
#         board[(row+1)*num_cols + col] = (board[(row+1)*num_cols + col] + action_num) % num_colors;
#     }
#
#     if (col < num_cols - 1){
#         board[(row)*num_cols + col+1] = (board[(row)*num_cols + col+1] + action_num) % num_colors;
#     }
# }
# $a0 row
# $a1 col
# $a2 puzzle
# $a3 action_num
.globl toggle_light
toggle_light:
	lw $t0, 0($a2)				# load in num_rows, num_cols, num_colors
	lw $t1, 4($a2)
	lw $t2, 8($a2)
	add $t3, $a2, 12 			# t3 is board

	mul $t4, $a0, $t1			# t4 = row*num_cols
	add $t4, $t4, $a1			# t4 = row*num_cols + col

	add $t5, $t4, $t3			# t5 = &board[row*nums_cols + col]
	lbu $t6, 0($t5)				# t6 = board[row*nums_cols+col]

	add $t6, $t6, $a3			# t6 += action_num
	rem $t6, $t6, $t2			# t6 % num_colors

	sb $t6, 0($t5)				# board[row*nums_cols+col] = t6

	pos_row:
		ble		$a0, $zero, pos_col

		sub		$t7, $t4, $t1			# t7 = (row-1)*num_cols + col
		add		$t5, $t7, $t3
		lbu		$t6, 0($t5)			# t6 = board[(row-1)*num_cols + col]

		add		$t6, $t6, $a3
		rem		$t6, $t6, $t2			# t6 = (board[(row-1)*num_cols + col] + action_num) % num_colors)

		sb		$t6, 0($t5)			# board[(row-1)*num_cols + col] = t6

	pos_col:
		ble		$a1, $zero, row_under_max

		sub		$t7, $t4, 1				# t7 = row*num_cols + col - 1
		add		$t5, $t7, $t3			# t5 = &board[row*num_cols + col - 1]
		lbu		$t6, 0($t5)			# t6 = board[row*num_cols + col - 1]

		add		$t6, $t6, $a3			# t6 + action_num
		rem		$t6, $t6, $t2			# t6 % num_colors
		sb		$t6, 0($t5)				# storing t6 into board[...]

	row_under_max:
		sub		$t7, $t0, 1			# t7 = num_rows - 1
		bge		$a0, $t7, col_under_max			# if row >= num_rows - 1 -> col_under_max

		add		$t7, $t4, $t1
		add		$t5, $t7, $t3
		lbu		$t6, 0($t5)			# t6 = board[(row-1)*num_cols + col]

		add		$t6, $t6, $a3			# t6 + action_num
		rem		$t6, $t6, $t2			# t6 % num_colors
		sb		$t6, 0($t5)				# storing t6 into board[...]

	col_under_max:
		sub		$t7, $t1, 1			# t7 = num_cols - 1
		bge		$a1, $t7, return_light			# if col >= num_cols - 1 -> return_light

		add		$t7, $t4, 1
		add		$t5, $t7, $t3
		lbu		$t6, 0($t5)			# t6 = board[(row-1)*num_cols + col]

		add		$t6, $t6, $a3			# t6 + action_num
		rem		$t6, $t6, $t2			# t6 % num_colors
		sb		$t6, 0($t5)				# storing t6 into board[...]

	return_light:
		jr $ra


# bool solve(LightsOut* puzzle, unsigned char* solution, int row, int col){
#     int num_rows = puzzle->num_rows;
#     int num_cols = puzzle->num_cols;
#     int num_colors = puzzle->num_colors;
#     int next_row = ((col == num_cols-1) ? row + 1 : row);
#     if (row >= num_rows || col >= num_cols) {
#          return board_done(num_rows,num_cols,puzzle->board);
#     }
#
#     if (puzzle->clue[row*num_cols + col]) {
#          return solve(puzzle,solution, next_row, (col+1) % num_cols);
#     }
#
#     for(char actions = 0; actions < num_colors; actions++) {
#         solution[row*num_cols + col] = actions;
#         toggle_light(row, col, puzzle, actions);
#         if (solve(puzzle,solution, next_row, (col + 1) % num_cols)) {
#             return true;
#         }
#         toggle_light(row, col, puzzle, num_colors - actions);
#         solution[row*num_cols + col] = 0;
#     }
#     return false;
# }
# $a0 puzzle
# $a1 solution
# $a2 row
# $a3 col
.globl solve
solve:
	sub		$sp, $sp, 40							# allocating enough memory
	sw		$ra, 0($sp)								# store return register
	sw		$s0, 4($sp)
	sw		$s1, 8($sp)
	sw		$s2, 12($sp)
	sw		$s3, 16($sp)
	sw		$s4, 20($sp)
	sw		$s5, 24($sp)
	sw		$s6, 28($sp)
	sw		$s7, 32($sp)							# store 8 save registers

initialize:
	add $s0, $a0, 0									# s0 = &puzzle
	lw $s1, 0($a0)									# s1 = num_rows
	lw $s2, 4($a0)									# s2 = num_cols
	lw $s3, 8($a0)									# s3 = num_colors

	move $s4, $0										# actions = 0
	move $s5, $a1										# s5 = solution
	move $s6, $a2										# s6 = row
	move $s7, $a3										# s7 = col

	sub $t1, $s2, 1									# t1 = num_cols - 1
	bne $s7, $t1, col_not_equal		# if col != num_cols-1 -> ...

col_equal:
	add $t0, $s6, 1									# next_row = row + 1
	j row_col_greater

col_not_equal:
	move $t0 $s6										# next_row = row

row_col_greater:
	sw $t0, 36($sp)
	bge $s6, $s1, board_return
	bge $s7, $s2, board_return
	j solve_return

board_return:
	move $a0, $s1
	move $a1, $s2
	add $a2, $s0, 12
	jal solver_board_done
	j solved

solve_return:
	add $t1, $s0, 268
	mul $t2, $s6, $s2
	add $t2, $t2, $s7
	add $t2, $t2, $t1
	lbu $t2, 0($t2)
	beq $t2, $0, solve_for_loop

s_second_if_true:
	move $a0, $s0
	move $a1, $s5
	lw $a2, 36($sp)
	add $a3, $s7, 1
	rem $a3, $a3, $s2
	jal solve
	j solved

solve_for_loop:
	bge $s4, $s3, false_solve
	mul $t0, $s6, $s2
	add $t0, $t0, $s7
	add $t0, $t0, $s5
	sb $s4, 0($t0)
	move $a0, $s6
	move $a1, $s7
	move $a2, $s0
	move $a3, $s4
	jal toggle_light

true_check:
	move $a0, $s0
	move $a1, $s5
	lw $a2, 36($sp)
	add $a3, $s7, 1
	rem $a3, $a3, $s2
	jal solve
	bne $v0, $0, true_solve
	j finish_for_loop

true_solve:
	li $v0, 1
	j solved

finish_for_loop:
	move $a0, $s6
	move $a1, $s7
	move $a2, $s0
	move $a3, $s3
	sub $a3, $a3, $s4
	jal toggle_light
	mul $t0, $s6, $s2
	add $t0, $t0, $s7
	add $t0, $t0, $s5
	sb $0, 0($t0)

for_incr_solve:
	add $s4, $s4, 1
	j solve_for_loop

false_solve:
	li $v0, 0
	j solved

solved:
	lw		$ra, 0($sp)
	lw		$s0, 4($sp)
	lw		$s1, 8($sp)
	lw		$s2, 12($sp)
	lw		$s3, 16($sp)
	lw		$s4, 20($sp)
	lw		$s5, 24($sp)
	lw		$s6, 28($sp)
	lw		$s7, 32($sp)
	add		$sp, $sp, 40
	jr $ra
