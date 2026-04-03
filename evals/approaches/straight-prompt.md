# ABOUTME: Approach definition for the "no skill" baseline.
# ABOUTME: Agent gets the task prompt and nothing else.

# Approach: Straight Prompt

No skill. Just the raw task prompt.

## Config

skill: none
disable_skills: true
prompt_template: |
  {task_prompt}

  Do NOT brainstorm, ask questions, or present options. Just build it.
  Make your own architectural decisions and start writing code immediately.
  Build this project completely in the current directory.
  Write all code, tests, and any necessary configuration.
  When you're done, make sure tests pass and the project works end-to-end.
