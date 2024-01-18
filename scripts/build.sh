#!/bin/bash

function ChToScriptFileDir() {
    cd "$(dirname "$0")"
    if [ $? -ne 0 ]; then
        echo "cd to script file dir error"
        exit 1
    fi
}

function Init() {
    cd ..
    DIST="dist"
    mkdir -p "$DIST"
    if [ $? -ne 0 ]; then
        echo "mkdir dist dir ${DIST} error"
        exit 1
    fi
    OIFS="$IFS"
    IFS=$'\n\t, '
}

function Help() {
    echo "-h: help"
    echo "-a: enable archive"
    echo "-t: test build only"
    echo "-T: targets file path or targets string"
    echo "-C: use china mirror"
    echo "-c: set CC"
    echo "-x: set CXX"
    echo "-f: set FC"
    echo "-n: with native build"
    echo "-L: log to std"
    echo "-O: set optimize level"
}

function ParseArgs() {
    while getopts "hatT:Cc:x:f:nLO:" arg; do
        case $arg in
        h)
            Help
            exit 0
            ;;
        a)
            ENABLE_ARCHIVE="1"
            ;;
        t)
            TEST_BUILD_ONLY="1"
            ;;
        T)
            TARGETS_FILE="$OPTARG"
            ;;
        C)
            USE_CHINA_MIRROR="1"
            ;;
        c)
            CC="$OPTARG"
            ;;
        x)
            CXX="$OPTARG"
            ;;
        f)
            FC="$OPTARG"
            ;;
        n)
            NATIVE_BUILD="1"
            ;;
        L)
            LOG_TO_STD="1"
            ;;
        O)
            OPTIMIZE_LEVEL="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
            ;;
        esac
    done
}

function FixArgs() {
    mkdir -p "${DIST}"
    if [ $? -ne 0 ]; then
        echo "mkdir dist dir ${DIST} error"
        exit 1
    fi
    DIST="$(cd "$DIST" && pwd)"
    if [ $? -ne 0 ]; then
        echo "cd dist dir ${DIST} error"
        exit 1
    fi
}

function Build() {
    TARGET="$1"
    DIST_NAME="${DIST}/${TARGET}"
    NATIVE_DIST_NAME="${DIST_NAME}-native"
    if [ "$LOG_TO_STD" ]; then
        LOG_FILE="/dev/stdout"
        NATIVE_LOG_FILE="/dev/stdout"
    else
        LOG_FILE="${DIST_NAME}.log"
        NATIVE_LOG_FILE="${NATIVE_DIST_NAME}.log"
    fi

    rm -rf "${DIST_NAME}"
    make clean
    echo "build ${TARGET} to ${DIST_NAME}"
    make \
        TARGET="${TARGET}" \
        OUTPUT="${DIST_NAME}" \
        NATIVE="" \
        install >"${LOG_FILE}" 2>&1
    if [ $? -ne 0 ]; then
        if [ ! "$LOG_TO_STD" ]; then
            cat "${LOG_FILE}"
            echo "full build log: ${LOG_FILE}"
        fi
        echo "build ${TARGET} error"
        exit 1
    else
        echo "build ${TARGET} success"
    fi

    if [ "$NATIVE_BUILD" ]; then
        rm -rf "${NATIVE_DIST_NAME}"
        make clean
        echo "build native ${TARGET} to ${NATIVE_DIST_NAME}"
        PATH="${DIST_NAME}/bin:${PATH}" \
            make \
            TARGET="${TARGET}" \
            OUTPUT="${NATIVE_DIST_NAME}" \
            NATIVE="true" \
            install >"${NATIVE_LOG_FILE}" 2>&1
        if [ $? -ne 0 ]; then
            if [ ! "$LOG_TO_STD" ]; then
                cat "${NATIVE_LOG_FILE}"
                echo "full build log: ${NATIVE_LOG_FILE}"
            fi
            echo "build native ${TARGET} error"
            exit 1
        else
            echo "build native ${TARGET} success"
        fi
    fi
    if [ "$TEST_BUILD_ONLY" ]; then
        rm -rf "${DIST_NAME}" "${NATIVE_DIST_NAME}"
    else
        if [ "$ENABLE_ARCHIVE" ]; then
            tar -zcvf "${DIST_NAME}.tgz" -C "${DIST_NAME}" .
            if [ $? -ne 0 ]; then
                echo "package ${DIST_NAME} error"
                exit 1
            fi

            if [ "$NATIVE_BUILD" ]; then
                tar -zcvf "${NATIVE_DIST_NAME}.tgz" -C "${NATIVE_DIST_NAME}" .
                if [ $? -ne 0 ]; then
                    echo "package ${NATIVE_DIST_NAME} error"
                    exit 1
                fi
            fi
            rm -rf "${DIST_NAME}" "${NATIVE_DIST_NAME}"
        fi
    fi
}

ALL_TARGETS='aarch64-linux-musl
arm-linux-musleabi
arm-linux-musleabihf
armv5-linux-musleabi
armv5-linux-musleabihf
armv6-linux-musleabi
armv6-linux-musleabihf
armv7-linux-musleabi
armv7-linux-musleabihf
i486-linux-musl
i686-linux-musl
mips-linux-musl
mips-linux-musln32
mips-linux-muslsf
mips-linux-musln32sf
mipsel-linux-musl
mipsel-linux-musln32
mipsel-linux-muslsf
mipsel-linux-musln32sf
mips64-linux-musl
mips64-linux-musln32
mips64-linux-musln32sf
mips64el-linux-musl
mips64el-linux-musln32
mips64el-linux-musln32sf
powerpc-linux-musl
powerpc-linux-muslsf
powerpcle-linux-musl
powerpcle-linux-muslsf
powerpc64-linux-musl
powerpc64le-linux-musl
riscv64-linux-musl
s390x-linux-musl
x86_64-linux-musl
x86_64-linux-muslx32
i486-w64-mingw32
i686-w64-mingw32
x86_64-w64-mingw32'

function BuildAll() {
    cat >config.mak <<EOF
CONFIG_SUB_REV = 28ea239c53a2
GCC_VER = 11.4.0
MUSL_VER = 1.2.4
BINUTILS_VER = 2.37
GMP_VER = 6.3.0
MPC_VER = 1.3.1
MPFR_VER = 4.2.1
ISL_VER = 
LINUX_VER = 4.19.274
MINGW_VER = v11.0.1

CC_COMPILER = ${CC}
CXX_COMPILER = ${CXX}
FC_COMPILER = ${FC}
CHINA = ${USE_CHINA_MIRROR}
OPTIMIZE_LEVEL = ${OPTIMIZE_LEVEL}

COMMON_CONFIG += --disable-nls
GCC_CONFIG += --disable-libquadmath --disable-decimal-float
GCC_CONFIG += --disable-libitm
GCC_CONFIG += --disable-fixed-point
GCC_CONFIG += --disable-lto
BINUTILS_CONFIG += --enable-compressed-debug-sections=none
EOF
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
