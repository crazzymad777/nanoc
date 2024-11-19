module nanoc.meta;

import std.meta;

struct ModuleDescriptor
{
    this(string name, string header) immutable
    {
        this.name = name;
        this.header = header;
    }
    immutable string name;
    immutable string header;
}

template Footprint()
{
    void build()
    {
        import nanoc.std.stdio;
        import nanoc.meta.mine;
        import std.traits;

        alias descriptors = AliasSeq!(
            immutable ModuleDescriptor("nanoc.std.string", "string.h"),
            immutable ModuleDescriptor("nanoc.std.stdlib", "stdlib.h"),
            immutable ModuleDescriptor("nanoc.std.stdio", "stdio.h"),
            immutable ModuleDescriptor("nanoc.std.unistd", "unistd.h"),
            immutable ModuleDescriptor("nanoc.sys.mman", "sys/mman.h"),
            immutable ModuleDescriptor("nanoc.sys.wait", "sys/wait.h")
        );

        //string result = "";
        static foreach(mod; descriptors)
        {
            MetaModule!(mod.name, mod.header).mine();
        }
        //return result;
    }
}

void footprint()
{
    import nanoc.std.stdio;
    Footprint!().build();
}

/+
immutable(string) footprint_module(string name)
{
    import nanoc.meta.mine;
    alias x = MetaModule!name;
    return x.mine();
}+/
