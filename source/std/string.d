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

unittest
{
    char[10] buffer = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
    assert(memset(cast(char*) buffer, -5, 10) == cast(void*) buffer);
    for (int i = 0; i < 10; i++)
    {
        assert(buffer[i] == cast(char) -5);
    }
}

unittest
{
    import nanoc.std.stdlib: _malloc, _free;
    char[] source = cast(char[]) "Я падал в бездну, ниже ада, мимо всех чертей".ptr;
    ulong length = strlen(cast(char*) source);
    char* dest = cast(char*) _malloc(length+1);
    assert(memcpy(dest, cast(char*) source, length+1) == cast(void*) dest);
    assert(strcmp(cast(char*) source, dest) == 0);
    _free(dest);
}

/// Compares two strings
extern(C) int strcmp(const char *s1, const char *s2)
{
    int i = 0;
    while (s1[i] != '\0' && s2[i] != '\0')
    {
        i++;
        if (s1[i] != s2[i]) break;
    }
    return s1[i] - s2[i];
}

/// Compares two memory area
extern(C) int memcmp(const void[] s1, const void[] s2, size_t n)
{
    byte[] buf1 = cast(byte[]) s1;
    byte[] buf2 = cast(byte[]) s2;
    for (int i = 0; i < n; i++)
    {
        if (buf1[i] != buf2[i])
        {
            return buf1[i] - buf2[i];
        }
    }
    return 0;
}

unittest
{
    immutable char* s1 = "Потом взлетал опять, пугая райских голубей".ptr;
    immutable char* s2 = "Потом взлетал опять, пугая райских голубей".ptr;
    immutable char* s3 = "Потом взлетал опять, пугая райских голубей3333".ptr;
    assert(strcmp(s1, s2) == 0);
    assert(strcmp(s1, s3) < 0);
    assert(strcmp(s3, s2) > 0);
}
