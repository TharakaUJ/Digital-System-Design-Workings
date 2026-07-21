#!/usr/bin/env bash
# commands/util.sh — generates a standalone utilization report.
# Requires synth to have completed successfully first.

cmd_util_help() {
    cat <<EOF
Usage: run.sh util --assignment NAME --exercise NAME

Generates flat + hierarchical utilization reports from the existing
synth_1 run. Requires 'synth' to have been run first.
EOF
}

cmd_main() {
    parse_common_opts "$@"

    if [[ $SHOW_HELP -eq 1 ]]; then
        cmd_util_help
        exit 0
    fi

    require_opt "$ASSIGNMENT" "--assignment"
    require_opt "$EXERCISE" "--exercise"

    cfg_init "$ASSIGNMENT" "$EXERCISE"
    common_resolve "$ASSIGNMENT" "$EXERCISE"

    log_info "Generating utilization report for $ASSIGNMENT/$EXERCISE"
    run_vivado_task "utilization.tcl"
    log_success "Reports written to $REPORT_DIR/utilization"
}
