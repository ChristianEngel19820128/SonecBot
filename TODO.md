# SonecBot – Nächste Aufgaben

**Stand:** 21. November 2026 · **Arbeitszweig:** `develop`

Hier stehen nur unmittelbar nächste, gemeinsam zu bearbeitende Schritte. Höchstens 3–5 offene Einträge; keine Releasehistorie und keine Sammlung aller Ideen.

## Jetzt

- [ ] **D4b – Automatischen Drohnen-Testspawn lokal prüfen.** Übergangsweise alle 20–35 Sekunden aktiver Spielzeit ein Spawnversuch, höchstens eine aktive Drohne. `DroneAutoSpawnDo` in `drone.agc`, Aufruf in `game.agc`; Chat B entfernt später nur den Timer-Aufruf und übernimmt die Spawnsteuerung. Test: Compile, erster Spawn ohne F6, beide Eintrittsseiten über Neustarts, keine Duplikate, unveränderte Drohnenaktionen, Pause hält Zeit an. Eine zerstörbare Drohne gibt es noch nicht.
- [ ] **D5 – Drohnen-Schaden und Zerstörung (nach D4b-Test).** D5a Gesundheit und Maschinengewehr; D5b Flammenwerfer, Granaten, Plasmablitz **und Explosionen**; D5c Trefferfeedback, Zerstörung, Aufräumen laufender Effekte und erneuter Spawn. Zusätzliche Positionierungsregeln erst bei konkretem Bedarf.


Die Roadmap-Besprechung ist abgeschlossen. Das Paintball-Easter-Egg ist nach dem Windows-Sichttest vom Entwickler abgenommen. Detaillierte Alpha-Umsetzung folgt in Themenchats; eine feste Reihenfolge ist noch nicht beschlossen.

## Pflege

- Erledigtes entfernen, sobald Ergebnis und nötige Testevidenz am passenden Ort dokumentiert sind.
- Weitere Releasearbeit bleibt in der Roadmap; unverbindliche Ideen in [BACKLOG.md](BACKLOG.md).
- Neue Aufgaben erst bei tatsächlicher Priorisierung hier aufnehmen.
- Wiedereinstieg: [HANDOFF.md](HANDOFF.md). Historische Aufgaben und Einzeltests: [Archivübersicht](docs/archive/README.md).

