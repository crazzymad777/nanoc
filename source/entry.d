module nanoc.entry;

extern(C) int main(int argc, char** argv);

extern(C) int __nanoc_main(int argc, char** argv)
{
    return main(argc, argv);
}
