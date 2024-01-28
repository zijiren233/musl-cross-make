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
OPTIMIZE_LEVEL = 
COMMON_FLAGS = -g0 -Wno-error
CC = gcc
CXX = g++
CFLAGS = 
CXXFLAGS = 
LDFLAGS = -s

XGCC_DIR = $(CURDIR)/obj_gcc/gcc
XGCC = $(XGCC_DIR)/xgcc -B $(XGCC_DIR) -B $(CURDIR)/obj_sysroot/$(TARGET)/lib
XCPP = $(XGCC_DIR)/cpp -B $(XGCC_DIR)
XAR  = $(CURDIR)/obj_binutils/binutils/ar
XAS  = $(CURDIR)/obj_binutils/gas/as-new
XRANLIB  = $(CURDIR)/obj_binutils/binutils/ranlib
XRC  = $(CURDIR)/obj_binutils/binutils/windres --preprocessor=$(XGCC_DIR)/xgcc --preprocessor-arg=-B --preprocessor-arg=$(XGCC_DIR) --preprocessor-arg=-I$(CURDIR)/obj_sysroot/$(TARGET)/include --preprocessor-arg=-E --preprocessor-arg=-xc-header --preprocessor-arg=-DRC_INVOKED -c 1252
DLLTOOL = $(CURDIR)/obj_binutils/binutils/dlltool

-include config.mak

ifeq ($(CROSS_CC)$(CROSS_CXX),)
CROSS_CC = $(TARGET)-gcc
CROSS_CXX = $(TARGET)-g++
endif

ifeq ($(OPTIMIZE_LEVEL),)
OPTIMIZE_LEVEL = s
else
ifeq ($(OPTIMIZE_LEVEL),0)
# dont use -O0
OPTIMIZE_LEVEL = 1
endif
endif
COMMON_FLAGS := -O$(OPTIMIZE_LEVEL) $(COMMON_FLAGS)

ifeq ($(STAT),)
STAT = -static --static
endif
ifeq ($(NATIVE),)
# cross
ifneq ($(DISABLE_CROSS_STATIC_BUILD),)
STAT = 
endif
else
# native
ifneq ($(DISABLE_NATIVE_STATIC_BUILD),)
STAT = 
endif
endif

ifneq ($(STAT),)
CC += $(STAT)
CXX += $(STAT)
CROSS_CC += $(STAT)
CROSS_CXX += $(STAT)
endif

CFLAGS := $(strip $(COMMON_FLAGS) $(CFLAGS))
CXXFLAGS := $(strip $(COMMON_FLAGS) $(CXXFLAGS))

ifeq ($(NATIVE),)
# cross build
COMPILER_ARGS += CC="$(CC)" CXX="$(CXX)"
else
# native build
COMPILER_ARGS += CC="$(CROSS_CC)" CXX="$(CROSS_CXX)"
endif
COMMON_CONFIG := $(COMPILER_ARGS) \
	CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" LDFLAGS="$(strip $(STAT) $(LDFLAGS))" \
	$(COMMON_CONFIG)
COMMON_MAKE_ARGS += CC_FOR_BUILD="$(CC)" CXX_FOR_BUILD="$(CXX)"

ifeq ($(CPUS),)
MAKE_ARGS := -j$(shell if command -v nproc >/dev/null 2>&1; then nproc; else echo 2; fi) \
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

