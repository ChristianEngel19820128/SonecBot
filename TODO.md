# SonecBot – Nächste Aufgaben

**Stand:** 21. November 2026 · **Arbeitszweig:** `develop`

Hier stehen nur unmittelbar nächste, gemeinsam zu bearbeitende Schritte. Höchstens 3–5 offene Einträge; keine Releasehistorie und keine Sammlung aller Ideen.

## Jetzt

- [ ] **D3c/2 – Drohnenlaser-Schaden lokal testen.** D3c/1 vom Entwickler mit **5/5 bestanden** bestätigt. Bei Lasertreffer werden nun testweise **20 Schaden** über die bestehende `ShieldAbsorbDamage`-Logik verteilt (Schild absorbiert ladungsabhängig bis zu 80 %, Rest trifft Gesundheit). Bestehende Schild-/Sonec-Trefferblitze werden verwendet. Laser verschwindet weiterhin beim Treffer; kein zusätzlicher Sound. AGK-Test: Compile, ohne Schild Gesundheitsschaden, mit Schild Ladungsverlust und reduzierter Gesundheitsschaden, Trefferblitze, keine doppelten Treffer, übrige Drohnenfunktionen unverändert. Danach Balancing separat abstimmen.

Die Roadmap-Besprechung ist abgeschlossen. Das Paintball-Easter-Egg ist nach dem Windows-Sichttest vom Entwickler abgenommen. Detaillierte Alpha-Umsetzung folgt in Themenchats; eine feste Reihenfolge ist noch nicht beschlossen.

## Pflege

- Erledigtes entfernen, sobald Ergebnis und nötige Testevidenz am passenden Ort dokumentiert sind.
- Weitere Releasearbeit bleibt in der Roadmap; unverbindliche Ideen in [BACKLOG.md](BACKLOG.md).
- Neue Aufgaben erst bei tatsächlicher Priorisierung hier aufnehmen.
- Wiedereinstieg: [HANDOFF.md](HANDOFF.md). Historische Aufgaben und Einzeltests: [Archivübersicht](docs/archive/README.md).

