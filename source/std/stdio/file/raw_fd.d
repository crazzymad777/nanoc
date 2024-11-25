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
        _free(f);
        return 0;
    }

    int _fgetc(FILE* stream)
    {
        import nanoc.os: syscall, SYS_read;
        char x;;
        long ret = syscall(SYS_read, stream.raw_fd, &x, 1);
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
        import nanoc.os: syscall, SYS_write;
        char x = cast(char) c;
        long ret = syscall(SYS_write, stream.raw_fd, &x, 1);
        if (ret >= 0)
        {
            return cast(int) x;
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

    int _fputs(const char* s, FILE* stream)
    {
        import nanoc.os: syscall, SYS_write;
        import nanoc.std.string: strlen;

        long r = syscall(SYS_write, stream.raw_fd, s, strlen(s));
        if (r >= 0)
        {
            return cast(int) r;
        }
        return EOF;
    }

    int _fseek(FILE *stream, long offset, int whence)
    {
        import nanoc.std.unistd: lseek;
        return cast(int) (lseek(stream.raw_fd, offset, whence) != -1);
    }

    long _ftell(FILE *stream)
    {
        import nanoc.std.unistd: lseek;
        return lseek(stream.raw_fd, 0, SEEK_CUR);
    }
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

extern(C) int fileno(FILE* stream)
{
    if (stream.type == File.Type.OS)
    {
        return stream.raw_fd;
    }
    return -1;
}
