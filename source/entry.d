module nanoc.entry;

extern(C)
{
    void __nanoc_init(int argc, char** argv, char **envp)
    {
        import nanoc.elf;
        ulong[NANOC_AT_MAX] _aux;

        int i;
        for (i = 0; envp[i] !is null; i++) { }
        ulong* auxv = cast(ulong*)(envp) + i + 1;

        for (i = 0; auxv[i] != 0; i += 2)
        {
            if (auxv[i] < NANOC_AT_MAX)
            {
                _aux[auxv[i]] = auxv[i+1];
            }
        }
    }

    int main(int argc, char** argv, char** envp);

    int __nanoc_main(int argc, char** argv, char **envp)
    {
        return main(argc, argv, envp);
    }

    import core.attribute: weak;
    @weak void __fini() {}

    void __nanoc_fini()
    {
        __fini();
    }
}
