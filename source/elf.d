/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */

module nanoc.elf;

extern (C):

/* 32-bit ELF base types. */
alias Elf32_Addr = uint;
alias Elf32_Half = ushort;
alias Elf32_Off = uint;
alias Elf32_Sword = int;
alias Elf32_Word = uint;

/* 64-bit ELF base types. */
alias Elf64_Addr = ulong;
alias Elf64_Half = ushort;
alias Elf64_SHalf = short;
alias Elf64_Off = ulong;
alias Elf64_Sword = int;
alias Elf64_Word = uint;
alias Elf64_Xword = ulong;
alias Elf64_Sxword = long;

/* These constants are for the segment types stored in the image headers */
enum PT_NULL = 0;
enum PT_LOAD = 1;
enum PT_DYNAMIC = 2;
enum PT_INTERP = 3;
enum PT_NOTE = 4;
enum PT_SHLIB = 5;
enum PT_PHDR = 6;
enum PT_TLS = 7; /* Thread local storage segment */
enum PT_LOOS = 0x60000000; /* OS-specific */
enum PT_HIOS = 0x6fffffff; /* OS-specific */
enum PT_LOPROC = 0x70000000;
enum PT_HIPROC = 0x7fffffff;
enum PT_GNU_EH_FRAME = PT_LOOS + 0x474e550;
enum PT_GNU_STACK = PT_LOOS + 0x474e551;
enum PT_GNU_RELRO = PT_LOOS + 0x474e552;
enum PT_GNU_PROPERTY = PT_LOOS + 0x474e553;

/* ARM MTE memory tag segment type */
enum PT_AARCH64_MEMTAG_MTE = PT_LOPROC + 0x2;

/*
 * Extended Numbering
 *
 * If the real number of program header table entries is larger than
 * or equal to PN_XNUM(0xffff), it is set to sh_info field of the
 * section header at index 0, and PN_XNUM is set to e_phnum
 * field. Otherwise, the section header at index 0 is zero
 * initialized, if it exists.
 *
 * Specifications are available in:
 *
 * - Oracle: Linker and Libraries.
 *   Part No: 817–1984–19, August 2011.
 *   https://docs.oracle.com/cd/E18752_01/pdf/817-1984.pdf
 *
 * - System V ABI AMD64 Architecture Processor Supplement
 *   Draft Version 0.99.4,
 *   January 13, 2010.
 *   http://www.cs.washington.edu/education/courses/cse351/12wi/supp-docs/abi.pdf
 */
enum PN_XNUM = 0xffff;

/* These constants define the different elf file types */
enum ET_NONE = 0;
enum ET_REL = 1;
enum ET_EXEC = 2;
enum ET_DYN = 3;
enum ET_CORE = 4;
enum ET_LOPROC = 0xff00;
enum ET_HIPROC = 0xffff;

/* This is the info that is needed to parse the dynamic section of the file */
enum DT_NULL = 0;
enum DT_NEEDED = 1;
enum DT_PLTRELSZ = 2;
enum DT_PLTGOT = 3;
enum DT_HASH = 4;
enum DT_STRTAB = 5;
enum DT_SYMTAB = 6;
enum DT_RELA = 7;
enum DT_RELASZ = 8;
enum DT_RELAENT = 9;
enum DT_STRSZ = 10;
enum DT_SYMENT = 11;
enum DT_INIT = 12;
enum DT_FINI = 13;
enum DT_SONAME = 14;
enum DT_RPATH = 15;
enum DT_SYMBOLIC = 16;
enum DT_REL = 17;
enum DT_RELSZ = 18;
enum DT_RELENT = 19;
enum DT_PLTREL = 20;
enum DT_DEBUG = 21;
enum DT_TEXTREL = 22;
enum DT_JMPREL = 23;
enum DT_ENCODING = 32;
enum OLD_DT_LOOS = 0x60000000;
enum DT_LOOS = 0x6000000d;
enum DT_HIOS = 0x6ffff000;
enum DT_VALRNGLO = 0x6ffffd00;
enum DT_VALRNGHI = 0x6ffffdff;
enum DT_ADDRRNGLO = 0x6ffffe00;
enum DT_ADDRRNGHI = 0x6ffffeff;
enum DT_VERSYM = 0x6ffffff0;
enum DT_RELACOUNT = 0x6ffffff9;
enum DT_RELCOUNT = 0x6ffffffa;
enum DT_FLAGS_1 = 0x6ffffffb;
enum DT_VERDEF = 0x6ffffffc;
enum DT_VERDEFNUM = 0x6ffffffd;
enum DT_VERNEED = 0x6ffffffe;
enum DT_VERNEEDNUM = 0x6fffffff;
enum OLD_DT_HIOS = 0x6fffffff;
enum DT_LOPROC = 0x70000000;
enum DT_HIPROC = 0x7fffffff;

