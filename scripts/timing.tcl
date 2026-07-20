# Usage: vivado -mode batch -source synthesize_all_adders.tcl

set script_dir [file dirname [file normalize [info script]]]
# Base directory pointing to the root "Adders" folder
set root_dir   $script_dir 
set report_dir [file normalize [file join $root_dir reports vivado_synthesis]]
set part       "xc7z020clg400-1"
set_param general.maxThreads 1
file mkdir $report_dir

# Target configurations mapped to: [file join $root_dir <folder_name> rtl <file_name>]
set targets [list \
    [list adder_8b        adder               ""    [list [file join $root_dir adder_8b rtl adder.sv]] 4.000] \
    [list cla_8b          cla_8b              ""    [list [file join $root_dir cla_8b rtl cla_8b.sv]] 4.000] \
    [list cascaded_adder  cascaded_adder       ""    [list [file join $root_dir adder_8b rtl adder.sv] [file join $root_dir cascaded_adder rtl cascaded_adder.sv]] 10.000] \
    [list piped_cascaded  piped_cascaded_adder i_clk [list [file join $root_dir adder_8b rtl adder.sv] [file join $root_dir piped_cascaded rtl piped_cascaded_adder.sv]] 4.000] \
    [list block_cla_32b   block_cla            ""    [list [file join $root_dir cla_8b rtl cla_8b.sv] [file join $root_dir block_cla_32b rtl block_cla_32b.sv]] 6.666667] \
    [list fp32_adder      fp32_adder           i_clk [list [file join $root_dir fp32_adder rtl fp32_pkg.sv] [file join $root_dir fp32_adder rtl fp32_adder.sv]] 20.000] \
    [list fp32_adder_comb fp32_adder_comb      ""    [list [file join $root_dir fp32_adder rtl fp32_pkg.sv] [file join $root_dir fp32_adder_comb rtl fp32_adder_comb.sv]] 50.000]]

if {[llength $argv] > 0} {
    set selected_targets [list]
    foreach target $targets {
        if {[lsearch -exact $argv [lindex $target 0]] >= 0} {
            lappend selected_targets $target
        }
    }
    set targets $selected_targets
}

set index_file [open [file join $report_dir SUMMARY.txt] w]
puts $index_file "VIVADO ADDER SYNTHESIS REPORT INDEX"
puts $index_file "Generated: [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S %Z}]"
puts $index_file "Target part: $part"
puts $index_file "Timing targets are specified per design."
puts $index_file ""
puts $index_file "Each target has standard Vivado utilization and timing reports:"
puts $index_file "  <target>_utilization.rpt"
puts $index_file "  <target>_timing_summary.rpt"
puts $index_file "  <target>_critical_paths.rpt"
puts $index_file ""

foreach target $targets {
    lassign $target name top clock_port sources period_ns
    puts "\n==== Synthesizing $name (top=$top) ===="
    puts $index_file "$name"
    puts $index_file "  Top module : $top"

    create_project -in_memory -part $part
    foreach source $sources {
        read_verilog -sv $source
    }
    synth_design -top $top -part $part -mode out_of_context

    if {$clock_port ne ""} {
        create_clock -name ${name}_clk -period $period_ns [get_ports $clock_port]
        puts $index_file "  Constraint : $clock_port clock, $period_ns ns period"
    } else {
        set_max_delay $period_ns -from [all_inputs] -to [all_outputs]
        puts $index_file "  Constraint : all input-to-output paths <= $period_ns ns"
    }

    report_utilization -file [file join $report_dir ${name}_utilization.rpt]
    report_timing_summary -delay_type max -max_paths 10 \
        -file [file join $report_dir ${name}_timing_summary.rpt]
    report_timing -delay_type max -max_paths 10 \
        -file [file join $report_dir ${name}_critical_paths.rpt]

    puts $index_file "  Reports    : ${name}_utilization.rpt, ${name}_timing_summary.rpt, ${name}_critical_paths.rpt"
    puts $index_file ""
    close_project
}

puts $index_file "Notes: synthesis is out-of-context. Results are valid for RTL comparison on the stated"
puts $index_file "part/constraints; placement, routing, IO constraints, and board specific clocks are not included."
close $index_file
puts "\nCompleted. Reports are in $report_dir"