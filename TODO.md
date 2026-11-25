# SonecBot – Nächste Aufgaben

**Stand:** 25. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] G2d vorbereiten: G2c `d87a2f6` 13/13 bestanden; kleine horizontale Sprungkorrektur und Jetpack ohne Haltezeit außerhalb des normalen Sprungs abstimmen, danach gezielt umsetzen/testen. Lokales Bewegungsbalancing (Sprunghöhe, vertikalen Jetpack-Bruttoschub 0.04 auf 0.02 halbieren; Schwerkraft 0.01 und horizontale Flugbeschleunigung 0.005 unverändert lassen, weitere Konstanten) und Gesamtabnahme; Parameter gesammelt übernehmen. [Spezifikation §13](docs/SONEC_MOVEMENT_SPEC.md#13-offene-detailfragen-für-technische-durchsicht-und-tests).

## Danach / separat

- [ ] Eigenständiges Gameplay-Balancing: Energiefluss, Startenergie, Overload-Tode und Gegnergefährlichkeit (Gegner insgesamt sehr gefährlich, Drohne vergleichsweise harmlos) gemeinsam bewerten. Keine Bearbeitung innerhalb der Bewegungsumstellung; Details im [BACKLOG.md](BACKLOG.md).

- [ ] Sporadisches Sprite nach Neustart reproduzieren und Ursache prüfen.
- [ ] Gelegentlich fehlende Granatwerfer/Flarak/Flak-Direkttreffer untersuchen; Explosionstreffer getrennt betrachten.
- [ ] Flammenwerfer: Kistendeckung, Löschen bei Kollision und beobachtete Flammenkollision bei Flak/Flarak-Silomodus gemeinsam prüfen; Siloschutz erhalten.

Schnelles Fallen durch Plattformen, Seitenkontakt und Mini-Hop werden im Rahmen der Bewegungsumstellung behandelt. Weitere Aufgaben und Balancing: [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md), [BACKLOG.md](BACKLOG.md). Historische Abnahmen bleiben in Git. Aktuelle Übergabe: [HANDOFF.md](HANDOFF.md).
