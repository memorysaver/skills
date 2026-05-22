# memorysaver/skills

Personal collection of agent skills, distributed two ways from one repo.

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
