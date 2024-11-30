module nanoc.std.stdio.common;

public import nanoc.os;

enum EOF = OS_EOF;
enum O_RDWR = OS_READ_AND_WRITE;
enum O_WRONLY = OS_WRITE_ONLY;
enum O_CREAT = OS_CREATE;
enum O_APPEND = OS_APPEND;
enum O_TRUNC = OS_TRUNCATE;
enum O_RONLY = OS_READ_ONLY;

enum STDIN_FILENO = OS_STDIN_FILENO;
enum STDOUT_FILENO = OS_STDOUT_FILENO;
enum STDERR_FILENO = OS_STDERR_FILENO;
enum F_DUPFD = OS_F_DUPFD;

extern (C) int open(const char *pathname, int flags, mode_t mode)
{
    import nanoc.os: fsopen;
    return fsopen(StringBuffer(pathname, -1), flags, mode);
}

extern (C) int close(int fd)
{
    import nanoc.os: sclose;
    return sclose(fd);
}

extern (C) size_t write(int fd, const char* buf, size_t count)
{
    import nanoc.os: MemoryChunk;
    import nanoc.os: swrite;
    return swrite(fd, MemoryChunk(buf, count));
}

extern (C) size_t read(int fd, char* buf, size_t count)
{
    import nanoc.os: MemoryChunk;
    import nanoc.os: sread;
    return sread(fd, MemoryChunk(buf, count));
}

extern(C) int puts(const char *str)
{
    import nanoc.os: StringBuffer;
    import nanoc.os: swrite_sb;
    auto r = swrite_sb(OS_STDOUT_FILENO, StringBuffer(str, -1));
    putchar(10);
    return cast(int) r;
}

extern(C) int putchar(int octet)
{
    import nanoc.os: swrite_single;
    int r = swrite_single(OS_STDOUT_FILENO, cast(char) octet);
    if (r == OS_EOF)
    {
        return EOF;
    }
    return cast(char) octet;
}

extern(C) int getchar()
{
    import nanoc.os: swrite_single;
    int r = sread_single(OS_STDIN_FILENO);
    if (r == OS_EOF)
    {
        return EOF;
    }
    return cast(char) r;
}
