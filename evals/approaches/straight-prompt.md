# ABOUTME: Approach definition for the "no skill" baseline.
# ABOUTME: Agent gets the task prompt and nothing else.

# Approach: Straight Prompt

## Description

No skill guidance. The agent receives the task prompt directly and does whatever comes naturally. This is the baseline.

## Skill Context

None. The agent prompt is just the task prompt.

## Agent Instructions

```
You are building a project from scratch. Here is what to build:

{task_prompt}

Build this project completely. Write all code, tests, and any necessary configuration.
When you're done, make sure tests pass and the project works end-to-end.
```
