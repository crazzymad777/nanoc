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

unittest
{
    size_t size = 4096;
    SuperMemoryBlock* smb = _init_super_block(size);
    if (smb is null)
    {
        assert(false, "_init_super_block failed");
    }

    assert(smb.entry.flags == (MemoryBlock.CLAIMED | MemoryBlock.PRIMARY | MemoryBlock.NANOC_MEMORY | MemoryBlock.SUPERBLOCK));
    assert(smb.entry.size == size);
    //assert(smb.field.flags == MemoryBlock.NEXT_HEAP_POINTER);
    //assert(smb.field.next_super_heap == 0);
    assert(smb.head.flags == (MemoryBlock.NANOC_MEMORY | MemoryBlock.HEAD));
    assert(smb.head.size == size - MemoryBlock.sizeof * 3);

    MemoryBlock* tail = cast(MemoryBlock*) (&smb.entry.data + size - MemoryBlock.sizeof*2);
    assert(tail.flags == (MemoryBlock.NANOC_MEMORY | MemoryBlock.TAIL));
    assert(tail.head == &smb.head);
    assert(_init_super_block(MemoryBlock.sizeof*4-1) is null);
}
