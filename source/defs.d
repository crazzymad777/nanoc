module nanoc.defs;

import nanoc.meta: SetKey, Nake;
import std.meta;

alias Includes = AliasSeq!("uchar.h");

@SetKey("noreturn") @Nake enum _noreturn = "[[ noreturn ]] void";
@SetKey("dchar") @Nake enum _dchar = "char32_t";
@SetKey("wchar") @Nake enum _wchar = "char16_t";
@SetKey("ushort") @Nake enum _ushort = "unsigned short";
@SetKey("uint") @Nake enum _uint = "unsigned";
@SetKey("ulong") @Nake enum _ulong = "unsigned long";
@SetKey("ubyte") @Nake enum _ubyte = "unsigned char";
@SetKey("byte") @Nake enum _byte = "char";

struct FILE {}

