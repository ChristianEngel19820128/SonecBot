# SonecBot – Nächste Aufgaben

**Stand:** 21. November 2026 · **Arbeitszweig:** `develop`

Hier stehen nur unmittelbar nächste, gemeinsam zu bearbeitende Schritte. Höchstens 3–5 offene Einträge; keine Releasehistorie und keine Sammlung aller Ideen.

## Jetzt

D5a vom Entwickler mit **7/7 bestanden** bestätigt (lokaler AGK-Test): MG trifft und zerstört Drohne, Angriffe enden, Timer erzeugt später neue Drohne, keine Regressionen; keine Auffälligkeiten.

D4b vom Entwickler am 21.11.2026 im lokalen AGK-/Windows-Test mit **6/6 bestanden** bestätigt: Compile, automatischer Spawn nach 20–35 Sekunden, beide Eintrittsseiten, maximal eine Drohne, unveränderte Funktionen, pausierender Timer. Keine Auffälligkeiten. Der Timer bleibt vorläufig aktiv und wird später durch Chat B ersetzt.

- [ ] **D5b – Alle übrigen Waffen lokal testen.** Flammenwerfer, Granat-Direkttreffer, Plasmablitz und Explosionen können die Drohne beschädigen/zerstören. Explosionen nutzen je Explosion einen eigenen Trefferabstand. Test: Compile, alle vier Trefferarten, Tod und neuer Spawn, keine Waffenregression. Code umgesetzt; Entwicklerabnahme offen.
- [ ] **D5c – Drohnenabschluss nach D5b.** Trefferfeedback, Zerstörungseffekt, Aufräumen laufender Effekte und längerer Spieltest. Zusätzliche Positionierungsregeln nur bei konkretem Bedarf.


Die Roadmap-Besprechung ist abgeschlossen. Das Paintball-Easter-Egg ist nach dem Windows-Sichttest vom Entwickler abgenommen. Detaillierte Alpha-Umsetzung folgt in Themenchats; eine feste Reihenfolge ist noch nicht beschlossen.

## Pflege

- Erledigtes entfernen, sobald Ergebnis und nötige Testevidenz am passenden Ort dokumentiert sind.
- Weitere Releasearbeit bleibt in der Roadmap; unverbindliche Ideen in [BACKLOG.md](BACKLOG.md).
- Neue Aufgaben erst bei tatsächlicher Priorisierung hier aufnehmen.
- Wiedereinstieg: [HANDOFF.md](HANDOFF.md). Historische Aufgaben und Einzeltests: [Archivübersicht](docs/archive/README.md).

