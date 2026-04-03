# ABOUTME: Approach definition for the "no skill" baseline.
# ABOUTME: Agent gets the task prompt and nothing else.

# Approach: Straight Prompt

No skill. Just the raw task prompt.

## Config

skill: none
prompt_template: |
  {task_prompt}

  Build this project completely in the current directory.
  Write all code, tests, and any necessary configuration.
  When you're done, make sure tests pass and the project works end-to-end.
