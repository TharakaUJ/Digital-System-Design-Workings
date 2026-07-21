#!/usr/bin/env bash
# log.sh — colored logging helpers. Source only, do not execute.

if [[ -t 1 ]]; then
    readonly C_RED=$'\033[0;31m'
    readonly C_GREEN=$'\033[0;32m'
    readonly C_YELLOW=$'\033[0;33m'
    readonly C_BLUE=$'\033[0;34m'
    readonly C_RESET=$'\033[0m'
else
    readonly C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_RESET=''
fi

log_info()    { printf '%s[INFO]%s  %s\n'  "$C_BLUE"   "$C_RESET" "$*" >&2; }
log_success() { printf '%s[ OK ]%s  %s\n'  "$C_GREEN"  "$C_RESET" "$*" >&2; }
log_warn()    { printf '%s[WARN]%s  %s\n'  "$C_YELLOW" "$C_RESET" "$*" >&2; }
log_error()   { printf '%s[FAIL]%s  %s\n'  "$C_RED"    "$C_RESET" "$*" >&2; }

die() {
    log_error "$*"
    exit 1
}
