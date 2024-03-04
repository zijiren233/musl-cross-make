SOURCES = sources

COMPILER = gcc

CONFIG_SUB_REV = 28ea239c53a2
CONFIG_GUESS_REV = 28ea239c53a2
LLVM_VER = 17.0.6
GCC_VER = 13.2.0
MUSL_VER = 1.2.4
BINUTILS_VER = 2.41
GMP_VER = 6.3.0
MPC_VER = 1.3.1
MPFR_VER = 4.2.1
ISL_VER = 0.26
LINUX_VER = 6.6.9
MINGW_VER = v11.0.1
CHINA = 

# curl --progress-bar -Lo <file> <url>
DL_CMD = curl --progress-bar -Lo
SHA1_CMD = sha1sum -c

COWPATCH = $(CURDIR)/cowpatch.sh

HOST = $(if $(NATIVE),$(TARGET))
BUILD_DIR = build-$(COMPILER)/$(if $(HOST),$(HOST),local)/$(TARGET)
OUTPUT = $(CURDIR)/output$(if $(HOST),-$(HOST))

REL_TOP = ../..$(if $(TARGET),/..)

-include config.mak

MUSL_REPO = https://git.musl-libc.org/cgit/musl

LINUX_HEADERS_SITE = https://ftp.barfooze.de/pub/sabotage/tarballs

ifneq ($(CHINA),)
MUSL_SITE ?= https://musl.libc.org/releases

GNU_SITE ?= https://mirrors.ustc.edu.cn/gnu

SOURCEFORGE_MIRROT ?= https://jaist.dl.sourceforge.net

GCC_SNAP ?= https://mirrors.tuna.tsinghua.edu.cn/sourceware/gcc/snapshots

LINUX_SITE ?= https://mirrors.ustc.edu.cn/kernel.org/linux/kernel

ISL_SITE ?= https://sources.buildroot.net/isl
else
MUSL_SITE ?= https://musl.libc.org/releases

GNU_SITE ?= https://ftp.gnu.org/gnu

SOURCEFORGE_MIRROT ?= https://downloads.sourceforge.net

GCC_SNAP ?= https://sourceware.org/pub/gcc/snapshots

LINUX_SITE ?= https://cdn.kernel.org/pub/linux/kernel
endif
GCC_SITE ?= $(GNU_SITE)/gcc
BINUTILS_SITE ?= $(GNU_SITE)/binutils
GMP_SITE ?= $(GNU_SITE)/gmp
MPC_SITE ?= $(GNU_SITE)/mpc
MPFR_SITE ?= $(GNU_SITE)/mpfr
ISL_SITE ?= $(SOURCEFORGE_MIRROT)/project/libisl
MINGW_SITE ?= $(SOURCEFORGE_MIRROT)/project/mingw-w64/mingw-w64/mingw-w64-release
LLVM_SITE ?= https://github.com/llvm/llvm-project/releases/download

ifeq ($(COMPILER),gcc)

override LLVM_VER = 

else

override TARGET = 
override GCC_VER = 
override GMP_VER = 
override MPC_VER =
override MPFR_VER =
override ISL_VER =
override BINUTILS_VER =
override MINGW_VER = 

endif

SRC_DIRS = $(if $(GCC_VER),gcc-$(GCC_VER)) \
	$(if $(BINUTILS_VER),binutils-$(BINUTILS_VER)) \
    $(if $(MUSL_VER),musl-$(MUSL_VER)) \
	$(if $(GMP_VER),gmp-$(GMP_VER)) \
	$(if $(MPC_VER),mpc-$(MPC_VER)) \
	$(if $(MPFR_VER),mpfr-$(MPFR_VER)) \
	$(if $(ISL_VER),isl-$(ISL_VER)) \
	$(if $(LINUX_VER),linux-$(LINUX_VER)) \
    $(if $(MINGW_VER),mingw-w64-$(MINGW_VER)) \
	$(if $(LLVM_VER),llvm-project-$(LLVM_VER).src)

all:

clean:
	( cd $(CURDIR) && \
	find . -maxdepth 1 \( \
    	-name "gcc-*" \
    	-o -name "binutils-*" \
    	-o -name "musl-*" \
    	-o -name "gmp-*" \
    	-o -name "mpc-*" \
    	-o -name "mpfr-*" \
    	-o -name "isl-*" \
    	-o -name "build" \
    	-o -name "build-*" \
    	-o -name "linux-*" \
    	-o -name "mingw-w64-*" \
    	-o -name "llvm-project-*" \
	\) \
	! -name "*.orig" \
	-type d \
	-exec echo rm -rf {} \; \
	-exec rm -rf {} + )

distclean:
	( cd $(CURDIR) && rm -rf sources gcc-* binutils-* musl-* gmp-* mpc-* mpfr-* isl-* build build-* linux-* mingw-w64-* llvm-project-* )

check:
	@echo "check bzip2"
	@which bzip2
	@echo "check xz"
	@which xz
	@echo "check gcc"
	@which gcc
	@echo "check g++"
	@which g++
	@echo "check bison"
	@which bison
	@echo "check rsync"
	@which rsync
	@echo "check sha1sum"
	@which sha1sum

