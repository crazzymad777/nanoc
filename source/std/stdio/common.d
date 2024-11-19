module nanoc.std.stdio.common;

alias mode_t = int;
enum EOF = -1;
enum O_RDONLY = 0;
enum O_WRONLY = 1;
enum O_RDWR = 2;
enum O_CREAT = 64;
enum O_TRUNC = 512;
enum O_APPEND = 1024;

enum STDOUT_FILENO = 1;
enum F_DUPFD = 0;

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

extern(C) int putchar(int octet)
{
    import nanoc.os: syscall, SYS_write;
    char x = cast(char) octet;
    if (syscall(SYS_write, 1, &x, 1) >= 0)
    {
        return cast(int) x;
    }
    return EOF;
}

extern(C) int getchar()
{
    import nanoc.os: syscall, SYS_read;
    char x;
    int ret = cast(int) syscall(SYS_read, 0, &x, 1);
    if (ret >= 0)
    {
        return x;
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

extern(C) int fcntl(T...)(int fd, int op, T args)
{
    import nanoc.os: syscall, SYS_fcntl;
    return cast(int) syscall(fd, op, args);
}
