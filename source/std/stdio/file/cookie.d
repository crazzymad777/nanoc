module nanoc.std.stdio.file.cookie;

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
    File cookieFile = {cookie: {user_data: cookie, readfn: readfn, writefn: writefn, seekfn: seekfn, closefn: closefn}};

    import nanoc.std.stdlib: _malloc;
    FILE* f = cast(FILE*) _malloc(FILE.sizeof);
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
