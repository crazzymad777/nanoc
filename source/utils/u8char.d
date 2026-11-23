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
        const dchar maxCodepoint = 0x10ffff;
        dchar minCodepoint = 0; // for overlong encoding detecting
        // UTF-8
        int mask = 0;
        if (length == 2) {mask = 0b000_11111; minCodepoint = 0x80;}
        if (length == 3) {mask = 0b0000_1111; minCodepoint = 0x00800;}
        if (length == 4) {mask = 0b00000_111; minCodepoint = 0x10000;}

        dchar codepoint = mask & buf[0];
        for (int i = 1; i < length; i++)
        {
            if ((buf[i] & 0xC0) != 0x80)
            {
                // Not a continuation byte
                return WEOF;
            }

            codepoint = (codepoint << 6) | (buf[i] & 0b00_111111);
        }

        if (codepoint < minCodepoint || codepoint > maxCodepoint) return WEOF;
        return codepoint;
    }
    return WEOF;
}

@Omit
dchar u8toc32(immutable char[4] buf)
{
    return u8toc32(&buf[0]);
}

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

    char[4] buf = [0, 0, 0, 0];
    codepoint = u8toc32(buf);
    assert(codepoint == 0);

    // Overlong encoding test
    buf = [0b11_00000_1, 0b10_000001, 0, 0]; // 7 bit can be encoded in ASCII
    codepoint = u8toc32(buf);
    assert(codepoint == -1);

    buf = [0b111_00000, 0b10_0_10000, 0b10_000000, 0]; // 11 bit can be encoded in 2 bytes of an UTF-8
    codepoint = u8toc32(buf);
    assert(codepoint == -1);

    buf = [0b1111_0000, 0b10_00_1000, 0b10_000000, 0b10_000000]; // 16 bit can be encoded in 2 bytes of the UTF-8
    codepoint = u8toc32(buf);
    assert(codepoint == -1);

    buf = [0b11_000010, 0b10_000001, 0, 0]; // 8 bit can not encoded in ASCII
    codepoint = u8toc32(buf);
    assert(codepoint == 0b10000001);

    buf = [0b111_00000, 0b10_100000, 0b10_000000, 0]; // 12 bit can not be encoded in 2 bytes of the UTF-8
    codepoint = u8toc32(buf);
    assert(codepoint == 0b100000_000000);

    buf = [0b1111_0000, 0b10_0_10000, 0b10_000000, 0b10_000000]; // 17 bit can not be encoded in 2 bytes of the UTF-8
    codepoint = u8toc32(buf);
    assert(codepoint == 0b10000_000000_000000);

    // test Missing continuation byte
    buf = [0b11_000010, 0b00_000001, 0, 0];
    codepoint = u8toc32(buf);
    assert(codepoint == -1);

    buf = [0b11_000010, 0b01_000001, 0, 0];
    codepoint = u8toc32(buf);
    assert(codepoint == -1);

    buf = [0b11_000010, 0b11_000001, 0, 0];
    codepoint = u8toc32(buf);
    assert(codepoint == -1);
}
