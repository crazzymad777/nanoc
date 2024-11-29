module nanoc.std.stdio.format.utils;

import nanoc.std.stdio.file;

@("metaomit")
int fprint_signed_int(FILE* stream, int value)
{
    int nbytes = 0;
    uint x;
    if (value < 0)
    {
        nbytes += fputc('-', stream) >= 0 ? 1 : 0;
        x = -1*value;
    }
    else
    {
        x = value;
    }
    return nbytes + fprint_unsigned_int(stream, x);
}

@("metaomit")
int fprint_unsigned_int(FILE* stream, uint value)
{
    int nbytes = 0;
    char[10] buffer;
    int j = 0;
    //args = args[1 .. $];
    while (value > 0)
    {
        char digit = value % 10;
        buffer[j] = cast(char) (digit + '0');
        value /= 10;
        j++;
    }

    j--;
    if (j == -1)
    {
        j++;
        buffer[j] = '0';
    }

    for (; j >= 0; j--)
    {
        nbytes += fputc(buffer[j], stream) >= 0 ? 1 : 0;
    }
    return nbytes;
}
