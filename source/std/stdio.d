module nanoc.std.stdio;

enum EOF = -1;

extern(C) int puts(const char *str)
{
    import nanoc.os: syscall;
    import nanoc.std.string: strlen;
    if (syscall(1, 1, str, strlen(str)) >= 0)
    {
        return 0;
    }
    return EOF;
}

extern(C) size_t write(int fd, const void[] buf, size_t count)
{
    import nanoc.os: syscall;
    return syscall(1, fd, cast(void*) buf, count);
}
