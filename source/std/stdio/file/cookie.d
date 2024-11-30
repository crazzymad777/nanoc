module nanoc.std.stdio.file.cookie;

import nanoc.std.stdio.common;
import nanoc.std.stdio.file;

alias cookie_read_function_t = extern (C) int function(void*, char*, int);
alias cookie_write_function_t = extern (C) int function(void*, const char*, int);
alias cookie_seek_function_t = extern (C) fpos_t function(void*, fpos_t, int);
alias cookie_close_function_t = extern (C) int function(void*);

struct cookie_io_functions_t {
               cookie_read_function_t read;
               cookie_write_function_t write;
               cookie_seek_function_t seek;
               cookie_close_function_t close;
};

extern (C)
FILE* funopen(const void* cookie, int function(void*, char*, int) readfn, int function(void*, const char*, int) writefn, fpos_t function(void*, fpos_t, int) seekfn, int function(void*) closefn)
{
    File cookieFile = {type: File.Type.COOKIE, cookie: {user_data: cookie, readfn: readfn, writefn: writefn, seekfn: seekfn, closefn: closefn}};

    import nanoc.std.stdlib: _malloc;
    FILE* f = cast(File*) _malloc(File.sizeof);
    if (f)
    {
        *f = cookieFile;
    }
    return f;
}

extern(C)
FILE *fopencookie(void* cookie, const char* mode, cookie_io_functions_t io_funcs)
{
    import nanoc.std.stdio.file.utils: parseMode;
    int imode = 0;
    if (parseMode(mode, &imode) is null)
    {
        import nanoc.std.errno: errno;
        errno = -22; // EINVAL
        return null;
    }

    File* f = funopen(cookie, io_funcs.read, io_funcs.write, io_funcs.seek, io_funcs.close);
    f.mode = imode;
    return f;
}

template FileInterface(alias A)
    if (A == File.Type.COOKIE)
{
    int _fclose(File* f)
    {
        import nanoc.std.stdlib: _free;
        int ret = 0;
        if (f.cookie.closefn !is null)
        {
            ret = f.cookie.closefn(cast(void*)f.cookie.user_data);
        }
        _free(f);
        return ret;
    }

    int _fgetc(FILE* stream)
    {
        if (stream.cookie.readfn !is null)
        {
            char x;
            int ret = stream.cookie.readfn(cast(void*)stream.cookie.user_data, &x, 1);
            if (ret >= 0)
            {
                return x;
            }
            return EOF;
        }
        return EOF;
    }

    int _fputc(int c, FILE* stream)
    {
        if (stream.cookie.writefn !is null)
        {
            char x = cast(char) c;
            int ret = stream.cookie.writefn(cast(void*)stream.cookie.user_data, &x, 1);
            if (ret >= 0)
            {
                return x;
            }
            return EOF;
        }
        return EOF;
    }

    fpos_t _seek(FILE *stream, fpos_t offset, int whence)
    {
        if (stream.cookie.seekfn !is null)
        {
            return stream.cookie.seekfn(cast(void*)stream.cookie.user_data, cast(fpos_t) offset, whence);
        }
        return EOF;
    }

    int _write(FILE* stream, const void* data, size_t size)
    {
        if (stream.cookie.writefn !is null)
        {
            import nanoc.std.string: strlen;
            return stream.cookie.writefn(cast(void*)stream.cookie.user_data, cast(char*) data, cast(int) size);
        }
        return EOF;
    }

    int _read(FILE* stream, void* data, size_t size)
    {
        if (stream.cookie.readfn !is null)
        {
            import nanoc.std.string: strlen;
            return stream.cookie.readfn(cast(void*)stream.cookie.user_data, cast(char*) data, cast(int) size);
        }
        return EOF;
    }
}

extern(C) private int readZero(void* cookie, char* x, int siz)
{
    int i = 0;
    for (; i < siz; i++)
    {
        x[i] = '\0';
    }
    return i;
}

extern(C) private int writeNull(void* cookie, const char* x, int siz)
{
    return siz;
}

unittest
{
    FILE* f = funopen(null, &readZero, null, null, null);
    assert(f !is null);
    for (int i = 0; i < 32; i++)
    {
        assert(fgetc(f) == '\0');
    }
    fclose(f);
}

unittest
{
    import nanoc.std.string: strlen;
    FILE* f = funopen(null, null, &writeNull, null, null);
    assert(f !is null);
    for (int i = 0; i < 32; i++)
    {
        assert(fputc(i, f) == i);
    }
    auto str = "hello".ptr;
    assert(fputs(str, f) == strlen(str));
    fclose(f);
}
