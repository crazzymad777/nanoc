module nanoc.std.stdio;

import std.meta: AliasSeq;
alias SubModules = AliasSeq!("common", "format", "file");
public import nanoc.std.stdio.common;
public import nanoc.std.stdio.format;
public import nanoc.std.stdio.file;

extern (C) void dump_it(int i)
{
    printf("%d\n", i);
}
