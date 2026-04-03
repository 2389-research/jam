#!/usr/bin/env bash
# ABOUTME: Evaluation harness that runs each task × approach combination.
# ABOUTME: Dispatches claude CLI agents with real skill invocation, then evaluates outputs.

set -euo pipefail

EVAL_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${EVAL_DIR}/.." && pwd)"
RESULTS_DIR="${EVAL_DIR}/results"
TASKS_DIR="${EVAL_DIR}/tasks"
APPROACHES_DIR="${EVAL_DIR}/approaches"

# Configurable
CLAUDE_CMD=${CLAUDE_CMD:-claude}
MAX_TURNS=${MAX_TURNS:-80}

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
    cat <<'USAGE'
Usage: run-eval.sh [OPTIONS]

Run Iron Chef comparative evaluation suite.

OPTIONS:
    --task TASK          Run only tasks matching TASK (substring match)
    --approach APPROACH  Run only approaches matching APPROACH (substring match)
    --eval-only          Skip building, just run evaluation on existing results
    --compare-only       Skip building and eval, just run comparison
    --list               List available tasks and approaches
    --clean              Remove all results and start fresh
    --max-turns N        Max turns per agent (default: 80)
    -h, --help           Show this help

EXAMPLES:
    run-eval.sh                                    # Run everything
    run-eval.sh --task 01-pomodoro-cli             # One task, all approaches
    run-eval.sh --approach iron-chef               # One approach, all tasks
    run-eval.sh --task 01 --approach straight      # One combination
    run-eval.sh --eval-only                        # Re-evaluate existing outputs
USAGE
}

# Python helper for markdown parsing (macOS sed is too limited)
pyextract() {
    python3 -c "
import re, sys
content = open(sys.argv[1]).read()
header = sys.argv[2]
pattern = r'## ' + re.escape(header) + r'\s*\n\n(.*?)(?=\n## |\Z)'
match = re.search(pattern, content, re.DOTALL)
if match:
    print(match.group(1).strip())
else:
    sys.exit(1)
" "$@"
}

