---
type: lesson
mode: session
capture_mode: notable
date: 2026-05-23
time_started: "23:23"
time_ended: "23:23"
project: skills
mission: document memory skill triggers
spec_ref: ""
outcome: success
agent: codex
model: gpt-5
skills_used: [project-memory]
tools_used: [exec_command, apply_patch]
tags: [memory, agents-md, skill-triggers]
related_sessions: []
---

# document memory skill triggers

## Mission
The user wanted the memory skill category documented clearly and then wanted
`AGENTS.md` adjusted so agents trigger `project-memory` more proactively during
substantive repo work.

## Prompt Evolution
1. Requested a README under the memory category describing the relationship
   between `project-memory` and `memory-forge`.
   Commentary: This established the category-level documentation goal.
2. Asked to review `AGENTS.md` so `project-memory` would trigger more
   automatically.
   Commentary: This shifted from docs to agent behavior guidance.
3. Corrected the first AGENTS draft to be concise and trigger-focused.
   Commentary: The first draft duplicated too much workflow detail that belongs
   in the skill itself.

## Steering & Course Corrections
<!-- Moments the user redirected: what the agent did, what the user said, why. -->

- [23:23] User corrected AGENTS.md toward concise trigger guidance rather than duplicating project-memory workflow detail or adding ASCII diagrams.

## Decisions Made
<!-- Agent-side choices: where the spec/intent was ambiguous, what was picked, and why.
     One bullet per decision. Use this when you (the agent) had to resolve ambiguity,
     not when the user steered you. -->

- Documented the memory category as a relationship map instead of repeating each
  skill's full README, because the leaf skills already own their workflow
  details.
- Kept the final AGENTS guidance as a short trigger list, because AGENTS.md
  should steer skill loading rather than become a second workflow source.

## What Worked
<!-- Concrete wins with enough context to reproduce. -->

- [23:23] Memory category README worked best as a relationship and routing page for project-memory and memory-forge, with detailed workflows left inside each skill.

## What Failed / Frustrations
<!-- What went wrong. Root cause if known. Dead ends tried. -->

- The first AGENTS update was too verbose and included ASCII decision art. That
  made the guide less suitable as a concise trigger surface.

## Skills & Tools Involved
| Name | Role | Quality | Quirks |
| ---- | ---- | ------- | ------ |
| project-memory | Captured the lesson after the user pointed out it should have triggered. | worked | The session was started after the fact, so capture was retrospective. |
| exec_command | Inspected files, git status, and ran project-memory scripts. | worked | Git operations needed escalation when writing `.git` or accessing the network. |
| apply_patch | Added and edited markdown files. | worked | Manual patching kept changes scoped. |

## Takeaways
<!-- Concrete heuristics future sessions should carry. Prefer testable rules over vibes. -->

- [23:23] AGENTS.md should improve skill trigger precision; detailed lifecycle mechanics belong in the skill's own README and workflows.

## Candidates for memory save
<!-- Draft entries for ~/.claude/projects/.../memory/. User approves before write.
     Format: `type: feedback | name: snake_case | body: "..."` -->

- type: feedback
  name: agents_md_skill_trigger_surface
  body: "AGENTS.md should guide when skills trigger, not duplicate detailed skill workflows. Keep it concise: describe the trigger conditions and delegate mechanics to the skill README/workflows."

## Open Questions

- Should future README/category documentation changes automatically start a
  `project-memory` session whenever they change agent behavior guidance?

## Links
<!-- [[2026-04-10/session-1415-related]] -->