# Rules for downloading and verifying sources. Treat an external SOURCES path as
# immutable and do not try to download anything into it.

ifeq ($(SOURCES),sources)

$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/gmp*)): SITE = $(GMP_SITE)
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/mpc*)): SITE = $(MPC_SITE)
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/mpfr*)): SITE = $(MPFR_SITE)
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/isl*)): SITE = $(ISL_SITE)
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/binutils*)): SITE = $(BINUTILS_SITE)
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/gcc-*)): SITE = $(GCC_SITE)/$(basename $(basename $(notdir $@)))
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/gcc-*-*)): SITE = $(GCC_SNAP)/$(subst gcc-,,$(basename $(basename $(notdir $@))))
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/musl*)): SITE = $(MUSL_SITE)
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/linux-6*)): SITE = $(LINUX_SITE)/v6.x
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/linux-5*)): SITE = $(LINUX_SITE)/v5.x
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/linux-4*)): SITE = $(LINUX_SITE)/v4.x
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/linux-3*)): SITE = $(LINUX_SITE)/v3.x
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/linux-2.6*)): SITE = $(LINUX_SITE)/v2.6
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/linux-headers-*)): SITE = $(LINUX_HEADERS_SITE)
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/mingw-w64*)): SITE = $(MINGW_SITE)
$(patsubst hashes/%.sha1,$(SOURCES)/%,$(wildcard hashes/llvm-project-*)): SITE = $(LLVM_SITE)/llvmorg-$(patsubst llvm-project-%.src,%,$(basename $(basename $(notdir $@))))

$(SOURCES):
	mkdir -p $@

$(SOURCES)/config.sub: | $(SOURCES)
	mkdir -p $@.tmp
	cd $@.tmp && $(DL_CMD) $(notdir $@) "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=$(CONFIG_SUB_REV)"
	cd $@.tmp && touch $(notdir $@)
	cd $@.tmp && $(SHA1_CMD) $(CURDIR)/hashes/$(notdir $@).$(CONFIG_SUB_REV).sha1
	mv $@.tmp/$(notdir $@) $@
	rm -rf $@.tmp

$(SOURCES)/config.guess: | $(SOURCES)
	mkdir -p $@.tmp
	cd $@.tmp && $(DL_CMD) $(notdir $@) "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=$(CONFIG_GUESS_REV)"
	cd $@.tmp && touch $(notdir $@)
	cd $@.tmp && $(SHA1_CMD) $(CURDIR)/hashes/$(notdir $@).$(CONFIG_GUESS_REV).sha1
	mv $@.tmp/$(notdir $@) $@
	rm -rf $@.tmp

$(SOURCES)/%: hashes/%.sha1 | $(SOURCES)
	mkdir -p $@.tmp
	cd $@.tmp && $(DL_CMD) $(notdir $@) $(SITE)/$(notdir $@)
	cd $@.tmp && touch $(notdir $@)
	cd $@.tmp && $(SHA1_CMD) $(CURDIR)/hashes/$(notdir $@).sha1
	mv $@.tmp/$(notdir $@) $@
	rm -rf $@.tmp

endif

# Rules for extracting and patching sources, or checking them out from git.

musl-git-%:
	rm -rf $@.tmp
	git clone $(MUSL_REPO) $@.tmp
	cd $@.tmp && git reset --hard $(patsubst musl-git-%,%,$@) && git fsck
	test ! -d patches/$@ || cat $(wildcard patches/$@/*) | ( cd $@.tmp && patch -p1 )
	mv $@.tmp $@

%.orig: $(SOURCES)/%.tar.gz
	case "$@" in */*) exit 1 ;; esac
	rm -rf $@.tmp
	mkdir $@.tmp
	( cd $@.tmp && tar -zxf - ) < $<
	rm -rf $@
	touch $@.tmp/$(patsubst %.orig,%,$@)
	mv $@.tmp/$(patsubst %.orig,%,$@) $@
	rm -rf $@.tmp

%.orig: $(SOURCES)/%.tar.bz2
	case "$@" in */*) exit 1 ;; esac
	rm -rf $@.tmp
	mkdir $@.tmp
	( cd $@.tmp && tar -jxf - ) < $<
	rm -rf $@
	touch $@.tmp/$(patsubst %.orig,%,$@)
	mv $@.tmp/$(patsubst %.orig,%,$@) $@
	rm -rf $@.tmp

%.orig: $(SOURCES)/%.tar.xz
	case "$@" in */*) exit 1 ;; esac
	rm -rf $@.tmp
	mkdir $@.tmp
	( cd $@.tmp && tar -Jxf - ) < $<
	rm -rf $@
	touch $@.tmp/$(patsubst %.orig,%,$@)
	mv $@.tmp/$(patsubst %.orig,%,$@) $@
	rm -rf $@.tmp

define find_and_prefix
$(addprefix $(SOURCES)/,$(notdir $(wildcard hashes/\$1*.sha1)))
endef

