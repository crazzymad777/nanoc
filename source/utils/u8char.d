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
}
