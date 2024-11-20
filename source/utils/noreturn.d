module nanoc.utils.noreturn;

/// No return function
noreturn never_be_reached()
{
    assert(false, "never be reached");
}
