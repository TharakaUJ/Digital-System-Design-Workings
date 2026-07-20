# -----------------------------------------------------------------------------
# Configuration - Change these to match your project
# -----------------------------------------------------------------------------
set PROJECT_PATH "my_project/my_project.xpr"
set TOP_MODULE "my_top_design"

# Open the existing Vivado project
open_project $PROJECT_PATH

# Set the top module for synthesis
set_property top $TOP_MODULE [current_fileset]

# -----------------------------------------------------------------------------
# Run Synthesis
# -----------------------------------------------------------------------------
# Reset the previous run (optional, ensures a clean start)
reset_run synth_1

# Launch synthesis and wait for it to finish
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Open the synthesized design in memory to generate reports/schematics
open_run synth_1

# -----------------------------------------------------------------------------
# Generate Reports & Schematic
# -----------------------------------------------------------------------------
# 1. Resource Utilization Report (Text format)
report_utilization -file utilization_report.txt

# 2. Export Schematic (Saves a visual representation of the design)
# You can change the extension to .pdf, .png, or .jpeg
write_schematic -format pdf -force schematic_output.pdf

# Close the project
close_project