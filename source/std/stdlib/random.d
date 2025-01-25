module nanoc.std.stdlib.random;
import nanoc.meta: Omit;

@Omit
__gshared ulong next = 2;

@Omit
static int do_rand(ulong *ctx)
{
    /*
    * Compute x = (7^5 * x) mod (2^31 - 1)
    * without overflowing 31 bits:
    *      (2^31 - 1) = 127773 * (7^5) + 2836
    * From "Random number generators: good ones are hard to find",
    * Park and Miller, Communications of the ACM, vol. 31, no. 10,
    * October 1988, p. 1195.
    */
    long hi, lo, x;

    /* Must be in [1, 0x7ffffffe] range at this point. */
    hi = *ctx / 127773;
    lo = *ctx % 127773;
    x = 16807 * lo - 2836 * hi;
    if (x < 0)
        x += 0x7fffffff;
    *ctx = x;
    /* Transform to [0, 0x7ffffffd] range. */
    return cast(int)(x - 1);
}

extern (C) int rand()
{
	return (do_rand(&next));
}

extern (C) void srand(uint seed)
{
	next = seed;
}
