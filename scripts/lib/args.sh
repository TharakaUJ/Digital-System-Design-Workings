#!/usr/bin/env bash
# args.sh — shared long-option parsing for subcommands.
# Source only. Depends on: log.sh

# parse_common_opts "$@"
# Understands the flags shared by every subcommand:
#   --assignment NAME   --exercise NAME
#   --top MODULE        --sim-top MODULE
#   --board NAME         --part PARTNUM
#   --help
# Sets globals: ASSIGNMENT EXERCISE TOP SIM_TOP BOARD PART SHOW_HELP
# Unrecognized flags are left in REMAINING_ARGS for the caller to handle.
parse_common_opts() {
    ASSIGNMENT="" EXERCISE="" TOP="" SIM_TOP="" BOARD="" PART="" SHOW_HELP=0
    REMAINING_ARGS=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --assignment) ASSIGNMENT="${2:?--assignment requires a value}"; shift 2 ;;
            --exercise)   EXERCISE="${2:?--exercise requires a value}"; shift 2 ;;
            --top)        TOP="${2:?--top requires a value}"; shift 2 ;;
            --sim-top)    SIM_TOP="${2:?--sim-top requires a value}"; shift 2 ;;
            --board)      BOARD="${2:?--board requires a value}"; shift 2 ;;
            --part)       PART="${2:?--part requires a value}"; shift 2 ;;
            --help|-h)    SHOW_HELP=1; shift ;;
            *)            REMAINING_ARGS+=("$1"); shift ;;
        esac
    done
}

# require_opt <value> <flag-name-for-error-message>
require_opt() {
    local val="$1"
    [[ -n "$val" ]] || die "Missing required option: $2"
}
