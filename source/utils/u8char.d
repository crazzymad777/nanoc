module nanoc.utils.u8char;

import nanoc.meta: Omit;

@Omit
int c32tou8(dchar codepoint, char* buf)
{
    import nanoc.std.wchar_: WEOF;
    // char[4] buf;
    int size;
    if (codepoint == WEOF)
    {
        return WEOF;
    }
    else if (codepoint < 0x80)
    {
        // ASCII
        buf[0] = cast(char) codepoint;
        size = 1;
    }
    else
    {
        // UTF-8
        int mask = 0;
        if (codepoint >= 0x80 && codepoint <= 0x7ff)
        {
            mask = 0b110_00000;
            size = 2;
        }
        else if (codepoint >= 0x800 && codepoint <= 0xffff)
        {
            mask = 0b1110_0000;
            size = 3;
        }
        else if (codepoint >= 0x10000 && codepoint <= 0x10ffff)
        {
            mask = 0b11110_000;
            size = 4;
        }
        else
        {
            return WEOF;
        }

        for (int i = size - 1; i > 0; i--)
        {
            buf[i] = cast(char) ((codepoint & 0b00_111111) | 0b10_000000);
            codepoint = codepoint >> 6;
        }
        buf[0] = cast(char) ((codepoint & 0b000_11111) | mask);
    }
    return size;
}

unittest
{
    char[4] buf;
    int size = c32tou8('!', &buf[0]);
    assert(size == 1);
    assert(buf[0] == '!');

    size = c32tou8('п', &buf[0]);
    assert(size == 2);
    assert(buf[0] == 0xd0);
    assert(buf[1] == 0xbf);

    size = c32tou8('ї', &buf[0]);
    assert(size == 2);
    assert(buf[0] == 0xd1);
    assert(buf[1] == 0x97);

    size = c32tou8('セ', &buf[0]);
    assert(size == 3);
    assert(buf[0] == 0xe3);
    assert(buf[1] == 0x82);
    assert(buf[2] == 0xbb);

    size = c32tou8(0x80, &buf[0]);
    assert(size == 2);
    assert(buf[0] == 0xc2);
    assert(buf[1] == 0x80);

    size = c32tou8(0x800, &buf[0]);
    assert(size == 3);
    assert(buf[0] == 0xe0);
    assert(buf[1] == 0xa0);
    assert(buf[2] == 0x80);

    size = c32tou8(0x10000, &buf[0]);
    assert(size == 4);
    assert(buf[0] == 0xf0);
    assert(buf[1] == 0x90);
    assert(buf[2] == 0x80);
    assert(buf[3] == 0x80);

    size = c32tou8(cast(dchar) 0x110000, &buf[0]);
    assert(size == -1);
}

@Omit
int u8clen(ubyte octet)
{
    if (octet >= 0x80 && (octet & 0xc0) != 0xc0)
    {
        // continuation byte
        return -1;
    }

    int size = -1;
    if (octet >= 0 && octet < 0x80)
    {
        size = 1;
    }
    else if (octet >= 0xc0 && octet <= 0xdf)
    {
        size = 2;
    }
    else if (octet >= 0xe0 && octet <= 0xef)
    {
        size = 3;
    }
    else if (octet >= 0xf0 && octet <= 0xf7)
    {
        size = 4;
    }
    // else if (octet >= 0xf5)
    // {
    //     // Overlong encoding
    //     size = -2;
    // }
    return size;
}

unittest
{
    auto x = "カ";
    assert(u8clen(x[0]) == 3);
    assert(u8clen(x[1]) == -1);
    assert(u8clen(x[2]) == -1);

    x = "т";
    assert(u8clen(x[0]) == 2);
    assert(u8clen(x[1]) == -1);

    x = "]";
    assert(u8clen(x[0]) == 1);
}

@Omit
dchar u8toc32(immutable (char)* buf)
{
    import nanoc.std.wchar_: WEOF;
    auto length = u8clen(buf[0]);
    if (length == -1) return WEOF;

    if (length == 1)
    {
        // ASCII
        return buf[0];
    }
    else
    {
        int mask = 0;
        if (length == 2) mask = 0b000_11111;
        if (length == 3) mask = 0b0000_1111;
        if (length == 4) mask = 0b00000_111;

        dchar codepoint = mask & buf[0];
        for (int i = 1; i < length; i++)
        {
            codepoint = (codepoint << 6) | (buf[i] & 0b00_111111);
        }
        return codepoint;
    }
    return WEOF;
}

// @Omit
// dchar u8toc32(immutable char[4] buf)
// {
//     return u8toc32(&buf[0]);
// }

unittest
{
    auto x = "!";
    assert(u8toc32(&x[0]) == '!');

    x = "Р";
    dchar codepoint = u8toc32(&x[0]);
    assert(codepoint == 'Р');

    x = "ї";
    codepoint = u8toc32(&x[0]);
    assert(codepoint == 'ї');

    x = "セ";
    codepoint = u8toc32(&x[0]);
    assert(codepoint == 'セ');
}