/* This info is needed when parsing the symbol table */
enum STB_LOCAL = 0;
enum STB_GLOBAL = 1;
enum STB_WEAK = 2;

enum STT_NOTYPE = 0;
enum STT_OBJECT = 1;
enum STT_FUNC = 2;
enum STT_SECTION = 3;
enum STT_FILE = 4;
enum STT_COMMON = 5;
enum STT_TLS = 6;

extern (D) auto ELF_ST_BIND(T)(auto ref T x)
{
    return x >> 4;
}

extern (D) auto ELF_ST_TYPE(T)(auto ref T x)
{
    return x & 0xf;
}

alias ELF32_ST_BIND = ELF_ST_BIND;
alias ELF32_ST_TYPE = ELF_ST_TYPE;
alias ELF64_ST_BIND = ELF_ST_BIND;
alias ELF64_ST_TYPE = ELF_ST_TYPE;

struct Elf32_Dyn
{
    Elf32_Sword d_tag;

    union d_un
    {
        Elf32_Sword d_val;
        Elf32_Addr d_ptr;
    }
}

struct Elf64_Dyn
{
    Elf64_Sxword d_tag; /* entry tag value */
    union d_un
    {
        Elf64_Xword d_val;
        Elf64_Addr d_ptr;
    }
}

/* The following are used with relocations */
extern (D) auto ELF32_R_SYM(T)(auto ref T x)
{
    return x >> 8;
}

extern (D) auto ELF32_R_TYPE(T)(auto ref T x)
{
    return x & 0xff;
}

extern (D) auto ELF64_R_SYM(T)(auto ref T i)
{
    return i >> 32;
}

extern (D) auto ELF64_R_TYPE(T)(auto ref T i)
{
    return i & 0xffffffff;
}

struct elf32_rel
{
    Elf32_Addr r_offset;
    Elf32_Word r_info;
}

alias Elf32_Rel = elf32_rel;

struct elf64_rel
{
    Elf64_Addr r_offset; /* Location at which to apply the action */
    Elf64_Xword r_info; /* index and type of relocation */
}

alias Elf64_Rel = elf64_rel;

struct elf32_rela
{
    Elf32_Addr r_offset;
    Elf32_Word r_info;
    Elf32_Sword r_addend;
}

alias Elf32_Rela = elf32_rela;

struct elf64_rela
{
    Elf64_Addr r_offset; /* Location at which to apply the action */
    Elf64_Xword r_info; /* index and type of relocation */
    Elf64_Sxword r_addend; /* Constant addend used to compute value */
}

alias Elf64_Rela = elf64_rela;

struct elf32_sym
{
    Elf32_Word st_name;
    Elf32_Addr st_value;
    Elf32_Word st_size;
    ubyte st_info;
    ubyte st_other;
    Elf32_Half st_shndx;
}

alias Elf32_Sym = elf32_sym;

struct elf64_sym
{
    Elf64_Word st_name; /* Symbol name, index in string tbl */
    ubyte st_info; /* Type and binding attributes */
    ubyte st_other; /* No defined meaning, 0 */
    Elf64_Half st_shndx; /* Associated section index */
    Elf64_Addr st_value; /* Value of the symbol */
    Elf64_Xword st_size; /* Associated symbol size */
}

alias Elf64_Sym = elf64_sym;

enum EI_NIDENT = 16;

struct elf32_hdr
{
    ubyte[EI_NIDENT] e_ident;
    Elf32_Half e_type;
    Elf32_Half e_machine;
    Elf32_Word e_version;
    Elf32_Addr e_entry; /* Entry point */
    Elf32_Off e_phoff;
    Elf32_Off e_shoff;
    Elf32_Word e_flags;
    Elf32_Half e_ehsize;
    Elf32_Half e_phentsize;
    Elf32_Half e_phnum;
    Elf32_Half e_shentsize;
    Elf32_Half e_shnum;
    Elf32_Half e_shstrndx;
}

alias Elf32_Ehdr = elf32_hdr;

