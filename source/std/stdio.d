module nanoc.std.stdio;

enum EOF = -1;

extern(C) int puts(const char *str)
{
    import nanoc.os.sysv.amd64.syscall;
    if (syscall(1, 1, str, strlen(str)) >= 0)
    {
        return 0;
    }
    return EOF;
}

extern(C) size_t strlen(const char *str)
{
    size_t i = 0;
    while(str[i] != 0)
    {
        i++;
    }
    return i;
}

extern(C) size_t write(int fd, const void[] buf, size_t count)
{
    import nanoc.os.sysv.amd64.syscall;
    return syscall(1, fd, cast(void*) buf, count);
}