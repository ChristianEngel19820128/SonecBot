# SonecBot – Nächste Aufgaben

**Stand:** 25. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] G2b fachlich abstimmen (Tippen/Halten über Key-Bindings, Sprungimpuls bei Richtungswunsch, Granatwerferrückstoß), danach implementieren und gebündelt testen. G2a `a41162c` 8/8 bestanden; agileres Fluggefühl für G2d-Balancing vorgemerkt. G2c Kollisions-/Tiefenebenenregeln und G2d lokales Balancing folgen. [Spezifikation §13](docs/SONEC_MOVEMENT_SPEC.md#13-offene-detailfragen-für-technische-durchsicht-und-tests).

## Danach / separat

- [ ] Sporadisches Sprite nach Neustart reproduzieren und Ursache prüfen.
- [ ] Gelegentlich fehlende Granatwerfer/Flarak/Flak-Direkttreffer untersuchen; Explosionstreffer getrennt betrachten.
- [ ] Flammenwerfer: Kistendeckung, Löschen bei Kollision und beobachtete Flammenkollision bei Flak/Flarak-Silomodus gemeinsam prüfen; Siloschutz erhalten.

Schnelles Fallen durch Plattformen, Seitenkontakt und Mini-Hop werden im Rahmen der Bewegungsumstellung behandelt. Weitere Aufgaben und Balancing: [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md), [BACKLOG.md](BACKLOG.md). Historische Abnahmen bleiben in Git. Aktuelle Übergabe: [HANDOFF.md](HANDOFF.md).
