# ABOUTME: Approach definition using test-kitchen's omakase-off skill.
# ABOUTME: Agent invokes the real omakase-off skill for parallel exploration.

# Approach: Omakase

Uses the real test-kitchen:omakase-off skill via slash command invocation.

## Config

skill: /test-kitchen:omakase-off
prompt_template: |
  /test-kitchen:omakase-off

  {task_prompt}

  When offered the choice between brainstorming and omakase, choose omakase.
  Since this is an automated eval with no interactive user, make reasonable
  decisions where the user would normally provide input. Approve panels and
  designs yourself and continue through all phases.

  Build ALL variants completely with working code and passing tests.
  Evaluate and pick a winner. The winning implementation should be the
  final state of the project in the current directory.
