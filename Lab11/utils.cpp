#include "utils.h"
#include <math.h>
#include <iostream>

uint32_t extract_tag(uint32_t address, const CacheConfig &cache_config)
{
  uint32_t ans = address;
  ans = ans >> (32 - cache_config.get_num_tag_bits());
  return ans;
}

uint32_t extract_index(uint32_t address, const CacheConfig &cache_config)
{
  uint32_t ans = address;
  ans = ans >> cache_config.get_num_block_offset_bits();
  int ander = pow(2, cache_config.get_num_index_bits()) - 1;
  ans = ans & ander;
  return ans;
}

uint32_t extract_block_offset(uint32_t address, const CacheConfig &cache_config)
{
  uint32_t ans = address;
  int ander = pow(2, cache_config.get_num_block_offset_bits()) - 1;
  ans = ans & ander;
  return ans;
}
