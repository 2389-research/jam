# Agent Guide: Jam

This file is for AI coding agents (Claude Code, Cursor, Aider, Codex, etc.) working in this repository.

## What this repo is

Jam is a [Claude Code](https://claude.com/claude-code) plugin that implements a parallel exploration workflow: diverse perspective panels propose approaches, variants are built in parallel, a review panel evaluates them, and the best insights from all variants are synthesized into the winner.

The canonical agent-facing documentation lives in [`CLAUDE.md`](./CLAUDE.md). If you're Claude Code, that file is loaded automatically. If you're another agent, read it — everything there applies to you too.

## The skill

The workflow is implemented as a Claude Code skill at `skills/jam/SKILL.md`. That file is the authoritative specification of the Jam workflow: phases, panel dispatch patterns, synthesis rules, common mistakes, red flags.

**If you are modifying the workflow, edit `skills/jam/SKILL.md`.** The `CLAUDE.md` and `README.md` are summaries — keep them in sync but treat `SKILL.md` as the source of truth.

## Triggering

Jam should activate on:

- "jam on X" / "let's jam" / "can we jam on" / "jam session"
- Generic build/create/implement requests where approaches vary
- User indecision signals ("not sure", "either works", "you pick")
- Explicit requests for diverse approaches or parallel exploration

Do **not** activate Jam for:

- Trivial edits, renames, config tweaks
- Tasks where the user has already specified the approach
- Single-path problems with no meaningful alternatives

## Editing conventions

- Match the surrounding style. Be consistent within a file.
- Smallest reasonable changes. Don't rewrite unless explicitly asked.
- Source files start with two `ABOUTME:` comment lines.
- Never introduce mock modes or fake data — evals and examples use real behavior.
- Keep evergreen naming. No "new", "improved", "v2" in identifiers.

## Layout

```
.claude-plugin/plugin.json   Plugin manifest
CLAUDE.md                    Agent-facing plugin guide (Claude Code auto-loads)
README.md                    Human-facing docs
AGENTS.md                    This file
skills/
  SKILL.md                   Router skill (points at jam:jam)
  jam/SKILL.md               The full Jam workflow (source of truth)
evals/                       Comparative eval harness
  approaches/                One file per approach being compared
  tasks/                     Task definitions
  rubric.md                  Scoring rubric
  run-eval.sh                Entry point
```

## Running the evals

```bash
./evals/run-eval.sh
```

Results land in `evals/results/<timestamp>/` (gitignored).
