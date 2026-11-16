# SonecBot 💚

A side-scrolling action game made with **AppGameKit Studio**. Move between platforms, use an energy-limited jetpack, fight enemies and manage health, energy and ammunition.

The project reworks an earlier **BlitzBasic Plus** game. Historical sources are preserved in `source/legacy/`; active development is in `source/sonec/`.

## Current status

**Development build / HTML5 pre-alpha preparation — 16 November 2026.**

The **Alpha-Walker** enemy is complete for this milestone and has passed the developer's final local test, including aiming, turning, two-shot bursts, alternating barrel recoil and turret recoil. This is a local desktop assessment; the current HTML5 export, browser controls and draft-page deployment still need verification.

The active branch is **develop**. The main branch is an earlier reference and does not represent the latest development work.

## Controls and browser support

The current complete input path is designed for a **gamepad**. The intro/menu and pause use gamepad input. Keyboard controls are partial and have not been confirmed as a complete playable alternative.

A gamepad-only HTML5 pre-alpha is the proposed minimal release scope. Actual browser/controller support must be tested before sharing the pre-alpha, and the release page must state the verified requirements. No tested browser list or live release URL is available yet.

## Known development limits

- Energy capacity and starting energy are currently 5250 as a testing aid; this is not final balance.
- Shield protection does not yet cover every damage path.
- Explosion interactions with the Walker and some collision edge cases remain future work.
- Options, key rebinding, online high scores and additional graphical polishing are not part of the immediate deployment scope.

These notes describe development status rather than a finished feature guarantee.

## Development and handoff

Start with [HANDOFF.md](HANDOFF.md) for the current deployment task.

- [AGENTS.md](AGENTS.md): collaboration and repository rules
- [PROJECT.md](PROJECT.md): concept, fairness and milestone decisions
- [TODO.md](TODO.md): current release gates and deferred work
- [TECHNICAL.md](TECHNICAL.md): current implementation and evidence
- [AGK Knowledge Base](https://github.com/ChristianEngel19820128/agk-knowledge-base): reusable findings and experiments

The next milestone is to export and test the HTML5 build, fix only demonstrated release blockers, and make a clearly labelled pre-alpha accessible to selected AGK community members and other invited testers **through the itch.io draft page's secret URL**. The page is intentionally **not published**: the developer is preserving the one-time itch.io discovery/index push for a later public release (possibly beta 0.9 or 1.0; not decided). Anyone with the secret link may access the draft page. The owner handles itch.io edits and uploads manually. This repository does not yet identify a verified live HTML5 test build.

## License

See [LICENSE](LICENSE).
