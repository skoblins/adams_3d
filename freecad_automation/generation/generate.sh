#!/usr/bin/env bash
# Generate STL exports from stroik1-D-leaf_PLA_flexi-sealing.FCStd.
#
# Usage: ./generate.sh <target> [target ...]
#   targets: reeds, leafs, box, lid

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VALID="reeds leafs box lid"

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <target> [target ...]"
    echo "  targets: $VALID"
    exit 1
fi

# Validate all arguments first
for arg in "$@"; do
    case "$arg" in
        reeds|leafs|box|lid) ;;
        *)
            echo "ERROR: unknown target '$arg' (valid: $VALID)"
            exit 1
            ;;
    esac
done

# Launch all targets in parallel
declare -A PIDS
for arg in "$@"; do
    case "$arg" in
        reeds) script="reed.py" ;;
        leafs) script="leaf.py" ;;
        box)   script="box.py"  ;;
        lid)   script="lid.py"  ;;
    esac
    echo "=== Starting: $arg (${script}) ==="
    flatpak run --command=freecadcmd org.freecad.FreeCAD -c \
        "exec(open('${SCRIPT_DIR}/${script}').read())" &
    PIDS[$arg]=$!
done

# Wait for each process and report results
FAILED=0
for arg in "${!PIDS[@]}"; do
    pid=${PIDS[$arg]}
    if wait "$pid"; then
        echo "=== DONE: $arg (pid $pid) — OK ==="
    else
        rc=$?
        echo "=== FAIL: $arg (pid $pid) — exit code $rc ==="
        FAILED=$((FAILED + 1))
    fi
done

if [[ $FAILED -gt 0 ]]; then
    echo "ERROR: $FAILED target(s) failed"
    exit 1
fi
echo "All targets completed successfully."
