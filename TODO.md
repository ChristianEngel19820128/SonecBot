# SonecBot – Nächste Aufgaben

**Stand:** 25. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] G2d vorbereiten: G2c `d87a2f6` 13/13 bestanden; kleine horizontale Sprungkorrektur und Jetpack ohne Haltezeit außerhalb des normalen Sprungs abstimmen, danach gezielt umsetzen/testen. Lokales Bewegungsbalancing (Sprunghöhe, Flugbeschleunigung, weitere Konstanten) und Gesamtabnahme; Parameter gesammelt übernehmen. [Spezifikation §13](docs/SONEC_MOVEMENT_SPEC.md#13-offene-detailfragen-für-technische-durchsicht-und-tests).

## Danach / separat

- [ ] Sporadisches Sprite nach Neustart reproduzieren und Ursache prüfen.
- [ ] Gelegentlich fehlende Granatwerfer/Flarak/Flak-Direkttreffer untersuchen; Explosionstreffer getrennt betrachten.
- [ ] Flammenwerfer: Kistendeckung, Löschen bei Kollision und beobachtete Flammenkollision bei Flak/Flarak-Silomodus gemeinsam prüfen; Siloschutz erhalten.

Schnelles Fallen durch Plattformen, Seitenkontakt und Mini-Hop werden im Rahmen der Bewegungsumstellung behandelt. Weitere Aufgaben und Balancing: [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md), [BACKLOG.md](BACKLOG.md). Historische Abnahmen bleiben in Git. Aktuelle Übergabe: [HANDOFF.md](HANDOFF.md).
