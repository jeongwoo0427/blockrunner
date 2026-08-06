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

The user writes in Korean; reply in Korean. Docs and `///` comments are Korean.
**UI strings are no longer Korean literals** — they live in `lib/core/i18n/strings_*.dart`,
one file per language, and screens read them through `context.strings`. A test fails if a
Korean literal reappears under `presentation/`.
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

**Every task doc is done — `docs/tasks/` holds only `README.md` and `completed/`.** The next request
is not a task from the list; ask what it should be. **The game is playable end to end on all
three platforms:** level select → play → clear → next level, with progress saved. The
rules engine is locked down by unit tests including all three hand-verified traces from
`docs/game-design.md` §4, **twenty levels** are ASCII constants whose `minMoves` a BFS solver in
`test/` verifies, and the play screen takes swipe, arrow keys, WASD, mouse drag, and `R`.

**Level design is a checked property, not taste** (`docs/game-design.md` §4.4). `test/feature/game/
level_design.dart` exhaustively searches every level and `level_design_test.dart` asserts five
things: no board reachable from the start may be unclearable (there is no undo, so a silent dead
end ends the level while the screen says nothing — the old level 1 had six of them); removing any
wall, edge wall, block, or black hole must change `minMoves`, or it was decoration; boards only
grow and carry no padding — **cutting an empty edge row must change `minMoves`**, which caught
half the first twenty (level 17 was 9×9 using a 4×8 corner); black holes appear only from level 15;
and the back ten levels must total more moves than the front ten. **Boards are deliberately not all
square** — at least five are wider than tall and five taller than wide, because a long axis slides
far and a short one hits the wall at once. **Maps are not hand-drawn**; a random search keeps only
what passes those checks, and the test then pins it.

**There is no on-screen d-pad on any platform** (`docs/game-design.md` §6) — a test asserts its
absence, so don't reintroduce one for discoverability. Discoverability is handled by **per-level
tutorial text** (`Level.tutorial`, §6.1): levels that introduce a new rule carry a Korean blurb, and
it is shown once as an overlay on first arrival. "Seen" is persisted by `TutorialRepository` in the
`level` feature — that feature therefore owns a little `SharedPreferences` state, not just constants.
Clear/star/best-move storage is separate and lives in `progress`; don't merge the two.

**There are two kinds of wall and they are not interchangeable.** `#` is a *cell wall* that occupies
a whole square; `|` and `-` are *edge walls* that sit between two squares and block passage without
consuming either one. Maps are written as an interleaved `2N+1` grid so edges are expressible at all
— see `docs/game-design.md` §9.1. Never "simplify" a map back to one line per row; that silently
drops every edge wall.

**There is no undo in the game** (`docs/game-design.md` §5.1) — reset is the only way to take a move
back, and that is what makes holes a real threat. But the *implementation* is still there and tested
(`history`, `undosLeft`, `UndoRequested`, `_undo`); only the button and the `Z` key were removed.
Don't delete it as dead code, and don't wire it back without reading §5.1 — a test asserts the UI
stays absent.

Stars come from `Level.starsFor(moveCount)` (§5.2): ★★★ within 20% over `minMoves`, ★★☆ within 40%
with a floor of 2 extra moves. **★★★ deliberately gets no flat floor** — on a `minMoves` of 1 an
extra move is 100% over — so short levels effectively demand the optimum while long ones get real
slack. ★★☆ needs its floor because 40% of 2 rounds down to zero. Don't collapse either into a plain
ratio.

