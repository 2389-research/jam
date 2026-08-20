Write this file to `docs/plans/<feature>/variants/result.md` at the end of Phase 5. It is the single durable artifact of a jam run — the [scorecard](scorecard.md) is the Phase 4 working comparison that feeds it.

One row per variant built — a jam produces 3-5, named for their philosophy and
matching the Phase 3 worktree names. The slugs below are illustrative; use the
real ones. Every variant gets a row whether it won, lost, or was eliminated,
because the synthesis table has to account for all of them.

```markdown
# Jam Results: <feature>

## Perspective Panel
[Who proposed approaches and why]

## Variants Explored
| Variant | Philosophy | Tests | Result |
|---------|-----------|-------|--------|
| variant-unix-composable | Pipes and small tools | PASS | WINNER |
| variant-batteries-included | One command does it all | PASS | Insights incorporated |
| variant-single-binary | Zero-dependency deploy | FAIL | Eliminated |

## Review Panel
[Who evaluated and their key findings]

## Winner: variant-unix-composable
[Why it won]

## Synthesis: What We Learned From Everyone
| Source | Insight | Incorporated? | How |
|--------|---------|---------------|-----|
| variant-batteries-included | Better error messages | Yes | Ported error handling pattern |
| variant-batteries-included | Interactive TUI mode | No | Over-complex for current needs |
| variant-single-binary | Static linking | Yes | Adopted for release builds |
| Reviewer X | Missing input validation | Yes | Added to all entry points |

## The Jam Was All of Us Together
[Brief narrative of how the final result is better than any single variant]
```