ifneq ($(filter %sf,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-float=soft
else
ifneq ($(filter %hf,$(TARGET)),)
GCC_CONFIG_FOR_TARGET += --with-float=hard
endif
endif

ifneq ($(findstring mingw,$(TARGET)),)
# mingw
GCC_CONFIG_FOR_TARGET += --disable-sjlj-exceptions
ifeq ($(NATIVE),)
# cross build
GCC_CONFIG_FOR_TARGET += --enable-threads=posix
else
# native build
GCC_CONFIG_FOR_TARGET += --enable-threads=win32
endif
ifneq ($(findstring x86_64,$(TARGET)),)
# 64
MINGW_CRT_CONFIG += --disable-lib32 --enable-lib64
else
MINGW_CRT_CONFIG += --enable-lib32 --disable-lib64
endif

else
# musl
GCC_CONFIG_FOR_TARGET += --enable-initfini-array \
	--enable-threads=posix
# # https://wiki.musl-libc.org/getting-started.html#Notes_on_ARM_Float_Mode
# ifneq ($(findstring armv5,$(TARGET)),)
# GCC_CONFIG_FOR_TARGET += --with-arch=armv5te --with-fpu=vfp
# else
# ifneq ($(findstring armv6,$(TARGET)),)
# GCC_CONFIG_FOR_TARGET += --with-arch=armv6 --with-fpu=vfpv2
# else
# ifneq ($(findstring armv7,$(TARGET)),)
# GCC_CONFIG_FOR_TARGET += --with-arch=armv7-a --with-fpu=vfpv3
# endif
# endif
# endif
endif

MAKE += MULTILIB_OSDIRNAMES=
MAKE += INFO_DEPS= infodir=
MAKE += ac_cv_prog_lex_root=lex.yy
MAKE += MAKEINFO=false

COMMON_CONFIG := --target=$(TARGET) --prefix= \
	--with-sysroot=$(SYSROOT) --libdir=/lib \
	--disable-werror \
	--disable-multilib \
	--disable-bootstrap \
	--enable-deterministic-archives \
	--disable-nls \
	--enable-lto \
	$(COMMON_CONFIG)

GCC_CONFIG := --enable-languages=c,c++ \
	--disable-libmudflap --disable-libsanitizer \
	--disable-gnu-indirect-function \
	--disable-libmpx \
	--enable-libstdcxx-time=yes \
	--enable-libstdcxx-filesystem-ts=yes \
	--enable-default-pie --enable-static-pie \
	--disable-decimal-float \
	$(GCC_CONFIG)

ifneq ($(SIMPLER_BUILD),)
COMMON_CONFIG += --disable-libquadmath \
	--disable-libquadmath-support \
	--disable-lto
endif

FULL_BINUTILS_CONFIG = $(COMMON_CONFIG) $(BINUTILS_CONFIG) $(TOOLCHAIN_CONFIG)

FULL_GCC_CONFIG = $(COMMON_CONFIG) \
	$(GCC_CONFIG) $(GCC_CONFIG_FOR_TARGET) $(TOOLCHAIN_CONFIG) \
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

FULL_BINUTILS_CONFIG += --build=$(BUILD) --host=$(BUILD)
FULL_GCC_CONFIG += --build=$(BUILD) --host=$(BUILD) \
	--with-build-sysroot=$(CURDIR)/obj_sysroot
GCC_MAKE_ARGS += AR_FOR_TARGET=$(CURDIR)/obj_binutils/binutils/ar \
	AS_FOR_TARGET=$(CURDIR)/obj_binutils/gas/as-new \
	LD_FOR_TARGET=$(CURDIR)/obj_binutils/ld/ld-new \
	NM_FOR_TARGET=$(CURDIR)/obj_binutils/binutils/nm-new \
	OBJCOPY_FOR_TARGET=$(CURDIR)/obj_binutils/binutils/objcopy \
	OBJDUMP_FOR_TARGET=$(CURDIR)/obj_binutils/binutils/objdump \
	RANLIB_FOR_TARGET=$(CURDIR)/obj_binutils/binutils/ranlib \
	READELF_FOR_TARGET=$(CURDIR)/obj_binutils/binutils/readelf \
	STRIP_FOR_TARGET=$(CURDIR)/obj_binutils/binutils/strip-new
FULL_MUSL_CONFIG += CC="$(XGCC)" \
	LIBCC="../obj_gcc/$(TARGET)/libgcc/libgcc.a"
MUSL_MAKE_ARGS = AR="../obj_binutils/binutils/ar" \
	RANLIB="../obj_binutils/binutils/ranlib"
MINGW_MAKE_ARGS = AS="$(XAS)" AR="$(XAR)" CC="$(XGCC)" RANLIB="$(XRANLIB)"
FULL_MINGW_PTHREADS_CONFIG += RC="$(XRC)" CC="$(XGCC)" CPP="$(XCPP)" \
	CPPFLAGS="-I$(CURDIR)/obj_sysroot/$(TARGET)/include" \
	LDFLAGS="-L$(CURDIR)/obj_sysroot/$(TARGET)/lib" \
	DLLTOOL="$(DLLTOOL)"
FULL_MINGW_CRT_CONFIG += RC="$(XRC)" CC="$(XGCC)" CPP="$(XCPP)" \
	CPPFLAGS="-I$(CURDIR)/obj_sysroot/$(TARGET)/include -Wno-expansion-to-defined" \
	DLLTOOL="$(DLLTOOL)"
obj_mingw_headers/.lc_configured: | obj_binutils/.lc_built
obj_mingw_crt/.lc_configured: | obj_sysroot/.lc_headers obj_gcc/gcc/.lc_built obj_binutils/.lc_built
obj_mingw_pthreads/.lc_configured: | obj_sysroot/.lc_headers obj_gcc/gcc/.lc_built obj_binutils/.lc_built obj_sysroot/.lc_libs_crt
obj_musl/.lc_configured: | obj_gcc/gcc/.lc_built
obj_musl/.lc_built: | obj_gcc/$(TARGET)/libgcc/libgcc.a
obj_gcc/gcc/.lc_built: | obj_sysroot/usr obj_sysroot/lib32 obj_sysroot/lib64 obj_sysroot/include
ifneq ($(MUSL_SRCDIR),)
obj_gcc/.lc_built: | obj_sysroot/.lc_libs obj_sysroot/.lc_headers
else
ifeq ($(findstring --enable-threads=posix,$(FULL_GCC_CONFIG)),)
obj_gcc/.lc_built: | obj_sysroot/.lc_libs_crt obj_sysroot/.lc_headers
else
obj_gcc/.lc_built: | obj_sysroot/.lc_libs obj_sysroot/.lc_headers
endif
endif
obj_gcc/.lc_configured: obj_binutils/.lc_built
check-compiler:
	@if ! command -v $(CC) >/dev/null; then \
		echo "$(CC) not found in the environment"; \
		exit 1; \
	fi
	@if ! command -v $(CXX) >/dev/null; then \
		echo "$(CXX) not found in the environment"; \
		exit 1; \
	fi

else
# native build
SYSROOT = 

FULL_BINUTILS_CONFIG += --build=$(BUILD) --host=$(TARGET)
FULL_GCC_CONFIG += --build=$(BUILD) --host=$(TARGET)

MUSL_MAKE_ARGS = 
MINGW_MAKE_ARGS = 

ifeq ($(MUSL_SRCDIR),)
# mingw default use /mingw/include
FULL_GCC_CONFIG += --with-build-sysroot=$(CURDIR)/obj_sysroot
endif
check-compiler:
	@if ! command -v $(CROSS_CC) >/dev/null; then \
		echo "$(CROSS_CC) not found in the environment"; \
		exit 1; \
	fi
	@if ! command -v $(CROSS_CXX) >/dev/null; then \
		echo "$(CROSS_CXX) not found in the environment"; \
		exit 1; \
	fi

endif

ifeq ($(TARGET),)

all:
	@echo TARGET must be set.
	@exit 1

install: all

else

all: | check-compiler
install: | check-compiler

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
	cd obj_binutils && $(MAKE) $(MAKE_ARGS) $(COMMON_MAKE_ARGS) $(BINUTILS_MAKE_ARGS) MAKE="$(MAKE) $(TOOLCHAIN_MAKE_ARGS)" all
	touch $@

obj_gcc/.lc_configured: | obj_gcc src_gcc
	cd obj_gcc && ../src_gcc/configure $(FULL_GCC_CONFIG)
	touch $@

obj_gcc/.lc_gmp_built: | obj_gcc/.lc_configured
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) $(COMMON_MAKE_ARGS) $(GCC_MAKE_ARGS) MAKE="$(MAKE) $(TOOLCHAIN_STATIC_MAKE_ARGS)" all-gmp
	touch $@

obj_gcc/.lc_mpfr_built: | obj_gcc/.lc_gmp_built
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) $(COMMON_MAKE_ARGS) $(GCC_MAKE_ARGS) MAKE="$(MAKE) $(TOOLCHAIN_STATIC_MAKE_ARGS)" all-mpfr
	touch $@

