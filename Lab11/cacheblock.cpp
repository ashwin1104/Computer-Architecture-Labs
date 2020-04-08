#include "cacheblock.h"
#include <iostream>

uint32_t Cache::Block::get_address() const
{
  uint32_t ans = _tag;
  ans = ans << _cache_config.get_num_index_bits();
  ans += _index;
  ans = ans << _cache_config.get_num_block_offset_bits();
  return ans;
}