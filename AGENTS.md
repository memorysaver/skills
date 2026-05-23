# Agent behavioral guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

# memorysaver/skills

Personal collection of agent skills, distributed two ways from one repo.

## Project Memory Autopilot

Use the `project-memory` skill proactively. Trigger it for substantive repo
work, not only when the user says "memory".

- Start a session before multi-step implementation, debugging, refactoring,
  design, or tool-heavy work. Use `mode=session` by default; use `mode=spec`
  only when implementing a written spec.
- Bootstrap first if `project-memory/_CONTEXT.md` is missing and the user wants
  ongoing project memory.
- Query memory before re-solving something that sounds recurring: similar bug,
  prior decision, repeated workflow, or "have we seen this before".
- Capture notable moments during work: user steering, skill/tool misfires,
  surprising wins or failures, and durable rules.
- Wrap up active sessions before final handoff, unless the task was trivial.
  Follow the `memory-forge` handoff when enough lessons have accumulated.

## Layout

```
skills/<group>/<skill-name>/SKILL.md   # source of truth (grouped by plugin)
.claude-plugin/marketplace.json        # Claude Code plugin manifest
.claude/skills/<skill-name>            # symlink → ../../skills/<group>/<skill-name>
.agents/skills/<skill-name>            # symlink → ../../skills/<group>/<skill-name>
scripts/link-skills.sh                 # regenerates the per-skill symlinks
```

Skills are organized under group folders that mirror the `plugins[]` entries in
`marketplace.json`. The discovery surfaces (`.claude/skills/` and
`.agents/skills/`) hold flat per-skill symlinks pointing back into the grouped
source tree, so Claude Code and other agents.md-spec scanners — which read only
the first level of `.claude/skills/<skill>/SKILL.md` — can find every skill
without the source tree being flat.

Each `SKILL.md` is YAML frontmatter (`name`, `description`) followed by markdown
instructions the agent will execute when the skill triggers.

## Adding a new skill

1. Create `skills/<group>/<skill-name>/SKILL.md` with valid frontmatter. Use an
   existing `<group>` or introduce a new one (groups map to plugin names).
2. Add `./skills/<group>/<skill-name>` to the `skills` array of the matching
   plugin entry in `.claude-plugin/marketplace.json`, or add a new plugin entry
   for a new group.
3. Run `bash scripts/link-skills.sh` to regenerate the per-skill symlinks under
   `.claude/skills/` and `.agents/skills/`. The script is idempotent and
   git-aware; commit its output alongside the new skill.
4. Bump `metadata.version` in `marketplace.json` if it's a meaningful change.

Skill leaf names must be unique across all groups — they collapse to a flat
namespace at the discovery surface, so two groups can't both contain a
`foo/`. `scripts/link-skills.sh` refuses on collisions.

## Distribution

- **npx CLI**: discoverable by [vercel-labs/skills](https://github.com/vercel-labs/skills).
  Users run `npx skills@latest add memorysaver/skills` to install.
- **Claude Code plugin**: `marketplace.json` registers the repo as a plugin
  marketplace. Users run `/plugin marketplace add memorysaver/skills` then
  `/plugin install <group>@memorysaver-skills`.

Both consumers read the same `skills/<group>/<name>/SKILL.md` files — no
duplication.

## Note on canonical-skills

This layout deliberately deviates from the
[`canonical-skills`](https://github.com/memorysaver/dotfiles) single-symlink
invariant (`.claude/skills → ../skills`). The canonical pattern is correct for
projects with a flat skills tree, but this repo's source tree is grouped to
mirror the plugin manifest. A passthrough symlink would hide every skill from
project-local first-layer scanners, so we use per-skill symlinks instead. The
trade-off is intentional and is regenerated mechanically by
`scripts/link-skills.sh`; never hand-edit the discovery symlinks.

## Spec

Skills follow the open [Agent Skills spec](https://agentskills.io/home).
