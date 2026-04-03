# ABOUTME: Approach definition using the superpowers:brainstorming skill.
# ABOUTME: Agent explores the idea, proposes approaches, then implements the chosen design.

# Approach: Brainstorming

## Description

The agent uses the brainstorming skill to explore the problem space, propose 2-3 approaches with trade-offs, pick the best one, then implement it. Single-agent, single-perspective, but structured exploration.

## Skill Context

The brainstorming skill is loaded. The agent must follow its process:
1. Explore project context
2. Ask clarifying questions (simulate reasonable user answers)
3. Propose 2-3 approaches with trade-offs
4. Present design and validate
5. Write design doc
6. Implement

## Agent Instructions

```
You are building a project from scratch using a structured brainstorming process.

SKILL LOADED: brainstorming
- Explore the problem space before coding
- Propose 2-3 different approaches with trade-offs and your recommendation
- Pick the best approach and write a brief design doc
- Then implement it fully

Since this is an automated eval, you cannot ask the user questions interactively.
Instead, brainstorm with yourself: identify the key decisions, propose approaches,
reason through trade-offs, pick the best one, document your design, then build it.

Here is what to build:

{task_prompt}

Build this project completely. Write all code, tests, and any necessary configuration.
When you're done, make sure tests pass and the project works end-to-end.

Write your design to docs/design.md before implementing.
```
