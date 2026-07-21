#!/usr/bin/env bash
# run.sh — Vivado automation CLI. Thin dispatcher: parses the subcommand
# name, sources the matching scripts/commands/<name>.sh, and calls its
# cmd_main function. All real logic lives in commands/ and tcl/tasks/.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"
# shellcheck source=lib/args.sh
source "$SCRIPT_DIR/lib/args.sh"
# shellcheck source=lib/context.sh
source "$SCRIPT_DIR/lib/context.sh"
# shellcheck source=lib/paths.sh
source "$SCRIPT_DIR/lib/paths.sh"
# shellcheck source=lib/vivado.sh
source "$SCRIPT_DIR/lib/vivado.sh"

REPO_ROOT="$(repo_root)"
export REPO_ROOT
export SCRIPT_DIR

# Available subcommands. Adding a new one = add a file to commands/ +
# one entry here.
declare -A COMMANDS=(
    [init]="Create/recreate a Vivado project and add discovered sources"
    [sim]="Run behavioral simulation"
    [synth]="Run synthesis and emit utilization/timing reports"
    [timing]="Generate a standalone timing report (requires prior synth)"
    [util]="Generate a standalone utilization report (requires prior synth)"
    [clean]="Delete the generated Vivado project and its build artifacts"
)

usage() {
    cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
EOF
    for cmd in init sim synth timing util clean; do
        printf '  %-8s %s\n' "$cmd" "${COMMANDS[$cmd]}"
    done
    cat <<EOF

Common options (accepted by every command):
  --assignment NAME   Assignment directory (e.g. assignment1)   [required]
  --exercise NAME     Exercise directory (e.g. exercise2)       [required]
  --top MODULE        Top-level module name                    (init only, required)
  --sim-top MODULE    Simulation top module                    (init only, optional)
  --board NAME        Board name from scripts/config/default.json
  --part PARTNUM      Explicit FPGA part number (overrides --board)
  -h, --help          Show command-specific help

Examples:
  $(basename "$0") init  --assignment assignment1 --exercise exercise2 --top alu
  $(basename "$0") synth --assignment assignment1 --exercise exercise2
  $(basename "$0") clean --assignment assignment1 --exercise exercise2
EOF
}

main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    local cmd="$1"; shift

    if [[ "$cmd" == "-h" || "$cmd" == "--help" ]]; then
        usage
        exit 0
    fi

    if [[ -z "${COMMANDS[$cmd]:-}" ]]; then
        log_error "Unknown command: $cmd"
        usage
        exit 2
    fi

    local cmd_file="$SCRIPT_DIR/commands/$cmd.sh"
    [[ -f "$cmd_file" ]] || die "Command implementation missing: $cmd_file"

    # shellcheck source=/dev/null
    source "$cmd_file"
    cmd_main "$@"
}

main "$@"
