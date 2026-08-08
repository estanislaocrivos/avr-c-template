#!/usr/bin/env bash
#
# Flash an AVR firmware image using avrdude.
#
# Two modes are supported:
#
#   direct  — target board exposes its own USB serial (e.g. Arduino Mega 2560
#             with the stock Optiboot/STK500v2 bootloader).
#             Programmer: wiring, baud: 115200.
#
#   isp     — target ATmega is programmed via ICSP through an Arduino board
#             running the "Arduino as ISP" sketch.
#             Programmer: stk500v1, baud: 19200.
#
# Run `./flash.sh --help` for the full option list.

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
readonly REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

MODE="direct"
MCU="atmega2560"
PORT=""
BAUD=""
PROGRAMMER=""
HEX_FILE=""
CONF_FILE=""
BUILD_DIR="build"
DRY_RUN=0
EXTRA_ARGS=()

# ---------------------------------------------------------------------------
# Pretty printing
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
    C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'
    C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YLW=$'\033[33m'; C_CYN=$'\033[36m'
else
    C_RESET=""; C_BOLD=""; C_RED=""; C_GRN=""; C_YLW=""; C_CYN=""
fi

info() { printf "${C_CYN}[flash]${C_RESET} %s\n" "$*"; }
ok()   { printf "${C_GRN}[ ok  ]${C_RESET} %s\n" "$*"; }
warn() { printf "${C_YLW}[warn]${C_RESET} %s\n" "$*" >&2; }
die()  { printf "${C_RED}[fail]${C_RESET} %s\n" "$*" >&2; exit 1; }

