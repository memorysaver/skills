# Memory Skills

Memory skills turn project experience into reusable agent behavior.

This category has two complementary skills:

| Skill | Role | Primary output |
|---|---|---|
| [`project-memory`](./project-memory/) | Captures project sessions, notable moments, decisions, failures, and lessons under `project-memory/`. | Git-committed memory files and qmd-backed recall. |
| [`memory-forge`](./memory-forge/) | Distills accumulated memory into reusable agent-loadable skills. | New or updated skills that future agents can trigger automatically. |

They are designed to work as a loop, not as two independent archives:

```
        during work                         after enough signal accumulates
 +------------------------+                +------------------------+
 | User + agent session   |                | Recurring lessons      |
 |                        |                | across sessions        |
 +------------+-----------+                +------------+-----------+
            |                                         |
            | capture, wrap up, query                 | distill, merge, prune
            v                                         v
 +------------------------+     older lessons     +------------------------+
 | project-memory         | --------------------> | memory-forge           |
 |                        |                       |                        |
 | Records what happened: |                       | Extracts what should   |
 | - session context      |                       | change next time:      |
 | - steering             |                       | - trigger rules        |
 | - decisions            |                       | - workflows            |
 | - failures             |                       | - references           |
 | - durable takeaways    |                       | - updated skills       |
 +------------+-----------+                       +------------+-----------+
            |                                                |
            | semantic recall                                | future auto-load
            v                                                v
 +------------------------+                       +------------------------+
 | Next agent remembers   |                       | Next agent behaves     |
 | prior project context  |                       | better by default      |
 +------------------------+                       +------------------------+
```

## Triggering

Use `project-memory` when the work itself is producing knowledge that should be
remembered.

```
User says / situation appears
        |
        +-- "start a session" / new mission -------> project-memory start
        +-- "capture this" / notable moment -------> project-memory append
        +-- "wrap up" / session ending ------------> project-memory wrap-up
        `-- "have we seen this before?" -----------> project-memory query
```

Use `memory-forge` when enough remembered knowledge should become future agent
behavior.

```
User says / situation appears
        |
        +-- "forge a skill" -----------------------> memory-forge run
        +-- "distill lessons" ---------------------> memory-forge run
        +-- "extract skills from memory" ----------> memory-forge run
        +-- 3+ new lessons after wrap-up ----------> memory-forge suggest
        `-- recurring theme across old sessions ---> memory-forge suggest
```

## Division of Responsibility

`project-memory` is the recorder. It should stay close to the work: what the
user asked, where the agent changed course, what failed, what worked, and what a
future session should know before repeating the same path.

`memory-forge` is the curator. It should stay close to behavior design: which
lessons have repeated often enough, which ones are old enough to trust, which
existing skill should absorb them, and which new trigger should make a future
agent load that behavior at the right moment.

The boundary is intentional:

```
project-memory answers: "What happened, and what did we learn?"
memory-forge   answers: "What should agents do differently from now on?"
```

Do not use `memory-forge` as a raw note-taking surface. Do not use
`project-memory` as the final destination for recurring behavior. Capture first,
then distill once patterns are visible.

## Practical Flow

1. Start or bootstrap `project-memory` for the project.
2. Capture notable moments during the mission.
3. Wrap up the session so lessons are indexed and skimmable.
4. After several lessons accumulate, run or suggest `memory-forge`.
5. Let forged skills update the agent's future trigger surface.

That gives the project two memory layers: a searchable record of what happened,
and a smaller skill layer that changes what the next agent does automatically.
