#!/usr/bin/env bash
# ABOUTME: Evaluation harness that runs each task × approach combination.
# ABOUTME: Dispatches claude CLI agents in isolated directories, then evaluates outputs.

set -euo pipefail

EVAL_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="${EVAL_DIR}/results"
TASKS_DIR="${EVAL_DIR}/tasks"
APPROACHES_DIR="${EVAL_DIR}/approaches"

# Configurable
MAX_PARALLEL=${MAX_PARALLEL:-2}  # How many agents to run at once
CLAUDE_CMD=${CLAUDE_CMD:-claude}  # Path to claude CLI

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[eval]${NC} $*"; }
success() { echo -e "${GREEN}[eval]${NC} $*"; }
warn() { echo -e "${YELLOW}[eval]${NC} $*"; }
error() { echo -e "${RED}[eval]${NC} $*"; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [TASK_FILTER] [APPROACH_FILTER]

Run Iron Chef evaluation suite.

OPTIONS:
    --task TASK          Run only this task (e.g., "01-pomodoro-cli")
    --approach APPROACH  Run only this approach (e.g., "iron-chef")
    --eval-only          Skip building, just run evaluation on existing results
    --list               List available tasks and approaches
    --clean              Remove all results and start fresh
    -h, --help           Show this help

EXAMPLES:
    $(basename "$0")                              # Run everything
    $(basename "$0") --task 01-pomodoro-cli       # Run one task, all approaches
    $(basename "$0") --approach iron-chef          # Run one approach, all tasks
    $(basename "$0") --task 01 --approach straight # Run one combination
    $(basename "$0") --eval-only                   # Re-evaluate existing outputs
EOF
}

# Extract a markdown section's content (between ## Header and next ##)
extract_section() {
    local file="$1"
    local header="$2"
    python3 -c "
import re, sys
content = open(sys.argv[1]).read()
pattern = r'## ' + re.escape(sys.argv[2]) + r'\s*\n\n(.*?)(?=\n## |\Z)'
match = re.search(pattern, content, re.DOTALL)
if match:
    print(match.group(1).strip())
else:
    print('ERROR: section not found: ' + sys.argv[2], file=sys.stderr)
    sys.exit(1)
" "$file" "$header"
}

extract_prompt() { extract_section "$1" "The Prompt"; }
extract_dimensions() { extract_section "$1" "Evaluation Dimensions"; }

# Extract agent instructions template from approach file and substitute task prompt
build_agent_prompt() {
    local approach_file="$1"
    local task_prompt="$2"
    python3 -c "
import re, sys
content = open(sys.argv[1]).read()
match = re.search(r'## Agent Instructions\s*\n\s*\x60\x60\x60\s*\n(.*?)\x60\x60\x60', content, re.DOTALL)
if match:
    template = match.group(1)
    print(template.replace('{task_prompt}', sys.argv[2]))
else:
    print('ERROR: Could not extract agent instructions', file=sys.stderr)
    sys.exit(1)
" "$approach_file" "$task_prompt"
}

# Run a single task × approach combination
run_combination() {
    local task_name="$1"
    local approach_name="$2"
    local task_file="${TASKS_DIR}/${task_name}.md"
    local approach_file="${APPROACHES_DIR}/${approach_name}.md"
    local output_dir="${RESULTS_DIR}/${task_name}/${approach_name}"
    local log_file="${output_dir}/agent.log"

    if [[ -f "${output_dir}/.done" ]]; then
        log "Skipping ${task_name} × ${approach_name} (already done)"
        return 0
    fi

    log "Running: ${task_name} × ${approach_name}"
    mkdir -p "$output_dir/project"

    # Extract task prompt and build agent prompt
    local task_prompt
    task_prompt=$(extract_prompt "$task_file")

    local agent_prompt_file="${output_dir}/prompt.txt"
    build_agent_prompt "$approach_file" "$task_prompt" > "$agent_prompt_file"

    # Run claude in the project directory
    if $CLAUDE_CMD --print \
        --output-format text \
        --max-turns 50 \
        --cwd "$output_dir/project" \
        "$(cat "$agent_prompt_file")" \
        > "$log_file" 2>&1; then
        touch "${output_dir}/.done"
        success "Completed: ${task_name} × ${approach_name}"
    else
        error "Failed: ${task_name} × ${approach_name} (see ${log_file})"
        touch "${output_dir}/.failed"
    fi
}

# Evaluate a single result
evaluate_result() {
    local task_name="$1"
    local approach_name="$2"
    local task_file="${TASKS_DIR}/${task_name}.md"
    local output_dir="${RESULTS_DIR}/${task_name}/${approach_name}"
    local eval_file="${output_dir}/evaluation.md"

    if [[ ! -f "${output_dir}/.done" ]]; then
        warn "Skipping eval for ${task_name} × ${approach_name} (not completed)"
        return 0
    fi

    if [[ -f "${eval_file}" ]] && [[ ! "${FORCE_EVAL:-}" == "true" ]]; then
        log "Skipping eval for ${task_name} × ${approach_name} (already evaluated)"
        return 0
    fi

    log "Evaluating: ${task_name} × ${approach_name}"

    local task_prompt
    task_prompt=$(extract_prompt "$task_file")

    local dimensions
    dimensions=$(extract_dimensions "$task_file")

    # Build evaluation prompt
    local eval_prompt="You are evaluating a project that was built to satisfy this brief:

${task_prompt}

The project is at the current directory.

Score the project on each of these dimensions (1-5 scale, integers only):

${dimensions}

For each dimension:
1. State your score
2. Give 1-2 sentences of justification with specific evidence from the code/output
3. Note the single most impressive thing and single biggest gap

Then provide:
- **Overall score**: Average of all dimensions (to 1 decimal)
- **One-line summary**: What this project gets right and wrong in one sentence
- **Would you use this?**: Honest yes/no with reasoning

IMPORTANT: Be calibrated. A 3 is fine — it means adequate. Don't inflate scores.
Reserve 5 for genuinely impressive work, not just 'works correctly.'

Write your evaluation as markdown. Be specific and cite evidence."

    if $CLAUDE_CMD --print \
        --output-format text \
        --max-turns 20 \
        --cwd "$output_dir/project" \
        "$eval_prompt" \
        > "$eval_file" 2>&1; then
        success "Evaluated: ${task_name} × ${approach_name}"
    else
        error "Eval failed: ${task_name} × ${approach_name}"
    fi
}

