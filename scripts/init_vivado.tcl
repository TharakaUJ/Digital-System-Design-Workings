# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
set PROJ_NAME    "my_automated_project"
set PROJ_DIR     "./vivado_project"
set PART_NUMBER  "xc7a35tcg236-1" ;# Change this to match your specific FPGA board/chip

set RTL_DIR      "./**/rtl"          ;# Path to your RTL files folder
set TB_DIR       "./**/tb"           ;# Path to your Testbench files folder

# -----------------------------------------------------------------------------
# Project Creation
# -----------------------------------------------------------------------------
# Create the project directory and project file
create_project $PROJ_NAME $PROJ_DIR -part $PART_NUMBER -force

# 1. Add RTL Sources
# This finds all .v, .sv, and .vhd files in your RTL folder
set rtl_files [glob -nocomplain "$RTL_DIR/*.{v,sv,vhd}"]
if {[llength $rtl_files] > 0} {
    add_files -fileset sources_1 $rtl_files
    puts "Added [llength $rtl_files] RTL files to the project."
} else {
    puts "Warning: No RTL files found in $RTL_DIR"
}

# 2. Add Testbench Sources
# This finds all .v, .sv, and .vhd files in your Testbench folder
set tb_files [glob -nocomplain "$TB_DIR/*.{v,sv,vhd}"]
if {[llength $tb_files] > 0} {
    add_files -fileset sim_1 $tb_files
    puts "Added [llength $tb_files] testbench files to the project."
} else {
    puts "Warning: No testbench files found in $TB_DIR"
}

# 3. Let Vivado automatically find the top modules
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Project initialization complete!"
close_project