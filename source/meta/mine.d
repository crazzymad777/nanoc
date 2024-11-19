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

void profit(char x)
{
    putchar(x);
}

void profit(string x)
{
    puts(x.ptr);
}

template MetaModule(string M, string H)
{
    void mine()
    {
        void put_alias_seq(T...)(T args)
        {
            foreach(m; args) profit(m);
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
                    alias submodule = MetaModule!(M ~ "." ~ mod, H);
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
    }
}
}
