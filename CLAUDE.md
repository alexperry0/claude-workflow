# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

**Hierarchy**: This file is authoritative. Guide files (`.claude/reference/guides/*.md`) elaborate but never contradict. If there's a conflict, this file wins.

---

## Quick Start (Read This First)

**For most tasks, you need these 3 things:**

1. **Don't push to main** - All changes go through Pull Requests.
2. **Test appropriately** - Bug fix → regression test. New logic → unit test. Trivial → none.
3. **Workflow**: `Write code → Commit locally → /ship`

**Don't push to main. Don't skip self-review.**

---

## Critical Rules

### 1. NEVER PUSH DIRECTLY TO MAIN
All changes must go through a Pull Request. Before ANY `git push`, verify: `git branch --show-current` must NOT be "main".

### 2. ALWAYS FOLLOW THE WORKFLOW
```
Write code → Commit locally → /self-review → Fix if needed → Push → /create-pr → /post-fresh-eyes-review → /create-deferred-issues → /verify-pr-ready → /merge-pr
```
Or use `/ship` to run the full workflow. Self-review happens AFTER local commit, BEFORE push.

### 3. TEST APPROPRIATELY
Every meaningful code change needs tests appropriate to the change:

| Change Type | Test Required |
|-------------|---------------|
| Bug fix | Regression test proving fix |
| New logic | Unit test |
| Service method | Unit + integration |
| UI component | UI test |
| Trivial (typo, formatting) | None |

For this framework repo, validation is done by running hooks against sample inputs (no test framework).

---

## GitHub Repository

**Owner:** `alexperry0`
**Repo:** `claude-workflow`
**Full path:** `alexperry0/claude-workflow`
**URL:** https://github.com/alexperry0/claude-workflow

---

## Build Commands

```bash
# Validate Python hooks compile correctly
python -m py_compile .claude/reference/hooks/bash-safety.py
python -m py_compile .claude/reference/hooks/security-check.py
python -m py_compile .claude/reference/hooks/validate-pr-template.py
python -m py_compile .claude/reference/hooks/validate-self-review.py
python -m py_compile .claude/reference/hooks/require-fresh-eyes-review.py
python -m py_compile .claude/reference/hooks/archive-plan.py
```

No test framework — validation is done by running hooks against sample inputs.

---

## Project Overview

AI-assisted development workflow framework for Claude Code. Provides a structured set of slash commands, safety hooks, review personas, and guides that enable Claude to autonomously process a GitHub issue backlog with quality gates.

## Architecture

```
.claude/
├── commands/           # Slash commands (/ship, /next-issue, /self-review, etc.)
├── reference/
│   ├── guides/         # Detailed guides (git workflow, acceptance criteria)
│   ├── hooks/          # Python safety hooks (PreToolUse/PostToolUse)
│   └── personas/       # Review personas (senior developer, fresh eyes reviewer)
├── plans/              # Archived plan files (gitignored, local working artifacts)
└── settings.local.json # Permissions, hook configuration
```

- **Commands** are markdown files that define multi-step workflows Claude follows
- **Hooks** are Python scripts that enforce safety rules (block push to main, validate PR templates, require reviews)
- **Personas** define review perspectives for self-review and independent review
- **Guides** provide detailed reference for git workflow and acceptance criteria standards

The framework follows a "trust but verify" model: Claude works autonomously but hooks enforce critical safety gates.

---

## Autonomous Work Mode

```
/next-issue -> implement -> /ship -> repeat
```

`/next-issue` auto-selects highest priority open issue (critical > high > medium > low), creates branch, begins work.

## Detailed Guides

These guides elaborate on rules defined above. They provide implementation details but do not override this file.

| Guide | Purpose |
|-------|---------|
| [**Git Workflow**](.claude/reference/guides/git-workflow.md) | Branching, commits, PR process |
| [**Acceptance Criteria**](.claude/reference/guides/acceptance-criteria.md) | GIVEN/WHEN/THEN format for issues |
