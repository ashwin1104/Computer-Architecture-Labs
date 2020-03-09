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
	lw $t0, 0($a2)				# t0 = num_rows
	lw $t1, 4($a2)				# t1 = num_cols
	lw $t2, 8($a2)				# t2 = num_colors
	add $t3, $a2, 12			# t3 = &board

	mul		$t4, $a0, $t1
	add		$t4, $t4, $a1			# $t4 = row*num_cols + col

	add		$t5, $t4, $t3			# $t5 = &board[row*num_cols + col]

	lbu		$t6, 0($t5)
	add		$t6, $t6, $a3
	rem		$t6, $t6, $t2			# t6 = (board[row*num_cols + col] + action_num) % num_colors)

	sb		$t6, 0($t5)			# board[row*num_cols + col] = t6

	pos_row:
		ble		$a0, 0, pos_col

		sub		$t5, $t4, $t1			# t5 = (row-1)*num_cols + col
		add		$t5, $t5, $t3

		lbu		$t6, 0($t5)			# t6 = board[(row-1)*num_cols + col]
		add		$t6, $t6, $a3
		rem		$t6, $t6, $t2			# t6 = (board[(row-1)*num_cols + col] + action_num) % num_colors)
		sb		$t6, 0($t5)			# board[(row-1)*num_cols + col] = t6

	pos_col:
		ble		$a1, 0, row_under_max

		sub		$t5, $t4, 1
		add		$t5, $t5, $t3			# $t5 = &board[row*num_cols + col - 1]

		lbu		$t6, 0($t5)			# $t6 = board[row*num_cols + col - 1]
		add		$t6, $t6, $a3
		rem		$t6, $t6, $t2
		sb		$t6, 0($t5)

	row_under_max:
		sub		$t0, $t0, 1			# t0 = num_rows - 1
		bge		$a0, $t0, col_under_max

		add		$t5, $t4, $t1
		add		$t5, $t5, $t3

		lbu		$t6, 0($t5)
		add		$t6, $t6, $a3
		rem		$t6, $t6, $t2
		sb		$t6, 0($t5)			# board[(row+1)*num_cols + col] = t6

	col_under_max:
		sub		$t1, $t1, 1			# t1 = num_cols - 1
		bge		$a1, $t1, finish_light

		add		$t5, $t4, 1			# t5 = row*num_cols + col + 1
		add		$t5, $t5, $t3

		lbu		$t6, 0($t5)
		add		$t6, $t6, $a3
		rem		$t6, $t6, $t2
		sb		$t6, 0($t5)			# board[row*num_cols + col + 1] = t6

		finish_light:
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
	sub		$sp, $sp, 36			# allocate enough space for vars
	sw		$ra, 0($sp)
	sw		$s0, 4($sp)
	sw		$s1, 8($sp)
	sw		$s2, 12($sp)
	sw		$s3, 16($sp)
	sw		$s4, 20($sp)
	sw		$s5, 24($sp)
	sw		$s6, 28($sp)
	sw		$s7, 32($sp)

	lw		$s0, 0($a0)			# s0 = num_rows
	lw		$s1, 4($a0)			# s1 = num_cols
	lw		$s2, 8($a0)			# s2 = num_colors

	add		$s3, $a0, 12			# s3 = &board
	add		$s4, $s3, 256			# s4 = &clue
	sub		$t0, $s1, 1			# $t0 = num_cols - 1
	move		$s5, $a2			# $s5 = next_row = row
	li		$s6, 0				# $s6 = actions = 0
	mul		$s7, $a2, $s1			# $s7 = row * num_cols
	add		$s7, $s7, $a3			# $s7 = row * num_cols + col
	bne		$t0, $a3, if_board_done
	add		$s5, $s5, 1			# $s5 = next_row = row + 1
if_board_done:
	sge		$t0, $a2, $s0			# $t0 = row >= num_rows
	sge		$t1, $a3, $s1			# $t1 = col >= num_cols
	or		$t0, $t0, $t1			# $t0 = $t0 || $t1
	beq		$t0, 0, if_clue			# if ($t0 || $t1)
	move		$a0, $s0			# $a0 = num_rows
	move		$a1, $s1			# $a1 = num_cols
	move		$a2, $s3			# $a2 = puzzle->board
	jal		solver_board_done
	j 		solve_end
if_clue:
	add		$t0, $s7, $s4			# $t0 = &clue[row * num_cols + col]
	lbu		$t0, 0($t0)
	beq		$t0, 0, loop
	move		$a2, $s5			# $a2 = next_row
	add		$a3, $a3, 1
	rem		$a3, $a3, $s1			# $a3 = (col + 1) % num_cols
	jal		solve
	j		solve_end
loop:
	bge		$s6, $s2, ret_false
	add		$t0, $a1, $s7			# $t0 = &solution[row*num_cols + col]
	sb		$s6, 0($t0)			# solution[row*num_cols + col] = actions
	sub		$sp, $sp, 16			# caller save
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)
	sw		$a3, 12($sp)
	move		$a1, $a3			# $a1 = col
	move		$t0, $a0			# $t0 = puzzle
	move		$a0, $a2			# $a0 = row
	move		$a2, $t0			# $a2 = puzzle
	move		$a3, $s6			# $a3 = actions
	jal		toggle_light
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	lw		$a3, 12($sp)
	move		$a2, $s5
	add		$a3, $a3, 1
	rem		$a3, $a3, $s1			# $a3 = (col + 1) % num_cols
	jal		solve
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	lw		$a3, 12($sp)
	add		$sp, $sp, 16			# caller restore
	bge		$v0, 1, solve_end		# if (solve(puzzle,solution, next_row, (col + 1) % num_cols))
	sub		$sp, $sp, 16			# caller save
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)
	sw		$a3, 12($sp)
	move		$a1, $a3			# $a1 = col
	move		$t0, $a0			# $t0 = puzzle
	move		$a0, $a2			# $a0 = row
	move		$a2, $t0			# $a2 = puzzle
	move		$a3, $s2			# $a3 = num_colors
	sub		$a3, $a3, $s6			# $a3 -= actions
	jal		toggle_light
	lw		$a0, 0($sp)
	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	lw		$a3, 12($sp)
	add		$sp, $sp, 16			# caller restore
	add		$t0, $a1, $s7			# $t0 = &solution[row*num_cols + col]
	sb		$0, 0($t0)			# solution[row*num_cols + col] = 0
	add		$s6, $s6, 1			# $s6 = actions += 1
	j		loop
ret_false:
	li		$v0, 0
solve_end:
	lw		$ra, 0($sp)
	lw		$s0, 4($sp)
	lw		$s1, 8($sp)
	lw		$s2, 12($sp)
	lw		$s3, 16($sp)
	lw		$s4, 20($sp)
	lw		$s5, 24($sp)
	lw		$s6, 28($sp)
	lw		$s7, 32($sp)
	add		$sp, $sp, 36			# callee restore
	jr 		$ra
