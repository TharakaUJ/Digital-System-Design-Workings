# Define path parameters and project settings
set proj_name "default_project" ;# Update with your desired project name
set proj_dir  "./vivado_proj"
set part_num  "xc7a35tcpg236-1" ;# Update with your target FPGA part number

# 1. Create or Open the Project
if {[file exists [file join $proj_dir "${proj_name}.xpr"]]} {
    puts "Opening existing Vivado project..."
    open_project [file join $proj_dir "${proj_name}.xpr"]
} else {
    puts "Creating new Vivado project..."
    create_project $proj_name $proj_dir -part $part_num
}

# Helper procedure to safely add or update files in a specific target fileset
proc add_or_update_files {fileset_name glob_pattern} {
    set file_list [glob -nocomplain $glob_pattern]
    if {[llength $file_list] > 0} {
        # add_files automatically adds new files and updates existing references
        add_files -fileset $fileset_name -norecurse $file_list
        puts "Updated $fileset_name with [llength $file_list] files from $glob_pattern"
    } else {
        puts "No files found for pattern: $glob_pattern"
    }
}

# 2. Add / Update Design Sources (RTL)
# Captures .v, .sv, and .vhd files inside /src/
# add_or_update_files "sources_1" "./**/rtl/*.v"
add_or_update_files "sources_1" "./**/rtl/*.sv"
# add_or_update_files "sources_1" "./**/rtl/*.vhd"

# 3. Add / Update Simulation Sources (Testbenches)
# Captures .v, .sv, and .vhd files inside /tb/
# add_or_update_files "sim_1" "./**/tb/*.v"
add_or_update_files "sim_1" "./**/tb/*.sv"
# add_or_update_files "sim_1" "./**/tb/*.vhd"

# 4. Refresh & Save
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
save_project_as -force $proj_name $proj_dir

puts "Vivado project setup complete."