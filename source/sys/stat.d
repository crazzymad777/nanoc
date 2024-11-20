module nanoc.sys.stat;

import nanoc.std.stdio.common;

extern(C) int mkdir(const char* pathname, mode_t mode)
{
    import nanoc.os: syscall, SYS_mkdir;
    return cast(int) syscall(SYS_mkdir, pathname, mode);
}
