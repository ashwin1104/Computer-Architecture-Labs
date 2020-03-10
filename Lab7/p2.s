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
	sub		$sp, $sp, 40
	sw		$ra, 0($sp)
	sw		$s0, 4($sp)
	sw		$s1, 8($sp)
	sw		$s2, 12($sp)
	sw		$s3, 16($sp)
	sw		$s4, 20($sp)
	sw		$s5, 24($sp)
	sw		$s6, 28($sp)
	sw		$s7, 32($sp)

	add $s0, $a0, 0
	lw $s1, 0($s0)
	add $s2, $a0, 4
	lw $s2, 0($s2)
	add $s3, $a0, 8
	lw $s3, 0($s3)

	move $s4, $0
	move $s5, $a1
	move $s6, $a2
	move $s7, $a3
	move $t0, $s6
	sub $t1, $s2, 1
	bne $s7, $t1, s_first_if

s_equal:
	add $t0, $t0, 1

s_first_if:
	sw $t0, 36($sp)
	bge $s6, $s1, s_return_if
	bge $s7, $s2, s_return_if
	j s_second_if

s_return_if:
	move $a0, $s1
	move $a1, $s2
	add $a2, $s0, 12
	jal board_done
	j s_end

s_second_if:
	add $t1, $s0, 268
	mul $t2, $s6, $s2
	add $t2, $t2, $s7
	add $t2, $t2, $t1
	lbu $t2, 0($t2)
	beq $t2, $0, s_for
	move $a0, $s0
	move $a1, $s5
	lw $a2, 36($sp)
	add $a3, $s7, 1
	rem $a3, $a3, $s2
	jal solve
	j s_end

s_second_if_true:
	move $a0, $s0
	move $a1, $s5
	lw $a2, 36($sp)
	add $a3, $s7, 1
	rem $a3, $a3, $s2
	jal solve
	j s_end

s_for:
	bge $s4, $s3, s_afterloop
	mul $t0, $s6, $s2
	add $t0, $t0, $s7
	add $t0, $t0, $s5
	sb $s4, 0($t0)
	move $a0, $s6
	move $a1, $s7
	move $a2, $s0
	move $a3, $s4
	jal toggle_light

s_for_if:
	move $a0, $s0
	move $a1, $s5
	lw $a2, 36($sp)
	add $a3, $s7, 1
	rem $a3, $a3, $s2
	jal solve
	bne $v0, $0, s_for_true
	j s_for_cont

s_for_true:
	li $v0, 1
	j s_end

s_for_cont:
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

s_for_inc:
	add $s4, $s4, 1
	j s_for

s_afterloop:
	li $v0, 0
	j s_end

s_end:
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
