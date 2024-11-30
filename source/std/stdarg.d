module nanoc.std.stdarg;

static import core.stdc.stdarg;

alias va_list = core.stdc.stdarg.va_list;
alias va_start = core.stdc.stdarg.va_start;
alias va_end = core.stdc.stdarg.va_end;
alias va_arg = core.stdc.stdarg.va_arg;
alias va_copy = core.stdc.stdarg.va_copy;
