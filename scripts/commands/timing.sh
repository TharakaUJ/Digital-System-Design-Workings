#!/usr/bin/env bash
# commands/timing.sh — generates a standalone timing report.
# Requires synth to have completed successfully first.

cmd_timing_help() {
    cat <<EOF
Usage: run.sh timing --assignment NAME --exercise NAME

Generates a timing summary + detailed timing report from the existing
synth_1 run. Requires 'synth' to have been run first.
EOF
}

cmd_main() {
    parse_common_opts "$@"

    if [[ $SHOW_HELP -eq 1 ]]; then
        cmd_timing_help
        exit 0
    fi

    require_opt "$ASSIGNMENT" "--assignment"
    require_opt "$EXERCISE" "--exercise"

    cfg_init "$ASSIGNMENT" "$EXERCISE"
    common_resolve "$ASSIGNMENT" "$EXERCISE"

    log_info "Generating timing report for $ASSIGNMENT/$EXERCISE"
    run_vivado_task "timing.tcl"
    log_success "Reports written to $REPORT_DIR/timing"
}
