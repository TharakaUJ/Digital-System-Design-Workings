# -----------------------------------------------------------------------------
# Configuration - Change your default testbench file name here
# -----------------------------------------------------------------------------
set DEFAULT_TB "my_default_tb"

# Check if a testbench name was passed as a command-line argument
if { $argc > 0 } {
    set tb_name [lindex $argv 0]
    puts "Using user-specified testbench: $tb_name"
} else {
    set tb_name $DEFAULT_TB
    puts "No argument provided. Using default testbench: $tb_name"
}

# -----------------------------------------------------------------------------
# Vivado Simulation Commands
# -----------------------------------------------------------------------------
# 1. Set the top-level simulation module
set_property top $tb_name [current_fileset -simset]

# 2. Launch the simulation (behavioral by default)
launch_simulation

# 3. Optional: Run the simulation for a specific time (e.g., run all or run 10us)
run all