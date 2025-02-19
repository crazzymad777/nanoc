module nanoc.meta.show;

import nanoc.meta;

version (DISABLE_METADATA)
{
}
else
{
import std.traits;
import std.meta;
import nanoc.std.stdio;

private
enum StreamModificator
{
    NONE,
    TRANSLATE
}

private __gshared StreamModificator sm = StreamModificator.NONE;

/// Print character
private void profit(char x)
{
    import nanoc.std.ctype: toupper;
    if (sm == StreamModificator.TRANSLATE)
    {
        x = cast(char) toupper(cast(int) x);
    }
    if (x == '.')
    {
        x = '_';
    }
    if (x == '/')
    {
        x = '_';
    }
    putchar(x);
}

/// Print string
private void profit(string y)
{
    if (sm == StreamModificator.TRANSLATE)
    {
        foreach (x; y)
        {
            profit(x);
        }
    }
    else
    {
        puts(y.ptr);
    }
}

/// Change stream modificator
private void profit(StreamModificator m)
{
    sm = m;
}

private void put_alias_seq(T...)(T args)
{
    foreach(m; args) profit(m);
}

template Unqualing(alias T)
if(isPointer!T)
{
    alias Unqualed = Unqualing!(PointerTarget!T);
    alias Unqualing = Unqualed*;
}

template Unqualing(alias T)
if(!isPointer!T)
{
    alias Unqualing = Unqual!T;
}

/// Prints declaration of static function, struct, enum, union, variable or constant
void show_meta_member(string x, alias member)()
{
    static if (__traits(isStaticFunction, member))
    {
        //puts(functionLinkage!member); // "D", "C", "C++", "Windows", "Objective-C", or "System".

        static if (functionLinkage!member == "C")
        {
            put_alias_seq((ReturnType!member).stringof, ' ', x, '(');
            alias names = ParameterIdentifierTuple!member;
            // alias names = AliasSeq!(ParameterIdentifierTuple!member);
            int n = 0;
            foreach (i, p; Parameters!member)
            {
                if (i > 0) put_alias_seq(", ");
                put_alias_seq(Unqualing!(p).stringof);
                static if (names[i] != "")
                {
                    put_alias_seq(" ", names[i]);
                }
                n++;
            }
            // static if (variadicFunctionStyle!member == Variadic.c)
            // {
            //     if (n > 0) put_alias_seq(", ");
            //     put_alias_seq("...");
            // }
            put_alias_seq(");\n");
        }
    } else {
        static if (__traits(isTemplate, member)) {
            put_alias_seq("// template: ", member.stringof, ' ', x, ";\n");
        }
        else if (__traits(isModule, member) || __traits(isPackage, member))
        {
        }
        else
        {
            static if (isType!member)
            {
                alias T = CommonType!member;
                static if (isAggregateType!T)
                {
                    static if (is(T == enum)) {
                        put_alias_seq("// Enum: ", member.stringof, "\n");
                    }
                    else static if (is(T == struct))
                    {
                        put_alias_seq("typedef struct {} ", member.stringof, ";\n");
                    }
                    else static if (is(T == union))
                    {
                        put_alias_seq("// Union: ", member.stringof, "\n");
                    }
                    else
                    {
                        put_alias_seq("// Aggregate Type: ", member.stringof, "\n");
                    }
                }
                else
                {
                    put_alias_seq("typedef ", member.stringof, ' ', x, ";\n");
                }
            }
            else
            {
                static if (x == member.stringof && !is(member : string))
                {
                    put_alias_seq("extern ", (Unqualing!(CommonType!member)).stringof , " ", x, ";\n");
                }
                else
                {
                    static if (hasUDA!(member, Nake))
                        const value = member;
                    else
                        const value = member.stringof;

                    static if (hasUDA!(member, SetKey))
                        const key = getUDAs!(member, SetKey)[0].name;
                    else
                        const key = x;

                    static if (hasUDA!(member, Typedef))
                    {
                        put_alias_seq("typedef ", value, " ", key, ";\n");
                    }
                    else
                    {
                        put_alias_seq("#define ", key, " ", value, "\n");
                    }
                }
            }
        }

        // pragma(msg, member);
    }
}

/// Prints module declaration
void show_meta_module(string M, string H, string G)()
{
    static if (M == G)
    {
        put_alias_seq("#ifndef NANOC_MODULE_", StreamModificator.TRANSLATE, H, StreamModificator.NONE, "\n");
        put_alias_seq("#define NANOC_MODULE_", StreamModificator.TRANSLATE, H, StreamModificator.NONE, "\n");
        static if (M != "nanoc.defs")
        {
            put_alias_seq("#include <nanoc/defs.h>\n");
        }
        put_alias_seq("// This header file for module " ~ M ~ " autogenerated by NanoC metadata.\n");
    }
    else
    {
        put_alias_seq("// submodule: " ~ M ~ "\n");
    }

    mixin("static import " ~ M ~ ";");

    alias module_alias = mixin(M);
    foreach(x; __traits(allMembers, module_alias))
    {
        alias member = __traits(getMember, module_alias, x);
        static if (x == "SubModules")
        {
            foreach(mod; member)
            {
                show_meta_module!(M ~ "." ~ mod, H, G)();
            }
        }
        else static if (x == "Includes")
        {
            foreach (file; member)
            {
                put_alias_seq("#include <", file, ">\n");
            }
        }
        else
        {
            static if (__traits(isTemplate, member) || !hasUDA!(member, Omit))
            {
                show_meta_member!(x, member)();
            }
        }
    }

    static if (M == G)
    {
        put_alias_seq("#endif\n");
    }
    else
    {
        put_alias_seq("// submodule " ~ M ~ " end\n");
    }
}
}
