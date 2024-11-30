module nanoc.std.stdio.file.raw_fd;

import nanoc.std.stdio.common;
import nanoc.std.stdio.file;

template FileInterface(alias A)
    if (A == File.Type.OS)
{
    int _fclose(File* f)
    {
        import nanoc.std.stdlib: _free;
        int r = close(f.raw_fd);
        if (r < 0)
        {
            return EOF;
        }
        if (!f.prealloc)
        {
            _free(f);
        }
        return 0;
    }

    int _fgetc(FILE* stream)
    {
        import nanoc.os;
        char x;
        long ret = read(stream.raw_fd, &x, 1);
        if (ret > 0)
        {
            return cast(int) x;
        }

        if (ret == 0)
        {
            stream.eof = true;
            return cast(int) x;
        }

        import nanoc.std.errno: errno;
        stream.error = errno;
        return EOF;
    }

    int _fputc(int c, FILE* stream)
    {
        import nanoc.os;

        char x = cast(char) c;
        long ret = write(stream.raw_fd, &x, 1);
        if (ret > 0)
        {
            return cast(int) x;
        }

        if (ret == 0)
        {
            return EOF;
        }

        if (ret < 0)
        {
            import nanoc.std.errno: errno;
            stream.error = errno;
            return EOF;
        }

        stream.eof = true;
        return EOF;
    }

    fpos_t _seek(FILE *stream, fpos_t offset, int whence)
    {
        import nanoc.std.unistd: lseek;
        long ret = lseek(stream.raw_fd, offset, whence);
        if (ret == -1)
        {
            import nanoc.std.errno: errno;
            stream.error = errno;
            return -1;
        }
        return ret;
    }

    int _write(FILE* stream, const void* data, size_t size)
    {
        import nanoc.os;

        long r = write(stream.raw_fd, cast(char*) data, size);
        return cast(int) r;
    }

    int _read(FILE* stream, void* data, size_t size)
    {
        import nanoc.os;

        long r = read(stream.raw_fd, cast(char*) data, size);
        return cast(int) r;
    }
}

extern (C) FILE* fopen(const char* filename, const char* mode)
{
    import nanoc.std.stdlib: _malloc, _free;
    FILE* f = cast(File*) _malloc(File.sizeof);
    if (f)
    {
        import nanoc.std.stdio.file.utils: parseMode;

        f.type = FILE.Type.OS;
        int imode = 0;
        if (parseMode(mode, &imode) is null)
        {
            import nanoc.std.errno: errno;
            errno = -22; // EINVAL
            _free(f);
            return null;
        }

        import std.conv;
        f.mode = imode;
        f.raw_fd = open(filename, imode, std.conv.octal!"0644");
        if (f.raw_fd)
        {
            return f;
        }
        _free(f);
    }
    return null;
}

extern(C) int fileno(FILE* stream)
{
    if (stream.type == File.Type.OS)
    {
        return stream.raw_fd;
    }
    return -1;
}
