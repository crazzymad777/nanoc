module nanoc.std.stdio;

alias mode_t = int;
enum EOF = -1;

enum O_WRONLY = 1;
enum O_CREAT = 64;

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

extern(C) int open(const char *pathname, int flags, mode_t mode)
{
    import nanoc.os: syscall, SYS_open;
    return cast(int) syscall(SYS_open, cast(void*) pathname, flags, mode);
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

extern(C) int close(int fd)
{
    import nanoc.os: syscall, SYS_close;
    return cast(int) syscall(SYS_close, fd);
}
