# Research Queue Loop

A reusable pattern for long-running, incremental research using a file-backed priority queue and subagent delegation.

## How It Works

All state lives in a single plan file. Each loop iteration reads the plan, does ONE thing, updates the plan, exits. Next run picks up where you left off. The orchestrator stays lean by delegating heavy work to subagents.

## Setup

Before starting the loop, create a plan file with this structure:

```markdown
# {Topic} Research Plan

## Goal
{What you're trying to achieve — 2-3 sentences}

## Hypothesis
{What you think the answer is — helps focus research}

## Phases
{Discovery → Deep-Dive → Synthesis → Design → Stress-Test}
Current Phase: {phase}

## Queue
- [ ] P1 | {topic} | {why it matters} | {output file}
- [ ] P2 | {topic} | {why it matters} | {output file}

## Completed
(none yet)

## Discovered
(none yet — new questions found during research go here)

## Session Log
(one line per cycle)
```

Then schedule with: `/loop {interval}`

## The Cycle (every iteration)

```
1. READ the plan file — you have no memory between runs
2. TRIAGE: move Discovered items into Queue with priorities
3. CHECK: should current phase advance? Update if transition criteria met
4. DEQUEUE: pick top unchecked item from Queue
5. NOTIFY: tell stakeholders what you're researching and why
6. EXECUTE: spawn a focused subagent to do the actual research
   - Give it specific search queries and output file path
   - It writes a full report with Key Takeaways + Follow-Up Questions
7. HARVEST: read ONLY the Key Takeaways and Follow-Up sections (not the full report)
8. UPDATE the plan:
   - Mark item as [x] in Queue
   - Add to Completed with date + 2-3 bullet findings
   - Add Follow-Up Questions to Discovered
   - Re-prioritize Queue if findings change what matters
   - Append to Session Log
9. NOTIFY: tell stakeholders what you learned (bite-sized)
10. EXIT. Next run picks up next item.
```

## Rules

- **ONE item per cycle.** Never batch. This rate-limits token burn and forces incremental progress.
- **Subagent does heavy lifting.** Orchestrator only reads summaries. This preserves main context.
- **File = state.** No database, no custom infra. Markdown checkboxes are the queue.
- **Items are self-contained.** A fresh agent with no conversation history must be able to execute any queue item from the item text alone. If it can't, the item is too terse.
- **Self-evolving agenda.** Research generates follow-up questions which become new queue items.
- **Queue empty ≠ done.** If queue is empty but goal isn't met, generate new research questions from completed findings.
- **Plan file stays lean.** Under 200 lines. Archive old completed items if needed.
- **Convergence matters.** Phases prevent infinite discovery. Transition criteria force progress toward the goal.

## Queue Item Format

The default template works for research: `- [ ] P1 | {topic} | {why it matters} | {output file}`

For execution loops (code changes, migrations, config updates), items need more detail. Example for a coding step:

```
- [ ] P1 | Migrate dns-setup-tables.py to lib/db.py | Delete DB_CONFIG dict (lines 6-11), add `from lib.db import DB_CONFIG` after psycopg2 import. Test: `UNIFI_DB_PASS=unifi_secret python3 scripts/dns-setup-tables.py` (idempotent DDL, safe). Rollback: `cp scripts/dns-setup-tables.py.bak scripts/dns-setup-tables.py` | inline
```

What makes this work: exact lines to change, the test command to run immediately after, and how to revert if it fails. A subagent can pick this up cold and execute it. Contrast with a bad item: `- [ ] P1 | Migrate dns-setup-tables.py | needs migration | inline` — useless without external context.

## Hard-Won Lessons (from running this in production)

### Fast-track obvious answers
Before dispatching a subagent, ask: can I answer this in 30 seconds with a direct read/curl/grep? If yes, do it inline. Reserve subagents for things that genuinely need research. A quick inspection can save a full cycle.

### Mid-loop reformulation is expected, not exceptional
When ground truth differs from your hypothesis (different tool, different API, different config location), don't fail the item — reformulate it. Keep a `self_corrections: []` array in state to log what changed and why. This is the most important thing a loop can do: update its own model of reality.

### `in_progress` status is a crash marker
If a cycle crashes mid-execution, the next run will see an item stuck at `in_progress`. Explicitly handle this: if `in_progress` is found at cycle start and the lockfile is dead/missing, reset it to `pending` and log the reset. Don't silently skip it.

### Verify before writing
For config writes or code changes where the exact field name / schema / API matters: dispatch a quick verification subagent (or run a grep/read) BEFORE writing. Writing a wrong config that passes no validation is silent breakage.

### Collect user actions — don't scatter them
Accumulate everything the user needs to do in a single `requires_user_action` list in state. Never block the loop waiting for user action — write the artefact, document the command, move on. Surface the full action list at convergence.

### Chain loops on convergence
Terminating is rarely the right end state. On convergence, consider whether a follow-on loop is valuable: evaluation of findings, implementation of conclusions, stress-testing of decisions. Add a convergence handler that explicitly decides: stop, or chain to the next loop?

### User messages mid-loop are corrections — act immediately
If the user sends a message while the loop is running, treat it as a priority override. Don't wait for the next cycle. Incorporate the correction (skip a task, change an assumption, reprioritize) immediately and log it in `self_corrections`.

### Ordering matters for chained work
In evaluation loops with multiple agents/personas: put the adversarial or breaking agent first. It surfaces the critical issues that all subsequent agents should reference and build on. Don't leave the wrecking ball for last.

## Why This Works

| Principle | Why |
|-----------|-----|
| File-backed state | Stateless between runs — survives crashes, session resets, context compaction |
| Priority queue in markdown | Claude reads natively, no parsing needed, human-readable |
| One item per cycle | Spreads cost over time, natural checkpoints, easy to pause/resume |
| Subagent isolation | Orchestrator context stays clean across dozens of cycles |
| Self-evolving queue | Research discovers what you don't know yet — agenda improves over time |
| Phase gates | Prevents research rabbit holes — forces convergence toward deliverable |

## Discord Notifications

Loop cycle updates go to **#brahma-cycles** — the channel for cycle decisions and progress.

| What | Channel | ID | Tool |
|------|---------|-----|------|
| Cycle updates (NOTIFY steps) | #brahma-cycles | `1488207247631974642` | `mcp__discord-mcp-basics__discord_send` |
| DMs to Dhruv (action items) | DM channel | `1480276741581705508` | `mcp__plugin_discord_discord__reply` |

**Important:** `discord-mcp-basics` is guild-only. It CANNOT send to DM channels (will error "not a text channel"). Use `plugin_discord` for DMs.

Format: Short update per cycle — what was done, key finding, what's next. Under 300 chars.

## Customization Points

- **Interval:** 30m for deep research, 10m for monitoring, 1h for low-priority
- **Notification channel:** #brahma-cycles (`1488207247631974642`) for cycle updates
- **Subagent type:** `general-purpose` for web research, `Explore` for codebase research
- **Output format:** Markdown reports, JSON data, code prototypes — match the phase
- **Convergence trigger:** Fixed count ("after 5 reports"), quality-based ("when 3 patterns confirmed"), or manual ("user says move on")
