# Fresh Eyes Review Comment Template

**This is the SINGLE SOURCE OF TRUTH for Fresh Eyes Review comments.**

When posting Fresh Eyes Review findings to a PR, use this exact format:

```markdown
## Fresh Eyes Review

Reviewer: Claude (fresh context agent)
Model: [MODEL_ID]

**Workflow:** [Code Review Loop](REPO_URL/blob/[COMMIT_SHA]/CLAUDE.md#critical-rules)
**Persona:** [Fresh Eyes Reviewer](REPO_URL/blob/[COMMIT_SHA]/.claude/reference/personas/fresh-eyes-reviewer.md)

### Summary

[One paragraph: Overall assessment from a fresh perspective. Is this ready to merge? Risk level?]

### Findings

[FINDINGS - either specific issues or "No P1/P2/P3 issues identified."]

**P1 - Blocking Issues**
[Security vulnerabilities, correctness bugs - or "None"]

**P2 - Serious Issues**
[Logic errors, missing validation - or "None"]

**P3 - Quality Issues**
[Edge cases, maintainability - or "None"]

### Positive Notes

[Good patterns, clean code, thoughtful handling observed]

### Verification Checklist
- [x] Security (secrets, injection, auth bypass)
- [x] Correctness (logic errors, null refs, race conditions)
- [x] Logic flow (control flow, state transitions, algorithms)
- [x] User impact (functionality, performance)
- [x] Best practices (error handling, architecture)

### Status

[STATUS - choose one:]
- Ready to merge - No blocking issues
- Needs changes - P1/P2 issues found, see above
- Re-review needed - After fixes are applied

---
*Fresh Eyes Review via [Claude Code](https://claude.com/claude-code)*
```

## Template Variables

| Variable | Source | Example |
|----------|--------|---------|
| MODEL_ID | The model used for the fresh context agent | claude-sonnet-4-20250514 |
| COMMIT_SHA | `git rev-parse HEAD` on the branch | bce8e0a |
| REPO_URL | From CLAUDE.md § GitHub Repository | https://github.com/owner/repo |
| FINDINGS | Agent output categorized by severity | P1/P2/P3 issues or "None" |
| STATUS | Based on findings | One of the three options above |

**Why use commit SHA?** Links with `/blob/main/` always show the latest version. Using the commit SHA ensures the links point to the exact workflow/persona version that was in effect when the review was conducted.

**Why checked boxes?** By the time you post, you've verified these areas. The checkboxes confirm verification was done.
