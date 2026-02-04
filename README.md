# claude-workflow

An AI-assisted development workflow framework for [Claude Code](https://claude.com/claude-code).

Provides slash commands, safety hooks, review personas, and guides that enable an autonomous development loop: **pick issue → implement → review → ship → repeat**.

## What's Included

```
.claude/
├── commands/            # 10 slash commands
│   ├── ship.md          # Full PR workflow (review → PR → merge)
│   ├── self-review.md   # Self-review with senior developer checklist
│   ├── create-pr.md     # Create PR with lean template
│   ├── merge-pr.md      # Squash merge and cleanup
│   ├── verify-pr-ready.md
│   ├── post-fresh-eyes-review.md  # Independent review via fresh agent
│   ├── create-deferred-issues.md  # Capture deferred items as issues
│   ├── next-issue.md    # Auto-select highest priority issue
│   ├── block-issue.md   # Mark blocked, move to next
│   └── prioritize.md    # Release planning
├── reference/
│   ├── hooks/           # 5 safety hooks (Python 3.10+)
│   │   ├── bash-safety.py          # Block push to main, force push, dangerous ops
│   │   ├── security-check.py       # Block hardcoded secrets, SQL injection
│   │   ├── validate-pr-template.py # Enforce PR template sections
│   │   ├── validate-self-review.py # Warn on incomplete self-review
│   │   └── require-fresh-eyes-review.py  # Block merge without review
│   ├── guides/
│   │   ├── git-workflow.md          # Branch naming, commits, PR process
│   │   └── acceptance-criteria.md   # GIVEN/WHEN/THEN format
│   ├── personas/
│   │   ├── senior-developer.md      # Self-review persona
│   │   └── fresh-eyes-reviewer.md   # Independent review persona
│   └── templates/
│       └── fresh-eyes-review-comment.md  # PR comment template
├── developer/
│   ├── README.md        # The autonomous loop explained
│   └── commands.md      # Command reference
├── README.md            # Framework overview
└── settings.local.json  # Hook config + permissions
```

## Prerequisites

- **Python 3.10+** (hooks use `str | None` union syntax)
- **GitHub CLI** (`gh`) — or equivalent SCM CLI
- **Claude Code** — the CLI tool from Anthropic

## Installation

1. Copy the `.claude/` directory into your project root
2. Copy `CLAUDE.md.template` to `CLAUDE.md` and fill in project-specific sections
3. Adjust `.claude/settings.local.json` permissions for your project (add project-specific MCP servers, domain-specific WebFetch, etc.)
4. Verify hooks work: Python 3.10+ and `gh` CLI available

## CLAUDE.md Convention

The framework commands reference standardized sections in your project's `CLAUDE.md`. These headings are expected:

| Section | Used By | Required? |
|---------|---------|-----------|
| `## GitHub Repository` | `/create-pr`, `/merge-pr`, `/verify-pr-ready` | Yes |
| `## Build Commands` | `/self-review`, `/ship` | Yes |
| `## Critical Rules` | `/self-review` (architecture checklist) | Yes |
| `## Architecture` | Personas (project context) | Yes |
| `## Testing Guidelines` | `/self-review` (test appropriateness) | Recommended |
| `## Autonomous Work Mode` | `/next-issue` | Optional |

See `CLAUDE.md.template` for the full template.

## The Workflow

```
/next-issue → implement → /ship → /next-issue → ...
```

`/ship` orchestrates: `/self-review` → `/create-pr` → `/post-fresh-eyes-review` → `/create-deferred-issues` → `/verify-pr-ready` → `/merge-pr`

## Hooks

All hooks are pre-configured in `settings.local.json` with both Bash and MCP matchers:

| Hook | Trigger | Action |
|------|---------|--------|
| bash-safety | Every Bash command | Blocks push to main, force push, dangerous ops |
| security-check | Every Write/Edit | Blocks hardcoded secrets, SQL injection |
| validate-pr-template | PR creation (Bash + MCP) | Blocks incomplete PR template |
| validate-self-review | Post Write/Edit/Bash | Warns on incomplete self-review |
| require-fresh-eyes-review | PR merge (Bash + MCP) | Blocks merge without independent review |

## Optional Enhancements

These Claude Code plugins enhance the workflow but are not required:

- **commit-commands** — `/commit`, `/commit-push-pr`, `/clean_gone`
- **pr-review-toolkit** — Specialized code review agents
- **hookify** — Dynamic hook management
- **feature-dev** — Guided feature development

## Origin

Generalized from a production workflow used to build [GroupChat](https://github.com/alexperry0/GroupChat), a Blazor/.NET 9 web application developed almost entirely by AI agents.
