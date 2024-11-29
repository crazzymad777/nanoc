module nanoc.std.stdio.format;

import std.meta: AliasSeq;
alias SubModules = AliasSeq!("print", "utils");
public import nanoc.std.stdio.format.print;
public import nanoc.std.stdio.format.utils;

unittest
{
    import nanoc.std.string: strcmp;
    char[32] buffer;
    immutable char* expected = "25 -42 hello!".ptr;
    int result = snprintf(cast(char*) buffer, 32, "%u %d %s", 25u, -42, cast(immutable char*)"hello!");
    assert(result >= 0);
    assert(strcmp(cast(char*)buffer, expected) == 0);
}
