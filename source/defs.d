module nanoc.defs;

import nanoc.meta: SetKey, Nake;
import std.meta;

@SetKey("noreturn") @Nake enum _noreturn = "[[ noreturn ]] void";
@SetKey("ulong") @Nake enum _ulong = "unsigned long";
@SetKey("ubyte") @Nake enum _ubyte = "unsigned char";
@SetKey("byte") @Nake enum _byte = "char";

struct FILE {}

