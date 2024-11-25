module nanoc.os.linux_amd64;

import nanoc.os.sysv.amd64.syscall;
import nanoc.os.sysv.amd64.linux;

noreturn exit(int status)
{
    import nanoc.utils.noreturn: never_be_reached;

    syscall(SYS_exit, status);
    never_be_reached(); // supress D error
}

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
    import nanoc.std.string: strlen;
    if (syscall(SYS_write, 1, str, strlen(str)) >= 0)
    {
        return 0;
    }
    return EOF;
}

extern(C) int putchar(int octet)
{
    char x = cast(char) octet;
    if (syscall(SYS_write, 1, &x, 1) >= 0)
    {
        return cast(int) x;
    }
    return EOF;
}

extern(C) int getchar()
{
    char x;
    int ret = cast(int) syscall(SYS_read, 0, &x, 1);
    if (ret >= 0)
    {
        return x;
    }
    return EOF;
}

/// open and possibly create a file
extern(C) int open(const char *pathname, int flags, mode_t mode)
{
    return cast(int) syscall(SYS_open, cast(void*) pathname, flags, mode);
}

extern(C) size_t write(int fd, const void* buf, size_t count)
{
    return syscall(SYS_write, fd, buf, count);
}

extern(C) size_t read(int fd, void* buf, size_t count)
{
    return syscall(SYS_read, fd, buf, count);
}

/// close a file descriptor
extern(C) int close(int fd)
{
    return cast(int) syscall(SYS_close, fd);
}

extern(C) int fcntl(T...)(int fd, int op, T args)
{
    return cast(int) syscall(SYS_fcntl, fd, op, args);
}

extern(C) int fsync(int fd)
{
    return cast(int) syscall(SYS_fsync, fd);
}

/// Fork process
int fork()
{
    return cast(int) syscall(SYS_fork);
}

extern (C) int rmdir(const char* pathname)
{
    return cast(int) syscall(SYS_rmdir, pathname);
}

extern (C) int unlink(const char* pathname)
{
    return cast(int) syscall(SYS_unlink, pathname);
}

long lseek(int fd, long offset, int whence)
{
    return syscall(SYS_lseek, fd, offset, whence);
}
