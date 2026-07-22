module nanoc.std.stdarg;

//@SetKey("va_start(x,1)") @Nake enum _va_start = "__builtin_va_start(x,1)";

public import core.stdc.stdarg;

// import nanoc.d.args;

import nanoc.meta: Nake, MacroParameter;
//alias _va_start = WrapFunction!va_start;
// @SetKey("va_start") alias _va_start = va_start;
// @SetKey("va_arg") alias _va_arg = va_arg;
// @SetKey("va_copy") alias _va_copy = va_copy;
// alias _va_list = Type!(va_list, "va_list");
// @SetKey("va_end") alias _va_end = va_end;
// extern va_list core.stdc.stdarg.va_list;

// alias dlang_va_start = va_start;

//extern(C) void _va_start(out dlang_va_list ap, ref long parmn)
//{
//    return dlang_va_start(ap, parmn);
//}

version (GNU)
{
import gcc.builtins;
// alias va_list = __gnuc_va_list;
// alias __gnuc_va_list = __builtin_va_list;

// alias va_end = __builtin_va_end;
// alias va_copy = __builtin_va_copy;
// alias va_start = __builtin_va_start;
alias _va_arg = va_arg;

enum @Nake @MacroParameter("v,l") va_start = "__builtin_va_start";
enum @Nake @MacroParameter("d,s") va_copy = "__builtin_va_copy";
enum @Nake @MacroParameter("v") va_end = "__builtin_va_end";
}
// alias _va_end = WrapFunction!(va_end);
