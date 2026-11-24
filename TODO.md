# SonecBot – Nächste Aufgaben

**Stand:** 24. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] G2: G1 `093c173` technisch 9/9 bestätigt, normaler Sprung laut Freitext nicht gezielt prüfbar. Priorisierte Nacharbeit gemäß [Spezifikation §13](docs/SONEC_MOVEMENT_SPEC.md#13-offene-detailfragen-für-technische-durchsicht-und-tests) gemeinsam freigeben: Start/Jetpack und Hop-Anzeige zuerst, danach Steuerung/Kanten/Tiefenebenen/Geometrie/Rückstoß, Gesamtbalancing.

## Danach / separat

- [ ] Sporadisches Sprite nach Neustart reproduzieren und Ursache prüfen.
- [ ] Gelegentlich fehlende Granatwerfer/Flarak/Flak-Direkttreffer untersuchen; Explosionstreffer getrennt betrachten.
- [ ] Flammenwerfer: Kistendeckung, Löschen bei Kollision und beobachtete Flammenkollision bei Flak/Flarak-Silomodus gemeinsam prüfen; Siloschutz erhalten.

Schnelles Fallen durch Plattformen, Seitenkontakt und Mini-Hop werden im Rahmen der Bewegungsumstellung behandelt. Weitere Aufgaben und Balancing: [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md), [BACKLOG.md](BACKLOG.md). Historische Abnahmen bleiben in Git. Aktuelle Übergabe: [HANDOFF.md](HANDOFF.md).
