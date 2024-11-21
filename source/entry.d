module nanoc.entry;

extern(C)
{
    void __nanoc_init()
    {

    }

    int main(int argc, char** argv);

    int __nanoc_main(int argc, char** argv)
    {
        return main(argc, argv);
    }

    import core.attribute: weak;
    @weak void __fini() {}

    void __nanoc_fini()
    {
        __fini();
    }
}
