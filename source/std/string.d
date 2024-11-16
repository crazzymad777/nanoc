module nanoc.std.string;

extern(C) size_t strlen(const char *str)
{
    size_t i = 0;
    while(str[i] != 0)
    {
        i++;
    }
    return i;
}

unittest
{
    assert(strlen("hello") == 5);
    assert(strlen("привет") == 6*2);
    assert(strlen("") == 0);
}
