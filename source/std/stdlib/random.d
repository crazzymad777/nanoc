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
    import nanoc.std.stdio;
    import nanoc.std.time;
    int seed = cast(int) time(null);
    printf("Seed: %d\n", seed);
    srand(seed);

    int[0x10000] count;
    for (int i = 0; i < 0x10000; i++)
    {
        uint x = rand()%0x10000u;
        count[x]++;
    }

    for (int i = 0; i < 0x10000; i++)
    {
        assert(count[i] == 1);
    }
}
