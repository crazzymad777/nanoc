module nanoc.std.wchar_;

import nanoc.meta: SetKey, Nake, Typedef;
import std.meta: Alias, AliasSeq;
@Typedef @SetKey("wchar_t") @Nake enum _dchar = "dchar";
alias WEOF = Alias!(-1);

import nanoc.std.string;

extern(C) size_t wcslen(const dchar *str)
{
    return astrlen!(dchar)(str);
}

unittest
{
    assert(wcslen("Привет, мир!\r\n") == 14);
}

extern(C) int wcscmp(const dchar *s1, const dchar *s2)
{
    return astrcmp!(dchar)(s1, s2);
}

extern(C) dchar* wcschr(const dchar *str, int c)
{
    return astrchr!(dchar)(str, c);
}
