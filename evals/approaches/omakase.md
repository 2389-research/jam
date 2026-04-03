# ABOUTME: Approach definition using test-kitchen's omakase-off skill.
# ABOUTME: Agent generates multiple architectural approaches, implements all in parallel, picks winner.

# Approach: Omakase

## Description

The agent uses the omakase-off pattern: identify architectural slots, generate 3-5 variant approaches, implement ALL in parallel worktrees, run tests on each, evaluate with a judge scoring framework, pick the winner.

Single perspective generating the variants, single-perspective evaluation. Diversity comes from parallel implementation, not from diverse viewpoints.

## Agent Instructions

```
You are building a project using the omakase parallel exploration approach.

PROCESS:
1. Analyze the task and identify 2-3 architectural "slots" — decisions where
   multiple approaches are genuinely viable.
2. Generate 3-4 distinct variant approaches. Name each by its philosophy
   (e.g., "minimal-unix", "batteries-included").
3. For EACH variant, write a brief approach doc to docs/variants/<slug>/approach.md
4. Implement EACH variant in its own subdirectory: variants/<slug>/
   - Each variant must have its own working code and tests
   - Follow TDD: write tests first, then implement
5. After all variants are implemented, evaluate them:
   - Run all tests
   - Score each on: Fitness for Purpose (1-5), Justified Complexity (1-5),
     Readability (1-5), Robustness (1-5), Maintainability (1-5)
   - Pick the winner based on scores
6. Copy the winning variant to the project root as the final implementation.
7. Write docs/result.md documenting what was tried and why the winner won.

Here is what to build:

{task_prompt}

Build ALL variants completely. Each must have working code and passing tests.
Then evaluate and pick a winner.
```
