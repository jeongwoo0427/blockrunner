# CLAUDE.md

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

## Project: blockrunner

A grid puzzle game. One direction input slides **every** block — player and obstacles alike — until
each hits a wall, the map edge, or a settled block. Clear the level by making the player block come
to rest **on** the goal tile. 2048-style movement, Sokoban-style win condition, no merging.
Targets web, mobile, and desktop from one codebase.

### Starting a session

This project is built one task at a time across many separate sessions. You have no memory of the
previous ones — the repo is the memory. Before doing anything, read these four, in this order:

| Document | What it gives you |
|---|---|
| `docs/game-design.md` | Game rules — the single source of truth. Movement algorithm, map elements, clear/undo rules, and *why* each rule was chosen |
| `docs/architecture.md` | Folder layout, DI/MVVM/repository conventions, naming. §3 lists deliberate departures from the reference project |
| `docs/tasks/README.md` | The work breakdown and status table — tells you what's done and what's next |
| `docs/prompt-history.md` | **Read the last 3–4 entries.** This is the running log of what was asked, what was built, and what was decided. It is how you catch up on the trajectory |

Then check `git log --oneline | head -10` and `git status`.

Do not infer the plan from the code alone. Decisions and their rationale live in the docs; the code
only shows the outcome.

### The working rhythm

The user drives this project one request at a time and expects the same rhythm every session:

1. **One task per request.** Take the next task in `docs/tasks/`, do it fully, stop. Don't roll into
   the following task, and don't half-do the current one.
2. **Plan first for anything structural.** Enter plan mode for new features or architectural work.
   Small, well-specified changes don't need it.
3. **Ask rather than guess on design decisions.** Game rules and product choices are the user's call.
   Unresolved questions get parked in the doc's "열린 질문 / 미결정 사항" section rather than silently
   decided. Routine engineering judgment calls you make yourself and state plainly.
4. **Log every request** to `docs/prompt-history.md` (see below). No exceptions.
5. **Verify before reporting.** `fvm flutter analyze && fvm flutter test` must pass. Say plainly what
   you actually ran and what you couldn't verify.
6. **Commit only when asked.** The user says "커밋 해줘" as a separate step and pushes themselves.

### Language

The user writes in Korean; reply in Korean. Docs, `///` comments, and UI strings are Korean.
**Commit messages are English**, and end with the `Co-Authored-By` trailer.

### Logging every request

**Every user request gets an entry appended to `docs/prompt-history.md` — no exceptions.**

Write it as part of finishing the task, before reporting back. Follow the format at the top of that
file: numbered heading with the date, the request verbatim, what was done, files changed, and
**decisions with their rationale**. The rationale is the point — it's what a future session can't
reconstruct from a diff. Log requests that produced no code change too.

When the user asks only to commit, add the entry for *that* request, then `git commit --amend` it
into the same commit rather than leaving a dangling follow-up commit.

### Finishing a task

1. Tick the completion checkboxes in the task doc
2. Add a "실제 결과" section to it — what got built, what was decided, what was left out
3. `git mv` the doc into `docs/tasks/completed/`
4. Fix every link pointing at it (`grep -rn "<task-name>" docs README.md CLAUDE.md`)
5. Update the status table in `docs/tasks/README.md`
6. If the change makes `README.md` or this file's **Current state** section untrue, fix them in the
   same pass — stale status text is worse than none

Rules changed? Edit `docs/game-design.md` before touching code.

### Current state

`00-foundation` through `04-game-screen` are done — **the game is playable.** The rules engine is
locked down by 31 unit tests including all three hand-verified traces from `docs/game-design.md` §4,
six 6×6 levels are ASCII constants whose `minMoves` a BFS solver in `test/` verifies, and the play
screen renders the board and handles clear / player-lost.

Still missing: **animation** (moves apply instantly), **swipe and keyboard input** (on-screen
direction buttons only), **undo**, and **progress saving**. The level select screen is still a
placeholder.

Rendering is a **hybrid**, decided in `04`: `BoardPainter` draws floors/grid/walls, and blocks are
`Positioned` widgets keyed by `block.id` on a `Stack` above it. Cell size is computed in exactly one
place — `BoardView`. Don't scatter that calculation.

Next up is `05-input`. Work through `docs/tasks/` in order, one task per request. Don't start the
next task unless asked.

### Architecture in brief

Clean Architecture, feature-first, modeled on the sibling project `../quizlab` — DI via plain
Riverpod providers in `<feature>_di.dart`, ViewModel = `Notifier<State>` with a `sealed` Event
class, Root (`ConsumerStatefulWidget`) / Screen (dumb `StatefulWidget`) split, Notifier → Usecase
container → Repository. No freezed, no build_runner, no barrel files.

**Deliberate departures from quizlab** (see `docs/architecture.md` §3 for the full table): there is
no API, so there is **no datasource layer** — `RepositoryImpl` holds the constant map data (and
`SharedPreferences`) directly — and no API models or mappers.

**Feature dependencies must stay acyclic — `game → level`, never the reverse.** `level` owns only
metadata (`Level`: number, name, minMoves) and knows nothing about boards; `game` owns the board
model, the ASCII maps, and the engine (`GameMap`: levelNumber, initialBoard). The two constant lists
are joined **by level number only**, and a test joins them so adding a level to one list but not the
other fails loudly. This split exists because bundling the board into `Level` created a real cycle —
don't undo it. `minMoves` lives on `Level`, not on the map, or level select would need `game` again.

### Hard constraint: no game engine

**Do not add Flame or any other game engine/library.** The game is built with the stock Flutter
framework only — `CustomPainter` / `RenderObject` for drawing, `Ticker` / `AnimationController`
for the game loop, `GestureDetector` / `Focus` for input.

If a task seems to need an engine, say so and propose a plain-Flutter approach instead of adding
the dependency.

### Commands

**Flutter version is pinned via FVM** (`.fvmrc` → 3.44.8). Always prefix commands with `fvm`:

```
fvm flutter pub get
fvm flutter analyze     # lints from analysis_options.yaml (flutter_lints)
fvm flutter test
fvm flutter run
```

Verification default: `fvm flutter analyze && fvm flutter test` must pass before reporting a change as done.
