#!/usr/bin/env bash
# commands/sim.sh — runs behavioral simulation on an already-initialized
# project.

cmd_sim_help() {
    cat <<EOF
Usage: run.sh sim --assignment NAME --exercise NAME

Runs behavioral simulation. Requires 'init' to have been run first.
EOF
}

cmd_main() {
    parse_common_opts "$@"

    if [[ $SHOW_HELP -eq 1 ]]; then
        cmd_sim_help
        exit 0
    fi

    require_opt "$ASSIGNMENT" "--assignment"
    require_opt "$EXERCISE" "--exercise"

    cfg_init "$ASSIGNMENT" "$EXERCISE"
    common_resolve "$ASSIGNMENT" "$EXERCISE"

    log_info "Running simulation for $ASSIGNMENT/$EXERCISE"
    run_vivado_task "simulate.tcl"
}
