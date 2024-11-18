module nanoc.std.stdlib.tests.memory;
import nanoc.std.stdlib.memory;

unittest
{
    size_t size = 4096;
    MemoryBlock* mb = _allocate_primary_memory_block(size);
    if (mb is null)
    {
        assert(false, "_allocate_primary_memory_block failed");
    }

    assert(mb.flags == (MemoryBlock.CLAIMED | MemoryBlock.PRIMARY));
    assert(mb.size == size);
    assert(_allocate_primary_memory_block(MemoryBlock.sizeof-1) is null);
}
