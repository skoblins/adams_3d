#!/usr/bin/env bash
# Generate STL exports from stroik1-D-leaf_PLA_flexi-sealing.FCStd.
#
# Usage: ./generate.sh <target> [target ...]
#   targets: reeds, leafs, box, lid, reed_box, reed_lid
#
# The "box" target runs a 3-phase pipeline:
#   1. box_prepare.py  — collect pockets, write row args (single process)
#   2. _row_worker.py  — build each row strip (N parallel freecadcmd processes)
#   3. box_assemble.py — compound rows + export STL (single process)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_freecad() {
    freecad.cmd "$@"
}

VALID="reeds leafs leaf_matrix reed_matrix box lid reed_box reed_lid ring"

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <target> [target ...]"
    echo "  targets: $VALID"
    exit 1
fi

# Validate all arguments first
for arg in "$@"; do
    case "$arg" in
        reeds|leafs|leaf_matrix|reed_matrix|box|lid|reed_box|reed_lid|ring) ;;
        *)
            echo "ERROR: unknown target '$arg' (valid: $VALID)"
            exit 1
            ;;
    esac
done

# ---- Helper: run a box pipeline (prepare → parallel rows → assemble) ----
# Args: $1 = mode ("listek" or "stroik"), $2 = display label
run_box_pipeline() {
    local mode="$1"
    local display="$2"
    echo "=== ${display}: phase 1/3 — preparing row data ==="
    local prepare_output
    prepare_output=$(BOX_MODE="$mode" run_freecad -c "exec(open('${SCRIPT_DIR}/box_prepare.py').read())" 2>&1)
    echo "$prepare_output"

    # Extract manifest path from last line: MANIFEST=/tmp/...
    local manifest
    manifest=$(echo "$prepare_output" | grep 'MANIFEST=' | tail -1 | sed 's/.*MANIFEST=//')
    if [[ -z "$manifest" || ! -f "$manifest" ]]; then
        echo "ERROR: box_prepare.py did not produce a manifest (got: '$manifest')"
        return 1
    fi
    echo "  Manifest: $manifest"

    # Read row worker entries from manifest using python (jq may not be available)
    local row_data
    row_data=$(python3 -c "
import json, sys
with open('$manifest') as f:
    m = json.load(f)
for box in m['boxes']:
    for row in box['rows']:
        print(row['args_file'] + '|' + row['stl_file'])
")

    # Phase 2: launch one freecadcmd per row in parallel
    echo "=== ${display}: phase 2/3 — building rows in parallel ==="
    local -a ROW_PIDS=()
    local -a ROW_LABELS=()
    while IFS='|' read -r args_file brep_file; do
        local label
        label=$(basename "$args_file" .pkl)
        echo "  Starting row worker: $label"
        ROW_WORKER_ARGS="$args_file" ROW_WORKER_OUTPUT="$brep_file" \
            run_freecad -c "exec(open('${SCRIPT_DIR}/_row_worker.py').read())" &
        ROW_PIDS+=($!)
        ROW_LABELS+=("$label")
    done <<< "$row_data"

    # Wait for all row workers
    local row_failed=0
    for i in "${!ROW_PIDS[@]}"; do
        local pid=${ROW_PIDS[$i]}
        local label=${ROW_LABELS[$i]}
        if wait "$pid"; then
            echo "  Row done: $label (pid $pid)"
        else
            local rc=$?
            echo "  ERROR: $label (pid $pid) — exit code $rc"
            row_failed=$((row_failed + 1))
        fi
    done
    if [[ $row_failed -gt 0 ]]; then
        echo "ERROR: $row_failed row worker(s) failed"
        return 1
    fi

    # Phase 3: concatenate row STLs into final file (no FreeCAD needed)
    echo "=== ${display}: phase 3/3 — concatenating STL ==="
    ROW_MANIFEST="$manifest" \
        python3 "${SCRIPT_DIR}/box_assemble.py"
}

# Launch all targets in parallel (box is special — runs its own pipeline)
declare -A PIDS
for arg in "$@"; do
    case "$arg" in
        reeds) script="reed.py" ;;
        leafs) script="leaf.py" ;;
        leaf_matrix) script="leaf_matrix.py" ;;
        reed_matrix) script="reed_matrix.py" ;;
        ring) script="ring.py" ;;
        lid)   script="lid.py"  ;;
        reed_lid)
            echo "=== Starting: reed_lid ==="
            BOX_MODE=stroik run_freecad -c "exec(open('${SCRIPT_DIR}/lid.py').read())" &
            PIDS[reed_lid]=$!
            continue
            ;;
        box)
            # Box runs inline (has its own internal parallelism)
            echo "=== Starting: box (3-phase pipeline) ==="
            run_box_pipeline listek "Box" &
            PIDS[box]=$!
            continue
            ;;
        reed_box)
            echo "=== Starting: reed_box (3-phase pipeline) ==="
            run_box_pipeline stroik "Reed box" &
            PIDS[reed_box]=$!
            continue
            ;;
    esac
    echo "=== Starting: $arg (${script}) ==="
    run_freecad -c "exec(open('${SCRIPT_DIR}/${script}').read())" &
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
