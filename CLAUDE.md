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

### Read these first

| Document | What it governs |
|---|---|
| `docs/game-design.md` | Game rules — the single source of truth. Movement algorithm, map elements, clear/undo rules |
| `docs/architecture.md` | Folder layout, DI/MVVM/repository conventions, naming |
| `docs/tasks/README.md` | Feature-by-feature work breakdown and its status table |

Rules changed? Edit `docs/game-design.md` before touching code.

**Finishing a task** means: tick its completion checkboxes, record what actually got built and what
was decided in the doc itself, `git mv` it into `docs/tasks/completed/`, fix the links pointing at
it, and update the status table in `docs/tasks/README.md`.

### Current state

`00-foundation` is done — packages, routing, theme, DI skeleton, and two placeholder screens.
**No game logic exists yet**: no board rendering, no move engine, no level data.

Work through `docs/tasks/` in order, one task per request. `02-move-engine` (pure Dart, fully
unit-tested) comes before any UI — the rules get fixed by tests, not by eyeballing the screen.
Don't start the next task unless asked.

### Architecture in brief

Clean Architecture, feature-first, modeled on the sibling project `../quizlab` — DI via plain
Riverpod providers in `<feature>_di.dart`, ViewModel = `Notifier<State>` with a `sealed` Event
class, Root (`ConsumerStatefulWidget`) / Screen (dumb `StatefulWidget`) split, Notifier → Usecase
container → Repository. No freezed, no build_runner, no barrel files.

**Deliberate departures from quizlab** (see `docs/architecture.md` §3 for the full table): there is
no API, so there is **no datasource layer** — `RepositoryImpl` holds the constant map data (and
`SharedPreferences`) directly — and no API models or mappers.

### Hard constraint: no game engine

**Do not add Flame or any other game engine/library.** The game is built with the stock Flutter
framework only — `CustomPainter` / `RenderObject` for drawing, `Ticker` / `AnimationController`
for the game loop, `GestureDetector` / `Focus` for input.

If a task seems to need an engine, say so and propose a plain-Flutter approach instead of adding
the dependency.

### Always log the prompt

**Every user request gets an entry appended to `docs/prompt-history.md` — no exceptions.**

Write the entry as part of finishing the task, before reporting back. Follow the format documented
at the top of that file: request (verbatim), what was done, files changed, decisions/notes.
This applies even to small requests. If the request produced no code change, log it anyway with
what was decided.

### Commands

**Flutter version is pinned via FVM** (`.fvmrc` → 3.44.8). Always prefix commands with `fvm`:

```
fvm flutter pub get
fvm flutter analyze     # lints from analysis_options.yaml (flutter_lints)
fvm flutter test
fvm flutter run
```

Verification default: `fvm flutter analyze && fvm flutter test` must pass before reporting a change as done.
