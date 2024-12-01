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
    import nanoc.std.stdio.file: File, fputs;
    return fputs(str, cast(File*) STDOUT_FILENO);
}

extern(C) int putchar(int octet)
{
    import nanoc.std.stdio.file: File, fputc;
    return fputc(octet, cast(File*) STDOUT_FILENO);
}

extern(C) int getchar()
{
    import nanoc.std.stdio.file: File, fgetc;
    return fgetc(cast(File*) STDOUT_FILENO);
}
