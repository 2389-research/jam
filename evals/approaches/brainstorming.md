# ABOUTME: Approach definition using the superpowers:brainstorming skill.
# ABOUTME: Agent invokes the real brainstorming skill, then implements.

# Approach: Brainstorming

Uses the real superpowers:brainstorming skill via slash command invocation.

## Config

skill: /superpowers:brainstorming
prompt_template: |
  /superpowers:brainstorming

  {task_prompt}

  Since this is an automated eval with no interactive user, when the skill asks
  you to get user approval, approve your own designs and continue. Make reasonable
  decisions where the user would normally provide input.

  Build this project completely in the current directory.
  Write all code, tests, and any necessary configuration.
  When you're done, make sure tests pass and the project works end-to-end.
