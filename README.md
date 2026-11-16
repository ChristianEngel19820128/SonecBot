# SonecBot 💚

**A side-scrolling sci-fi action game built with AppGameKit Studio.**

Pilot Sonec across moving platforms, fly with an energy-powered jetpack, collect resources and survive encounters with mines, orbs, destructible objects and the heavily armed **Alpha-Walker**. Choose your weapons carefully: flying, shielding yourself and using special weapons all compete for energy.

SonecBot is a reworking of an earlier **BlitzBasic Plus** project. The preserved legacy sources are in `source/legacy/`; active AGK development is in `source/sonec/`.

## Current status: playable HTML5 pre-alpha

**16 November 2026 — HTML5 pre-alpha uploaded to itch.io and tested in its embedded player.**

The developer successfully compiled the current build, exported HTML5, tested it locally through Apache/XAMPP, created and uploaded the ZIP, and confirmed that the game starts inside the itch.io embed. The embedded test verified controller detection, movement (including backward movement and flight), all four weapons, shield, energy attraction, pause, and death by energy depletion/falling. ESC and the quit action are intentionally unavailable in the HTML5 player. No visible tearing was reported in the local browser test; performance on other devices has not yet been established.

**The itch.io page remains in Draft with secret-link access; it is not publicly published.** The secret link can be shared with invited community testers. The exact export SHA was not independently recorded, and repeated restarts have been verified in the local HTML5 session; **a restart in the itch.io embed was subsequently confirmed by the developer**. The Alpha-Walker and initial player-weapon collision paths have passed targeted developer tests.

The itch.io page now links to both the [`develop`](https://github.com/ChristianEngel19820128/SonecBot/tree/develop) and [`main`](https://github.com/ChristianEngel19820128/SonecBot/tree/main) GitHub branches, as confirmed by the developer. **`develop` is the active development branch**; `main` remains an earlier reference until a separately approved milestone merge.

## Gameplay

- **Fly and fight:** navigate a scrolling 2D world with a jetpack, machine gun, flamethrower, plasma flash and grenade launcher.
- **Manage resources:** health, shields, energy and ammunition matter. Energy is shared between movement and several combat abilities.
- **Face different hazards:** mines, orbs, towers and the multi-part **Alpha-Walker**. The Walker patrols platforms, stops in front of Sonec and aims its two-shot bursts; its turret is the intended weak point.
- **Use the environment:** direct hits and nearby explosions can damage targets, and chain reactions can produce surprising encounters.
- **Try again:** game-over and multiple restarts have been tested in the local HTML5 browser, and a restart has also been confirmed inside itch.io.

This is an early experimental build, not a feature-complete game. Balance, objectives and presentation may change in response to player feedback.

## Controls — gamepad required for the HTML5 pre-alpha

Tested by the developer using an Xbox-style compatible controller in a local HTML5 browser session:

| Input | Action |
| --- | --- |
| Left analog stick or D-pad | Move; up to jump / engage jetpack |
| LT / L2 | Move backward to the left |
| RT / R2 | Move backward to the right |
| A | Machine gun |
| B | Grenade launcher |
| X | Flamethrower |
| Y | Plasma flash (charges before discharging) |
| LB / L1 | Attract energy |
| RB / R1 | Activate shield |
| Start | Pause / resume; confirm in menus |
| D-pad in menus | Navigate selections |

The HTML5 version currently relies on a controller. **Full keyboard play is not supported or verified**, so please connect a gamepad before starting. The first controller interaction may take **2–3 seconds** to initialize in the browser. The exact mapping may vary with controller and browser.

The developer's local browser runs used VSync with **60 Hz** as the main test reference; a short **75 Hz** test also appeared smooth. This is not a general browser-compatibility guarantee.

## Known pre-alpha limitations

- **Browser exit:** ESC/quit does not terminate the embedded HTML5 game in the same way as the Windows version. Leave or close the browser page to exit.
- **Keyboard and debugging:** keyboard controls are incomplete; browser shortcuts can intercept some developer/debug keys.
- **Collision edge cases:** the Walker stops before Sonec, but Sonec can currently jump into the Walker's body. The Walker's turret remains the primary damage zone.
- **Balance is provisional:** the current normal energy maximum is **4,000**, with **4,500** starting energy (an initial **500** overload). Overload can carry a health cost. The HUD has a larger display range for overload; this does not grant additional energy.
- **Spawning and difficulty:** mine spawn decisions currently depend on game updates, and groups can form naturally. Spawning has deliberately been left unchanged for this pre-alpha so testers can evaluate the actual experience.
- **Not yet included:** complete rebinding/options, achievements, online leaderboards, an AI helper voice, extensive armor/damage-type balancing and a dedicated full keyboard control scheme.

These are known boundaries of the development build, not promises that every possible issue has already been discovered.

## Testing and feedback 💚

We are interested in practical feedback from invited players, especially:

- Does the game start and recognize your controller in your browser?
- Is the combat readable and fun? Does the Alpha-Walker feel fair?
- Are energy usage, mines and weapon strengths understandable?
- Can you pause, die and restart without getting stuck?
- Did you encounter a repeatable bug? Please include browser, operating system, controller and the steps that caused it.

Local developer tests and the first itch.io embedded playtest have been positive, but **external browser/device compatibility remains to be established**.

## Development and project notes

- [HANDOFF.md](HANDOFF.md) — latest confirmed state and next development step
- [TODO.md](TODO.md) — current pre-alpha checklist and deferred work
- [PROJECT.md](PROJECT.md) — game concept, design goals and roadmap
- [TECHNICAL.md](TECHNICAL.md) — implementation notes, technical evidence and earlier tests
- [AGENTS.md](AGENTS.md) — repository collaboration rules
- [AGK Knowledge Base](https://github.com/ChristianEngel19820128/agk-knowledge-base) — reusable AGK findings and experiments

The project is developed in small, individually tested changes. The developer performs the actual AGK Studio compilation and Windows/HTML5 playtests; source analysis and documentation are tracked in Git.

## License

See [LICENSE](LICENSE).
