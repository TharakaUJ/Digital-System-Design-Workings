source [file join [file dirname [info script]] .. bootstrap.tcl]

open_target_project

set report_path [file join $::REPORT_DIR "synth"]
ensure_dir $report_path

log_msg "Launching synth_1"
reset_run synth_1
launch_runs synth_1 -jobs 2
wait_on_run synth_1

set progress [get_property PROGRESS [get_runs synth_1]]
if {$progress ne "100%"} {
    write_status FAIL
    close_project
    error "Synthesis did not complete (progress: $progress). See Vivado log for details."
}

open_run synth_1 -name synth_1
report_utilization -file [file join $report_path "utilization.rpt"]
report_timing_summary -file [file join $report_path "timing_summary.rpt"]

close_project
log_msg "Synthesis complete. Reports in $report_path"
write_status OK
