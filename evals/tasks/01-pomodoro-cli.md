# ABOUTME: Eval task definition for a pomodoro timer CLI tool.
# ABOUTME: Tests architectural decisions around storage, interface, and notification design.

# Task: Pomodoro CLI Timer

## The Prompt

Build a pomodoro timer CLI tool in Python. It should:
- Let users start a 25-minute work session followed by a 5-minute break
- Track completed pomodoros across sessions (persistent)
- Show daily/weekly stats
- Notify the user when a session ends

That's it. Keep it simple. Make your own decisions on architecture.

## Why This Task

This task has genuine architectural slots:
- **Storage**: SQLite vs JSON file vs plain text log
- **Interface**: Rich TUI (textual/rich) vs simple CLI commands vs hybrid
- **Notifications**: System notifications (OS-level) vs terminal bell vs visual in-terminal
- **Timer approach**: Blocking foreground process vs background daemon vs polling

These choices interact — a TUI implies foreground blocking, a daemon implies CLI commands to check status, etc.

## Acceptance Criteria

The output must be:
1. A working Python project that can be installed/run
2. Tests that pass
3. A user can actually start a pomodoro, see it count down, get notified, and check stats

## Evaluation Dimensions

| Dimension | What to look for |
|-----------|-----------------|
| **Functionality** | Does it actually work end-to-end? Can a user do all the things? |
| **Architecture quality** | Is the design coherent? Do the choices reinforce each other? |
| **Approach creativity** | Did the process surface non-obvious approaches? |
| **User experience** | Is it pleasant to use? Would a real person choose this over alternatives? |
| **Code quality** | Clean, readable, maintainable, well-tested? |
| **Robustness** | Error handling, edge cases (timer interrupted, disk full, etc.)? |
