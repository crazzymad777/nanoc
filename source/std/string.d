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

extern(C)
void* memset(void* s, int c, size_t n)
{
    char* buffer = cast(char*) s;
    char x = cast(char) c;
    for (int i = 0; i < n; i++)
    {
        buffer[i] = x;
    }
    return s;
}

extern(C)
void* memcpy(void* dest, const void* src, size_t n)
{
    char* dest_buffer = cast(char*) dest;
    char* src_buffer = cast(char*) src;
    for (int i = 0; i < n; i++)
    {
        dest_buffer[i] = src_buffer[i];
    }
    return dest;
}
