module nanoc.std.stdio.format;

import nanoc.std.stdio.common;
import nanoc.std.stdio.file;

import core.vararg;


extern (C) int fprintf(T...)(FILE* stream, const char* format, T args)
{
    // struct Conversion {}
    // %[$][flags][width][.precision][length modifier]conversion

    bool conversion = false;
    int nbytes = 0;
    int i = 0;
    while (format[i] != '\0')
    {
        char x = format[i];
        if (x == '%')
        {
            if (conversion)
            {
                nbytes += fputc(x, stream) >= 0 ? 1 : 0;
                conversion = false;
            }
            else
            {
                conversion = true;
            }
        }
        else if (conversion)
        {
            if (x == 'u')
            {
                static if (args.length > 0)
                {
                    char[10] buffer;
                    int j = 0;

                    uint value = args[0];
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

                    i++;
                    break;
                }
                else
                {
                    return EOF;
                }
            }
        }
        else
        {
            nbytes += fputc(x, stream) >= 0 ? 1 : 0;
        }
        i++;
    }

    if (format[i] != '\0')
    {
        static if (args.length > 0)
        {
            int n = fprintf(stream, &format[i], args[1..$]);
            if (n < 0)
            {
                return EOF;
            }
            nbytes += n;
        }
    }

    return nbytes;
}
