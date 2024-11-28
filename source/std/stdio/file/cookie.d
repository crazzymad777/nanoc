module nanoc.std.stdio.file.cookie;

import nanoc.std.stdio.file;

extern (C)
FILE* funopen(void* cookie, int function(void*, char*, int) readfn, int function(void*, const char*, int) writefn, fpos_t function(void*, fpos_t, int) seekfn, int function(void*) closefn)
{
    import nanoc.std.stdlib: _malloc;
    FILE* f = cast(FILE*) _malloc(FILE.sizeof);
    if (f)
    {
        f.cookie.user_data = cookie;
        f.cookie.readfn = readfn;
        f.cookie.writefn = writefn;
        f.cookie.seekfn = seekfn;
        f.cookie.closefn = closefn;
    }
    return f;
}
