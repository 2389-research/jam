# ABOUTME: Evaluation rubric for comparing approach outputs.
# ABOUTME: Used by the evaluation panel to score each approach's final output.

# Iron Chef Eval Rubric

## How Evaluation Works

Each task × approach combination produces a final output (code, content, etc.).
An evaluation agent reviews the output blind (doesn't know which approach produced it)
and scores it on the task's evaluation dimensions.

## Universal Scoring Scale

All dimensions scored 1-5:

| Score | Meaning |
|-------|---------|
| 5 | Exceptional — meaningfully better than expected |
| 4 | Good — fully meets the bar, no issues |
| 3 | Adequate — works but has clear gaps |
| 2 | Poor — significant problems |
| 1 | Failing — doesn't meet basic requirements |

## Per-Task Dimensions

Each task defines its own dimensions (see task files). The evaluator scores
each dimension independently, then provides an overall assessment.

## Evaluation Agent Prompt Template

```
You are evaluating a project that was built to satisfy this brief:

{task_prompt}

The project is at: {project_path}

Score the project on each of these dimensions (1-5 scale, integers only):

{dimensions_from_task}

For each dimension:
1. State your score
2. Give 1-2 sentences of justification with specific evidence from the code/output
3. Note the single most impressive thing and single biggest gap

Then provide:
- **Overall score**: Average of all dimensions (to 1 decimal)
- **One-line summary**: What this project gets right and wrong in one sentence
- **Would you use this?**: Honest yes/no with reasoning

IMPORTANT: Be calibrated. A 3 is fine — it means adequate. Don't inflate scores.
Reserve 5 for genuinely impressive work, not just "works correctly."
```

## Cross-Approach Comparison

After all four approaches are evaluated for a task, produce a comparison:

```
## Task: {task_name}

| Dimension | Straight | Brainstorm | Omakase | Iron Chef |
|-----------|----------|------------|---------|-----------|
| Dim 1     | X/5      | X/5        | X/5     | X/5       |
| Dim 2     | X/5      | X/5        | X/5     | X/5       |
| ...       |          |            |         |           |
| **Overall** | X.X    | X.X        | X.X     | X.X       |

### Winner: {approach}
### Why: {1-2 sentences}

### Interesting Patterns:
- {What did more structured approaches do better?}
- {What did simpler approaches do better?}
- {Where did Iron Chef's synthesis actually improve the output?}
- {Was the overhead of Iron Chef justified by the quality delta?}
```