struct elf64_hdr
{
    ubyte[EI_NIDENT] e_ident; /* ELF "magic number" */
    Elf64_Half e_type;
    Elf64_Half e_machine;
    Elf64_Word e_version;
    Elf64_Addr e_entry; /* Entry point virtual address */
    Elf64_Off e_phoff; /* Program header table file offset */
    Elf64_Off e_shoff; /* Section header table file offset */
    Elf64_Word e_flags;
    Elf64_Half e_ehsize;
    Elf64_Half e_phentsize;
    Elf64_Half e_phnum;
    Elf64_Half e_shentsize;
    Elf64_Half e_shnum;
    Elf64_Half e_shstrndx;
}

alias Elf64_Ehdr = elf64_hdr;

/* These constants define the permissions on sections in the program
   header, p_flags. */
enum PF_R = 0x4;
enum PF_W = 0x2;
enum PF_X = 0x1;

struct elf32_phdr
{
    Elf32_Word p_type;
    Elf32_Off p_offset;
    Elf32_Addr p_vaddr;
    Elf32_Addr p_paddr;
    Elf32_Word p_filesz;
    Elf32_Word p_memsz;
    Elf32_Word p_flags;
    Elf32_Word p_align;
}

alias Elf32_Phdr = elf32_phdr;

struct elf64_phdr
{
    Elf64_Word p_type;
    Elf64_Word p_flags;
    Elf64_Off p_offset; /* Segment file offset */
    Elf64_Addr p_vaddr; /* Segment virtual address */
    Elf64_Addr p_paddr; /* Segment physical address */
    Elf64_Xword p_filesz; /* Segment size in file */
    Elf64_Xword p_memsz; /* Segment size in memory */
    Elf64_Xword p_align; /* Segment alignment, file & memory */
}

alias Elf64_Phdr = elf64_phdr;

/* sh_type */
enum SHT_NULL = 0;
enum SHT_PROGBITS = 1;
enum SHT_SYMTAB = 2;
enum SHT_STRTAB = 3;
enum SHT_RELA = 4;
enum SHT_HASH = 5;
enum SHT_DYNAMIC = 6;
enum SHT_NOTE = 7;
enum SHT_NOBITS = 8;
enum SHT_REL = 9;
enum SHT_SHLIB = 10;
enum SHT_DYNSYM = 11;
enum SHT_NUM = 12;
enum SHT_LOPROC = 0x70000000;
enum SHT_HIPROC = 0x7fffffff;
enum SHT_LOUSER = 0x80000000;
enum SHT_HIUSER = 0xffffffff;

/* sh_flags */
enum SHF_WRITE = 0x1;
enum SHF_ALLOC = 0x2;
enum SHF_EXECINSTR = 0x4;
enum SHF_RELA_LIVEPATCH = 0x00100000;
enum SHF_RO_AFTER_INIT = 0x00200000;
enum SHF_MASKPROC = 0xf0000000;

/* special section indexes */
enum SHN_UNDEF = 0;
enum SHN_LORESERVE = 0xff00;
enum SHN_LOPROC = 0xff00;
enum SHN_HIPROC = 0xff1f;
enum SHN_LIVEPATCH = 0xff20;
enum SHN_ABS = 0xfff1;
enum SHN_COMMON = 0xfff2;
enum SHN_HIRESERVE = 0xffff;

struct elf32_shdr
{
    Elf32_Word sh_name;
    Elf32_Word sh_type;
    Elf32_Word sh_flags;
    Elf32_Addr sh_addr;
    Elf32_Off sh_offset;
    Elf32_Word sh_size;
    Elf32_Word sh_link;
    Elf32_Word sh_info;
    Elf32_Word sh_addralign;
    Elf32_Word sh_entsize;
}

alias Elf32_Shdr = elf32_shdr;

struct elf64_shdr
{
    Elf64_Word sh_name; /* Section name, index in string tbl */
    Elf64_Word sh_type; /* Type of section */
    Elf64_Xword sh_flags; /* Miscellaneous section attributes */
    Elf64_Addr sh_addr; /* Section virtual addr at execution */
    Elf64_Off sh_offset; /* Section file offset */
    Elf64_Xword sh_size; /* Size of section in bytes */
    Elf64_Word sh_link; /* Index of another section */
    Elf64_Word sh_info; /* Additional section information */
    Elf64_Xword sh_addralign; /* Section alignment */
    Elf64_Xword sh_entsize; /* Entry size if section holds table */
}

alias Elf64_Shdr = elf64_shdr;

enum EI_MAG0 = 0; /* e_ident[] indexes */
enum EI_MAG1 = 1;
enum EI_MAG2 = 2;
enum EI_MAG3 = 3;
enum EI_CLASS = 4;
enum EI_DATA = 5;
enum EI_VERSION = 6;
enum EI_OSABI = 7;
enum EI_PAD = 8;

