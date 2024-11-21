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
