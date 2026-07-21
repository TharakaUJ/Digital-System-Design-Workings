source [file join [file dirname [info script]] .. bootstrap.tcl]

log_msg "Creating project '$::PROJECT_NAME' for part $::PART"

ensure_dir $::BUILD_DIR
create_project $::PROJECT_NAME [project_path] -part $::PART -force

set rtl_files [discover_sources $::RTL_DIR {.v .sv .svh .vh}]
set tb_files  [discover_sources $::TB_DIR  {.v .sv .svh .vh}]

if {[llength $rtl_files] == 0} {
    write_status FAIL
    error "No RTL sources found under $::RTL_DIR"
}

log_msg "Adding [llength $rtl_files] RTL file(s)"
add_files -norecurse -fileset sources_1 $rtl_files

if {[llength $tb_files] > 0} {
    log_msg "Adding [llength $tb_files] testbench file(s)"
    add_files -norecurse -fileset sim_1 $tb_files
}

set_property top $::TOP [get_filesets sources_1]

if {[info exists ::SIM_TOP] && $::SIM_TOP ne ""} {
    set_property top $::SIM_TOP [get_filesets sim_1]
}

update_compile_order -fileset sources_1
if {[llength $tb_files] > 0} {
    update_compile_order -fileset sim_1
}

close_project
log_msg "Project created at [project_path]"
write_status OK
