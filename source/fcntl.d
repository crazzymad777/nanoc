module nanoc.fcntl;

extern(C) int fcntl(int fd, int op, ...)
{
    import std.meta: AliasSeq, Alias;
    import nanoc.os: fscntl, get_argc_fscntl;
    // return fscntl(fd, op, args);
    import nanoc.d.args;
    dlang_va_list args = void;
    dlang_va_start(args, op);

    int n = get_argc_fscntl(op);
    int r = -1;
    if (n == 1)
    {
        long arg0 = dlang_va_arg!(long)(args);
        r = fscntl(fd, op, arg0);
    }
    else if (n == 2)
    {
        long arg0 = dlang_va_arg!(long)(args);
        long arg1 = dlang_va_arg!(long)(args);
        r = fscntl(fd, op, arg0, arg1);
    }

    dlang_va_end(args);
    return r;
}

public import nanoc.std.stdio.common: open;

import nanoc.meta: WrapFunction;

alias _open = WrapFunction!open;

// public import nanoc.os;
