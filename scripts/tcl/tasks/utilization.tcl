source [file join [file dirname [info script]] .. bootstrap.tcl]

open_target_project

if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    write_status FAIL
    close_project
    error "synth_1 has not completed successfully — run 'synth' first."
}

set report_path [file join $::REPORT_DIR "utilization"]
ensure_dir $report_path

open_run synth_1 -name synth_1
report_utilization -file [file join $report_path "utilization.rpt"]
report_utilization -hierarchical -file [file join $report_path "utilization_hierarchical.rpt"]

close_project
log_msg "Utilization report written to $report_path"
write_status OK
