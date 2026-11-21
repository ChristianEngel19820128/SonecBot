# SonecBot – Nächste Aufgaben

**Stand:** 21. November 2026 · **Arbeitszweig:** `develop`

Hier stehen nur unmittelbar nächste, gemeinsam zu bearbeitende Schritte. Höchstens 3–5 offene Einträge; keine Releasehistorie und keine Sammlung aller Ideen.

## Jetzt

D4b vom Entwickler am 21.11.2026 im lokalen AGK-/Windows-Test mit **6/6 bestanden** bestätigt: Compile, automatischer Spawn nach 20–35 Sekunden, beide Eintrittsseiten, maximal eine Drohne, unveränderte Funktionen, pausierender Timer. Keine Auffälligkeiten. Der Timer bleibt vorläufig aktiv und wird später durch Chat B ersetzt.

- [ ] **D5a – Gesundheit und Maschinengewehr lokal prüfen.** Drohne hat 100 HP, MG-Geschosse nutzen die bestehende Nearest-Hit-Sweep-Prüfung (46×30 px Drohnenbox), richten ihren vorhandenen Waffenschaden an und werden beim Treffer entfernt. Bei 0 HP wird die Drohne deaktiviert und ihre Laser-/Aktionszustände beendet; späterer Timer-Spawn setzt Gesundheit zurück. Test: Compile, Treffer, mehrere Treffer, Zerstörung, erneuter Spawn, keine Doppeltreffer/Regression. Explosion und weitere Waffen folgen D5b; visuelles Zerstörungsfeedback D5c.
- [ ] **D5b/D5c – Weitere Waffen und Abschluss.** Flammenwerfer, Granaten, Plasmablitz und Explosionen; danach Trefferfeedback, Zerstörungseffekt und längerer Spieltest. Zusätzliche Positionierungsregeln erst bei konkretem Bedarf.


Die Roadmap-Besprechung ist abgeschlossen. Das Paintball-Easter-Egg ist nach dem Windows-Sichttest vom Entwickler abgenommen. Detaillierte Alpha-Umsetzung folgt in Themenchats; eine feste Reihenfolge ist noch nicht beschlossen.

## Pflege

- Erledigtes entfernen, sobald Ergebnis und nötige Testevidenz am passenden Ort dokumentiert sind.
- Weitere Releasearbeit bleibt in der Roadmap; unverbindliche Ideen in [BACKLOG.md](BACKLOG.md).
- Neue Aufgaben erst bei tatsächlicher Priorisierung hier aufnehmen.
- Wiedereinstieg: [HANDOFF.md](HANDOFF.md). Historische Aufgaben und Einzeltests: [Archivübersicht](docs/archive/README.md).

