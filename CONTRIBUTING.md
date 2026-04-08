# Contributing to Jam

Thanks for your interest in improving Jam.

## Ground rules

- **`skills/jam/SKILL.md` is the source of truth** for the Jam workflow. If you're changing behavior, edit that file. `CLAUDE.md`, `AGENTS.md`, and `README.md` are summaries — keep them in sync.
- **Smallest reasonable changes.** Don't bundle unrelated refactors with behavior changes.
- **Match surrounding style.** Consistency within a file matters more than any external style guide.
- **Evergreen naming.** No "new", "improved", "v2" in identifiers or filenames.
- **No mock modes.** Jam runs against real panels and real code — don't introduce fake-data paths for "testing."

## Development setup

Jam is a Claude Code plugin. To work on it locally, load it as a dev plugin:

```bash
claude --plugin-dir /path/to/jam
```

Then invoke it with "jam on X" against a throwaway test task to see your changes in action.

## Testing changes to the workflow

The `evals/` directory contains a harness that runs representative tasks against multiple approaches (plain Claude, brainstorming, test-kitchen, jam) and compares outputs.

```bash
./evals/run-eval.sh
```

Results land in `evals/results/<timestamp>/` (gitignored). Compare before/after runs when making substantive changes to the workflow.

## Pull requests

- Describe the motivation — what problem is this solving?
- If you changed the workflow, mention whether you ran the evals and what the results looked like.
- Keep PRs focused. Docs-only, behavior, and tooling changes should usually be separate PRs.

## Reporting issues

Open a GitHub issue with:

- What you asked Jam to do
- What actually happened
- What you expected instead
- Enough context to reproduce (skill version, Claude Code version, sanitized prompts)
