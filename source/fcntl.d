module nanoc.fcntl;

extern(C) int fcntl(T...)(int fd, int op, T args)
{
    import nanoc.os: fscntl;
    return fscntl(fd, op, args);
}

public import nanoc.os;
