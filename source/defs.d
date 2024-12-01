module nanoc.defs;

import nanoc.meta: SetKey, Nake, Typedef;
import std.meta;

alias Includes = AliasSeq!("uchar.h");

@SetKey("noreturn") @Nake enum _noreturn = "[[ noreturn ]] void";
@Typedef @SetKey("dchar") @Nake enum _dchar = "char32_t";
@Typedef @SetKey("wchar") @Nake enum _wchar = "char16_t";
@Typedef @SetKey("ushort") @Nake enum _ushort = "unsigned short";
@Typedef @SetKey("uint") @Nake enum _uint = "unsigned";
@Typedef @SetKey("ulong") @Nake enum _ulong = "unsigned long";
@Typedef @SetKey("ubyte") @Nake enum _ubyte = "unsigned char";
@Typedef @SetKey("byte") @Nake enum _byte = "char";
