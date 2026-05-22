# memorysaver/skills

Personal agent skills by [memorysaver](https://github.com/memorysaver) — installable in any
[Agent Skills](https://agentskills.io/home)-compatible client.

> Status: bare-bones scaffold. Real skills are on the way.

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

| Category | Skill | Description |
|----------|-------|-------------|
| `project-scaffold` | [`canonical-project-skills-layout`](./skills/project-scaffold/canonical-project-skills-layout) | Converge any project to a canonical layout so Claude Code, Codex, and Pi Agent share one `skills/` source and one `AGENTS.md` guide. Idempotent, with a dry-run. |

## Layout

```
.claude-plugin/marketplace.json   # Claude Code plugin manifest
skills/<skill-name>/SKILL.md      # one folder per skill
AGENTS.md                         # repo guide for contributing agents
```

See [`AGENTS.md`](./AGENTS.md) for how to add a skill.

## License

[MIT](./LICENSE)
