module nanoc.std.stdio.format.print;

import nanoc.std.stdio.file;

extern (C) int snprintf(T...)(char* buffer, size_t size, const char* format, T args)
{
    FILE* f = fmemopen(buffer, size-1, "w");
    if (f)
    {
        int result = fprintf(f, format, args);
        fclose(f);
        if (result >= 0 && result < size)
        {
            buffer[result] = '\0';
        }
        return result;
    }
    return EOF;
}

extern (C) int printf(T...)(const char* format, T args)
{
    return fprintf(cast(File*) STDOUT_FILENO, format, args);
}

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
            static if (args.length > 0)
            {
                int ret = -1;
                if (x == 'u')
                {
                    // TYPES!!!!
                    static if (is(typeof(args[0]) == uint))
                    {
                        ret = fprint_unsigned_int(stream, args[0]);
                    }
                }
                else if (x == 'd')
                {
                    static if (is(typeof(args[0]) == int))
                    {
                        ret = fprint_signed_int(stream, args[0]);
                    }
                }
                else if (x == 's')
                {
                    //pragma(msg, typeof(args[0]));
                    static if (is(typeof(args[0]) == immutable(char)*))
                    {
                        ret = fputs(args[0], stream);
                    }
                    else
                    {
                        ret = 0;
                    }
                    //ret = 0;
                }

                if (ret < 0)
                {
                    return EOF;
                }
                nbytes += ret;
                i++;
                break;
            }
            else
            {
                return EOF;
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
