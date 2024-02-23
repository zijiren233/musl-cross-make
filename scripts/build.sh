#!/bin/bash

set -e

function ChToScriptFileDir() {
    cd "$(dirname "$0")"
}

function Init() {
    cd ..
    DIST="dist"
    mkdir -p "$DIST"
    OIFS="$IFS"
    IFS=$'\n\t, '

    if [ "$(uname)" == "Darwin" ]; then
        MAKE="gmake"
        TMP_BIN_DIR="$(mktemp -d)"
        PATH="$TMP_BIN_DIR:$PATH"
        trap "rm -rf \"$TMP_BIN_DIR\"" EXIT

        if [ -x "$(command -v gsed)" ]; then
            SED_PATH="$(command -v gsed)"
            ln -s "$SED_PATH" "$TMP_BIN_DIR/sed"
        else
            echo "Warn: gsed not found"
            echo "Warn: when sed is not gnu version, it may cause build error"
            echo "Warn: you can install gsed with brew"
            echo "Warn: brew install gnu-sed"
            sleep 3
        fi

        if [ -x "$(command -v glibtool)" ]; then
            LIBTOOL_PATH="$(command -v glibtool)"
            ln -s "$LIBTOOL_PATH" "$TMP_BIN_DIR/libtool"
        else
            echo "Warn: glibtool not found"
            echo "Warn: when libtool is not gnu version, it may cause build error"
            echo "Warn: you can install libtool with brew"
            echo "Warn: brew install libtool"
            sleep 3
        fi

        if [ -x "$(command -v greadlink)" ]; then
            READLINK_PATH="$(command -v greadlink)"
            ln -s "$READLINK_PATH" "$TMP_BIN_DIR/readlink"
        else
            echo "Warn: greadlink not found"
            echo "Warn: when readlink is not gnu version, it may cause build error"
            echo "Warn: you can install coreutils with brew"
            echo "Warn: brew install coreutils"
            sleep 3
        fi

        if [ -x "$(command -v gfind)" ]; then
            FIND_PATH="$(command -v gfind)"
            ln -s "$FIND_PATH" "$TMP_BIN_DIR/find"
        else
            echo "Warn: gfind not found"
            echo "Warn: when find is not gnu version, it may cause build error"
            echo "Warn: you can install findutils with brew"
            echo "Warn: brew install findutils"
            sleep 3
        fi

        if [ -x "$(command -v gawk)" ]; then
            AWK_PATH="$(command -v gawk)"
            ln -s "$AWK_PATH" "$TMP_BIN_DIR/awk"
        else
            echo "Warn: gawk not found"
            echo "Warn: when awk is not gnu version, it may cause build error"
            echo "Warn: you can install gawk with brew"
            echo "Warn: brew install gawk"
            sleep 3
        fi

        if [ -z "$(patch -v | grep "GNU patch")" ]; then
            echo "Warn: patch not gnu version"
            echo "Warn: when patch is not gnu version, it may cause build error"
            echo "Warn: you can install gpatch with brew"
            echo "Warn: brew install gpatch"
            sleep 3
        fi

    else
        MAKE="make"
    fi

    {
        DEFAULT_CONFIG_SUB_REV="28ea239c53a2"
        DEFAULT_GCC_VER="13.2.0"
        DEFAULT_MUSL_VER="1.2.4"
        DEFAULT_BINUTILS_VER="2.42"
        DEFAULT_GMP_VER="6.3.0"
        DEFAULT_MPC_VER="1.3.1"
        DEFAULT_MPFR_VER="4.2.1"
        DEFAULT_ISL_VER="0.26"
        DEFAULT_LINUX_VER="6.6.9"
        DEFAULT_MINGW_VER="v11.0.1"
        if [ ! "$CONFIG_SUB_REV" ]; then
            CONFIG_SUB_REV="$DEFAULT_CONFIG_SUB_REV"
        fi
        if [ ! "$GCC_VER" ]; then
            GCC_VER="$DEFAULT_GCC_VER"
        fi
        if [ -z "${MUSL_VER+x}" ]; then
            MUSL_VER="$DEFAULT_MUSL_VER"
        fi
        if [ ! "$BINUTILS_VER" ]; then
            BINUTILS_VER="$DEFAULT_BINUTILS_VER"
        fi
        if [ ! "$GMP_VER" ]; then
            GMP_VER="$DEFAULT_GMP_VER"
        fi
        if [ ! "$MPC_VER" ]; then
            MPC_VER="$DEFAULT_MPC_VER"
        fi
        if [ ! "$MPFR_VER" ]; then
            MPFR_VER="$DEFAULT_MPFR_VER"
        fi
        if [ -z "${ISL_VER+x}" ]; then
            ISL_VER="$DEFAULT_ISL_VER"
        fi
        if [ -z "${LINUX_VER+x}" ]; then
            LINUX_VER="$DEFAULT_LINUX_VER"
        fi
        if [ -z "${MINGW_VER+x}" ]; then
            MINGW_VER="$DEFAULT_MINGW_VER"
        fi
    }
}

