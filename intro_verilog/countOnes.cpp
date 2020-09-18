/**
 * @file
 * Contains an implementation of the countOnes function.
 */

unsigned countOnes(unsigned input) {
	int right, left, sum;

	right = (input & 0x55555555);
	left = ((input & 0xAAAAAAAA) >> 1);
	sum = right + left;

	right = (sum & 0x33333333);
	left = ((sum & 0xCCCCCCCC) >> 2);
	sum = right + left;

	right = (sum & 0x0F0F0F0F);
	left = ((sum & 0xF0F0F0F0) >> 4);
	sum = right + left;

	right = (sum & 0x00FF00FF);
	left = ((sum & 0xFF00FF00) >> 8);
	sum = right + left;

	right = (sum & 0x0000FFFF);
	left = ((sum & 0xFFFF0000) >> 16);

	return (right + left);
}
