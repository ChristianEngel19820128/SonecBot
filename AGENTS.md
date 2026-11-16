# SonecBot – Agent Instructions

## 1. Project context

- **Repository:** `ChristianEngel19820128/SonecBot`
- **Project:** SonecBot
- **Engine:** AppGameKit Studio (AGK)
- **Active development branch:** `develop`
- **Reference branch:** `main`
- **Historical source:** `source/legacy/`
- **Current handoff:** `HANDOFF.md`
- **Current milestone:** Alpha-Walker complete and locally accepted; HTML5 pre-alpha deployment next.

SonecBot is an independently developed side-scrolling action game featuring platforming, weapons, energy management and enemy encounters.

The original game was developed using **BlitzBasic Plus**. The historical source code is preserved for reference only. A separate, unfinished BlitzMax file also exists.

The current game is developed in AppGameKit Studio.

**Primary goal:** Produce a stable, playable alpha version before expanding the game with additional features.

## Collaboration and release workflow (confirmed 16 November 2026)

- Work as a team in **small, jointly agreed steps**: inspect the actual GitHub `develop` HEAD, understand the current question, discuss evidence and options, approve the exact change, implement only that scope, and check results together.
- The owner runs AppGameKit Studio and a local Apache test server on their desktop. **Only the owner can perform and confirm local AGK exports, compiles, browser/gamepad runs and itch.io page changes here.** Assistant code review and static checks are not runtime tests.
- If an interesting AGK peculiarity appears, record the observation, evidence level and source in the relevant project documentation, **finish the current task step first**, and only then decide whether to investigate or add it to the [AGK Knowledge Base](https://github.com/ChristianEngel19820128/agk-knowledge-base). The Knowledge Base is reusable background knowledge, not an automatic parallel task. The 1.0 release of Crystals provides useful process experience.
- GitHub repositories can be read as needed for comparisons; write changes remain subject to each repository's permissions and a specific agreement. Do not expand work to another repository automatically.
- Maintain handoff-ready notes as part of each approved change: actual HEAD/tested revision, what was changed, who tested it and where, verified versus suspected findings, open decisions, and the **single next step**. Before a chat change or context limit, update `HANDOFF.md` and relevant status documents. Never assume prior chat attachments or local files are accessible.
- Prioritize a playable HTML5 pre-alpha for the AGK community and selected testers, **not a rushed public launch**. The itch.io project page deliberately remains in **Draft**. Its secret URL can be shared with chosen testers; anyone holding that URL may access it. The owner reports that switching to Published provides a one-time discovery/index boost that cannot be regained; **do not publish or suggest changing the visibility without explicit owner approval**. The decision to publish at beta 0.9 or 1.0 is open.
- itch.io edits and uploads are done manually by the owner. Prepare itch.io texts and public release-facing descriptions in **English Markdown** for copy/paste. The green heart **💚** is the agreed visual identity for GitHub README and itch.io.
- Do not spend the last release steps on general balance or Walker polish. Investigate potentially frame-driven spawn probabilities as a **hypothesis**, compare options, and change only after an explicit decision and real test.

## 2. Fundamental rule: investigation first

**The default authorization is READ-ONLY.**

A request to investigate, review, analyze or report a bug does not authorize implementation.

Unless the repository owner explicitly approves a specific change:

- Do not create, edit, delete, move or rename files.
- Do not apply patches or refactor code.
- Do not create commits, branches, pull requests, issues or releases.
- Do not modify project configuration or dependencies.
- Do not automatically fix discovered bugs.
- Do not change gameplay, balancing, graphics or sound.

Explain findings and possible solutions. Wait for explicit approval before implementation.

## 3. Understand the game before reporting bugs

**Unfinished does not automatically mean defective.**

SonecBot is under active development. Disabled enemies, incomplete systems, placeholders and experimental code may be intentional.

Before classifying behavior as a bug:

1. Read the relevant source code.
2. Trace the affected execution path.
3. Consult `PROJECT.md` and `TECHNICAL.md`, if available.
4. Distinguish intended behavior from actual behavior.
5. Ask for clarification when the intended behavior is unknown.

Do not invent requirements or treat assumptions as established facts.

## 4. Preserve existing gameplay

Existing gameplay mechanics must be protected.

Pay particular attention to:

- Player movement, jumping, gravity and jetpack behavior.
- Energy absorption, consumption and regeneration.
- Weapons, ammunition and defensive systems.
- Platforms, scrolling and camera movement.
- Enemy movement, attacks and collisions.
- Animation, graphics, sound and input handling.

Do not change the behavior of these systems as an unintended side effect of a bugfix.

**A technically cleaner implementation is not automatically a better implementation.**

Avoid unrelated optimizations, redesigns and architectural changes.

## 5. Bug investigation procedure

For each suspected bug:

1. Identify the affected files and functions.
2. Trace the relevant code and dependencies.
3. Describe the observed or suspected problem.
4. Separate verified facts from hypotheses.
5. Explain the potential impact on gameplay.
6. Provide reproduction steps or a proposed verification method.
7. Check existing entries in `TODO.md` or a dedicated bug register.
8. Suggest the smallest reasonable correction.

Never claim that a bug was reproduced or a test was executed unless this actually happened.

Do not generate large collections of speculative bug reports. Prioritize actionable, well-supported findings.

## 6. Bug report format

Bug reports must be written in **German**.

Each report should contain:

- **ID:** `SB-###`, only when assigned and verified; otherwise `Noch nicht vergeben`
- **Title:** Short, descriptive summary
- **Priority:** Kritisch / Hoch / Mittel / Niedrig / Offen
- **Status:** Vermutet / Bestätigt / In Bearbeitung / Behoben / Verworfen
- **Affected files and functions**
- **Source evidence:** Relevant locations and commit SHA when available
- **Expected behavior:** Only when documented or confirmed
- **Actual or suspected behavior**
- **Reproduction or verification steps**
- **Potential impact**
- **Suggested minimal correction**
- **Duplicate check**

The repository documentation is the shared reference. Do not claim to have updated a bug register unless the update was actually performed and authorized.

## 7. Development and version control

- Perform active development on `develop`.
- Do not modify `main` without explicit authorization.
- Keep changes small, focused and understandable.
- Avoid combining unrelated fixes.
- Preserve the historical code in `source/legacy/`.
- Do not modify legacy source unless explicitly instructed.
- Respect `.gitignore`.
- Do not commit compiled executables or temporary build artifacts.
- Do not rewrite Git history without explicit authorization.

Commit messages should clearly describe the actual changes.

## 8. Implementation after explicit approval

When implementation is authorized:

1. Confirm the exact scope.
2. Identify the files that need modification.
3. Prefer the smallest behavior-preserving solution.
4. Avoid unrelated cleanup and refactoring.
5. Validate the result where possible.
6. Report which tests were actually performed.
7. Explain any remaining uncertainty or risk.

If the approved scope needs to expand, request approval again.

## 9. Project documentation

The following Markdown files form the shared project documentation:

- `HANDOFF.md` – Current new-chat entry point, tested baseline, release gates and exact next steps
- `README.md` – Public project status and verified usage limits

- `AGENTS.md` – Agent instructions and safety rules
- `PROJECT.md` – Game concept, mechanics and development goals
- `TECHNICAL.md` – Architecture and verified technical findings
- `TODO.md` – Prioritized tasks, bugs and milestones

Some documents may not exist yet. Their absence does not authorize an agent to create them.

**Keep relevant documentation current with every commit.** Update the important documents affected by the change in the same commit; do not touch every document routinely. Record implemented behavior, developer-reported tests, remaining uncertainties, provisional test/balancing values and the current next step. For a documentation-only commit, update only the relevant instructions or status entries. Chat handoffs depend on these files; do not defer necessary documentation to a later chat.

**Review reusable findings for the AGK Knowledge Base.** During implementation, debugging and test review, check whether the result could become a useful general lesson, reproducible experiment or reference in `ChristianEngel19820128/agk-knowledge-base`. Check existing topics before proposing an addition. Record promising candidates and their evidence/test status in the project documentation; do not present an uncompiled or visually untested experiment as a proven solution. The Knowledge Base should grow with the projects and serve as a reusable implementation reference. Contributions require sources/revisions, conditions, limitations and a reproducible explanation, with source-project code distinguished from AGK engine behavior. Respect each repository's existing write scope.

Do not silently overwrite existing documentation or contradict established project decisions.

When new findings conflict with documentation, report the discrepancy instead of independently deciding which source is correct.

**Chatwechsel / Kontextgrenzen:** Do not assume automatic chat/history/attachment transfer. Start by reading AGENTS.md and HANDOFF.md, then current PROJECT.md, TODO.md and TECHNICAL.md. Query the real develop HEAD and relevant source files again. HANDOFF.md is the canonical current transition; pinned older documents are history, not instructions to repeat completed work. The owner has explicitly closed the Alpha-Walker task after the final turret-recoil test. Preserve the accepted IK, pivots, artwork/prototypes, aim and recoil; the next task is HTML5 export/browser verification/deployment. Do not reopen Walker polishing without a specific owner request or demonstrated release blocker. Local developer tests, translated simulations, actual AGK compiles and actual browser tests must remain distinct.

## 10. Working principles

- **Understand first.**
- **Investigate before implementing.**
- **Protect working functionality.**
- **Separate facts from assumptions.**
- **Prefer small, testable steps.**
- **Document important findings.**
- **Ask before changing anything.**

The repository owner retains control over project direction, priorities, implementation and releases.