function Help() {
    echo "-h: help"
    echo "-a: enable archive"
    echo "-T: targets file path or targets string"
    echo "-C: use china mirror"
    echo "-c: set CC"
    echo "-x: set CXX"
    echo "-n: with native build"
    echo "-N: only native build"
    echo "-L: log to std"
    echo "-l: disable log to file"
    echo "-O: set optimize level"
    echo "-j: set job number"
    echo "-i: simpler build"
    echo "-d: download sources only"
    echo "-D: disable log print date prefix"
    echo "-P: disable log print target prefix"
}

function ParseArgs() {
    while getopts "haT:Cc:x:nLlO:j:NidDP" arg; do
        case $arg in
        h)
            Help
            exit 0
            ;;
        a)
            ENABLE_ARCHIVE="true"
            ;;
        T)
            TARGETS_FILE="$OPTARG"
            ;;
        C)
            USE_CHINA_MIRROR="true"
            ;;
        c)
            CC="$OPTARG"
            ;;
        x)
            CXX="$OPTARG"
            ;;
        n)
            NATIVE_BUILD="true"
            ;;
        N)
            NATIVE_BUILD="true"
            ONLY_NATIVE_BUILD="true"
            ;;
        L)
            LOG_TO_STD="true"
            ;;
        l)
            DISABLE_LOG_TO_FILE="true"
            ;;
        O)
            OPTIMIZE_LEVEL="$OPTARG"
            ;;
        j)
            if [ "$OPTARG" -eq "$OPTARG" ] 2>/dev/null; then
                CPU_NUM="$OPTARG"
            else
                echo "cpu number must be number"
                exit 1
            fi
            ;;
        i)
            SIMPLER_BUILD="true"
            ;;
        d)
            SOURCES_ONLY="true"
            ;;
        D)
            DISABLE_LOG_PRINT_DATE_PREFIX="true"
            ;;
        P)
            DISABLE_LOG_PRINT_TARGET_PREFIX="true"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
            ;;
        esac
    done
    shift $((OPTIND - 1))
    MORE_ARGS="$@"
}

function FixArgs() {
    mkdir -p "${DIST}"
    DIST="$(cd "$DIST" && pwd)"

    if [ ! "$CPU_NUM" ]; then
        CPU_NUM=$(nproc)
        if [ $? -ne 0 ]; then
            CPU_NUM=2
        fi
    fi

    MAKE="$MAKE -j${CPU_NUM}"

    if [ "$SOURCES_ONLY" ]; then
        WriteConfig
        $MAKE SOURCES_ONLY="true" extract_all
        exit $?
    fi

    if [ ! "$OPTIMIZE_LEVEL" ]; then
        OPTIMIZE_LEVEL="s"
    fi
}

function Date() {
    if [ "$DISABLE_LOG_PRINT_DATE_PREFIX" ]; then
        return
    fi
    echo "[$(date '+%H:%M:%S')] "
}

