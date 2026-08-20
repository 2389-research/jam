Use this format to compile Phase 4 review findings into the cross-variant comparison you present when picking the winner. This is working output — the strengths captured here feed Phase 5 synthesis and land in `result.md` via the [result template](result-template.md).

One column per variant, one row per reviewer focus. A jam produces 3-5 variants
named for their philosophy (`variant-<slug>`, matching the worktree names from
Phase 3) — add or drop columns to match what you actually built.

```markdown
## Jam Evaluation: <feature>

### Variant Scorecard

| Criterion | variant-<slug-1> | variant-<slug-2> | ... |
|-----------|------------------|------------------|-----|
| [Reviewer 1 focus] | findings | findings | findings |
| [Reviewer 2 focus] | findings | findings | findings |
| Tests passing | Y/N | Y/N | Y/N |

### Per-Variant Strengths (PRESERVE THESE FOR SYNTHESIS)

One line per variant built:

**variant-<slug>:** [what reviewers loved]

### Per-Variant Weaknesses

**variant-<slug>:** [what reviewers flagged]

### Winner: variant-<slug>
[Why, based on panel findings]
```
