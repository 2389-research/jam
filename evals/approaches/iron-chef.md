# ABOUTME: Approach definition using the iron-chef skill.
# ABOUTME: Agent invokes the real iron-chef skill with diverse panels + synthesis.

# Approach: Iron Chef

Uses the real iron-chef:iron-chef skill via slash command invocation.
Loaded via --plugin-dir pointing to the local plugin directory.

## Config

skill: /iron-chef:iron-chef
plugin_dir: .
prompt_template: |
  /iron-chef:iron-chef

  {task_prompt}

  Since this is an automated eval with no interactive user, make reasonable
  decisions where the user would normally provide input. Approve panels,
  variants, and synthesis plans yourself and continue through all phases.

  Follow ALL Iron Chef phases: diverse perspective panel for slot generation,
  parallel implementation, review panel evaluation, and synthesis of best
  insights into the winner.

  The final synthesized winner should be the final state of the project
  in the current directory.