function WriteConfig() {
    cat >config.mak <<EOF
CONFIG_SUB_REV = ${CONFIG_SUB_REV}
TARGET = ${TARGET}
NATIVE = ${NATIVE}
OUTPUT = ${OUTPUT}
GCC_VER = ${GCC_VER}
MUSL_VER = ${MUSL_VER}
BINUTILS_VER = ${BINUTILS_VER}

GMP_VER = ${GMP_VER}
MPC_VER = ${MPC_VER}
MPFR_VER = ${MPFR_VER}
ISL_VER = ${ISL_VER}

LINUX_VER = ${LINUX_VER}
MINGW_VER = ${MINGW_VER}

# only work in cross build
# native build will find ${TARGET}-gcc ${TARGET}-g++ in env to build
ifneq (${CC}${CXX},)
CC = ${CC}
CXX = ${CXX}
endif

CHINA = ${USE_CHINA_MIRROR}

COMMON_FLAGS += -O${OPTIMIZE_LEVEL}

SIMPLER_BUILD = ${SIMPLER_BUILD}

COMMON_CONFIG += --with-debug-prefix-map=\$(CURDIR)= --enable-compressed-debug-sections=none

EOF
    for arg in "$@"; do
        echo "$arg" >>config.mak
    done
}

function TestCrossCompiler() {
    COMPILER="$@"
    if [ -z "$COMPILER" ]; then
        echo "no compiler"
        return 1
    fi
    echo "test cross compiler: $COMPILER"
    if ! echo '#include <stdio.h>
int main()
{
    printf("hello world\\n");
    return 0;
}
' | $COMPILER -x c - -o buildtest; then
        echo "test cross compiler error"
        return 1
    else
        rm buildtest
        echo "test cross compiler success"
        return
    fi
}