obj_gcc/.lc_mpc_built: | obj_gcc/.lc_mpfr_built
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) $(COMMON_MAKE_ARGS) $(GCC_MAKE_ARGS) MAKE="$(MAKE) $(TOOLCHAIN_STATIC_MAKE_ARGS)" all-mpc
	touch $@

ifeq ($(MUSL_SRCDIR),)
obj_gcc/gcc/.lc_built: | obj_gcc/.lc_mpc_built obj_sysroot/.lc_headers
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) $(COMMON_MAKE_ARGS) $(GCC_MAKE_ARGS) MAKE="$(MAKE) $(TOOLCHAIN_MAKE_ARGS)" all-gcc
	touch $@
else
obj_gcc/gcc/.lc_built: | obj_gcc/.lc_mpc_built
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) $(COMMON_MAKE_ARGS) $(GCC_MAKE_ARGS) MAKE="$(MAKE) $(TOOLCHAIN_MAKE_ARGS)" all-gcc
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
	cd obj_musl && $(MAKE) $(MAKE_ARGS) $(MUSL_MAKE_ARGS) DESTDIR=$(CURDIR)/obj_sysroot install-headers
	touch $@
endif

obj_gcc/$(TARGET)/libgcc/libgcc.a: | obj_sysroot/.lc_headers
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) $(COMMON_MAKE_ARGS) $(GCC_MAKE_ARGS) MAKE="$(MAKE) enable_shared=no $(TOOLCHAIN_MAKE_ARGS)" all-target-libgcc

