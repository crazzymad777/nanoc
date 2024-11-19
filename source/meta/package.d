module nanoc.meta;

import nanoc.std.stdio;
import nanoc.std.string;
import std.traits;
import std.meta;

template MetaModule(string M)
{
    void show()
    {
        mixin("static import " ~ M ~ ";");

        alias module_alias = mixin(M);
        foreach(x; __traits(allMembers, module_alias))
        {
            alias member = __traits(getMember, module_alias, x);
            static if (x == "SubModules")
            {
                foreach(mod; member)
                {

                    alias submodule = MetaModule!(M ~ "." ~ mod);
                    submodule.show();
                }
            }
            else
            {
                static if (!hasUDA!(member, "metaomit"))
                {
                    static if (__traits(isStaticFunction, member))
                    {
                        //puts(functionLinkage!member); // "D", "C", "C++", "Windows", "Objective-C", or "System".

                        puts((ReturnType!member).stringof);
                        putchar(' ');
                        puts(x);
                        putchar('(');
                        int i = 0;
                        foreach (p ; Parameters!member)
                        {
                            if (i > 0) puts(", ");
                            puts(p.stringof);
                            i++;
                        }
                        putchar(')');
                        putchar(';');
                        putchar(10);
                    }
                }
            }
        }
    }
}

void footprint()
{
    //import nanoc.std.stdio;

    foreach(mod; AliasSeq!("nanoc.std.string", "nanoc.std.stdlib", "nanoc.std.stdio", "nanoc.std.unistd", "nanoc.sys.mman", "nanoc.sys.wait"))
    {
        alias x = MetaModule!mod;
        x.show();
    }
}

