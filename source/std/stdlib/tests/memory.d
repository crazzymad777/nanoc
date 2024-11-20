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

    assert(smb.field.flags == MemoryBlock.NEXT_HEAP_POINTER);
    assert(smb.field.next_super_heap is null);
    assert(smb.head.flags == (MemoryBlock.NANOC_MEMORY | MemoryBlock.HEAD));
    assert(smb.head.size == size - MemoryBlock.sizeof * 4);

    byte* tail_in_bytes = cast(byte*) &smb.data + size - MemoryBlock.sizeof*4;
    MemoryBlock* tail = cast(MemoryBlock*) tail_in_bytes;
    assert(tail.flags == (MemoryBlock.NANOC_MEMORY | MemoryBlock.TAIL));
    assert(tail.head == &smb.head);
    assert(_init_super_block(MemoryBlock.sizeof*4-1) is null);
}

unittest
{
    byte* bytes = cast(byte*) _malloc(4096 * 2);
    if (bytes is null)
    {
        assert(false, "_malloc failed");
    }
    _free(bytes);
}


unittest
{
    const number = 4048*2;
    void*[number] ptrs;
    for (int i = 0; i < number; i++)
    {
        ptrs[i] = cast(byte*) _malloc(i%8+1); // very tiny allocations
        assert(cast(int)ptrs[i] % 2 == 0);

        if (i > 0)
        {
            assert(ptrs[i-1] != ptrs[i]);
        }

        if (ptrs[i] is null)
        {
            assert(false, "very tiny _malloc failed");
        }
    }

    for (int i = 0; i < number; i++)
    {
        _free(ptrs[i]);
    }
}
