# ABOUTME: Approach definition using the jam skill.
# ABOUTME: Agent invokes the real jam skill with diverse panels + synthesis.

# Approach: Jam

Uses the real jam:jam skill via slash command invocation.
Loaded via --plugin-dir pointing to the local plugin directory.

## Config

skill: /jam:jam
plugin_dir: .
prompt_template: |
  /jam:jam

  {task_prompt}

  Since this is an automated eval with no interactive user, make reasonable
  decisions where the user would normally provide input. Approve panels,
  variants, and synthesis plans yourself and continue through all phases.

  Follow ALL Jam phases: diverse perspective panel for slot generation,
  parallel implementation, review panel evaluation, and synthesis of best
  insights into the winner.

  The final synthesized winner should be the final state of the project
  in the current directory.
