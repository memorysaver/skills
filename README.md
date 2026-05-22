# memorysaver/skills

Personal agent skills by [memorysaver](https://github.com/memorysaver) — installable in any
[Agent Skills](https://agentskills.io/home)-compatible client.

## Install

### Via `npx skills` (Claude Code, Cursor, Codex, Continue, etc.)

Uses the [vercel-labs/skills](https://github.com/vercel-labs/skills) CLI:

```bash
# Install all skills from this repo into the current project
npx skills@latest add memorysaver/skills

# Install a specific skill
npx skills@latest add memorysaver/skills --skill example-skill

# Install globally (user scope)
npx skills@latest add memorysaver/skills --global
```

### Via Claude Code plugin marketplace

```text
/plugin marketplace add memorysaver/skills
/plugin install project-scaffold@memorysaver-skills
```

## What's in here

### Project Scaffold

Skills for setting up and aligning project-level agent layouts across Claude
Code, Codex, Pi Agent, and other agents.md-compatible workflows.

| Skill | Description |
|-------|-------------|
| [`canonical-project-skills-layout`](./skills/project-scaffold/canonical-project-skills-layout) | Converges a project to one shared agent layout: `skills/` as the source of truth, `.claude/skills` and `.agents/skills` symlinked into it, `AGENTS.md` as the canonical guide, and `CLAUDE.md` as an `@AGENTS.md` import. Includes an idempotent migration script with dry-run support. |
| [`project-behavior`](./skills/project-scaffold/project-behavior) | Creates or updates `AGENTS.md` with reusable behavior packs that define how agents should work in a project. The bundled default is a Karpathy-style coding-discipline preamble focused on thinking before coding, simplicity, surgical changes, and verification. |

### Memory

Skills for capturing project knowledge, retrieving prior lessons, and turning
recurring lessons into reusable skills.

| Skill | Description |
|-------|-------------|
| [`project-memory`](./skills/memory/project-memory) | Bootstraps and maintains a git-committable `project-memory/` system for session lessons, retrospectives, notable moments, and semantic recall. It uses bundled scripts for bootstrap, session start, moment capture, wrap-up, and qmd-backed querying with fallback reads when qmd is unavailable. |
| [`memory-forge`](./skills/memory/memory-forge) | Distills accumulated `project-memory/` lessons into reusable, agent-loadable skills. It selects older lessons, clusters recurring themes, detects the host project's skill-loading path, writes or updates class-level skills, and protects hand-edited generated skills from being overwritten. |

## Layout

```
.claude-plugin/marketplace.json   # Claude Code plugin manifest
skills/<group>/<skill-name>/SKILL.md
.claude/skills/<skill-name>       # symlink to grouped source skill
.agents/skills/<skill-name>       # symlink to grouped source skill
scripts/link-skills.sh            # regenerates discovery symlinks
AGENTS.md                         # repo guide for contributing agents
```

See [`AGENTS.md`](./AGENTS.md) for how to add a skill.

## License

[MIT](./LICENSE)
