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
