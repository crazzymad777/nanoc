module nanoc.std.stdio.file;

import nanoc.std.stdio.common;

struct FILE {
    enum Type {
        OS,
        MEMORY_STREAM,
        DYNAMIC_MEMORY_STREAM,
        COOKIE
    }
    struct Mem {
        void[] data;
        size_t size;
        int mode;

        long offset;
    };

    Type type;
    union {
        int raw_fd;
        Mem memory;
        // fmemopen / memory as stream
        // memory stream / dynamic memory buffer
        // cookie
    }
};

extern(C) FILE* fmemopen(void[] buf, size_t size, const char* mode)
{
    import nanoc.std.stdlib: _malloc, _free;
    FILE* f = cast(FILE*) _malloc(FILE.sizeof);
    if (f)
    {
        f.type = FILE.Type.MEMORY_STREAM;
        f.memory.data = buf;
        f.memory.size = size;
        f.memory.mode = O_RDWR;
        f.memory.offset = 0;
        return f;
    }
    return null;
}

extern (C) int fclose(FILE* f)
{
    import nanoc.std.stdlib: _free;
    if (f.type == FILE.Type.MEMORY_STREAM)
    {
        _free(f);
        return 0;
    }
    else if (f.type == FILE.Type.OS)
    {
        int r = close(f.raw_fd);
        if (r < 0)
        {
            return EOF;
        }
        _free(f);
        return 0;
    }
    return EOF;
}

extern (C) int fputc(int c, FILE* stream)
{
    if (stream.type == FILE.Type.MEMORY_STREAM)
    {
        FILE.Mem* memory = &stream.memory;
        long offset = memory.offset;
        char x = cast(char) c;
        if (offset < memory.size)
        {
            char[] buf = cast(char[]) memory.data;
            buf[offset] = x;
            memory.offset++;
            return x;
        }
        return EOF;
    }
    else if (stream.type == FILE.Type.OS)
    {
        import nanoc.os: syscall, SYS_write;
        char x = cast(char) c;
        if (syscall(SYS_write, stream.raw_fd, &x, 1) >= 0)
        {
            return cast(int) x;
        }
        return EOF;
    }
    return EOF;
}

extern (C) int fputs(const char* s, FILE* stream)
{
    int i = 0;
    while (s[i] != '\0')
    {
        int r = fputc(s[i], stream);
        if (r == EOF)
        {
            return EOF;
        }
        i++;
    }
    return i;
}

extern (C) int fgetc(FILE *stream)
{
    return EOF;
}

extern (C) FILE* fopen(const char* filename, const char* mode)
{
    import nanoc.std.stdlib: _malloc, _free;
    FILE* f = cast(FILE*) _malloc(FILE.sizeof);
    if (f)
    {
        f.type = FILE.Type.OS;
        int imode = 0;
        // rwa+cemx
        bool read = false;
        bool write = false;
        bool extend = false; // +
        bool append = false;
        for (int i = 0; i < 8 && mode[i] != 0; i++)
        {
            if (mode[i] == 'r')
            {
                read = true;
            }
            if (mode[i] == 'w')
            {
                write = true;
            }
            if (mode[i] == 'a')
            {
                append = true;
            }
            if (mode[i] == '+')
            {
                extend = true;
            }
        }

        if (write && append)
        {
            import nanoc.std.errno: errno;
            errno = -22; // EINVAL
            _free(f);
            return null;
        }

        if ((write || append) && read)
        {
            imode |= O_RDWR;
        }
        else if (write || append)
        {
            imode |= O_WRONLY;
        }

        if (extend)
        {
            imode = O_RDWR;
        }

        if (imode == O_WRONLY || imode == O_RDWR)
        {
            if (append)
            {
                imode |= O_CREAT | O_APPEND;
            }
            else
            {
                imode |= O_CREAT | O_TRUNC;
            }
        }

        import std.conv;
        f.raw_fd = open(filename, imode, std.conv.octal!"0644");
        if (f.raw_fd)
        {
            return f;
        }
        _free(f);
    }
    return null;
}
//
//
// extern (C) int fclose(FILE* f)
// {
//     import nanoc.std.stdlib: _free;
//     if (f.type == FILE.Type.OS)
//     {
//         int r = close(f.raw_fd);
//         if (r < 0)
//         {
//             return EOF;
//         }
//         _free(f);
//     }
//     return 0;
// }
