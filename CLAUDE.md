# Iron Chef Plugin

## Overview

Iron Chef is a parallel exploration framework that uses diverse perspective panels at two key moments: generating approaches and evaluating implementations. After picking a winner, it synthesizes the best insights from ALL variants into the final result.

**The Iron Chef was all of us together.**

## Skills

| Skill | Triggers | Description |
|-------|----------|-------------|
| `iron-chef:iron-chef` | Build/create/implement requests, "iron chef", "diverse approaches", indecision signals | Full Iron Chef workflow: diverse panels → parallel implementation → panel evaluation → synthesis |

## The Flow

```
Build/Create request
    ↓
Context & identify architectural slots
    ↓
Generate domain-specific perspective panel
    ↓
Panel agents independently propose approaches
    ↓
Synthesize into 3-5 distinct variants
    ↓
Implement all variants in parallel (worktrees)
    ↓
Generate domain-specific review panel
    ↓
Review panel evaluates ALL variants
    ↓
Pick winner based on panel findings
    ↓
Synthesize: fold best insights from ALL variants into winner
    ↓
Ship the improved winner
```

## Key Principles

1. **Real diversity, not imagined diversity.** Dispatch independent agents with different worldviews. One mind imagining perspectives is not the same as independent agents reasoning separately.

2. **Domain-specific panels.** Perspective and review panels are generated fresh for each problem. No hardcoded persona templates.

3. **Active synthesis, not a backlog.** Insights from losing variants get incorporated into the winner NOW, not documented for later.

4. **User approval at every gate.** Panels and synthesis plans are presented before execution.

## Common Mistakes

- Generating approaches from a single perspective instead of dispatching panel agents
- Using pre-defined persona templates instead of domain-specific panels
- Evaluating from one viewpoint instead of a review panel
- Picking a winner and discarding loser insights
- Noting improvements "for later" instead of synthesizing now
