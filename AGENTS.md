# memorysaver/skills

Personal collection of agent skills, distributed two ways from one repo.

## Layout

```
skills/<skill-name>/SKILL.md     # one folder per skill
.claude-plugin/marketplace.json  # Claude Code plugin manifest
```

Each `SKILL.md` is YAML frontmatter (`name`, `description`) followed by markdown
instructions the agent will execute when the skill triggers.

## Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` with valid frontmatter.
2. Add `./skills/<skill-name>` to the `skills` array of the relevant plugin
   group in `.claude-plugin/marketplace.json`.
3. Bump `metadata.version` in `marketplace.json` if it's a meaningful change.

## Distribution

- **npx CLI**: discoverable by [vercel-labs/skills](https://github.com/vercel-labs/skills).
  Users run `npx skills@latest add memorysaver/skills` to install.
- **Claude Code plugin**: `marketplace.json` registers the repo as a plugin
  marketplace. Users run `/plugin marketplace add memorysaver/skills` then
  `/plugin install core@memorysaver-skills`.

Both consumers read the same `skills/<name>/SKILL.md` files — no duplication.

## Spec

Skills follow the open [Agent Skills spec](https://agentskills.io/home).
