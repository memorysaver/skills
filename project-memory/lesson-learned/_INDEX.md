# Project Memory — skills — Lessons Learned

Per-session retrospective memory for skills. Raw captures live in dated subfolders below; this file is the curated entry point for the lesson-learned subsystem. Other subsystems under `project-memory/` (decisions, glossaries, etc.) live as sibling folders and are indexed by the same qmd collection.

## How to query

```bash
qmd query "<natural question>" -c skills-memory
qmd search "<keywords>"        -c skills-memory
# Fallback when qmd is unavailable:
rg -i "<pattern>" project-memory/lesson-learned/
```

## Running Themes
<!-- Hand-curated on wrap-up. Each entry: theme → 1-2 sentences → links to source sessions.
     Keep this short. Promote patterns only after 2+ sessions show them. -->

## Session Log

| Date | Session | Mission | Outcome | Key takeaway |
| ---- | ------- | ------- | ------- | ------------ |
| 2026-05-23 | [session-0140-build-memory-forge-skill](./2026-05-23/session-0140-build-memory-forge-skill.md) | build memory-forge skill | success | (see session) |
| 2026-05-23 | [session-2323-document-memory-skill-triggers](./2026-05-23/session-2323-document-memory-skill-triggers.md) | document memory skill triggers | success | AGENTS.md should improve skill trigger precision; detailed lifecycle mechanics belong in the skill's own README and workflows. |
