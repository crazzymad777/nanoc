module nanoc.sys.stat;

import nanoc.std.stdio.common;

import nanoc.os: StringBuffer, fsmkdir;

extern(C) int mkdir(const char* pathname, mode_t mode)
{
    return fsmkdir(StringBuffer(pathname, -1), mode);
}
