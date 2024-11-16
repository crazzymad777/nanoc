module nanoc.utils.noreturn;

extern (C) noreturn never_be_reached()
{
    assert(false, "never be reached");
}
