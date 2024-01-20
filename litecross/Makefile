OUTPUT = $(CURDIR)/output

BINUTILS_SRCDIR = BINUTILS_SRCDIR_not_set
GCC_SRCDIR = GCC_SRCDIR_not_set

MAKE_ARGS = 
GCC_CONFIG_FOR_TARGET = 
COMMON_CONFIG = 
GCC_CONFIG = 
MINGW_CRT_CONFIG = 
MINGW_HEADERS_CONFIG =
TOOLCHAIN_CONFIG = 
FULL_CC = 
FULL_CXX = 
FULL_FC = 
STATIC_FLAGS = -static --static
COMMON_FLAGS = -Wno-error
OPTIMIZE_LEVEL = 
C_FLAGS = -g0
CXX_FLAGS = -g0
FC_FLAGS = -g0
LD_FLAGS = -s $(STATIC_FLAGS)

XGCC_DIR = $(CURDIR)/obj_gcc/gcc
XGCC = $(XGCC_DIR)/xgcc -B $(XGCC_DIR) -B $(CURDIR)/obj_sysroot/$(TARGET)/lib
XCPP = $(XGCC_DIR)/cpp -B $(XGCC_DIR)
XAR  = $(CURDIR)/obj_binutils/binutils/ar
XAS  = $(CURDIR)/obj_binutils/gas/as-new
XRANLIB  = $(CURDIR)/obj_binutils/binutils/ranlib
XRC  = $(CURDIR)/obj_binutils/binutils/windres --preprocessor=$(XGCC_DIR)/xgcc --preprocessor-arg=-B --preprocessor-arg=$(XGCC_DIR) --preprocessor-arg=-I$(CURDIR)/obj_sysroot/$(TARGET)/include --preprocessor-arg=-E --preprocessor-arg=-xc-header --preprocessor-arg=-DRC_INVOKED -c 1252
DLLTOOL = $(CURDIR)/obj_binutils/binutils/dlltool

-include config.mak

ifeq ($(OPTIMIZE_LEVEL),)
C_FLAGS := -Os $(C_FLAGS)
CXX_FLAGS := -Os $(CXX_FLAGS)
FC_FLAGS := -Os $(FC_FLAGS)
else
C_FLAGS := -O$(OPTIMIZE_LEVEL) $(C_FLAGS)
CXX_FLAGS := -O$(OPTIMIZE_LEVEL) $(CXX_FLAGS)
FC_FLAGS := -O$(OPTIMIZE_LEVEL) $(FC_FLAGS)
endif

ifeq ($(CPUS),)
MAKE_ARGS := -j$(shell if command -v nproc >/dev/null 2>&1; then nproc; else echo 1; fi) \
	$(MAKE_ARGS)
else
MAKE_ARGS := -j$(CPUS) \
	$(MAKE_ARGS)
endif

ifneq ($(findstring musl,$(TARGET)),)
# musl
MINGW_SRCDIR = 
else
# mingw
MUSL_SRCDIR = 
LINUX_SRCDIR = 
endif

