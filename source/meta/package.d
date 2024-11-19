module nanoc.meta;

import std.traits;
import std.meta;


void footprint()
{
    static import nanoc.std.string;
    import nanoc.std.stdio;

    import std.stdio: writeln;

    foreach(m; __traits(derivedMembers, nanoc.std.string))
    {
        alias member = __traits(getMember, nanoc.std.string, m);
        static if (__traits(isStaticFunction, member))
        {
            puts((ReturnType!member).stringof);
            putchar(' ');
            puts(m);
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
