# bootstrap.tcl — sourced first by every task script.
# Expects the environment variable RUN_CONTEXT to point at the
# Bash-generated context file (a set of `set KEY {VALUE}` lines).

set context_path $::env(RUN_CONTEXT)
if {![file exists $context_path]} {
    puts "RUN_STATUS:FAIL"
    error "Context file not found: $context_path"
}
source $context_path

set lib_dir [file join [file dirname [info script]] lib]
source [file join $lib_dir common.tcl]
