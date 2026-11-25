module nanoc.fcntl;

// extern(C) int fcntl(int fd, int op, ...)
// {
//     import nanoc.os: fscntl;
//     // return fscntl(fd, op, args);
//     import core.stdc.stdarg;
//     va_list args = void;
//     va_start(args, op);
//     va_end(args);
//
//     return 0;
// }

public import nanoc.std.stdio.common: open;

import nanoc.meta: WrapFunction;

alias _open = WrapFunction!open;

public import nanoc.os;
