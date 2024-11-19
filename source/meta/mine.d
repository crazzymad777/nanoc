module nanoc.meta.mine;

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
        void put_string(string x)
        {
            profit(x);
        }

        void put(char x)
        {
            profit(x);
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

                        put_string((ReturnType!member).stringof);
                        put(' ');
                        put_string(x);
                        put('(');
                        int i = 0;
                        foreach (p ; Parameters!member)
                        {
                            if (i > 0) put_string(", ");
                            put_string(p.stringof);
                            i++;
                        }
                        put(')');
                        put(';');
                        put(10);
                    }
                }
            }
        }
    }
}