enum ELFMAG0 = 0x7f; /* EI_MAG */
enum ELFMAG1 = 'E';
enum ELFMAG2 = 'L';
enum ELFMAG3 = 'F';
enum ELFMAG = "\177ELF";
enum SELFMAG = 4;

enum ELFCLASSNONE = 0; /* EI_CLASS */
enum ELFCLASS32 = 1;
enum ELFCLASS64 = 2;
enum ELFCLASSNUM = 3;

enum ELFDATANONE = 0; /* e_ident[EI_DATA] */
enum ELFDATA2LSB = 1;
enum ELFDATA2MSB = 2;

enum EV_NONE = 0; /* e_version, EI_VERSION */
enum EV_CURRENT = 1;
enum EV_NUM = 2;

enum ELFOSABI_NONE = 0;
enum ELFOSABI_LINUX = 3;

enum ELF_OSABI = ELFOSABI_NONE;

/*
 * Notes used in ET_CORE. Architectures export some of the arch register sets
 * using the corresponding note types via the PTRACE_GETREGSET and
 * PTRACE_SETREGSET requests.
 * The note name for these types is "LINUX", except NT_PRFPREG that is named
 * "CORE".
 */
enum NT_PRSTATUS = 1;
enum NT_PRFPREG = 2;
enum NT_PRPSINFO = 3;
enum NT_TASKSTRUCT = 4;
enum NT_AUXV = 6;
/*
 * Note to userspace developers: size of NT_SIGINFO note may increase
 * in the future to accomodate more fields, don't assume it is fixed!
 */
