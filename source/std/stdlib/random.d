module nanoc.std.stdlib.random;

import nanoc.meta: Omit;

// Given pseudorandom number generator was obtained by heuristic technique. That's it.

@Omit
__gshared uint i = 1;

@Omit
__gshared uint j = 0;

extern(C) int rand()
{
    j = j + i;
    i = i ^ j << 1;
    return i++;
}

extern(C) void srand(int seed)
{
    i = seed & 0xFFFF;
    j = (seed >> 8) & 0xFFFF;
}
