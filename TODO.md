# SonecBot – Nächste Aufgaben

**Stand:** 25. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] G2d-2: G2d-1 `3e6e07c` 8/8 bestanden, Bewegungsumstellung technisch abgenommen. Entwickler lokales Bewegungsbalancing (Sprunghöhe, vertikaler Jetpack-Bruttoschub 0.02 als Testwert, weitere Konstanten), Gesamtspieltest und reine Parameteränderungen direkt selbst auf develop einchecken. Danach HEAD und Gesamtabnahme dokumentieren. [Spezifikation §13](docs/SONEC_MOVEMENT_SPEC.md#13-offene-detailfragen-für-technische-durchsicht-und-tests).

## Danach / separat

- [ ] Eigenständiges Gameplay-Balancing: Energiefluss, Startenergie, Overload-Tode und Gegnergefährlichkeit (Gegner insgesamt sehr gefährlich, Drohne vergleichsweise harmlos) gemeinsam bewerten. Keine Bearbeitung innerhalb der Bewegungsumstellung; Details im [BACKLOG.md](BACKLOG.md).

- [ ] Sporadisches Sprite nach Neustart reproduzieren und Ursache prüfen.
- [ ] Gelegentlich fehlende Granatwerfer/Flarak/Flak-Direkttreffer untersuchen; Explosionstreffer getrennt betrachten.
- [ ] Flammenwerfer: Kistendeckung, Löschen bei Kollision und beobachtete Flammenkollision bei Flak/Flarak-Silomodus gemeinsam prüfen; Siloschutz erhalten.

Schnelles Fallen durch Plattformen, Seitenkontakt und Mini-Hop werden im Rahmen der Bewegungsumstellung behandelt. Weitere Aufgaben und Balancing: [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md), [BACKLOG.md](BACKLOG.md). Historische Abnahmen bleiben in Git. Aktuelle Übergabe: [HANDOFF.md](HANDOFF.md).
