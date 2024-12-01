module nanoc.meta.external;

version (DISABLE_METADATA)
{
}
else
{
    import nanoc.meta;

    extern(C) int metadata_version()
    {
        return 0;
    }

    extern(C) void metadata_query(void* ptr)
    {
        if (ptr == cast(void*) 1)
        {
            footprint();
            return;
        }

        if (ptr == cast(void*) 2)
        {
            footprint_all();
            return;
        }
    }
}