ifeq ($(SOURCES_ONLY),)
%: %.orig | $(SOURCES)/config.sub $(SOURCES)/config.guess
	case "$@" in */*) exit 1 ;; esac
	rm -rf $@.tmp
	mkdir $@.tmp
	( cd $@.tmp && $(COWPATCH) -C ../$< )
	if [ -d patches/$@ ] && [ -n "$(shell find patches/$@ -type f)" ]; then \
		if [ -z "$(findstring mingw,$(TARGET))" ]; then \
			cat $(filter-out %-mingw.diff,$(wildcard patches/$@/*)) | ( cd $@.tmp && $(COWPATCH) -p1 ); \
		else \
			cat $(filter-out %-musl.diff,$(wildcard patches/$@/*)) | ( cd $@.tmp && $(COWPATCH) -p1 ); \
		fi \
	fi
	( cd $@.tmp && find -L . -name config.sub -type f -exec cp -f $(CURDIR)/$(SOURCES)/config.sub {} \; -exec chmod +x {} \; )
	( cd $@.tmp && find -L . -name configfsf.sub -type f -exec cp -f $(CURDIR)/$(SOURCES)/config.sub {} \; -exec chmod +x {} \; )
	( cd $@.tmp && find -L . -name config.guess -type f -exec cp -f $(CURDIR)/$(SOURCES)/config.guess {} \; -exec chmod +x {} \; )
	( cd $@.tmp && find -L . -name configfsf.guess -type f -exec cp -f $(CURDIR)/$(SOURCES)/config.guess {} \; -exec chmod +x {} \; )
	rm -rf $@
	mv $@.tmp $@

ifneq ($(findstring mingw,$(TARGET)),)
extract_all: | $(filter-out linux-% musl-%,$(SRC_DIRS))
else
ifneq ($(findstring musl,$(TARGET)),)
extract_all: | $(filter-out mingw-w64-%,$(SRC_DIRS))
else
extract_all: | $(SRC_DIRS)
endif
endif

else
extract_all: | $(patsubst %.sha1,%, $(foreach item,$(SRC_DIRS),$(call find_and_prefix,$(item)))) $(SOURCES)/config.sub $(SOURCES)/config.guess
endif
# Add deps for all patched source dirs on their patchsets
$(foreach dir,$(notdir $(basename $(basename $(basename $(wildcard hashes/*))))),$(eval $(dir): $$(wildcard patches/$(dir) patches/$(dir)/*)))

# Rules for building.

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/Makefile: | $(BUILD_DIR)
	ln -sf $(REL_TOP)/litecross/Makefile.$(COMPILER) $@

$(BUILD_DIR)/config.mak: | $(BUILD_DIR)
	printf >$@ '%s\n' \
	"HOST = $(HOST)" \
	$(if $(TARGET),"TARGET = $(TARGET)") \
	$(if $(GCC_VER),"GCC_SRCDIR = $(REL_TOP)/gcc-$(GCC_VER)") \
	$(if $(BINUTILS_VER),"BINUTILS_SRCDIR = $(REL_TOP)/binutils-$(BINUTILS_VER)") \
	$(if $(MUSL_VER),"MUSL_SRCDIR = $(REL_TOP)/musl-$(MUSL_VER)") \
	$(if $(GMP_VER),"GMP_SRCDIR = $(REL_TOP)/gmp-$(GMP_VER)") \
	$(if $(MPC_VER),"MPC_SRCDIR = $(REL_TOP)/mpc-$(MPC_VER)") \
	$(if $(MPFR_VER),"MPFR_SRCDIR = $(REL_TOP)/mpfr-$(MPFR_VER)") \
	$(if $(ISL_VER),"ISL_SRCDIR = $(REL_TOP)/isl-$(ISL_VER)") \
	$(if $(LINUX_VER),"LINUX_SRCDIR = $(REL_TOP)/linux-$(LINUX_VER)") \
	$(if $(MINGW_VER),"MINGW_SRCDIR = $(REL_TOP)/mingw-w64-$(MINGW_VER)") \
	$(if $(LLVM_VER),"LLVM_SRCDIR = $(REL_TOP)/llvm-project-$(LLVM_VER).src") \
	$(if $(LLVM_VER),"LLVM_VER = $(LLVM_VER)") \
	"-include $(REL_TOP)/config.mak"

ifeq ($(COMPILER),)

all:
	@echo COMPILER must be set via config.mak or command line.
	@exit 1

else ifeq ($(COMPILER)$(TARGET),gcc)

all:
	@echo TARGET must be set for gcc build via config.mak or command line.
	@exit 1

else

all: | extract_all $(BUILD_DIR) $(BUILD_DIR)/Makefile $(BUILD_DIR)/config.mak
	cd $(BUILD_DIR) && $(MAKE) $@

install: | extract_all $(BUILD_DIR) $(BUILD_DIR)/Makefile $(BUILD_DIR)/config.mak
	cd $(BUILD_DIR) && $(MAKE) OUTPUT=$(OUTPUT) $@

endif

.SECONDARY:
