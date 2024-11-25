module nanoc.std.stdio.file.raw_fd;

import nanoc.std.stdio.file;

template FileInterface(alias A)
    if (A == File.Type.OS)
{
    int _fclose(File* f)
    {
        import nanoc.std.stdlib: _free;
        import nanoc.std.stdio.common;
        int r = close(f.raw_fd);
        if (r < 0)
        {
            return EOF;
        }
        _free(f);
        return 0;
    }

    int _fputc(int c, FILE* stream)
    {
        import nanoc.std.stdio.common;
        import nanoc.os: syscall, SYS_write;
        char x = cast(char) c;
        if (syscall(SYS_write, stream.raw_fd, &x, 1) >= 0)
        {
            return cast(int) x;
        }
        return EOF;
    }
}
