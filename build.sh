#!/usr/bin/env bash
#
# Configure and build the AVR firmware via CMake.
#
# Usage: ./build.sh [options]
# Run `./build.sh --help` for the full option list.

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
readonly REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly TOOLCHAIN_FILE="${REPO_ROOT}/avr-gcc-toolchain.cmake"

MCU="atmega2560"
F_CPU="16000000UL"
BUILD_TYPE="Release"
BUILD_DIR="build"
JOBS=""
CLEAN=0
CLEAN_ONLY=0
VERBOSE=0

# ---------------------------------------------------------------------------
# Pretty printing
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
    C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'
    C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YLW=$'\033[33m'; C_CYN=$'\033[36m'
else
    C_RESET=""; C_BOLD=""; C_RED=""; C_GRN=""; C_YLW=""; C_CYN=""
fi

info()  { printf "${C_CYN}[build]${C_RESET} %s\n" "$*"; }
ok()    { printf "${C_GRN}[ ok  ]${C_RESET} %s\n" "$*"; }
warn()  { printf "${C_YLW}[warn]${C_RESET} %s\n" "$*" >&2; }
die()   { printf "${C_RED}[fail]${C_RESET} %s\n" "$*" >&2; exit 1; }

usage() {
    cat <<EOF
${C_BOLD}Usage:${C_RESET} $(basename "$0") [options]

Options:
  -m, --mcu MCU            Target AVR MCU                 (default: ${MCU})
  -f, --fcpu HZ            Clock frequency (with UL)      (default: ${F_CPU})
  -t, --build-type TYPE    Debug | Release | MinSizeRel |
                           RelWithDebInfo                 (default: ${BUILD_TYPE})
  -B, --build-dir DIR      Build directory                (default: ${BUILD_DIR})
  -j, --jobs N             Parallel build jobs            (default: auto)
  -c, --clean              Wipe build dir before building
  -C, --clean-only         Wipe build dir and exit
  -v, --verbose            Verbose build output
  -h, --help               Show this help and exit

Examples:
  $(basename "$0")
  $(basename "$0") -m atmega328p -f 8000000UL -t Debug
  $(basename "$0") --clean-only
EOF
}

# ---------------------------------------------------------------------------
# Argument parsing (supports long and short flags, plus "flag=value").
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--mcu)         MCU="$2"; shift 2 ;;
        --mcu=*)          MCU="${1#*=}"; shift ;;
        -f|--fcpu)        F_CPU="$2"; shift 2 ;;
        --fcpu=*)         F_CPU="${1#*=}"; shift ;;
        -t|--build-type)  BUILD_TYPE="$2"; shift 2 ;;
        --build-type=*)   BUILD_TYPE="${1#*=}"; shift ;;
        -B|--build-dir)   BUILD_DIR="$2"; shift 2 ;;
        --build-dir=*)    BUILD_DIR="${1#*=}"; shift ;;
        -j|--jobs)        JOBS="$2"; shift 2 ;;
        --jobs=*)         JOBS="${1#*=}"; shift ;;
        -c|--clean)       CLEAN=1; shift ;;
        -C|--clean-only)  CLEAN_ONLY=1; shift ;;
        -v|--verbose)     VERBOSE=1; shift ;;
        -h|--help)        usage; exit 0 ;;
        --)               shift; break ;;
        -*)               die "Unknown option: $1 (try --help)" ;;
         *)               die "Unexpected argument: $1 (try --help)" ;;
    esac
done

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
case "$BUILD_TYPE" in
    Debug|Release|MinSizeRel|RelWithDebInfo) ;;
    *) die "Invalid --build-type '$BUILD_TYPE' (Debug|Release|MinSizeRel|RelWithDebInfo)" ;;
esac

[[ -n "$MCU"   ]] || die "MCU is empty"
[[ -n "$F_CPU" ]] || die "F_CPU is empty"

# Allow either "16000000" or "16000000UL" — normalise to the UL form the
# compiler expects when the value is used inside preprocessor arithmetic.
[[ "$F_CPU" =~ [Uu][Ll]$ ]] || F_CPU="${F_CPU}UL"

command -v cmake >/dev/null || die "cmake not found on PATH"
[[ -f "$TOOLCHAIN_FILE" ]]  || die "Toolchain file not found: $TOOLCHAIN_FILE"

# ---------------------------------------------------------------------------
# Clean handling
# ---------------------------------------------------------------------------
BUILD_PATH="${REPO_ROOT}/${BUILD_DIR}"

if (( CLEAN || CLEAN_ONLY )); then
    if [[ -d "$BUILD_PATH" ]]; then
        info "Removing ${BUILD_PATH}"
        rm -rf -- "$BUILD_PATH"
    else
        warn "Build directory does not exist, nothing to clean: ${BUILD_PATH}"
    fi
    (( CLEAN_ONLY )) && exit 0
fi

# ---------------------------------------------------------------------------
# Configure + build
# ---------------------------------------------------------------------------
mkdir -p "$BUILD_PATH"

info "MCU       : ${C_BOLD}${MCU}${C_RESET}"
info "F_CPU     : ${C_BOLD}${F_CPU}${C_RESET}"
info "Build type: ${C_BOLD}${BUILD_TYPE}${C_RESET}"
info "Build dir : ${BUILD_PATH}"

cmake_args=(
    -S "$REPO_ROOT"
    -B "$BUILD_PATH"
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE"
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
    -DMCU="$MCU"
    -DF_CPU="$F_CPU"
)

cmake "${cmake_args[@]}"

build_args=(--build "$BUILD_PATH" --config "$BUILD_TYPE")
if [[ -n "$JOBS" ]]; then
    build_args+=(--parallel "$JOBS")
else
    build_args+=(--parallel)
fi
(( VERBOSE )) && build_args+=(--verbose)

cmake "${build_args[@]}"

ok "Build finished — artifacts in ${BUILD_PATH}"
