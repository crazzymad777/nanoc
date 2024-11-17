module nanoc.std.stdlib;

extern (C) noreturn exit(int status)
{
    import nanoc.utils.noreturn: never_be_reached;
    import nanoc.os: syscall, SYS_exit;
    syscall(SYS_exit, status);
    never_be_reached(); // supress D warning
}
