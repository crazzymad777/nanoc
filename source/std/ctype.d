module nanoc.std.ctype;

extern(C) int toupper(int wc)
{
    auto toUpper(C)(C c)
    if (is(C : dchar))
    {
        import std.traits : OriginalType;

        static if (!__traits(isScalar, C))
            alias R = dchar;
        else static if (is(immutable OriginalType!C == immutable OC, OC))
            alias R = OC;

        return isLower(c) ? cast(R)(cast(R) c - ('a' - 'A')) : cast(R) c;
    }

    bool isLower(dchar c) @safe pure nothrow @nogc
    {
        return c >= 'a' && c <= 'z';
    }

    return toUpper(wc);
}