ifneq ($(findstring fdpic,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --enable-fdpic
endif

ifneq ($(filter x86_64%x32,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-abi=x32
endif

# ifneq ($(findstring microblaze,$(TARGET)),)
# ICE in GCC; temporarily disable gfortran support.
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=87438
# GCC_CONFIG_FOR_TARGET += --enable-languages=c,c++
# endif

ifneq ($(findstring powerpc64,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-abi=elfv2 --with-cpu=970
endif

ifneq ($(findstring mips64,$(TARGET))$(findstring mipsisa64,$(TARGET)),)
ifneq ($(findstring n32,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-abi=n32
else
GCC_CONFIG_FOR_TARGET += --with-abi=64
endif
endif

ifneq ($(findstring s390x,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-long-double-128
endif

# ifeq ($(findstring riscv64,$(TARGET)),)
# not riscv64
# if `read-only segment has dynamic relocations` error occurs, try deleting `--disable-shared` option.
# COMMON_CONFIG += --disable-shared
# endif

ifneq ($(filter %sf,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-float=soft
endif

ifneq ($(filter %hf,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-float=hard
endif

ifneq ($(findstring mingw,$(TARGET)),)
# mingw
GCC_CONFIG_FOR_TARGET += --enable-fully-dynamic-string \
	--disable-sjlj-exceptions \
	--enable-threads=win32

ifneq ($(findstring x86_64,$(TARGET)),)
# 64
MINGW_CRT_CONFIG += --disable-lib32 --enable-lib64 --disable-libarm32
else
GCC_CONFIG_FOR_TARGET += --with-dwarf2
endif

else
# musl
GCC_CONFIG_FOR_TARGET += --disable-bootstrap \
	--enable-initfini-array
# # https://wiki.musl-libc.org/getting-started.html#Notes_on_ARM_Float_Mode
# ifneq ($(findstring armv5,$(TARGET)),)
# GCC_CONFIG_FOR_TARGET += --with-arch=armv5te --with-fpu=vfp
# else ifneq ($(findstring armv6,$(TARGET)),)
# GCC_CONFIG_FOR_TARGET += --with-arch=armv6 --with-fpu=vfpv2
# else ifneq ($(findstring armv7,$(TARGET)),)
# GCC_CONFIG_FOR_TARGET += --with-arch=armv7-a --with-fpu=vfpv3
# endif
endif

ifneq ($(LIBTOOL),)
LIBTOOL_ARG = LIBTOOL=$(LIBTOOL)
endif

MAKE += MULTILIB_OSDIRNAMES=
MAKE += INFO_DEPS= infodir=
MAKE += ac_cv_prog_lex_root=lex.yy
MAKE += MAKEINFO=false

FULL_C_FLAGS = $(COMMON_FLAGS) $(C_FLAGS)
FULL_CXX_FLAGS = $(COMMON_FLAGS) $(CXX_FLAGS)
FULL_FC_FLAGS = $(COMMON_FLAGS) $(FC_FLAGS)
FULL_LD_FLAGS = $(COMMON_FLAGS) $(LD_FLAGS)

COMMON_CONFIG := --disable-werror \
	--target=$(TARGET) --prefix= \
	--with-sysroot=$(SYSROOT) \
	--libdir=/lib --disable-multilib --disable-multiarch \
	--enable-deterministic-archives \
	CFLAGS="$(FULL_C_FLAGS)" CXXFLAGS="$(FULL_CXX_FLAGS)" FFLAGS="$(FULL_FC_FLAGS)" LDFLAGS="$(FULL_LD_FLAGS)" \
	$(COMMON_CONFIG)

# `--disable-gprofng` fix gprofng: unknown type name off64_t in `binutils version 2.38+`
BINUTILS_CONFIG := --disable-gprofng \
	$(BINUTILS_CONFIG)

GCC_CONFIG := --enable-libquadmath --enable-libquadmath-support \
	--enable-tls \
	--disable-libmudflap --disable-libsanitizer \
	--disable-gnu-indirect-function \
	--disable-libmpx \
	--disable-assembly \
	--enable-libstdcxx-time \
	--enable-default-pie --enable-static-pie --disable-cet \
	$(GCC_CONFIG)

FULL_BINUTILS_CONFIG = \
	--disable-separate-code \
	$(COMMON_CONFIG) $(BINUTILS_CONFIG) $(TOOLCHAIN_CONFIG)

FULL_GCC_CONFIG = --enable-languages=c,c++ \
	$(GCC_CONFIG_FOR_TARGET) \
	$(COMMON_CONFIG) $(GCC_CONFIG) $(TOOLCHAIN_CONFIG) \
    $(OVERRIDE)

FULL_MUSL_CONFIG = $(MUSL_CONFIG) \
	--prefix= --host=$(TARGET)

FULL_MINGW_HEADERS_CONFIG = $(MINGW_CONFIG) $(MINGW_HEADERS_CONFIG) \
	--prefix= --host=$(TARGET) --enable-sdk=all \
	--enable-idl --enable-secure-api --with-sysroot=$(SYSROOT)

FULL_MINGW_CRT_CONFIG = $(MINGW_CONFIG) $(MINGW_CRT_CONFIG) \
	--prefix= --host=$(TARGET) --with-sysroot=$(SYSROOT)

FULL_MINGW_PTHREADS_CONFIG = $(MINGW_CONFIG) \
	--prefix= --host=$(TARGET) --with-sysroot=$(SYSROOT)

ifeq ($(BUILD),)
GUESS = $(shell cd $(GCC_SRCDIR) && ./config.guess)
TARGET_CANON = $(shell cd $(GCC_SRCDIR) && ./config.sub $(TARGET))
BUILD = $(GUESS)$(if $(subst $(TARGET_CANON),,$(GUESS)),,xx)
endif

ifeq ($(NATIVE),)
# cross build
SYSROOT = /$(TARGET)
ifeq ($(CC_COMPILER),)
CC_PATH = gcc
else
CC_PATH = $(CC_COMPILER)
endif

ifeq ($(CXX_COMPILER),)
CXX_PATH = g++
else
CXX_PATH = $(CXX_COMPILER)
endif
ifeq ($(FC_COMPILER),)
FC_PATH = gfortran
else
FC_PATH = $(FC_COMPILER)
endif

FULL_COMPILER_CONFIG = CC="$(CC_PATH) $(STATIC_FLAGS)" CXX="$(CXX_PATH) $(STATIC_FLAGS)" FC="$(FC_PATH) $(STATIC_FLAGS)"

FULL_BINUTILS_CONFIG += --build=$(BUILD) --host=$(BUILD) \
	$(FULL_COMPILER_CONFIG)
FULL_GCC_CONFIG += --with-build-sysroot=$(CURDIR)/obj_sysroot \
	AR_FOR_TARGET=$(PWD)/obj_binutils/binutils/ar \
	AS_FOR_TARGET=$(PWD)/obj_binutils/gas/as-new \
	LD_FOR_TARGET=$(PWD)/obj_binutils/ld/ld-new \
	NM_FOR_TARGET=$(PWD)/obj_binutils/binutils/nm-new \
	OBJCOPY_FOR_TARGET=$(PWD)/obj_binutils/binutils/objcopy \
	OBJDUMP_FOR_TARGET=$(PWD)/obj_binutils/binutils/objdump \
	RANLIB_FOR_TARGET=$(PWD)/obj_binutils/binutils/ranlib \
	READELF_FOR_TARGET=$(PWD)/obj_binutils/binutils/readelf \
	STRIP_FOR_TARGET=$(PWD)/obj_binutils/binutils/strip-new \
	$(FULL_COMPILER_CONFIG) \
	--build=$(BUILD) --host=$(BUILD)

FULL_MUSL_CONFIG += CC="$(XGCC)" LIBCC="../obj_gcc/$(TARGET)/libgcc/libgcc.a" 
MUSL_VARS = AR=../obj_binutils/binutils/ar RANLIB=../obj_binutils/binutils/ranlib
MINGW_VARS = AS="$(XAS)" AR="$(XAR)" CC="$(XGCC)" RANLIB="$(XRANLIB)"
FULL_MINGW_PTHREADS_CONFIG += RC="$(XRC)" CC="$(XGCC)" CPP="$(XCPP)" CPPFLAGS="-I$(CURDIR)/obj_sysroot/$(TARGET)/include $(CPPFLAGS)" LDFLAGS="-L$(CURDIR)/obj_sysroot/$(TARGET)/lib $(LDFLAGS)" DLLTOOL=$(DLLTOOL)
FULL_MINGW_CRT_CONFIG += CC="$(XGCC)" CPP="$(XCPP)" CPPFLAGS="-I$(CURDIR)/obj_sysroot/$(TARGET)/include $(CPPFLAGS)" DLLTOOL="$(DLLTOOL)" RC="$(XRC)"
obj_mingw_headers/.lc_configured: | obj_binutils/.lc_built
obj_mingw_crt/.lc_configured: | obj_sysroot/.lc_headers obj_gcc/gcc/.lc_built obj_binutils/.lc_built
obj_mingw_pthreads/.lc_configured: | obj_sysroot/.lc_headers obj_gcc/gcc/.lc_built obj_binutils/.lc_built obj_sysroot/.lc_libs_crt
obj_musl/.lc_configured: | obj_gcc/gcc/.lc_built
obj_musl/.lc_built: | obj_gcc/$(TARGET)/libgcc/libgcc.a
obj_gcc/gcc/.lc_built: | obj_sysroot/usr obj_sysroot/lib32 obj_sysroot/lib64 obj_sysroot/include
ifneq ($(MUSL_SRCDIR),)
obj_gcc/.lc_built: | obj_sysroot/.lc_libs obj_sysroot/.lc_headers
else
obj_gcc/.lc_built: | obj_sysroot/.lc_libs_crt obj_sysroot/.lc_headers
endif
obj_gcc/.lc_configured: obj_binutils/.lc_built

else
# native build
SYSROOT = /

CC_PATH = $(TARGET)-gcc
CXX_PATH = $(TARGET)-g++
FC_PATH = $(TARGET)-gfortran

FULL_COMPILER_CONFIG = CC="$(CC_PATH) $(STATIC_FLAGS)" CXX="$(CXX_PATH) $(STATIC_FLAGS)" FC="$(FC_PATH) $(STATIC_FLAGS)"

FULL_BINUTILS_CONFIG += --build=$(BUILD) --host=$(TARGET) \
	$(FULL_COMPILER_CONFIG)
FULL_GCC_CONFIG += --build=$(BUILD) --host=$(TARGET) \
	$(FULL_COMPILER_CONFIG)

MAKE += STMP_FIXINC=
ifeq ($(findstring mingw,$(TARGET)),)
# musl
FULL_BINUTILS_CONFIG += --with-native-system-header-dir=/include
FULL_GCC_CONFIG += --with-native-system-header-dir=/include
MUSL_VARS = 
else
# mingw
endif

endif

# COMPILER
check-compiler:
	@if ! command -v $(CC_PATH) >/dev/null; then \
		echo "$(CC_PATH) not found in the environment"; \
		exit 1; \
	fi
	@if ! command -v $(CXX_PATH) >/dev/null; then \
		echo "$(CXX_PATH) not found in the environment"; \
		exit 1; \
	fi

obj_mingw_headers/.lc_configured: | check-compiler
obj_mingw_crt/.lc_configured: | check-compiler
obj_mingw_pthreads/.lc_configured: | check-compiler
obj_musl/.lc_configured: | check-compiler
obj_musl/.lc_built: | check-compiler
obj_gcc/gcc/.lc_built: | check-compiler
obj_gcc/.lc_built: | check-compiler
obj_gcc/.lc_configured: | check-compiler

ifeq ($(TARGET),)

all:
	@echo TARGET must be set.
	@exit 1

install: all

else

ifeq ($(MUSL_SRCDIR),)
all: mingw gcc binutils
install: install-mingw install-gcc install-binutils
else
all: musl gcc binutils
install: install-musl install-gcc install-binutils
endif

musl: obj_musl/.lc_built

mingw: obj_mingw_headers/.lc_built obj_mingw_crt/.lc_built obj_mingw_pthreads/.lc_built

toolchain: gcc binutils

install-toolchain: install-gcc install-binutils

gcc: obj_gcc/.lc_built

binutils: obj_binutils/.lc_built

.PHONY: all musl mingw toolchain install-musl install-mingw install-toolchain clean

src_binutils: | $(BINUTILS_SRCDIR)
	ln -sf $(BINUTILS_SRCDIR) $@

src_gcc_base: | $(GCC_SRCDIR)
	ln -sf $(GCC_SRCDIR) $@

src_musl: | $(MUSL_SRCDIR)
	ln -sf $(MUSL_SRCDIR) $@

src_mingw: | $(MINGW_SRCDIR)
	ln -sf $(MINGW_SRCDIR) $@

ifneq ($(GMP_SRCDIR),)
src_gcc: src_gmp
src_gmp: | $(GMP_SRCDIR)
	ln -sf "$(GMP_SRCDIR)" $@
endif

ifneq ($(MPC_SRCDIR),)
src_gcc: src_mpc
src_mpc: | $(MPC_SRCDIR)
	ln -sf "$(MPC_SRCDIR)" $@
endif

ifneq ($(MPFR_SRCDIR),)
src_gcc: src_mpfr
src_mpfr: | $(MPFR_SRCDIR)
	ln -sf "$(MPFR_SRCDIR)" $@
endif

ifneq ($(ISL_SRCDIR),)
src_gcc: src_isl
src_isl: | $(ISL_SRCDIR)
	ln -sf "$(ISL_SRCDIR)" $@
endif

src_gcc: src_gcc_base
	rm -rf $@ $@.tmp
	mkdir $@.tmp
	cd $@.tmp && ln -sf ../src_gcc_base/* .
	$(if $(GMP_SRCDIR),cd $@.tmp && ln -sf ../src_gmp gmp)
	$(if $(MPC_SRCDIR),cd $@.tmp && ln -sf ../src_mpc mpc)
	$(if $(MPFR_SRCDIR),cd $@.tmp && ln -sf ../src_mpfr mpfr)
	$(if $(ISL_SRCDIR),cd $@.tmp && ln -sf ../src_isl isl)
	mv $@.tmp $@

obj_%:
	mkdir -p $@

obj_sysroot/include:
	mkdir -p $@

obj_sysroot/usr: | obj_sysroot
	ln -sf . $@

obj_sysroot/lib32: | obj_sysroot
	ln -sf lib $@

obj_sysroot/lib64: | obj_sysroot
	ln -sf lib $@

obj_binutils/.lc_configured: | obj_binutils src_binutils
	cd obj_binutils && ../src_binutils/configure $(FULL_BINUTILS_CONFIG)
	touch $@

obj_binutils/.lc_built: | obj_binutils/.lc_configured
	cd obj_binutils && $(MAKE) $(MAKE_ARGS) MAKE="$(MAKE) $(LIBTOOL_ARG)" all
	touch $@

obj_gcc/.lc_configured: | obj_gcc src_gcc
	cd obj_gcc && ../src_gcc/configure $(FULL_GCC_CONFIG)
	touch $@

obj_gcc/.lc_gmp_built: | obj_gcc/.lc_configured
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) MAKE="$(MAKE) $(LIBTOOL_STATIC_ARG)" all-gmp
	touch $@

obj_gcc/.lc_mpfr_built: | obj_gcc/.lc_gmp_built
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) MAKE="$(MAKE) $(LIBTOOL_STATIC_ARG)" all-mpfr
	touch $@

obj_gcc/.lc_mpc_built: | obj_gcc/.lc_mpfr_built
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) MAKE="$(MAKE) $(LIBTOOL_STATIC_ARG)" all-mpc
	touch $@

ifeq ($(MUSL_SRCDIR),)
obj_gcc/gcc/.lc_built: | obj_gcc/.lc_mpc_built obj_sysroot/.lc_headers
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) MAKE="$(MAKE) $(LIBTOOL_ARG)" all-gcc
	touch $@
else
obj_gcc/gcc/.lc_built: | obj_gcc/.lc_mpc_built
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) MAKE="$(MAKE) $(LIBTOOL_ARG)" all-gcc
	touch $@
endif

obj_musl/.lc_configured: | obj_musl src_musl
	cd obj_musl && ../src_musl/configure $(FULL_MUSL_CONFIG)
	touch $@

obj_mingw/.lc_configured: | obj_mingw src_mingw obj_mingw_headers/.lc_configured obj_mingw_crt/.lc_configured
	touch $@

ifeq ($(MUSL_SRCDIR),)
obj_sysroot/.lc_headers: | obj_mingw_headers/.lc_configured obj_sysroot
	cd obj_mingw_headers && $(MAKE) $(MAKE_ARGS) DESTDIR=$(CURDIR)/obj_sysroot/$(TARGET) install
	rm -f $(CURDIR)/obj_sysroot/mingw
	ln -s $(TARGET) $(CURDIR)/obj_sysroot/mingw
	touch $@
else
obj_sysroot/.lc_headers: | obj_musl/.lc_configured obj_sysroot
	cd obj_musl && $(MAKE) $(MAKE_ARGS) DESTDIR=$(CURDIR)/obj_sysroot install-headers
	touch $@
endif

obj_gcc/$(TARGET)/libgcc/libgcc.a: | obj_sysroot/.lc_headers
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) MAKE="$(MAKE) enable_shared=no $(LIBTOOL_ARG)" all-target-libgcc

obj_musl/.lc_built: | obj_musl/.lc_configured
	cd obj_musl && $(MAKE) $(MAKE_ARGS) $(MUSL_VARS)
	touch $@

ifeq ($(MUSL_SRCDIR),)
obj_sysroot/.lc_libs: | obj_sysroot/.lc_libs_pthreads obj_sysroot/.lc_libs_crt
	touch $@
else
obj_sysroot/.lc_libs: | obj_musl/.lc_built
	cd obj_musl && $(MAKE) $(MAKE_ARGS) $(MUSL_VARS) DESTDIR=$(CURDIR)/obj_sysroot install
	touch $@
endif

obj_gcc/.lc_built: | obj_gcc/.lc_configured obj_gcc/gcc/.lc_built
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) MAKE="$(MAKE) $(LIBTOOL_ARG)"
	touch $@

install-musl: | obj_musl/.lc_built
	cd obj_musl && $(MAKE) $(MAKE_ARGS) $(MUSL_VARS) DESTDIR=$(DESTDIR)$(OUTPUT)$(SYSROOT) install

install-binutils: | obj_binutils/.lc_built
	cd obj_binutils && $(MAKE) $(MAKE_ARGS) MAKE="$(MAKE) $(LIBTOOL_ARG)" DESTDIR=$(DESTDIR)$(OUTPUT) install

install-gcc: | obj_gcc/.lc_built
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) MAKE="$(MAKE) $(LIBTOOL_ARG)" DESTDIR=$(DESTDIR)$(OUTPUT) install
	ln -sf $(TARGET)-gcc $(DESTDIR)$(OUTPUT)/bin/$(TARGET)-cc

obj_mingw_headers/.lc_configured: | obj_mingw_headers src_mingw
	cd obj_mingw_headers && ../src_mingw/mingw-w64-headers/configure $(FULL_MINGW_HEADERS_CONFIG)
	touch $@

obj_mingw_headers/.lc_built: | obj_mingw_headers/.lc_configured
	cd obj_mingw_headers && $(MAKE) $(MAKE_ARGS) $(MINGW_VARS)
	touch $@

obj_mingw_crt/.lc_configured: | obj_sysroot/.lc_headers obj_binutils/.lc_built obj_gcc/gcc/.lc_built obj_mingw_crt src_mingw
	cd obj_mingw_crt && ../src_mingw/mingw-w64-crt/configure $(FULL_MINGW_CRT_CONFIG)
	touch $@

obj_mingw_crt/.lc_built: | obj_mingw_crt/.lc_configured
	cd obj_mingw_crt && $(MAKE) $(MAKE_ARGS) $(MINGW_VARS)
	touch $@

obj_mingw_pthreads/.lc_configured: | obj_mingw_crt/.lc_built obj_mingw_pthreads src_mingw
	cd obj_mingw_pthreads && ../src_mingw/mingw-w64-libraries/winpthreads/configure $(FULL_MINGW_PTHREADS_CONFIG)
	touch $@

obj_mingw_pthreads/.lc_built: | obj_mingw_pthreads/.lc_configured
	cd obj_mingw_pthreads && $(MAKE) $(MAKE_ARGS) $(MINGW_VARS)
	touch $@

obj_sysroot/.lc_libs_pthreads: | obj_mingw_pthreads/.lc_built
	cd obj_mingw_pthreads && $(MAKE) $(MAKE_ARGS) $(MINGW_VARS) DESTDIR=$(CURDIR)/obj_sysroot/$(TARGET) install
	touch $@

obj_sysroot/.lc_libs_crt: | obj_mingw_crt/.lc_built
	cd obj_mingw_crt && $(MAKE) $(MAKE_ARGS) $(MINGW_VARS) DESTDIR=$(CURDIR)/obj_sysroot/$(TARGET) install
	touch $@

install-mingw-headers: | obj_mingw_headers/.lc_configured
	cd obj_mingw_headers && $(MAKE) $(MAKE_ARGS) $(MINGW_VARS) DESTDIR=$(DESTDIR)$(OUTPUT)$(SYSROOT) install

install-mingw-crt: | obj_mingw_crt/.lc_built
	cd obj_mingw_crt && $(MAKE) $(MAKE_ARGS) $(MINGW_VARS) DESTDIR=$(DESTDIR)$(OUTPUT)$(SYSROOT) install

install-mingw-pthreads: | obj_mingw_pthreads/.lc_built
	cd obj_mingw_pthreads && $(MAKE) $(MAKE_ARGS) $(MINGW_VARS) DESTDIR=$(DESTDIR)$(OUTPUT)$(SYSROOT) install

install-mingw: install-mingw-headers install-mingw-crt install-mingw-pthreads

ifneq ($(LINUX_SRCDIR),)
TARGET_ARCH = $(firstword $(subst -, ,$(TARGET)))
TARGET_ARCH_MANGLED = $(patsubst i%86,x86,$(patsubst aarch64%,arm64%,$(patsubst or1k%,openrisc%,$(TARGET_ARCH))))
LINUX_ARCH_LIST = $(sort $(notdir $(wildcard $(LINUX_SRCDIR)/arch/*)))
LINUX_ARCH = $(lastword $(foreach a,$(LINUX_ARCH_LIST),$(if $(filter $(a)%,$(TARGET_ARCH_MANGLED)),$(a))))
ifneq ($(LINUX_ARCH),)
all: kernel-headers
install: install-kernel-headers
kernel-headers: | obj_kernel_headers/.lc_built
src_kernel_headers: | $(LINUX_SRCDIR)
	ln -sf "$(LINUX_SRCDIR)" $@
obj_kernel_headers/.lc_built: | src_kernel_headers
	mkdir -p $(CURDIR)/obj_kernel_headers/staged
	cd src_kernel_headers && $(MAKE) $(MAKE_ARGS) ARCH=$(LINUX_ARCH) O=$(CURDIR)/obj_kernel_headers INSTALL_HDR_PATH=$(CURDIR)/obj_kernel_headers/staged headers_install HOSTCC="$(CC) $(STAT)"
	find obj_kernel_headers/staged/include '(' -name .install -o -name ..install.cmd ')' -exec rm {} +
	touch $@
install-kernel-headers: | obj_kernel_headers/.lc_built
	mkdir -p $(DESTDIR)$(OUTPUT)$(SYSROOT)/include
	cp -R obj_kernel_headers/staged/include/* $(DESTDIR)$(OUTPUT)$(SYSROOT)/include
endif
endif

endif

clean:
	rm -rf src_* obj_*