enum NT_SIGINFO = 0x53494749;
enum NT_FILE = 0x46494c45;
enum NT_PRXFPREG = 0x46e62b7f; /* copied from gdb5.1/include/elf/common.h */
enum NT_PPC_VMX = 0x100; /* PowerPC Altivec/VMX registers */
enum NT_PPC_SPE = 0x101; /* PowerPC SPE/EVR registers */
enum NT_PPC_VSX = 0x102; /* PowerPC VSX registers */
enum NT_PPC_TAR = 0x103; /* Target Address Register */
enum NT_PPC_PPR = 0x104; /* Program Priority Register */
enum NT_PPC_DSCR = 0x105; /* Data Stream Control Register */
enum NT_PPC_EBB = 0x106; /* Event Based Branch Registers */
enum NT_PPC_PMU = 0x107; /* Performance Monitor Registers */
enum NT_PPC_TM_CGPR = 0x108; /* TM checkpointed GPR Registers */
enum NT_PPC_TM_CFPR = 0x109; /* TM checkpointed FPR Registers */
enum NT_PPC_TM_CVMX = 0x10a; /* TM checkpointed VMX Registers */
enum NT_PPC_TM_CVSX = 0x10b; /* TM checkpointed VSX Registers */
enum NT_PPC_TM_SPR = 0x10c; /* TM Special Purpose Registers */
enum NT_PPC_TM_CTAR = 0x10d; /* TM checkpointed Target Address Register */
enum NT_PPC_TM_CPPR = 0x10e; /* TM checkpointed Program Priority Register */
enum NT_PPC_TM_CDSCR = 0x10f; /* TM checkpointed Data Stream Control Register */
enum NT_PPC_PKEY = 0x110; /* Memory Protection Keys registers */
enum NT_PPC_DEXCR = 0x111; /* PowerPC DEXCR registers */
enum NT_PPC_HASHKEYR = 0x112; /* PowerPC HASHKEYR register */
enum NT_386_TLS = 0x200; /* i386 TLS slots (struct user_desc) */
enum NT_386_IOPERM = 0x201; /* x86 io permission bitmap (1=deny) */
enum NT_X86_XSTATE = 0x202; /* x86 extended state using xsave */
/* Old binutils treats 0x203 as a CET state */
enum NT_X86_SHSTK = 0x204; /* x86 SHSTK state */
enum NT_S390_HIGH_GPRS = 0x300; /* s390 upper register halves */
enum NT_S390_TIMER = 0x301; /* s390 timer register */
enum NT_S390_TODCMP = 0x302; /* s390 TOD clock comparator register */
enum NT_S390_TODPREG = 0x303; /* s390 TOD programmable register */
enum NT_S390_CTRS = 0x304; /* s390 control registers */
enum NT_S390_PREFIX = 0x305; /* s390 prefix register */
enum NT_S390_LAST_BREAK = 0x306; /* s390 breaking event address */
enum NT_S390_SYSTEM_CALL = 0x307; /* s390 system call restart data */
enum NT_S390_TDB = 0x308; /* s390 transaction diagnostic block */
enum NT_S390_VXRS_LOW = 0x309; /* s390 vector registers 0-15 upper half */
enum NT_S390_VXRS_HIGH = 0x30a; /* s390 vector registers 16-31 */
enum NT_S390_GS_CB = 0x30b; /* s390 guarded storage registers */
enum NT_S390_GS_BC = 0x30c; /* s390 guarded storage broadcast control block */
enum NT_S390_RI_CB = 0x30d; /* s390 runtime instrumentation */
enum NT_S390_PV_CPU_DATA = 0x30e; /* s390 protvirt cpu dump data */
enum NT_ARM_VFP = 0x400; /* ARM VFP/NEON registers */
enum NT_ARM_TLS = 0x401; /* ARM TLS register */
enum NT_ARM_HW_BREAK = 0x402; /* ARM hardware breakpoint registers */
enum NT_ARM_HW_WATCH = 0x403; /* ARM hardware watchpoint registers */
enum NT_ARM_SYSTEM_CALL = 0x404; /* ARM system call number */
enum NT_ARM_SVE = 0x405; /* ARM Scalable Vector Extension registers */
enum NT_ARM_PAC_MASK = 0x406; /* ARM pointer authentication code masks */
enum NT_ARM_PACA_KEYS = 0x407; /* ARM pointer authentication address keys */
enum NT_ARM_PACG_KEYS = 0x408; /* ARM pointer authentication generic key */
enum NT_ARM_TAGGED_ADDR_CTRL = 0x409; /* arm64 tagged address control (prctl()) */
enum NT_ARM_PAC_ENABLED_KEYS = 0x40a; /* arm64 ptr auth enabled keys (prctl()) */
enum NT_ARM_SSVE = 0x40b; /* ARM Streaming SVE registers */
enum NT_ARM_ZA = 0x40c; /* ARM SME ZA registers */
enum NT_ARM_ZT = 0x40d; /* ARM SME ZT registers */
enum NT_ARM_FPMR = 0x40e; /* ARM floating point mode register */
enum NT_ARC_V2 = 0x600; /* ARCv2 accumulator/extra registers */
enum NT_VMCOREDD = 0x700; /* Vmcore Device Dump Note */
enum NT_MIPS_DSP = 0x800; /* MIPS DSP ASE registers */
enum NT_MIPS_FP_MODE = 0x801; /* MIPS floating-point mode */
enum NT_MIPS_MSA = 0x802; /* MIPS SIMD registers */
enum NT_RISCV_CSR = 0x900; /* RISC-V Control and Status Registers */
enum NT_RISCV_VECTOR = 0x901; /* RISC-V vector registers */
enum NT_LOONGARCH_CPUCFG = 0xa00; /* LoongArch CPU config registers */
enum NT_LOONGARCH_CSR = 0xa01; /* LoongArch control and status registers */
enum NT_LOONGARCH_LSX = 0xa02; /* LoongArch Loongson SIMD Extension registers */
enum NT_LOONGARCH_LASX = 0xa03; /* LoongArch Loongson Advanced SIMD Extension registers */
enum NT_LOONGARCH_LBT = 0xa04; /* LoongArch Loongson Binary Translation registers */
enum NT_LOONGARCH_HW_BREAK = 0xa05; /* LoongArch hardware breakpoint registers */
enum NT_LOONGARCH_HW_WATCH = 0xa06; /* LoongArch hardware watchpoint registers */

/* Note types with note name "GNU" */
enum NT_GNU_PROPERTY_TYPE_0 = 5;

/* Note header in a PT_NOTE section */
struct elf32_note
{
    Elf32_Word n_namesz; /* Name size */
    Elf32_Word n_descsz; /* Content size */
    Elf32_Word n_type; /* Content type */
}

alias Elf32_Nhdr = elf32_note;

/* Note header in a PT_NOTE section */
struct elf64_note
{
    Elf64_Word n_namesz; /* Name size */
    Elf64_Word n_descsz; /* Content size */
    Elf64_Word n_type; /* Content type */
}

alias Elf64_Nhdr = elf64_note;

/* .note.gnu.property types for EM_AARCH64: */
enum GNU_PROPERTY_AARCH64_FEATURE_1_AND = 0xc0000000;

/* Bits for GNU_PROPERTY_AARCH64_FEATURE_1_BTI */
enum GNU_PROPERTY_AARCH64_FEATURE_1_BTI = 1U << 0;

/* _LINUX_ELF_H */