Clearing a level persists the best run through `SaveClearResultUsecase`, which also emits on a
stream the level select screen subscribes to, so stars and unlocks update without leaving and
re-entering the screen. **That usecase must stay a single instance** — `ProgressUsecases` owns it,
and both `GameUsecases` and `LevelUsecases` are handed the same object (the latter gets only its
`Stream`, since saving is the play screen's job). Two instances mean two streams and a subscriber
that silently never fires; tests pin both the identity and the live update.

**`progress` must not import another feature.** It briefly took a `Level` to compute stars, which
became a cycle the moment level select needed progress. `SaveClearResultUsecase` now takes a level
number and a star value instead; the formula still lives only in `Level.starsFor` and the caller
passes the result.

Rendering is a **hybrid**, decided in `04`: `BoardPainter` draws floors/grid/walls, and blocks are
`AnimatedPositioned` widgets keyed by `block.id` on a `Stack` above it. Cell size is computed in
exactly one place — `BoardView`. Don't scatter that calculation.

**Animation is implicit — there is no `AnimationController`.** `AnimatedPositioned` slides the
blocks; the Screen holds only a `Timer` that reports `AnimationCompleted` back to the Notifier.
`state.isAnimating` doubles as "should this change be shown": when it is false the durations
collapse to zero, which is exactly why reset (and, in `07`, undo) applies instantly without
replaying a rewind. Falling blocks are removed from `board` but kept in `state.fallingBlocks` so
they can slide into the hole before shrinking — the shrink is delayed by an `Interval`, not a
second timer.

**The app is multilingual** (`docs/architecture.md` §13, `docs/tasks/completed/11-i18n.md`):
Korean, English, Japanese, Simplified Chinese, French. **No i18n package** — `intl`,
`flutter_localizations` and friends are all absent on purpose, the same way Flame is. Strings are
an abstract `AppStrings` with one hand-written implementation per language, so a missing key breaks
the build instead of surfacing as an empty string to whoever reads that language. Anything with a
value in it is a **function**, which is what lets English do `1 move` / `2 moves` inside its own
file. Screens read `context.strings` from an `InheritedWidget`, never Riverpod.

**Level names and tutorial text are not in `Level` anymore** — `Level` keeps `hasTutorial`, a bool,
because "which level teaches something" is level design, not translation; if the two travelled
together a missing translation would silently delete a tutorial. The text is in `AppStrings`, keyed
by level number, and those maps are the one place with no compile-time check — a parity test pins
their keys to `kLevels`.

**Parser errors, asserts and `debugMessage` stay Korean.** A level author reads those, not a
player. `no_hardcoded_korean_test` encodes that boundary by scanning only `presentation/` and
`level_data.dart`.

**The UI has a shape language and it is enforced by code, not by memory.** `gameButtonShape()` in
`lib/core/widget/` is the single definition of the beveled corner that buttons, level cards, overlay
cards and dialogs all wear; there are **no borders** anywhere, so fill colour carries every
distinction. A source-scan test fails if a Material `FilledButton`/`OutlinedButton`/`TextButton`/
`IconButton` reappears in `lib/`. Level cards encode exactly three states in colour — locked
(`surfaceContainerHighest`, board hidden entirely), playable (`primary`), cleared (`tertiary`) — and
star count is carried by the star row, not by the fill.

**There are five animation controllers and each one broke `06`'s "implicit animations only" rule for
a stated reason**: black-hole rotation and the tutorial demo never end, the overlay entrance needs a
guaranteed first frame (`TweenAnimationBuilder` renders its end value immediately), and the bump
must replay on an unchanged value. **A running controller makes `pumpAndSettle` hang forever** —
level 1 has no black hole but does have a tutorial demo, so widget tests that reach a board or a
tutorial must `pump` instead.

**Layout is verified, not assumed** (`docs/tasks/completed/10-responsive.md`). `test/responsive_test.dart`
renders both screens across five languages, three window sizes, a width sweep and text scale ×2, and
fails on any overflow. Two of that doc's completion criteria turned out to be *false* when finally
measured — the French HUD overflowed a 320px phone at default text size, and every language
overflowed at ×2 — so treat "we never checked" as "probably broken" for anything visual.

**Nothing is fixed by ellipsis.** The criterion is that text is not cut, so `GameHud` is a `Wrap`
that folds to two lines, level cards grow taller as the font scales, and **over-long translations
get shortened rather than the card widened** — card labels have a length budget, and a test fails if
a translated level name is truncated.

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
