# common.tcl — reusable procs shared by all task scripts.
# Sourced by bootstrap.tcl after the context file, so REPO_ROOT, BUILD_DIR,
# REPORT_DIR, PROJECT_NAME, RTL_DIR, TB_DIR, PART, TOP, SIM_TOP are set.

proc log_msg {msg} {
    puts "\[TCL\] $msg"
}

# write_status OK|FAIL — the authoritative last line of every task's log.
# Bash greps for this instead of trusting the vivado process exit code,
# since Vivado can exit 0 on logical failures (e.g. a failed synth run).
proc write_status {status} {
    puts "RUN_STATUS:$status"
}

# discover_sources <dir> <extensions list>
# Recursively finds source files under <dir> matching any of <extensions>.
# Skips hidden directories (so generated/.git-ish trees are ignored).
proc discover_sources {dir extensions} {
    set found {}
    if {![file isdirectory $dir]} {
        return $found
    }
    foreach entry [glob -nocomplain -directory $dir *] {
        set tail [file tail $entry]
        if {[string match ".*" $tail]} {
            continue
        }
        if {[file isdirectory $entry]} {
            lappend found {*}[discover_sources $entry $extensions]
        } else {
            foreach ext $extensions {
                if {[string equal [file extension $entry] $ext]} {
                    lappend found $entry
                    break
                }
            }
        }
    }
    return $found
}

# ensure_dir <path> — mkdir -p equivalent.
proc ensure_dir {path} {
    file mkdir $path
}

# project_path — directory containing the .xpr created by init_project.tcl.
proc project_path {} {
    return [file join $::BUILD_DIR $::PROJECT_NAME]
}

# open_target_project — opens the project created by `run.sh init`.
# Every task other than init/clean calls this first.
proc open_target_project {} {
    set xpr [file join [project_path] "$::PROJECT_NAME.xpr"]
    if {![file exists $xpr]} {
        write_status FAIL
        error "Project not found at $xpr — run 'init' first."
    }
    open_project $xpr
}
