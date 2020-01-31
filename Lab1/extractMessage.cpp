/**
 * @file
 * Contains an implementation of the extractMessage function.
 */

#include <iostream> // might be useful for debugging
#include <assert.h>
#include "extractMessage.h"

using namespace std;

char *extractMessage(const char *message_in, int length) {
   // Length must be a multiple of 8
   assert((length % 8) == 0);

   // allocates an array for the output
   char *message_out = new char[length];
   for (int i=0; i<length; i++) {
   		message_out[i] = 0;    // Initialize all elements to zero.
	}

// my code below

	int num_blocks = length/8;
  int num_chars = 8;

  for (int i = 0; i < num_blocks; i++) {
    unsigned char and_op = 1;
    for (int j = 0; j < num_chars; j++) {
      unsigned char temp = 0;
      for (int k = 0; k < num_chars; k++) {
        unsigned char temp2;
        temp2 = (((message_in[i*num_chars + k]&and_op) >> j) << k);
        temp = temp | temp2;
      }
      message_out[(i*num_chars) + j] = temp;
      and_op = and_op << 1;
    }
  }

	return message_out;
}
