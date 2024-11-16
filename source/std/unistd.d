module nanoc.std.unistd;

extern (C) int fork()
{
    import nanoc.os: syscall, SYS_fork;
    return cast(int) syscall(SYS_fork);
}
