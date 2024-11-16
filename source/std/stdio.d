module nanoc.std.stdio;

enum EOF = -1;

extern(C) int puts(const char *str)
{
    import nanoc.os: syscall, SYS_write;
    import nanoc.std.string: strlen;
    if (syscall(SYS_write, 1, str, strlen(str)) >= 0)
    {
        return 0;
    }
    return EOF;
}

extern(C) size_t write(int fd, const void[] buf, size_t count)
{
    import nanoc.os: syscall, SYS_write;
    return syscall(SYS_write, fd, cast(void*) buf, count);
}

extern(C) size_t read(int fd, void[] buf, size_t count)
{
    import nanoc.os: syscall, SYS_read;
    return syscall(SYS_read, fd, cast(void*) buf, count);
}
