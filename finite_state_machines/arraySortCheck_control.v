
module arraySortCheck_control(sorted, done, load_input, load_index, select_index, go, inversion_found, end_of_array, zero_length_array, clock, reset);
	output sorted, done, load_input, load_index, select_index;
	input go, inversion_found, end_of_array, zero_length_array;
	input clock, reset;

	wire  sGarbage, sStart, sCheckStart, sCheckSelect, sSorted, sUnsorted;

	wire sNextGarbage = (sGarbage & ~go) | reset;
	wire sNextStart = ((sStart | sGarbage | sSorted | sUnsorted) & go) & ~reset;
	wire sNextCheckStart = sStart & ~go & ~reset;
	wire sNextCheckSelect = (sCheckStart & ~zero_length_array | sCheckSelect & ~end_of_array & ~inversion_found) & ~reset;
	wire sNextSorted = (sCheckSelect & end_of_array & ~inversion_found | sCheckStart & zero_length_array | sSorted & ~go) & ~reset;
	wire sNextUnsorted = (sCheckSelect & inversion_found | sUnsorted & ~go) & ~reset;

	dffe d0 (sGarbage, sNextGarbage, clock, 1'b1, 1'b0);
	dffe d1 (sStart, sNextStart, clock, 1'b1, 1'b0);
	dffe d2 (sCheckStart, sNextCheckStart, clock, 1'b1, 1'b0);
	dffe d3 (sCheckSelect, sNextCheckSelect, clock, 1'b1, 1'b0);
	dffe d4 (sSorted, sNextSorted, clock, 1'b1, 1'b0);
	dffe d5 (sUnsorted, sNextUnsorted, clock, 1'b1, 1'b0);

	assign done = sSorted | sUnsorted;
	assign load_index = sStart | sCheckStart | sCheckSelect;
	assign load_input = sStart | sCheckStart | sCheckSelect;
	//sGarbage | sStart | sCheckStart | sCheckSelect | sNextSorted | sNextUnsorted;
	assign select_index = sCheckStart | sCheckSelect;

	assign sorted = sSorted;

endmodule
