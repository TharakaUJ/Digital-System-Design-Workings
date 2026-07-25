#!/usr/bin/env bash
# commands/synth.sh — runs synthesis and emits utilization + timing
# reports for the resulting run.

cmd_synth_help() {
    cat <<EOF
Usage: run.sh synth --assignment NAME --exercise NAME

Runs synthesis (synth_1) on an already-initialized project and writes
utilization/timing reports to the configured report directory.
EOF
}

cmd_main() {
    parse_common_opts "$@"

    if [[ $SHOW_HELP -eq 1 ]]; then
        cmd_synth_help
        exit 0
    fi

    require_opt "$ASSIGNMENT" "--assignment"
    require_opt "$EXERCISE" "--exercise"

    cfg_init "$ASSIGNMENT" "$EXERCISE"
    common_resolve "$ASSIGNMENT" "$EXERCISE"

    log_info "Running synthesis for $ASSIGNMENT/$EXERCISE"
    run_vivado_task "synthesize.tcl"
    log_success "Reports written to $REPORT_DIR/synth"
}
