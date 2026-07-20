#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Default variables
PART="xc7a35tcg236-1"
TOP_MODULE=""
TESTBENCH=""
RTL_DIR="."           # Changed to current directory to scan subfolders
TB_DIR="."            # Changed to current directory to scan subfolders
PROJ_DIR="./vivado_project"
PROJ_NAME="assignment_1"

export _JAVA_AWT_WM_NONREPARENTING=1

# Use a standard function or environment export instead of an alias
vivado() {
    ~/src/Vivado/2024.2/bin/vivado "$@"
}

# Help Menu Function
show_help() {
    echo "Usage: $0 [options] <action>"
    echo ""
    echo "Actions:"
    echo "  init          Initialize the Vivado project from source folders"
    echo "  synth         Run synthesis, generate resource reports & schematic"
    echo "  sim           Run behavioral simulation"
    echo "  all           Run init, synth, and sim sequentially"
    echo ""
    echo "Options:"
    echo "  -p, --part    FPGA part number (default: $PART)"
    echo "  -t, --top     Top-level module name for synthesis (required for synth/all)"
    echo "  -b, --tb      Testbench module name for simulation"
    echo "  -r, --rtl     Path to search root for RTL (default: $RTL_DIR)"
    echo "  -s, --simdir  Path to search root for testbenches (default: $TB_DIR)"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -t my_top_design init"
    echo "  $0 -t my_top_design -b my_tb_name all"
    echo "  $0 -b custom_tb sim"
    exit 0
}

# Parse Command Line Options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--part)    PART="$2"; shift 2 ;;
        -t|--top)     TOP_MODULE="$2"; shift 2 ;;
        -b|--tb)      TESTBENCH="$2"; shift 2 ;;
        -r|--rtl)     RTL_DIR="$2"; shift 2 ;;
        -s|--simdir)  TB_DIR="$2"; shift 2 ;;
        -h|--help)    show_help ;;
        init|synth|sim|all) ACTION="$1"; shift ;;
        *) echo "Error: Unknown argument '$1'"; show_help ;;
    esac
done

# Validate input
if [ -z "$ACTION" ]; then
    echo "Error: Missing action (init, synth, sim, or all)."
    show_help
fi

PROJECT_PATH="${PROJ_DIR}/${PROJ_NAME}.xpr"

# -----------------------------------------------------------------------------
# Core Action Functions
# -----------------------------------------------------------------------------

run_init() {
    echo "==> Initializing Vivado Project..."
    vivado -mode batch -notrace -source /dev/stdin <<EOF
create_project $PROJ_NAME $PROJ_DIR -part $PART -force

# Target files only within nested 'rtl' folders to avoid mixing sources
set rtl_files [glob -nocomplain -directory $RTL_DIR -type f **/rtl/*.v **/rtl/*.sv **/rtl/*.vhd]
if {[llength \$rtl_files] > 0} { add_files -fileset sources_1 \$rtl_files }

# Target files only within nested 'tb' folders
set tb_files [glob -nocomplain -directory $TB_DIR -type f **/tb/*.v **/tb/*.sv **/tb/*.vhd]
if {[llength \$tb_files] > 0} { add_files -fileset sim_1 \$tb_files }

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
close_project
EOF
}

run_synth() {
    if [ -z "$TOP_MODULE" ]; then
        echo "Error: Synthesis requires a top module name. Pass it with -t or --top."
        exit 1
    fi
    echo "==> Running Synthesis & Generating Reports..."
    vivado -mode batch -notrace -source /dev/stdin <<EOF
open_project $PROJECT_PATH
set_property top $TOP_MODULE [current_fileset]
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
open_run synth_1
report_utilization -file utilization_report.txt
close_project
EOF
}

run_sim() {
    echo "==> Running Simulation..."
    TCL_ARGS=""
    if [ -n "$TESTBENCH" ]; then
        TCL_ARGS="-tclargs $TESTBENCH"
    fi

    vivado -mode batch -notrace $TCL_ARGS -source /dev/stdin <<EOF
open_project $PROJECT_PATH
if { \$argc > 0 } {
    set tb_name [lindex \$argv 0]
    set_property top \$tb_name [current_fileset -simset]
}
update_compile_order -fileset sim_1
launch_simulation
run all
close_project
EOF
}

# -----------------------------------------------------------------------------
# Execution Flow
# -----------------------------------------------------------------------------

case "$ACTION" in
    init)  run_init ;;
    synth) run_synth ;;
    sim)   run_sim ;;
    all)
        run_init
        run_synth
        run_sim
        ;;
esac

echo "==> Action '$ACTION' completed successfully."