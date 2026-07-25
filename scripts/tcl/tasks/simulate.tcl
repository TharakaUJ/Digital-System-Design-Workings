source [file join [file dirname [info script]] .. bootstrap.tcl]

open_target_project

set report_path [file join $::REPORT_DIR "simulation"]
ensure_dir $report_path

log_msg "Launching simulation (sim_top: $::SIM_TOP)"
launch_simulation

log_msg "Simulation log directory: [project_path]/${::PROJECT_NAME}.sim"
close_project
write_status OK
