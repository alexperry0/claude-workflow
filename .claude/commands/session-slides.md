---
description: Summarize the current Claude Code session's learning into a self-contained HTML slide deck
---

# Session Slides (Learning Deck Generator)

**Turn the session you just completed — brainstorm → plan → implementation — into a
self-contained HTML slide deck that captures what was learned and experienced, for later
reference.**

This is a four-phase **Opus 4.8 multi-agent** workflow. It deliberately fans out to
parallel subagents to harvest the session, then synthesizes, builds, and independently
verifies the deck.

## Model & effort

- Default model: **`claude-opus-4-8`** — the most capable model currently available.
  (Claude Fable 5 / Mythos 5 were disabled June 2026 by a US government export-control
  directive; if they return, they become the preferred ceiling. Until then, Opus 4.8.)
- Run **harvest** subagents at low/medium effort (cheap, parallel) and **synthesis +
  build** at high/xhigh effort (quality matters there).

## Inputs this skill mines

- The **current conversation** (the session itself) — primary source for the "experience".
- The **archived plan** in `.claude/plans/` (if plan mode was used).
- The **git diff and commits** made during the session (`git diff main...HEAD`, `git log`).
- Any **brainstorm notes** produced during the session.

## Output

A single self-contained `.html` file (embedded CSS/JS, zero external dependencies, keyboard
nav, works offline) written to **`docs/session-decks/<YYYY-MM-DD>-<slug>.html`**, built
from `.claude/templates/learning-deck.html`. Decks are committed to the repo.

---

## Workflow

Execute the phases in order. State the goal up front to each subagent and instruct it to
work autonomously — **do not** ask the user mid-run for confirmation on routine choices.

### Phase 1 — Harvest (parallel fan-out)

Spawn **five `learning-harvester` subagents in a single message** so they run concurrently.
Opus 4.8 is conservative about delegating, so this fan-out is explicit and required — do not
collapse it into one pass. Give each subagent **one** lens plus full context:

| # | Lens |
|---|------|
| 1 | Problem & context |
| 2 | Decisions & rationale |
| 3 | Techniques used |
| 4 | Pitfalls & surprises |
| 5 | Outcomes & verification |

For each Task invocation include:
- `subagent_type: learning-harvester`
- **LENS**: the assigned lens
- **SESSION CONTEXT**: a faithful summary/excerpt of this conversation (you have it — pass
  enough that the subagent can work without seeing the live chat)
- **ARTIFACTS**: tell it to inspect `.claude/plans/`, `git diff main...HEAD` (fall back to
  `git diff` / `git diff --staged` if no main divergence), `git log`, and changed files

Collect the five structured digests.

### Phase 2 — Synthesize (orchestrator, high effort)

Merge the digests into a **deck spec** — an ordered list of slides. Aim for **10-16 slides**:

1. **Title** — what the session was about + one-line subtitle.
2. **Section: The problem** → 1-2 content slides from lens 1.
3. **Section: The approach** → decisions/rationale (lens 2) + techniques (lens 3), including
   1 code slide if there's a genuinely instructive snippet.
4. **Section: The experience** → pitfalls & surprises (lens 4); use a quote slide for the
   single best insight or dead-end.
5. **Section: Outcome** → what shipped + verification (lens 5).
6. **Takeaways** — "what I'd carry forward" recap (3-5 points).

Rules:
- Every slide bullet must trace to a harvester's Evidence. Drop anything unsupported —
  **accuracy over polish**. This deck is a memory aid; a fabricated lesson is worse than a
  missing one.
- 4-6 bullets per content slide; split if longer.
- Pick the strongest Highlight across lenses for the quote slide and the code slide.

### Phase 3 — Build

1. Determine the date (`YYYY-MM-DD`) and a short kebab-case `slug` from the session topic.
2. Copy `.claude/templates/learning-deck.html` to `docs/session-decks/<date>-<slug>.html`.
3. Fill the `<head>` title token and the title slide tokens (`{{DECK_TITLE}}`,
   `{{DECK_SUBTITLE}}`, `{{SESSION_DATE}}`, `{{MODEL}}` = `Claude Opus 4.8`).
4. Replace everything between `<!-- SLIDES:START -->` and `<!-- SLIDES:END -->` with the
   generated `<section class="slide">` blocks per the deck spec, using the slide-type
   patterns documented in the template.
5. **Do not touch the CSS or JS** — they must stay inline and dependency-free.
6. **Escape `<`, `>`, `&`** inside any code slide content.

### Phase 4 — Fresh-eyes verify

Spawn **one verifier subagent with no session context** (`subagent_type: Explore` or
`general-purpose`). Per Opus 4.8, a fresh-context verifier outperforms self-critique. Give it:
- the generated HTML file path and the five harvester digests
- instruction: "You did not attend this session. Check each slide's claims against the
  digests. Flag any slide bullet not supported by a digest, any factual drift, broken HTML,
  or unescaped code. Also give a one-line UX read on readability. Report P1 (must fix) /
  P2 / P3."

Fix any P1/P2 findings, then re-open the file to confirm it's valid.

### Phase 5 — Report

Tell the user:
- the deck path,
- slide count and section outline,
- any P1/P2 issues the verifier raised and how they were resolved,
- a one-line note that the deck is offline-portable.

Offer to open/preview it. Commit only if the user asks (per CLAUDE.md: never push to main;
deck commits go through the normal branch/PR flow).

## Usage

```
/session-slides
```

No arguments. Optionally pass a focus hint, e.g. `/session-slides focus on the architecture decisions`.