# Generate cross-approach comparison for a task
compare_task() {
    local task_name="$1"
    local comparison_file="${RESULTS_DIR}/${task_name}/comparison.md"

    log "Generating comparison for: ${task_name}"

    # Collect all evaluations
    local eval_content=""
    for approach_dir in "${RESULTS_DIR}/${task_name}"/*/; do
        local approach_name
        approach_name=$(basename "$approach_dir")
        local eval_file="${approach_dir}/evaluation.md"
        if [[ -f "$eval_file" ]]; then
            eval_content+="
## Approach: ${approach_name}

$(cat "$eval_file")

---
"
        fi
    done

    if [[ -z "$eval_content" ]]; then
        warn "No evaluations found for ${task_name}"
        return 0
    fi

    local task_file="${TASKS_DIR}/${task_name}.md"
    local task_prompt
    task_prompt=$(extract_prompt "$task_file")

    local compare_prompt="You are comparing four different approaches to building the same project.

The project brief was:
${task_prompt}

Here are the individual evaluations (the approach names are: straight-prompt, brainstorming, omakase, iron-chef):

${eval_content}

Create a comparison table and analysis:

1. Build a markdown table with dimensions as rows and approaches as columns, showing scores
2. Calculate overall averages
3. Name the winner
4. Answer these questions:
   - What did more structured approaches (omakase, iron-chef) do better than simpler ones?
   - What did simpler approaches (straight-prompt, brainstorming) do better?
   - Where did Iron Chef's synthesis visibly improve the output?
   - Was the overhead of Iron Chef justified by the quality delta?
   - What surprised you?

Be honest and specific. If simpler approaches won, say so."

    if $CLAUDE_CMD --print \
        --output-format text \
        --max-turns 10 \
        "$compare_prompt" \
        > "$comparison_file" 2>&1; then
        success "Comparison written: ${comparison_file}"
    else
        error "Comparison failed for ${task_name}"
    fi
}

# Main
main() {
    local task_filter=""
    local approach_filter=""
    local eval_only=false
    local do_clean=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --task) task_filter="$2"; shift 2 ;;
            --approach) approach_filter="$2"; shift 2 ;;
            --eval-only) eval_only=true; shift ;;
            --clean) do_clean=true; shift ;;
            --list)
                echo "Tasks:"
                for f in "${TASKS_DIR}"/*.md; do echo "  $(basename "$f" .md)"; done
                echo "Approaches:"
                for f in "${APPROACHES_DIR}"/*.md; do echo "  $(basename "$f" .md)"; done
                exit 0
                ;;
            -h|--help) usage; exit 0 ;;
            *) error "Unknown option: $1"; usage; exit 1 ;;
        esac
    done

    if $do_clean; then
        warn "Cleaning results directory..."
        rm -rf "${RESULTS_DIR:?}"/*
        success "Cleaned."
        exit 0
    fi

    # Collect tasks and approaches
    local tasks=()
    local approaches=()

    for f in "${TASKS_DIR}"/*.md; do
        local name
        name=$(basename "$f" .md)
        if [[ -z "$task_filter" ]] || [[ "$name" == *"$task_filter"* ]]; then
            tasks+=("$name")
        fi
    done

    for f in "${APPROACHES_DIR}"/*.md; do
        local name
        name=$(basename "$f" .md)
        if [[ -z "$approach_filter" ]] || [[ "$name" == *"$approach_filter"* ]]; then
            approaches+=("$name")
        fi
    done

    log "Tasks: ${tasks[*]}"
    log "Approaches: ${approaches[*]}"
    log "Combinations: $(( ${#tasks[@]} * ${#approaches[@]} ))"

    # Phase 1: Build (unless --eval-only)
    if ! $eval_only; then
        log "=== PHASE 1: Building ==="
        for task in "${tasks[@]}"; do
            for approach in "${approaches[@]}"; do
                run_combination "$task" "$approach"
            done
        done
    fi

    # Phase 2: Evaluate
    log "=== PHASE 2: Evaluating ==="
    for task in "${tasks[@]}"; do
        for approach in "${approaches[@]}"; do
            evaluate_result "$task" "$approach"
        done
    done

    # Phase 3: Compare
    log "=== PHASE 3: Comparing ==="
    for task in "${tasks[@]}"; do
        compare_task "$task"
    done

    # Summary
    log "=== DONE ==="
    log "Results in: ${RESULTS_DIR}/"
    for task in "${tasks[@]}"; do
        if [[ -f "${RESULTS_DIR}/${task}/comparison.md" ]]; then
            success "  ${task}/comparison.md"
        fi
    done
}

main "$@"
