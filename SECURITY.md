# Security Policy

## Reporting a vulnerability

If you find a security issue in Jam — for example, a skill instruction that could cause an agent to exfiltrate data, execute unintended commands, or bypass user approval gates — please report it privately.

**Preferred:** Open a [private security advisory](https://github.com/2389-research/jam/security/advisories/new) on GitHub.

**Alternative:** Email the maintainers at `security@2389.ai` with:

- A description of the issue
- Steps to reproduce
- The impact you're concerned about
- Any suggested mitigations

Please do not open a public issue for security problems.

## Scope

Jam is a Claude Code plugin consisting of skill documentation (Markdown) and an eval harness (shell scripts). The primary security considerations are:

- **Prompt injection** — skill content that could be manipulated to cause unintended agent behavior
- **Command execution** — shell snippets in skills or eval scripts that run without proper user consent
- **Approval gate bypass** — anything that causes the workflow to skip user confirmation steps

Out of scope:

- Vulnerabilities in Claude Code itself (report those to Anthropic)
- Vulnerabilities in third-party tools invoked by the eval harness
