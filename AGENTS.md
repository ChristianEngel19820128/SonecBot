# SonecBot – Agent Instructions

## 1. Project context

- **Repository:** `ChristianEngel19820128/SonecBot`
- **Project:** SonecBot
- **Engine:** AppGameKit Studio (AGK)
- **Active development branch:** `develop`
- **Reference branch:** `main`
- **Historical source:** `source/legacy/`

SonecBot is an independently developed side-scrolling action game featuring platforming, weapons, energy management and enemy encounters.

The original game was developed using **BlitzBasic Plus**. The historical source code is preserved for reference only. A separate, unfinished BlitzMax file also exists.

The current game is developed in AppGameKit Studio.

**Primary goal:** Produce a stable, playable alpha version before expanding the game with additional features.

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

The following Markdown files form the intended shared project documentation:

- `AGENTS.md` – Agent instructions and safety rules
- `PROJECT.md` – Game concept, mechanics and development goals
- `TECHNICAL.md` – Architecture and verified technical findings
- `TODO.md` – Prioritized tasks, bugs and milestones

Some documents may not exist yet. Their absence does not authorize an agent to create them.

Do not silently overwrite existing documentation or contradict established project decisions.

When new findings conflict with documentation, report the discrepancy instead of independently deciding which source is correct.

## 10. Working principles

- **Understand first.**
- **Investigate before implementing.**
- **Protect working functionality.**
- **Separate facts from assumptions.**
- **Prefer small, testable steps.**
- **Document important findings.**
- **Ask before changing anything.**

The repository owner retains control over project direction, priorities, implementation and releases.
