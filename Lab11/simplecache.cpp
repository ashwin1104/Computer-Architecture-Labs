#include "simplecache.h"

int SimpleCache::find(int index, int tag, int block_offset)
{
  for (SimpleCacheBlock b : _cache[index])
  {
    if (b.valid() && b.tag() == tag)
    {
      return b.get_byte(block_offset);
    }
  }
  return 0xdeadbeef;
}

/*For insert, you will again look up the set of blocks corresponding to the given index. Next, look through
the set for an invalid block. If there is one, replace it with the block being inserted and return. If not,
replace the 0th block of the set (overwriting whatever was in it). Use the provided replace function in
simplecache.h. */

void SimpleCache::insert(int index, int tag, char data[])
{
  for (SimpleCacheBlock &b : _cache[index])
  {
    if (!b.valid())
    {
      b.replace(tag, data);
      return;
    }
  }
  _cache[index][0].replace(tag, data);
}
