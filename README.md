# SonecBot 💚

**A side-scrolling sci-fi action game built with AppGameKit Studio.**

Pilot Sonec across moving platforms, fly with an energy-powered jetpack, collect resources and survive encounters with mines, orbs, destructible objects and the heavily armed **Alpha-Walker**. Choose your weapons carefully: flying, shielding yourself and using special weapons all compete for energy.

SonecBot is a reworking of a game originally written in **BlitzBasic Plus**. A later attempt to recreate it in **BlitzMax** was never completed. The preserved legacy sources are in `source/legacy/`; active AppGameKit Studio development is in `source/sonec/`.

## Current status: playable HTML5 pre-alpha

**18 November 2026 — Four-step keyboard controls update completed and developer-tested on Windows and local HTML5/Apache.**

**The updated HTML5 build has been uploaded to the itch.io Draft and the developer reports that it loads.** The final **itch.io embedded gameplay smoke test remains pending** for this keyboard-enabled update. The refreshed itch.io description now introduces the keyboard controls and upcoming Real Alpha goals. The following earlier embed results apply to the previous pre-alpha build.

For the earlier pre-alpha deployment, the developer compiled and exported HTML5, tested it locally through Apache/XAMPP, uploaded the ZIP, and confirmed that the game started inside the itch.io embed. The embedded test verified controller detection, movement (including backward movement and flight), all four weapons, shield, energy attraction, pause, and death by energy depletion/falling. ESC and the quit action are intentionally unavailable in the HTML5 player. No visible tearing was reported in the local browser test; performance on other devices has not yet been established.

**The itch.io page remains in Draft with secret-link access; it is not publicly published.** The secret link can be shared with invited community testers. The exact export SHA was not independently recorded, and repeated restarts have been verified in the local HTML5 session; **a restart in the itch.io embed was subsequently confirmed by the developer**. The Alpha-Walker and initial player-weapon collision paths have passed targeted developer tests.

The itch.io page links to both the [`develop`](https://github.com/ChristianEngel19820128/SonecBot/tree/develop) and [`main`](https://github.com/ChristianEngel19820128/SonecBot/tree/main) GitHub branches, as confirmed by the developer.

## Branches

This repository uses two branches:

- **[`main`](https://github.com/ChristianEngel19820128/SonecBot/tree/main)** — the milestone/reference branch. It is not automatically the latest development version or the same as a public itch.io release.
- **[`develop`](https://github.com/ChristianEngel19820128/SonecBot/tree/develop)** — the active development branch with current changes, experiments, fixes and post-pre-alpha work; individual changes may be unfinished or not yet tested.

For the latest development work, see `develop`. Tested milestones are brought into `main` after review; GitHub milestone merges do **not** publish the itch.io Draft page.

## Gameplay

- **Fly and fight:** navigate a scrolling 2D world with a jetpack, machine gun, flamethrower, plasma flash and grenade launcher.
- **Manage resources:** health, shields, energy and ammunition matter. Energy is shared between movement and several combat abilities.
- **Face different hazards:** mines, orbs, towers and the multi-part **Alpha-Walker**. The Walker patrols platforms, stops in front of Sonec and aims its two-shot bursts; its turret is the intended weak point.
- **Use the environment:** direct hits and nearby explosions can damage targets, and chain reactions can produce surprising encounters.
- **Try again:** game-over and multiple restarts have been tested in the local HTML5 browser, and a restart has also been confirmed inside itch.io.

This is an early experimental build, not a feature-complete game. Balance, objectives and presentation may change in response to player feedback.

## Controls — keyboard and gamepad

**Keyboard support is available in the HTML5 pre-alpha.** All four keyboard-menu steps passed developer-run Windows and local HTML5/Apache checks, including remapping, persistence after browser reload, duplicate-binding indicators, fixed menu navigation and RESTORE DEFAULTS. An Xbox-style compatible gamepad remains recommended.

### Keyboard — default assignments

| Key | Action |
| --- | --- |
| W / A / S / D | Move up / left / down / right |
| Q / E | Move backward left / right |
| J | Machine gun |
| K | Grenade launcher |
| L | Flamethrower |
| I | Plasma flash |
| U | Attract energy |
| O | Energy shield |
| Space | Hover / jetpack |
| Enter | Start / pause |
| Backspace | Back |

Go to **OPTIONS → CONTROLS → KEYBOARD** to view and remap keyboard assignments on the MOVEMENT and ACTIONS pages. Duplicate keys are allowed and shown in red; **CONTROLS → RESTORE DEFAULTS** opens a RESET/CANCEL confirmation, with CANCEL selected initially. This restores keyboard bindings only, preserving gamepad assignments. In menus, **W / S** or the **up / down arrow keys** navigate, **Enter** selects and **Backspace** goes back, regardless of gameplay assignments. Capture accepts letters A–Z, numbers 0–9, Space and the arrow keys; reserved keys such as Enter and Backspace cannot be assigned through capture.

### Gamepad

Tested by the developer using an Xbox-style compatible controller in local HTML5 browser sessions:

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

Both keyboard and gamepad input are supported in the current local HTML5 test build. The first controller interaction may take **2–3 seconds** to initialize in the browser. The exact gamepad mapping may vary with controller and browser. Keyboard rebinding does not change controller assignments.

The developer's local browser runs used VSync with **60 Hz** as the main test reference; a short **75 Hz** test also appeared smooth. This is not a general browser-compatibility guarantee.

## Known pre-alpha limitations

- **Browser exit:** ESC/quit does not terminate the embedded HTML5 game in the same way as the Windows version. Leave or close the browser page to exit.
- **Keyboard and browser shortcuts:** keyboard rebinding supports a deliberate 41-key whitelist (A–Z, 0–9, Space, arrows) to avoid browser-sensitive keys; unrelated browser shortcuts and developer/debug keys may still be handled by the browser.
- **Collision edge cases:** the Walker stops before Sonec, but Sonec can currently jump into the Walker's body. The Walker's turret remains the primary damage zone.
- **Balance is provisional:** the current normal energy maximum is **4,000**, with **4,500** starting energy (an initial **500** overload). Overload can carry a health cost. The HUD has a larger display range for overload; this does not grant additional energy.
- **Spawning and difficulty:** mine spawn decisions currently depend on game updates, and groups can form naturally. Spawning has deliberately been left unchanged for this pre-alpha so testers can evaluate the actual experience.
- **Not yet included:** gamepad rebinding, achievements, online leaderboards, an AI helper voice, extensive armor/damage-type balancing and additional Real Alpha gameplay content. The keyboard menu and keyboard RESTORE DEFAULTS are now implemented and locally tested.

These are known boundaries of the development build, not promises that every possible issue has already been discovered.

## Testing and feedback 💚

We are interested in practical feedback from invited players, especially:

- Does the game load and respond to keyboard or gamepad input in your browser?
- Can you remap keys, cancel safely, restore defaults and retain assignments after reloading?
- Is the combat readable and fun? Does the Alpha-Walker feel fair?
- Are energy usage, mines and weapon strengths understandable?
- Can you pause, die and restart without getting stuck?
- Did you encounter a repeatable bug? Please include browser, operating system, input device (keyboard or controller) and the steps that caused it.

Local developer tests and the earlier itch.io embedded playtest have been positive. **The updated keyboard-enabled itch.io embed still requires its own smoke test**, and external browser/device compatibility remains to be established.

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
