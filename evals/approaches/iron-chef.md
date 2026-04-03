# ABOUTME: Approach definition using the iron-chef skill.
# ABOUTME: Diverse panels generate approaches AND evaluate, then synthesizes learnings into winner.

# Approach: Iron Chef

## Agent Instructions

```
You are building a project using the Iron Chef parallel exploration approach.

PROCESS — follow these phases exactly:

PHASE 1 - CONTEXT & SLOTS:
Analyze the task. Identify 2-3 architectural slots — decisions where multiple
approaches are genuinely viable.

PHASE 2 - DIVERSE PERSPECTIVE PANEL:
Generate 4-5 personas with genuinely different worldviews about this problem.
Rules:
- Each persona must have a DIFFERENT optimization function
- Span beyond developer archetypes: include end-users, operators, stakeholders
- Each needs: name, 1-2 sentence worldview, what they optimize for

Then dispatch each persona as an independent subagent (all in a SINGLE message,
run_in_background: true). Each agent receives:
- Their persona
- The problem description and architectural slots
- Instruction to propose their preferred approach with reasoning
- NO visibility into other agents' proposals

After all return, synthesize proposals into 3-4 distinct variants. Name each
by its core philosophy. Write docs/panel/personas.md and docs/panel/proposals.md.

PHASE 3 - PARALLEL IMPLEMENTATION:
Implement EACH variant in its own subdirectory: variants/<slug>/
- Each variant must have working code and tests
- Follow TDD
- Dispatch implementation agents in a SINGLE message if possible

PHASE 4 - REVIEW PANEL EVALUATION:
Generate a domain-specific review panel (3-4 reviewers with different evaluation
angles — NOT just code quality). Dispatch each reviewer to evaluate ALL variants.

Each reviewer reports:
- Findings ranked by severity
- What each variant does WELL (critical for synthesis)
- What each variant does POORLY

Consolidate into a cross-variant comparison. Pick a winner.
Write docs/evaluation.md.

PHASE 5 - SYNTHESIS:
Go through every strength from losing variants:
- Can it improve the winner without contradicting its philosophy?
- For each YES: implement the improvement in the winning variant
- For each NO: document why not

Copy the synthesized winner to the project root.
Write docs/result.md including the synthesis table.

PHASE 6 - VERIFY:
Run all tests on the final synthesized result. Confirm everything works.

Here is what to build:

{task_prompt}

Follow ALL phases. The final result should be better than any single variant
because it incorporates the best insights from every approach.
```