usage() {
    cat <<EOF
${C_BOLD}Usage:${C_RESET} $(basename "$0") [options] [-- <extra avrdude args>]

Options:
  -m, --mode MODE          direct | isp                    (default: ${MODE})
  -M, --mcu MCU            Target MCU                      (default: ${MCU})
  -p, --port PORT          Serial port                     (default: auto-detect)
  -b, --baud RATE          Baud rate                       (default: mode-dependent)
  -P, --programmer NAME    avrdude programmer id           (default: mode-dependent)
  -H, --hex FILE           HEX file to flash               (default: newest ${BUILD_DIR}/*.hex)
  -B, --build-dir DIR      Build dir to search for HEX     (default: ${BUILD_DIR})
  -C, --config PATH        avrdude config file             (default: avrdude built-in)
  -n, --dry-run            Print the avrdude command and exit
  -h, --help               Show this help and exit

Modes:
  direct   Programmer 'wiring' @ 115200 baud (Arduino Mega bootloader over USB).
  isp      Programmer 'stk500v1' @ 19200 baud (Arduino as ISP over ICSP).

Examples:
  $(basename "$0")                          # direct-flash the newest build HEX
  $(basename "$0") -m isp                   # flash via Arduino-as-ISP
  $(basename "$0") -m direct -p /dev/tty.usbmodem14201
  $(basename "$0") -H build/firmware.hex -- -e   # forward -e (chip erase) to avrdude
EOF
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--mode)         MODE="$2"; shift 2 ;;
        --mode=*)          MODE="${1#*=}"; shift ;;
        -M|--mcu)          MCU="$2"; shift 2 ;;
        --mcu=*)           MCU="${1#*=}"; shift ;;
        -p|--port)         PORT="$2"; shift 2 ;;
        --port=*)          PORT="${1#*=}"; shift ;;
        -b|--baud)         BAUD="$2"; shift 2 ;;
        --baud=*)          BAUD="${1#*=}"; shift ;;
        -P|--programmer)   PROGRAMMER="$2"; shift 2 ;;
        --programmer=*)    PROGRAMMER="${1#*=}"; shift ;;
        -H|--hex)          HEX_FILE="$2"; shift 2 ;;
        --hex=*)           HEX_FILE="${1#*=}"; shift ;;
        -B|--build-dir)    BUILD_DIR="$2"; shift 2 ;;
        --build-dir=*)     BUILD_DIR="${1#*=}"; shift ;;
        -C|--config)       CONF_FILE="$2"; shift 2 ;;
        --config=*)        CONF_FILE="${1#*=}"; shift ;;
        -n|--dry-run)      DRY_RUN=1; shift ;;
        -h|--help)         usage; exit 0 ;;
        --)                shift; EXTRA_ARGS=("$@"); break ;;
        -*)                die "Unknown option: $1 (try --help)" ;;
         *)                die "Unexpected argument: $1 (try --help)" ;;
    esac
done

# ---------------------------------------------------------------------------
# Mode defaults
# ---------------------------------------------------------------------------
# DISABLE_AUTO_ERASE controls whether we pass avrdude's -D flag.
#
# In bootloader ("direct") mode the bootloader can't perform a chip erase, so
# -D is required or avrdude aborts. In ISP mode the programmer *can* erase,
# and skipping the erase leaves stale bits behind (bits can only go 1->0
# without an erase), which produces a verification mismatch on any byte that
# needed to become larger than what was already there.
case "$MODE" in
    direct)
        : "${PROGRAMMER:=wiring}"
        : "${BAUD:=115200}"
        DISABLE_AUTO_ERASE=1
        ;;
    isp)
        : "${PROGRAMMER:=stk500v1}"
        : "${BAUD:=19200}"
        DISABLE_AUTO_ERASE=0
        ;;
    *) die "Invalid mode '$MODE' (expected: direct | isp)" ;;
esac

# ---------------------------------------------------------------------------
# HEX resolution
# ---------------------------------------------------------------------------
if [[ -z "$HEX_FILE" ]]; then
    search_dir="${REPO_ROOT}/${BUILD_DIR}"
    [[ -d "$search_dir" ]] || die "Build directory not found: $search_dir (build first, or pass --hex)"

    # Newest .hex under the build tree.
    HEX_FILE=$(find "$search_dir" -maxdepth 2 -type f -name '*.hex' -print0 2>/dev/null \
        | xargs -0 ls -t 2>/dev/null | head -n1 || true)

    [[ -n "$HEX_FILE" ]] || die "No .hex found in $search_dir — pass --hex explicitly"
fi

[[ -f "$HEX_FILE" ]] || die "HEX file not found: $HEX_FILE"

# ---------------------------------------------------------------------------
# Port auto-detection (macOS and Linux Arduino-style device names).
# ---------------------------------------------------------------------------
if [[ -z "$PORT" ]]; then
    candidates=()
    while IFS= read -r -d '' dev; do candidates+=("$dev"); done < <(
        {
            ls -1t /dev/tty.usbmodem* /dev/tty.usbserial-* \
                   /dev/ttyACM*       /dev/ttyUSB*         2>/dev/null || true
        } | tr '\n' '\0'
    )

    (( ${#candidates[@]} > 0 )) || die "No USB serial device found — pass --port"

    PORT="${candidates[0]}"
    if (( ${#candidates[@]} > 1 )); then
        warn "Multiple serial devices found; using ${PORT}"
        for dev in "${candidates[@]}"; do warn "  - $dev"; done
    fi
fi

if [[ ! -e "$PORT" ]] && (( ! DRY_RUN )); then
    die "Port does not exist: $PORT"
fi

# ---------------------------------------------------------------------------
# Assemble and run the avrdude command
# ---------------------------------------------------------------------------
if (( ! DRY_RUN )); then
    command -v avrdude >/dev/null || die "avrdude not found on PATH"
fi

cmd=(avrdude)
[[ -n "$CONF_FILE" ]] && cmd+=(-C "$CONF_FILE")
cmd+=(
    -p "$MCU"
    -c "$PROGRAMMER"
    -P "$PORT"
    -b "$BAUD"
)
(( DISABLE_AUTO_ERASE )) && cmd+=(-D)
cmd+=(-U "flash:w:${HEX_FILE}:i")
(( ${#EXTRA_ARGS[@]} > 0 )) && cmd+=("${EXTRA_ARGS[@]}")

info "Mode       : ${C_BOLD}${MODE}${C_RESET}"
info "MCU        : ${MCU}"
info "Port       : ${PORT}"
info "Programmer : ${PROGRAMMER} @ ${BAUD} baud"
info "HEX file   : ${HEX_FILE}"

if (( DRY_RUN )); then
    printf "${C_YLW}[dry-run]${C_RESET} "
    printf '%q ' "${cmd[@]}"
    printf "\n"
    exit 0
fi

info "Running: ${cmd[*]}"
"${cmd[@]}"
ok "Flash completed successfully"