obj_musl/.lc_built: | obj_musl/.lc_configured
	cd obj_musl && $(MAKE) $(MAKE_ARGS) $(MUSL_MAKE_ARGS)
	touch $@

ifeq ($(MUSL_SRCDIR),)
obj_sysroot/.lc_libs: | obj_sysroot/.lc_libs_pthreads obj_sysroot/.lc_libs_crt
	touch $@
else
obj_sysroot/.lc_libs: | obj_musl/.lc_built
	cd obj_musl && $(MAKE) $(MAKE_ARGS) $(MUSL_MAKE_ARGS) DESTDIR=$(CURDIR)/obj_sysroot install
	touch $@
endif

obj_gcc/.lc_built: | obj_gcc/.lc_configured obj_gcc/gcc/.lc_built
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) $(COMMON_MAKE_ARGS) $(GCC_MAKE_ARGS) MAKE="$(MAKE) $(TOOLCHAIN_MAKE_ARGS)"
	touch $@

install-musl: | obj_musl/.lc_built
	cd obj_musl && $(MAKE) $(MAKE_ARGS) $(MUSL_MAKE_ARGS) DESTDIR=$(DESTDIR)$(OUTPUT)$(SYSROOT) install

install-binutils: | obj_binutils/.lc_built
	cd obj_binutils && $(MAKE) $(MAKE_ARGS) $(COMMON_MAKE_ARGS) $(BINUTILS_MAKE_ARGS) MAKE="$(MAKE) $(TOOLCHAIN_MAKE_ARGS)" DESTDIR=$(DESTDIR)$(OUTPUT) install

