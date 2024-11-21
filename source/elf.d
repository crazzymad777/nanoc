/* This file defines standard ELF types, structures, and macros.
   Copyright (C) 1995-2024 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */

module nanoc.elf;

/* Standard ELF types.  */

/* Type for a 16-bit quantity.  */
alias Elf32_Half = ushort;
alias Elf64_Half = ushort;

/* Types for signed and unsigned 32-bit quantities.  */
alias Elf32_Word = uint;
alias Elf32_Sword = int;
alias Elf64_Word = uint;
alias Elf64_Sword = int;

/* Types for signed and unsigned 64-bit quantities.  */
alias Elf32_Xword = ulong;
alias Elf32_Sxword = long;
alias Elf64_Xword = ulong;
alias Elf64_Sxword = long;

/* Type of addresses.  */
alias Elf32_Addr = uint;
alias Elf64_Addr = long;

/* Type of file offsets.  */
alias Elf32_Off = uint;
alias Elf64_Off = ulong;

/* Type for section indices, which are 16-bit quantities.  */
alias Elf32_Section = ushort;
alias Elf64_Section = ushort;

/* Type for version symbol information.  */
alias Elf32_Versym = ushort;
alias Elf64_Versym = ushort;

/* Auxiliary vector.  */

/* This vector is normally only used by the program interpreter.  The
   usual definition in an ABI supplement uses the name auxv_t.  The
   vector is not usually defined in a standard <elf.h> file, but it
   can't hurt.  We rename it to avoid conflicts.  The sizes of these
   types are an arrangement between the exec server and the program
   interpreter, so we don't fully specify them here.  */

struct Elf32_auxv_t
{
    uint a_type; /* Entry type */

    /* Integer value */
    /* We use to have pointer elements added here.  We cannot do that,
    	 though, since it does not work when using 32-bit definitions
    	 on 64-bit platforms and vice versa.  */
    union a_un
    {
        uint a_val;
    }
}

struct Elf64_auxv_t
{
    ulong a_type; /* Entry type */

    /* Integer value */
    /* We use to have pointer elements added here.  We cannot do that,
    	 though, since it does not work when using 32-bit definitions
    	 on 64-bit platforms and vice versa.  */
    union a_un
    {
        ulong a_val;
    }
}

/* Legal values for a_type (entry type).  */

enum AT_NULL = 0; /* End of vector */
enum AT_IGNORE = 1; /* Entry should be ignored */
enum AT_EXECFD = 2; /* File descriptor of program */
enum AT_PHDR = 3; /* Program headers for program */
enum AT_PHENT = 4; /* Size of program header entry */
enum AT_PHNUM = 5; /* Number of program headers */
enum AT_PAGESZ = 6; /* System page size */
enum AT_BASE = 7; /* Base address of interpreter */
enum AT_FLAGS = 8; /* Flags */
enum AT_ENTRY = 9; /* Entry point of program */
enum AT_NOTELF = 10; /* Program is not ELF */
enum AT_UID = 11; /* Real uid */
enum AT_EUID = 12; /* Effective uid */
enum AT_GID = 13; /* Real gid */
enum AT_EGID = 14; /* Effective gid */
enum AT_CLKTCK = 17; /* Frequency of times() */

/* Some more special a_type values describing the hardware.  */
enum AT_PLATFORM = 15; /* String identifying platform.  */
enum AT_HWCAP = 16; /* Machine-dependent hints about
					   processor capabilities.  */

/* This entry gives some information about the FPU initialization
   performed by the kernel.  */
enum AT_FPUCW = 18; /* Used FPU control word.  */

/* Cache block sizes.  */
enum AT_DCACHEBSIZE = 19; /* Data cache block size.  */
enum AT_ICACHEBSIZE = 20; /* Instruction cache block size.  */
enum AT_UCACHEBSIZE = 21; /* Unified cache block size.  */

/* A special ignored value for PPC, used by the kernel to control the
   interpretation of the AUXV. Must be > 16.  */
enum AT_IGNOREPPC = 22; /* Entry should be ignored.  */

enum AT_SECURE = 23; /* Boolean, was exec setuid-like?  */

enum AT_BASE_PLATFORM = 24; /* String identifying real platforms.*/

enum AT_RANDOM = 25; /* Address of 16 random bytes.  */

enum AT_HWCAP2 = 26; /* More machine-dependent hints about
					   processor capabilities.  */

enum AT_RSEQ_FEATURE_SIZE = 27; /* rseq supported feature size.  */
enum AT_RSEQ_ALIGN = 28; /* rseq allocation alignment.  */

/* More machine-dependent hints about processor capabilities.  */
enum AT_HWCAP3 = 29; /* extension of AT_HWCAP.  */
enum AT_HWCAP4 = 30; /* extension of AT_HWCAP.  */

