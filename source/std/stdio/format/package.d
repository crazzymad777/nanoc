module nanoc.std.stdio.format;

import std.meta: AliasSeq;
alias SubModules = AliasSeq!("print", "utils");
public import nanoc.std.stdio.format.print;
public import nanoc.std.stdio.format.utils;