install-gcc: | obj_gcc/.lc_built
	cd obj_gcc && $(MAKE) $(MAKE_ARGS) $(COMMON_MAKE_ARGS) $(GCC_MAKE_ARGS) MAKE="$(MAKE) $(TOOLCHAIN_MAKE_ARGS)" DESTDIR=$(DESTDIR)$(OUTPUT) install
	ln -sf $(TARGET)-gcc $(DESTDIR)$(OUTPUT)/bin/$(TARGET)-cc

obj_mingw_headers/.lc_configured: | obj_mingw_headers src_mingw
	cd obj_mingw_headers && ../src_mingw/mingw-w64-headers/configure $(FULL_MINGW_HEADERS_CONFIG)
	touch $@

obj_mingw_headers/.lc_built: | obj_mingw_headers/.lc_configured
	cd obj_mingw_headers && $(MAKE) $(MAKE_ARGS) $(MINGW_MAKE_ARGS)
	touch $@

obj_mingw_crt/.lc_configured: | obj_sysroot/.lc_headers obj_binutils/.lc_built obj_gcc/gcc/.lc_built obj_mingw_crt src_mingw
	cd obj_mingw_crt && ../src_mingw/mingw-w64-crt/configure $(FULL_MINGW_CRT_CONFIG)
	touch $@

obj_mingw_crt/.lc_built: | obj_mingw_crt/.lc_configured
	cd obj_mingw_crt && $(MAKE) $(MAKE_ARGS) $(MINGW_MAKE_ARGS)
	touch $@

obj_mingw_pthreads/.lc_configured: | obj_mingw_crt/.lc_built obj_mingw_pthreads src_mingw
	cd obj_mingw_pthreads && ../src_mingw/mingw-w64-libraries/winpthreads/configure $(FULL_MINGW_PTHREADS_CONFIG)
	touch $@

obj_mingw_pthreads/.lc_built: | obj_mingw_pthreads/.lc_configured
	cd obj_mingw_pthreads && $(MAKE) $(MAKE_ARGS) $(MINGW_MAKE_ARGS)
	touch $@

obj_sysroot/.lc_libs_pthreads: | obj_mingw_pthreads/.lc_built
	cd obj_mingw_pthreads && $(MAKE) $(MAKE_ARGS) $(MINGW_MAKE_ARGS) DESTDIR=$(CURDIR)/obj_sysroot/$(TARGET) install
	touch $@

obj_sysroot/.lc_libs_crt: | obj_mingw_crt/.lc_built
	cd obj_mingw_crt && $(MAKE) $(MAKE_ARGS) $(MINGW_MAKE_ARGS) DESTDIR=$(CURDIR)/obj_sysroot/$(TARGET) install
	touch $@

install-mingw-headers: | obj_mingw_headers/.lc_configured
	cd obj_mingw_headers && $(MAKE) $(MAKE_ARGS) $(MINGW_MAKE_ARGS) DESTDIR=$(DESTDIR)$(OUTPUT)$(SYSROOT) install

install-mingw-crt: | obj_mingw_crt/.lc_built
	cd obj_mingw_crt && $(MAKE) $(MAKE_ARGS) $(MINGW_MAKE_ARGS) DESTDIR=$(DESTDIR)$(OUTPUT)$(SYSROOT) install

install-mingw-pthreads: | obj_mingw_pthreads/.lc_built
	cd obj_mingw_pthreads && $(MAKE) $(MAKE_ARGS) $(MINGW_MAKE_ARGS) DESTDIR=$(DESTDIR)$(OUTPUT)$(SYSROOT) install

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
	cd src_kernel_headers && $(MAKE) $(MAKE_ARGS) ARCH=$(LINUX_ARCH) O=$(CURDIR)/obj_kernel_headers INSTALL_HDR_PATH=$(CURDIR)/obj_kernel_headers/staged headers_install HOSTCC="$(CC)"
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
