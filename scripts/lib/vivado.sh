#!/usr/bin/env bash
# vivado.sh — resolves standard context values and invokes a TCL task
# script under `vivado -mode batch`, with the log/journal/lock files kept
# local to the project's own build directory.
# Source only. Depends on: log.sh, paths.sh, context.sh

# common_resolve <assignment> <exercise>
# Populates: EXERCISE_DIR RTL_DIR TB_DIR BUILD_DIR REPORT_DIR PROJECT_NAME PART
# Requires cfg_init to have already been called by the caller.
common_resolve() {
    local assignment="$1" exercise="$2"

    EXERCISE_DIR="$(exercise_dir "$assignment" "$exercise")"
    RTL_DIR="$(rtl_dir "$EXERCISE_DIR")"
    TB_DIR="$(tb_dir "$EXERCISE_DIR")"
    BUILD_DIR="$(build_dir "$assignment" "$exercise")"
    REPORT_DIR="$(report_dir "$assignment" "$exercise")"
    PROJECT_NAME="${assignment}_${exercise}"
}

# run_vivado_task <task_tcl_file> <context_kv...>
# Writes the context file, then runs vivado in batch mode from inside
# BUILD_DIR so .Xil/, *.jou, *.log land there instead of the repo root.
# Fails loudly if the task's RUN_STATUS sentinel is not OK.
run_vivado_task() {
    local task_file="$1"; shift

    mkdir -p "$BUILD_DIR"

    local context_file="$BUILD_DIR/.run_context.tcl"
    write_context "$context_file" \
        "REPO_ROOT=$REPO_ROOT" \
        "RTL_DIR=$RTL_DIR" \
        "TB_DIR=$TB_DIR" \
        "BUILD_DIR=$BUILD_DIR" \
        "REPORT_DIR=$REPORT_DIR" \
        "PROJECT_NAME=$PROJECT_NAME" \
        "PART=${PART:-}" \
        "TOP=${TOP:-}" \
        "SIM_TOP=${SIM_TOP:-}" \
        "$@"

    local log_file="$BUILD_DIR/vivado.log"
    local jou_file="$BUILD_DIR/vivado.jou"
    local task_path="$SCRIPT_DIR/tcl/tasks/$task_file"

    [[ -f "$task_path" ]] || die "Task script not found: $task_path"

    log_info "Running Vivado task: $task_file"

    local exit_code=0
    ( cd "$BUILD_DIR" && \
      RUN_CONTEXT="$context_file" vivado -mode batch -nolog -nojournal \
          -log "$log_file" -journal "$jou_file" \
          -source "$task_path" ) || exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Vivado exited with code $exit_code — see $log_file"
        exit "$exit_code"
    fi

    if ! grep -q "RUN_STATUS:OK" "$log_file" 2>/dev/null; then
        log_error "Task did not report success — see $log_file"
        exit 1
    fi

    log_success "Task '$task_file' completed"
}
