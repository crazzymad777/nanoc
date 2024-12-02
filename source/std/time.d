module nanoc.std.time;

enum CLOCKS_PER_SEC = 1000000;
alias clock_t = long;
alias time_t = long;

extern(C) time_t time(time_t* location)
{
    static import nanoc.os;
    auto r = nanoc.os.time();
    if (location !is null)
    {
        *location = r;
    }
    return r;
}

import nanoc.os: timeval;

private clock_t timeval_to_clock_t(timeval s)
{
    return s.tv_sec * CLOCKS_PER_SEC + s.tv_usec / (1000000 / CLOCKS_PER_SEC);
}

extern(C) clock_t clock()
{
    import nanoc.os;
    rusage resources;
    if (getrusage(0, &resources) == 0)
    {
        return timeval_to_clock_t(resources.ru_utime) + timeval_to_clock_t(resources.ru_stime);
    }
    return cast(clock_t) -1;
}

