module nanoc.std.ctype;

unittest
{
    assert(toupper('a') == 'A');
    assert(tolower('G') == 'g');
    for (int i = 0; i < 255; i++)
    {
        assert(iscntrl(i) == !isprint(i));
    }
}

// for ASCII
extern(C) int toupper(int x)
{
    return islower(x) ? x - ('a' - 'A') : x;
}

extern (C) int tolower(int x)
{
    return isupper(x) ? x - ('A' - 'a') : x;
}

extern (C) int iscntrl(int x) pure
{
    if (x < 0x20 || x == 0x7F)
    {
        return true;
    }
    return false;
}

extern (C) int isblank(int x) pure
{
    if (x == 0x09 || x == 0x20)
    {
        return true;
    }
    return false;
}

extern (C) int isspace(int x) pure
{
    if (x >= 0x09 && x <= 0x0D || x == 0x20)
    {
        return true;
    }
    return false;
}

extern (C) int isupper(int x) pure
{
    if (x >= 0x41 && x <= 0x5A)
    {
        return true;
    }
    return false;
}

extern (C) int islower(int x) pure
{
    if (x >= 0x61 && x <= 0x7A)
    {
        return true;
    }
    return false;
}

extern (C) int isalpha(int x) pure
{
    return isupper(x) || islower(x);
}

extern (C) int isdigit(int x) pure
{
    if (x >= '0' && x <= '9')
    {
        return true;
    }
    return false;
}

extern (C) int isalnum(int x) pure
{
    return isalpha(x) || isdigit(x);
}

extern (C) int isxdigit(int x) pure
{
    if (isdigit(x))
    {
        return true;
    }
    if (x >= 'A' && x <= 'F')
    {
        return true;
    }
    if (x >= 'a' && x <= 'f')
    {
        return true;
    }
    return false;
}

extern (C) int isprint(int x) pure
{
    if (x >= 0x20 && x != 0x7F)
    {
        return true;
    }
    return false;
}

extern (C) int isgraph(int x)
{
     if (x > 0x20 && x != 0x7F)
    {
        return true;
    }
    return false;
}

extern (C) int ispunct(int x)
{
    return isgraph(x) && !isalnum(x);
}
