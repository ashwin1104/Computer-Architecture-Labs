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
