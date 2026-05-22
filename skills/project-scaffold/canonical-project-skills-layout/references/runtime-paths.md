# Runtime Paths Reference

Where each agent runtime reads project skills, personal skills, and the agent guide. The `canonical-project-skills-layout` skill enforces the shared project layout; the user-level cells are populated by whichever installer (or symlink setup) you use.

| Runtime | Project skills | Personal skills | Agent guide |
| --- | --- | --- | --- |
| Claude Code | `<project>/.claude/skills` | `~/.claude/skills` | `<project>/CLAUDE.md` (imports `AGENTS.md` via `@AGENTS.md`) |
| Codex | `<project>/.agents/skills` for Codex and agents.md-compatible project-local discovery | `~/.codex/skills` | `<project>/AGENTS.md` |
| Pi Agent | Shared project guide via `<project>/AGENTS.md`; skills are supplied from personal skill links | `~/.pi/agent/skills` | `<project>/AGENTS.md` |

## Why `.claude/skills` and `.agents/skills` both exist

Claude Code reads project skills from `<project>/.claude/skills`. Codex and agents.md-compatible tooling can discover project-local skills from `<project>/.agents/skills`. Both paths must be symlinks to the same real `<project>/skills/` directory so contributors edit one source of truth and git diffs stay honest.

Pi loads skills from its fixed user-home directory and may not merge a project-local skills tree. It still reads `<project>/AGENTS.md`, so the project-level setup supports Pi through the shared guide while each runtime's user-level skill store supplies the same skill implementations.

## Why both AGENTS.md and CLAUDE.md

`AGENTS.md` is the agents.md-spec file that Codex and Pi Agent (and any other agents.md-compatible tool) read directly. Claude Code reads `CLAUDE.md`, but it supports the `@<file>` import syntax — so a one-line `CLAUDE.md` containing `@AGENTS.md` makes Claude inherit the same guide that Codex and Pi see, with no duplication and no chance of drift.

Edit only `AGENTS.md`. Treat `CLAUDE.md` as a forwarding stub.

## How the personal-skills paths get populated

Each runtime expects skills at the per-user path listed in column 2 of the table above. Common ways to populate them:

- **`npx skills@latest add <repo> --global`** — the [vercel-labs/skills](https://github.com/vercel-labs/skills) CLI writes installed skills into the runtime's per-user skills directory automatically.
- **Claude Code plugin install** — `/plugin marketplace add <repo>` then `/plugin install <group>@<marketplace>` registers the skill with Claude Code.
- **Manual symlink** — symlink the skill directory into the runtime's user skills path, e.g. `ln -s "$PWD/skills/<category>/<skill>" ~/.claude/skills/<skill>` (and matching entries for `~/.codex/skills/` and `~/.pi/agent/skills/`).

After adding a new skill to the source repo, re-run your installer (or refresh symlinks) so each runtime sees it.