# Extract a yaml-like value from the ## Config block of an approach file
approach_config() {
    local file="$1"
    local key="$2"
    python3 -c "
import re, sys
content = open(sys.argv[1]).read()
# Get the Config section
config_match = re.search(r'## Config\s*\n\n(.*?)(?=\n## |\Z)', content, re.DOTALL)
if not config_match:
    sys.exit(1)
config = config_match.group(1)

key = sys.argv[2]

# Handle multiline 'prompt_template: |' style
pattern = re.escape(key) + r':\s*\|\s*\n((?:(?:  .*)?\n)*)'
ml_match = re.search(pattern, config)
if ml_match:
    # Strip 2-space indent from each line
    lines = ml_match.group(1).split('\n')
    print('\n'.join(line[2:] if line.startswith('  ') else line for line in lines).strip())
    sys.exit(0)

# Handle single-line 'key: value'
pattern = re.escape(key) + r':\s*(.+)'
sl_match = re.search(pattern, config)
if sl_match:
    print(sl_match.group(1).strip())
    sys.exit(0)

sys.exit(1)
" "$file" "$key"
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
        log "Skipping ${task_name} × ${approach_name} (already done, use --clean to reset)"
        return 0
    fi

    # Clean up any previous failed attempt
    rm -f "${output_dir}/.failed"

    log "Running: ${task_name} × ${approach_name}"
    mkdir -p "${output_dir}/project"

    # Initialize a git repo in the project dir so worktrees work
    (cd "${output_dir}/project" && git init -q && git commit --allow-empty -m "init" -q) 2>/dev/null || true

    # Extract task prompt
    local task_prompt
    task_prompt=$(pyextract "$task_file" "The Prompt")

    # Extract approach config
    local prompt_template
    prompt_template=$(approach_config "$approach_file" "prompt_template")

    # Substitute task prompt into template
    local full_prompt
    full_prompt=$(echo "$prompt_template" | sed "s|{task_prompt}|${task_prompt}|")

    # Save prompt for debugging
    echo "$full_prompt" > "${output_dir}/prompt.txt"

    # Build claude command
    local -a claude_args=(
        --print
        --output-format text
        --max-turns "$MAX_TURNS"
        --dangerously-skip-permissions
    )

    # Check if approach needs a local plugin dir
    local plugin_dir
    if plugin_dir=$(approach_config "$approach_file" "plugin_dir" 2>/dev/null); then
        # Resolve relative to project root
        if [[ "$plugin_dir" == "." ]]; then
            plugin_dir="$PROJECT_ROOT"
        fi
        claude_args+=(--plugin-dir "$plugin_dir")
    fi

    log "  Prompt: $(echo "$full_prompt" | head -1)"
    log "  Working dir: ${output_dir}/project"
    log "  Log: ${log_file}"

    # Run claude
    local start_time
    start_time=$(date +%s)

    if $CLAUDE_CMD "${claude_args[@]}" \
        --cwd "${output_dir}/project" \
        "$full_prompt" \
        > "$log_file" 2>&1; then
        local end_time
        end_time=$(date +%s)
        local duration=$(( end_time - start_time ))
        echo "$duration" > "${output_dir}/duration.txt"
        touch "${output_dir}/.done"
        success "Completed: ${task_name} × ${approach_name} (${duration}s)"
    else
        local end_time
        end_time=$(date +%s)
        local duration=$(( end_time - start_time ))
        echo "$duration" > "${output_dir}/duration.txt"
        error "Failed: ${task_name} × ${approach_name} (${duration}s, see ${log_file})"
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
    task_prompt=$(pyextract "$task_file" "The Prompt")

    local dimensions
    dimensions=$(pyextract "$task_file" "Evaluation Dimensions")

    local duration="unknown"
    [[ -f "${output_dir}/duration.txt" ]] && duration="$(cat "${output_dir}/duration.txt")s"

    # Evaluation agent gets NO skills — just reads the output and scores it
    local eval_prompt="You are evaluating a project that was built to satisfy this brief:

${task_prompt}

The project is in the current directory. Read the code, run the tests, and evaluate.
Build time was: ${duration}

Score the project on each of these dimensions (1-5 scale, integers only):

${dimensions}

For each dimension:
1. State your score
2. Give 1-2 sentences of justification with specific evidence
3. Note the single most impressive thing and single biggest gap

Then provide:
- **Overall score**: Average of all dimensions (to 1 decimal)
- **One-line summary**: What this project gets right and wrong
- **Would you use this?**: Honest yes/no with reasoning

IMPORTANT: Be calibrated. A 3 means adequate. Don't inflate.
Reserve 5 for genuinely impressive work."

    if $CLAUDE_CMD --print \
        --output-format text \
        --max-turns 20 \
        --dangerously-skip-permissions \
        --disable-slash-commands \
        --cwd "${output_dir}/project" \
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
        [[ -d "$approach_dir" ]] || continue
        local approach_name
        approach_name=$(basename "$approach_dir")
        local eval_file="${approach_dir}/evaluation.md"
        if [[ -f "$eval_file" ]]; then
            local duration="unknown"
            [[ -f "${approach_dir}/duration.txt" ]] && duration="$(cat "${approach_dir}/duration.txt")s"
            eval_content+="
## Approach: ${approach_name} (build time: ${duration})

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
    task_prompt=$(pyextract "$task_file" "The Prompt")

    local compare_prompt="You are comparing different approaches to building the same project.

The project brief was:
${task_prompt}

Here are the individual evaluations:

${eval_content}

Create a comparison table and analysis:

1. Build a markdown table: dimensions as rows, approaches as columns, showing scores
2. Calculate overall averages
3. Name the winner
4. Answer:
   - What did more structured approaches (omakase, iron-chef) do better?
   - What did simpler approaches (straight-prompt, brainstorming) do better?
   - Where did Iron Chef's synthesis visibly improve the output?
   - Was the overhead of Iron Chef justified by the quality delta?
   - Factor in build time — was slower approach worth the wait?
   - What surprised you?

Be honest. If simpler approaches won, say so."

    if $CLAUDE_CMD --print \
        --output-format text \
        --max-turns 10 \
        --disable-slash-commands \
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
    local compare_only=false
    local do_clean=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --task) task_filter="$2"; shift 2 ;;
            --approach) approach_filter="$2"; shift 2 ;;
            --eval-only) eval_only=true; shift ;;
            --compare-only) compare_only=true; shift ;;
            --clean) do_clean=true; shift ;;
            --max-turns) MAX_TURNS="$2"; shift 2 ;;
            --list)
                echo "Tasks:"
                for f in "${TASKS_DIR}"/*.md; do echo "  $(basename "$f" .md)"; done
                echo ""
                echo "Approaches:"
                for f in "${APPROACHES_DIR}"/*.md; do
                    local name skill
                    name=$(basename "$f" .md)
                    skill=$(approach_config "$f" "skill" 2>/dev/null || echo "none")
                    printf "  %-20s  skill: %s\n" "$name" "$skill"
                done
                echo ""
                echo "Total combinations: $(( $(ls "${TASKS_DIR}"/*.md | wc -l) * $(ls "${APPROACHES_DIR}"/*.md | wc -l) ))"
                exit 0
                ;;
            -h|--help) usage; exit 0 ;;
            *) error "Unknown option: $1"; usage; exit 1 ;;
        esac
    done

    if $do_clean; then
        warn "Cleaning results directory..."
        rm -rf "${RESULTS_DIR:?}"
        mkdir -p "${RESULTS_DIR}"
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
    echo ""

    # Phase 1: Build
    if ! $eval_only && ! $compare_only; then
        log "=== PHASE 1: Building ==="
        for task in "${tasks[@]}"; do
            for approach in "${approaches[@]}"; do
                run_combination "$task" "$approach"
            done
        done
        echo ""
    fi

    # Phase 2: Evaluate
    if ! $compare_only; then
        log "=== PHASE 2: Evaluating ==="
        for task in "${tasks[@]}"; do
            for approach in "${approaches[@]}"; do
                evaluate_result "$task" "$approach"
            done
        done
        echo ""
    fi

    # Phase 3: Compare
    log "=== PHASE 3: Comparing ==="
    for task in "${tasks[@]}"; do
        compare_task "$task"
    done
    echo ""

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
