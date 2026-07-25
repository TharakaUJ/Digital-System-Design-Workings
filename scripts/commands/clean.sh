#!/usr/bin/env bash
# commands/clean.sh — deletes the generated Vivado project and its build
# artifacts. Pure Bash — no Vivado invocation needed, since it's just
# deleting the build directory (which also holds .Xil/, *.jou, *.log
# because run_vivado_task always cd's there before invoking vivado).

cmd_clean_help() {
    cat <<EOF
Usage: run.sh clean --assignment NAME --exercise NAME [--reports]

Deletes the generated Vivado project directory (build/vivado_projects/...),
including .Xil/, journal, and log files, since Vivado is always invoked
from inside that directory.

Optional:
  --reports    Also delete the generated reports directory
EOF
}

cmd_main() {
    parse_common_opts "$@"

    local remove_reports=0
    for arg in "${REMAINING_ARGS[@]:-}"; do
        [[ "$arg" == "--reports" ]] && remove_reports=1
    done

    if [[ $SHOW_HELP -eq 1 ]]; then
        cmd_clean_help
        exit 0
    fi

    require_opt "$ASSIGNMENT" "--assignment"
    require_opt "$EXERCISE" "--exercise"

    cfg_init "$ASSIGNMENT" "$EXERCISE"
    common_resolve "$ASSIGNMENT" "$EXERCISE"

    if [[ -d "$BUILD_DIR" ]]; then
        log_info "Removing $BUILD_DIR"
        rm -rf -- "$BUILD_DIR"
    else
        log_warn "Nothing to clean at $BUILD_DIR"
    fi

    if [[ $remove_reports -eq 1 && -d "$REPORT_DIR" ]]; then
        log_info "Removing $REPORT_DIR"
        rm -rf -- "$REPORT_DIR"
    fi

    log_success "Clean complete for $ASSIGNMENT/$EXERCISE"
}