enum AT_EXECFN = 31; /* Filename of executable.  */

/* Pointer to the global system page used for system calls and other
   nice things.  */
enum AT_SYSINFO = 32;
enum AT_SYSINFO_EHDR = 33;

/* Shapes of the caches.  Bits 0-3 contains associativity; bits 4-7 contains
   log2 of line size; mask those to get cache size.  */
enum AT_L1I_CACHESHAPE = 34;
enum AT_L1D_CACHESHAPE = 35;
enum AT_L2_CACHESHAPE = 36;
enum AT_L3_CACHESHAPE = 37;

/* Shapes of the caches, with more room to describe them.
   *GEOMETRY are comprised of cache line size in bytes in the bottom 16 bits
   and the cache associativity in the next 16 bits.  */
enum AT_L1I_CACHESIZE = 40;
enum AT_L1I_CACHEGEOMETRY = 41;
enum AT_L1D_CACHESIZE = 42;
enum AT_L1D_CACHEGEOMETRY = 43;
enum AT_L2_CACHESIZE = 44;
enum AT_L2_CACHEGEOMETRY = 45;
enum AT_L3_CACHESIZE = 46;
enum AT_L3_CACHEGEOMETRY = 47;

enum AT_MINSIGSTKSZ = 51; /* Stack needed for signal delivery  */
enum NANOC_AT_MAX = AT_MINSIGSTKSZ + 1;

/* Program segment header.  */

struct Elf32_Phdr
{
    Elf32_Word p_type; /* Segment type */
    Elf32_Off p_offset; /* Segment file offset */
    Elf32_Addr p_vaddr; /* Segment virtual address */
    Elf32_Addr p_paddr; /* Segment physical address */
    Elf32_Word p_filesz; /* Segment size in file */
    Elf32_Word p_memsz; /* Segment size in memory */
    Elf32_Word p_flags; /* Segment flags */
    Elf32_Word p_align; /* Segment alignment */
}

struct Elf64_Phdr
{
    Elf64_Word p_type; /* Segment type */
    Elf64_Word p_flags; /* Segment flags */
    Elf64_Off p_offset; /* Segment file offset */
    Elf64_Addr p_vaddr; /* Segment virtual address */
    Elf64_Addr p_paddr; /* Segment physical address */
    Elf64_Xword p_filesz; /* Segment size in file */
    Elf64_Xword p_memsz; /* Segment size in memory */
    Elf64_Xword p_align; /* Segment alignment */
}

/* Special value for e_phnum.  This indicates that the real number of
   program headers is too large to fit into e_phnum.  Instead the real
   value is in the field sh_info of section 0.  */

enum PN_XNUM = 0xffff;

/* Legal values for p_type (segment type).  */

enum PT_NULL = 0; /* Program header table entry unused */
enum PT_LOAD = 1; /* Loadable program segment */
enum PT_DYNAMIC = 2; /* Dynamic linking information */
enum PT_INTERP = 3; /* Program interpreter */
enum PT_NOTE = 4; /* Auxiliary information */
enum PT_SHLIB = 5; /* Reserved */
enum PT_PHDR = 6; /* Entry for header table itself */
enum PT_TLS = 7; /* Thread-local storage segment */
enum PT_NUM = 8; /* Number of defined types */
enum PT_LOOS = 0x60000000; /* Start of OS-specific */
enum PT_GNU_EH_FRAME = 0x6474e550; /* GCC .eh_frame_hdr segment */
enum PT_GNU_STACK = 0x6474e551; /* Indicates stack executability */
enum PT_GNU_RELRO = 0x6474e552; /* Read-only after relocation */
enum PT_GNU_PROPERTY = 0x6474e553; /* GNU property */
enum PT_GNU_SFRAME = 0x6474e554; /* SFrame segment.  */
enum PT_LOSUNW = 0x6ffffffa;
enum PT_SUNWBSS = 0x6ffffffa; /* Sun Specific segment */
enum PT_SUNWSTACK = 0x6ffffffb; /* Stack segment */
enum PT_HISUNW = 0x6fffffff;
enum PT_HIOS = 0x6fffffff; /* End of OS-specific */
enum PT_LOPROC = 0x70000000; /* Start of processor-specific */
enum PT_HIPROC = 0x7fffffff; /* End of processor-specific */

/* Legal values for p_flags (segment flags).  */

enum PF_X = 1 << 0; /* Segment is executable */
enum PF_W = 1 << 1; /* Segment is writable */
enum PF_R = 1 << 2; /* Segment is readable */
enum PF_MASKOS = 0x0ff00000; /* OS-specific */
enum PF_MASKPROC = 0xf0000000; /* Processor-specific */
