module nanoc.meta.mine;

import nanoc.meta;

version (DISABLE_METADATA)
{
}
else
{
import std.traits;
import std.meta;
import nanoc.std.stdio;

enum StreamModificator
{
    NONE,
    TRANSLATE
}

static StreamModificator sm = StreamModificator.NONE;

void profit(char x)
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
    //fsync(STDOUT_FILENO);
}

void profit(string y)
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

void profit(StreamModificator m)
{
    sm = m;
}

template MetaModule(string M, string H, string G)
{
    void mine()
    {
        void put_alias_seq(T...)(T args)
        {
            foreach(m; args) profit(m);
        }

        if (M == G)
        {
            put_alias_seq("// module ", StreamModificator.TRANSLATE, M, StreamModificator.NONE, "\n");
            put_alias_seq("#ifndef NANOC_MODULE_", StreamModificator.TRANSLATE, H, StreamModificator.NONE, "\n");
            put_alias_seq("#define NANOC_MODULE_", StreamModificator.TRANSLATE, H, StreamModificator.NONE, "\n");
        }
        else
        {
            put_alias_seq("// submodule " ~ M ~ "\n");
        }
        put_alias_seq('\n');

        mixin("static import " ~ M ~ ";");

        alias module_alias = mixin(M);
        foreach(x; __traits(allMembers, module_alias))
        {
            alias member = __traits(getMember, module_alias, x);
            static if (x == "SubModules")
            {
                foreach(mod; member)
                {
                    alias submodule = MetaModule!(M ~ "." ~ mod, H, G);
                    submodule.mine();
                }
            }
            else
            {
                static if (!hasUDA!(member, "metaomit"))
                {
                    static if (__traits(isStaticFunction, member))
                    {
                        //puts(functionLinkage!member); // "D", "C", "C++", "Windows", "Objective-C", or "System".

                        put_alias_seq((ReturnType!member).stringof, ' ', x, '(');
                        int i = 0;
                        foreach (p ; Parameters!member)
                        {
                            if (i > 0) put_alias_seq(", ");
                            put_alias_seq(p.stringof);
                            i++;
                        }
                        put_alias_seq(");\n");
                    }
                }
            }
        }

        if (M == G)
        {
            put_alias_seq("#endif\n");
        }
        else
        {
            put_alias_seq("// submodule " ~ M ~ " end\n");
        }
    }
}
}
