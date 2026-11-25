module nanoc.utils.test;

// unittest
// {
//     assert(false);
// }

unittest
{
    // test fputwc
    import nanoc.std.wchar_;
    import nanoc.std.stdio;

    immutable(dchar)* buffer = "Привет!\n\0"d.ptr;
    byte[14] memory;
    byte[14] expected = cast(byte[14]) [0xd0, 0x9f, 0xd1, 0x80, 0xd0, 0xb8, 0xd0, 0xb2, 0xd0, 0xb5, 0xd1, 0x82, 0x21, 0x0a];
    auto f = fmemopen(cast(void*)&memory, 15, "w".ptr);
    assert(f !is null);
    for (int i = 0; i < wcslen(buffer); i++)
    {
        fputwc(buffer[i], f);
    }

    import nanoc.std.string: memcmp;
    assert(memcmp(&expected[0], &memory[0], 14) == 0);
    fclose(f);
}


unittest
{
    // test fgetwc
    import nanoc.std.wchar_;
    import nanoc.std.stdio;

    immutable(dchar)* expected = "Hello!\n\0"d.ptr;
    // dchar[8] buffer;
    // buffer[7] = 0;

    dchar[8] buffer;
    buffer[7] = 0;
    byte[7] memory = cast(byte[7]) [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x21, 0x0a];
    auto f = fmemopen(cast(void*)&memory, 7, "r".ptr);
    assert(f !is null);
    for (int i = 0; i < buffer.length-1; i++)
    {
        buffer[i] = fgetwc(f);
    }

    // import nanoc.std.wchar_: wcscmp;
    assert(wcscmp(&expected[0], &buffer[0]) == 0);
    fclose(f);
}

unittest
{
    // test fgetwc
    import nanoc.std.wchar_;
    import nanoc.std.stdio;

    immutable(dchar)* expected = "Привет!\n\0"d.ptr;
    // dchar[8] buffer;
    // buffer[7] = 0;

    dchar[14] buffer;
    byte[14] memory = cast(byte[14]) [0xd0, 0x9f, 0xd1, 0x80, 0xd0, 0xb8, 0xd0, 0xb2, 0xd0, 0xb5, 0xd1, 0x82, 0x21, 0x0a];
    auto f = fmemopen(cast(void*)&memory, 14, "r".ptr);
    assert(f !is null);

    int i = 0;
    while (feof(f) == 0)
    {
        dchar x = fgetwc(f);
        if (x != -1)
        {
            buffer[i] = x;
            i++;
        }
    }
    buffer[i] = 0;

    // import nanoc.std.wchar_: wcscmp;
    assert(wcscmp(&expected[0], &buffer[0]) == 0);
    fclose(f);
}

