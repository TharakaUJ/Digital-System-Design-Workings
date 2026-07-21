#!/usr/bin/env bash
# paths.sh — resolves repo-relative paths for a given assignment/exercise.
# Source only. Depends on: log.sh, context.sh (for cfg_get)

# repo_root: absolute path to the git repository root.
repo_root() {
    local root
    root="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel 2>/dev/null)" \
        || die "Not inside a git repository (or git is not installed)."
    printf '%s\n' "$root"
}

# exercise_dir <assignment> <exercise>
# Prints absolute path to the exercise directory, validates it exists.
exercise_dir() {
    local assignment="$1" exercise="$2"
    local dir="$REPO_ROOT/$assignment/$exercise"
    [[ -d "$dir" ]] || die "Exercise directory not found: $assignment/$exercise"
    printf '%s\n' "$dir"
}

# rtl_dir / tb_dir <exercise_dir>
rtl_dir() { printf '%s\n' "$1/rtl"; }
tb_dir()  { printf '%s\n' "$1/tb"; }

# build_dir <assignment> <exercise>
# Where the actual Vivado project + all its junk (.Xil, .jou, .log, .cache)
# lives. Kept separate from reports so `clean` can safely rm -rf it, and
# used as the cwd for `vivado` invocations so lock/journal files land here
# instead of scattering into the repo root.
build_dir() {
    local assignment="$1" exercise="$2"
    printf '%s\n' "$REPO_ROOT/$(cfg_get '.paths.build_dir')/$assignment/$exercise"
}

# report_dir <assignment> <exercise>
# Resolves to either the central reports/ tree or a folder local to the
# exercise, depending on the "reports.location" config value
# ("central" | "local").
report_dir() {
    local assignment="$1" exercise="$2"
    local location
    location="$(cfg_get '.reports.location')"

    case "$location" in
        local)
            printf '%s\n' "$REPO_ROOT/$assignment/$exercise/reports"
            ;;
        central|*)
            printf '%s\n' "$REPO_ROOT/$(cfg_get '.paths.reports_dir')/$assignment/$exercise"
            ;;
    esac
}
