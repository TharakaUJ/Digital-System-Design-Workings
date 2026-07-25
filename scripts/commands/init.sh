#!/usr/bin/env bash
# commands/init.sh — creates (or force-recreates) the Vivado project and
# adds all discovered RTL/TB sources.

cmd_init_help() {
    cat <<EOF
Usage: run.sh init --assignment NAME --exercise NAME --top MODULE [options]

Creates a fresh Vivado project for the given exercise, auto-discovering
sources under rtl/ and tb/. Re-running init recreates the project from
scratch (use 'clean' first if you want a fully empty build directory).

Required:
  --assignment NAME   Assignment directory
  --exercise NAME      Exercise directory
  --top MODULE          Top-level RTL module name

Optional:
  --sim-top MODULE     Testbench top module (defaults to --top if omitted)
  --board NAME          Board name from scripts/config/default.json
  --part PARTNUM        Explicit part number (overrides --board)
EOF
}

cmd_main() {
    parse_common_opts "$@"

    if [[ $SHOW_HELP -eq 1 ]]; then
        cmd_init_help
        exit 0
    fi

    require_opt "$ASSIGNMENT" "--assignment"
    require_opt "$EXERCISE" "--exercise"
    require_opt "$TOP" "--top"

    cfg_init "$ASSIGNMENT" "$EXERCISE"
    common_resolve "$ASSIGNMENT" "$EXERCISE"

    PART="$(resolve_part "$BOARD" "$PART")"
    SIM_TOP="${SIM_TOP:-$TOP}"

    log_info "Initializing project for $ASSIGNMENT/$EXERCISE (top=$TOP, part=$PART)"
    run_vivado_task "init_project.tcl"
    log_success "Project ready: $BUILD_DIR/$PROJECT_NAME"
}
