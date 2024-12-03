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
    i = i ^ j << 2;
    return i++;
}

extern(C) void srand(int seed)
{
    i = seed & 0xFFFF;
    j = (seed >> 8) & 0xFFFF;
}

unittest
{
    import nanoc.std.time;
    srand(cast(int) time(null));
    int[256] count;
    //memset(cast(void*)count, 0, 256 * int.sizeof);
    for (int i = 0; i < 256; i++)
    {
        uint r = rand();
        count[r%256]++;
    }

    for (int i = 0; i < 256; i++)
    {
        assert(count[i] == 1);
    }
}