function Build() {
    TARGET="$1"
    DIST_NAME="${DIST}/${DIST_NAME_PREFIX}${TARGET}"
    CROSS_DIST_NAME="${DIST_NAME}-cross${DIST_NAME_SUFFIX}"
    NATIVE_DIST_NAME="${DIST_NAME}-native${DIST_NAME_SUFFIX}"
    CROSS_LOG_FILE="${CROSS_DIST_NAME}.log"
    NATIVE_LOG_FILE="${NATIVE_DIST_NAME}.log"

    if [ ! "$ONLY_NATIVE_BUILD" ]; then
        echo "build cross ${DIST_NAME_PREFIX}${TARGET} to ${CROSS_DIST_NAME}"
        {
            OUTPUT="${CROSS_DIST_NAME}"
            NATIVE=""
            WriteConfig
        }
        $MAKE tmpclean
        rm -rf "${CROSS_DIST_NAME}" "${CROSS_LOG_FILE}"
        while IFS= read -r line; do
            CURRENT_DATE=$(Date)
            if [ "$LOG_TO_STD" ]; then
                if [ "$DISABLE_LOG_PRINT_TARGET_PREFIX" ]; then
                    echo "${CURRENT_DATE}$line"
                else
                    echo "${CURRENT_DATE}${DIST_NAME_PREFIX}${TARGET}-cross: $line"
                fi
            fi
            if [ ! "$DISABLE_LOG_TO_FILE" ]; then
                echo "${CURRENT_DATE}$line" >>"${CROSS_LOG_FILE}"
            fi
        done < <(
            set +e
            $MAKE $MORE_ARGS install 2>&1
            echo $? >"${CROSS_DIST_NAME}.exit"
            set -e
        )
        read EXIT_CODE <"${CROSS_DIST_NAME}.exit"
        rm "${CROSS_DIST_NAME}.exit"
        if [ $EXIT_CODE -ne 0 ]; then
            if [ ! "$LOG_TO_STD" ]; then
                tail -n 3000 "${CROSS_LOG_FILE}"
                echo "full build log: ${CROSS_LOG_FILE}"
            fi
            echo "build cross ${DIST_NAME_PREFIX}${TARGET} error"
            exit $EXIT_CODE
        else
            echo "build cross ${DIST_NAME_PREFIX}${TARGET} success"
            TestCrossCompiler "${CROSS_DIST_NAME}/bin/${TARGET}-gcc -static --static"
        fi
        if [ "$ENABLE_ARCHIVE" ]; then
            tar -zcf "${CROSS_DIST_NAME}.tgz" -C "${CROSS_DIST_NAME}" .
            echo "package ${CROSS_DIST_NAME} to ${CROSS_DIST_NAME}.tgz success"
        fi
    fi

    if [ "$NATIVE_BUILD" ]; then
        echo "build native ${DIST_NAME_PREFIX}${TARGET} to ${NATIVE_DIST_NAME}"
        {
            OUTPUT="${NATIVE_DIST_NAME}"
            NATIVE="true"
            WriteConfig "export PATH := ${CROSS_DIST_NAME}/bin:\$(PATH)"
        }
        if [ "$ONLY_NATIVE_BUILD" ]; then
            $MAKE tmpclean
        fi
        rm -rf "${NATIVE_DIST_NAME}" "${NATIVE_LOG_FILE}"
        while IFS= read -r line; do
            CURRENT_DATE=$(Date)
            if [ "$LOG_TO_STD" ]; then
                if [ "$DISABLE_LOG_PRINT_TARGET_PREFIX" ]; then
                    echo "${CURRENT_DATE}$line"
                else
                    echo "${CURRENT_DATE}${DIST_NAME_PREFIX}${TARGET}-native: $line"
                fi
            fi
            if [ ! "$DISABLE_LOG_TO_FILE" ]; then
                echo "${CURRENT_DATE}$line" >>"${NATIVE_LOG_FILE}"
            fi
        done < <(
            set +e
            $MAKE $MORE_ARGS install 2>&1
            echo $? >"${NATIVE_DIST_NAME}.exit"
            set -e
        )
        read EXIT_CODE <"${NATIVE_DIST_NAME}.exit"
        rm "${NATIVE_DIST_NAME}.exit"
        if [ $EXIT_CODE -ne 0 ]; then
            if [ ! "$LOG_TO_STD" ]; then
                tail -n 3000 "${NATIVE_LOG_FILE}"
                echo "full build log: ${NATIVE_LOG_FILE}"
            fi
            echo "build native ${DIST_NAME_PREFIX}${TARGET} error"
            exit $EXIT_CODE
        else
            echo "build native ${DIST_NAME_PREFIX}${TARGET} success"
        fi
        if [ "$ENABLE_ARCHIVE" ]; then
            tar -zcf "${NATIVE_DIST_NAME}.tgz" -C "${NATIVE_DIST_NAME}" .
            echo "package ${NATIVE_DIST_NAME} to ${NATIVE_DIST_NAME}.tgz success"
        fi
    fi
}

ALL_TARGETS='aarch64-linux-musl
armv5-linux-musleabi
armv6-linux-musleabi
armv6-linux-musleabihf
armv7-linux-musleabi
armv7-linux-musleabihf
loongarch64-linux-musl
mips-linux-musl
mips-linux-muslsf
mipsel-linux-musl
mipsel-linux-muslsf
mips64-linux-musl
mips64-linux-muslsf
mips64el-linux-musl
mips64el-linux-muslsf
powerpc64-linux-musl
powerpc64le-linux-musl
riscv64-linux-musl
s390x-linux-musl
i586-linux-musl
i686-linux-musl
x86_64-linux-musl
i586-w64-mingw32
i686-w64-mingw32
x86_64-w64-mingw32'

function BuildAll() {
    if [ "$TARGETS_FILE" ]; then
        if [ -f "$TARGETS_FILE" ]; then
            while read line; do
                if [ -z "$line" ] || [ "${line:0:1}" == "#" ]; then
                    continue
                fi
                Build "$line"
            done <"$TARGETS_FILE"
            return
        else
            TARGETS="$TARGETS_FILE"
        fi
    else
        TARGETS="$ALL_TARGETS"
    fi

    for line in $TARGETS; do
        if [ -z "$line" ] || [ "${line:0:1}" == "#" ]; then
            continue
        fi
        Build "$line"
    done
}

ChToScriptFileDir
Init
ParseArgs "$@"
FixArgs
BuildAll
