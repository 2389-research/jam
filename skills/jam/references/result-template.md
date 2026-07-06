Write this file to `docs/plans/<feature>/variants/result.md` at the end of Phase 5.

```markdown
# Jam Results: <feature>

## Perspective Panel
[Who proposed approaches and why]

## Variants Explored
| Variant | Philosophy | Tests | Result |
|---------|-----------|-------|--------|
| variant-a | ... | PASS | WINNER |
| variant-b | ... | PASS | Insights incorporated |
| variant-c | ... | FAIL | Eliminated |

## Review Panel
[Who evaluated and their key findings]

## Winner: variant-a
[Why it won]

## Synthesis: What We Learned From Everyone
| Source | Insight | Incorporated? | How |
|--------|---------|---------------|-----|
| variant-b | Better error messages | Yes | Ported error handling pattern |
| variant-b | GraphQL subscriptions | No | Over-complex for current needs |
| variant-c | Single-binary deploy | Yes | Adopted static linking approach |
| Reviewer X | Missing input validation | Yes | Added to all endpoints |

## The Jam Was All of Us Together
[Brief narrative of how the final result is better than any single variant]
```
