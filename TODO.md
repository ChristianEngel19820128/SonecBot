# SonecBot – Nächste Aufgaben

**Stand:** 21. November 2026 · **Arbeitszweig:** `develop`

Hier stehen nur unmittelbar nächste, gemeinsam zu bearbeitende Schritte. Höchstens 3–5 offene Einträge; keine Releasehistorie und keine Sammlung aller Ideen.

## Jetzt

- [ ] **D6 – Jetstream-Feinabstimmung lokal prüfen.** Funktionstest zuvor mit **8/8 bestanden**. Nach Screenshot wurden Intervall von 30 auf 50 ms und X-Offsets von −14/0/+14 auf −10/0/+10 px angepasst. Jetzt nur visuelle Dichte, Auslasspositionen und unverändertes Verhalten prüfen; lokaler Nachtest offen.

**Drohne D1–D5c vorerst abgeschlossen.** D5c vom Entwickler mit **8/8 bestanden** bestätigt: Compile, Trefferblinken, einmalige Zerstörungsexplosion, sauberes Aufräumen, volle Gesundheit beim Respawn, wiederholte Zyklen, keine unerwünschten Explosionsschäden und keine Langzeitauffälligkeiten. Farbabgleich nach D5c: Drohnen-Trefferfeedback an Rumpf, Sensoren und Fallback auf Standardrot RGB (255,0,0) gesetzt; Farbänderung vom Entwickler visuell bestätigt. Kein weiterer Drohnen-Codeauftrag; Chat B übernimmt später die Spawnsteuerung.

D5b vom Entwickler mit **7/7 bestanden** bestätigt: Flammenwerfer, Granat-Direkttreffer, Plasma und Explosionen beschädigen/zerstören Drohne, neuer Spawn und keine Regressionen; keine Auffälligkeiten.

D5a vom Entwickler mit **7/7 bestanden** bestätigt (lokaler AGK-Test): MG trifft und zerstört Drohne, Angriffe enden, Timer erzeugt später neue Drohne, keine Regressionen; keine Auffälligkeiten.

D4b vom Entwickler am 21.11.2026 im lokalen AGK-/Windows-Test mit **6/6 bestanden** bestätigt: Compile, automatischer Spawn nach 20–35 Sekunden, beide Eintrittsseiten, maximal eine Drohne, unveränderte Funktionen, pausierender Timer. Keine Auffälligkeiten. Der Timer bleibt vorläufig aktiv und wird später durch Chat B ersetzt.



Die Roadmap-Besprechung ist abgeschlossen. Das Paintball-Easter-Egg ist nach dem Windows-Sichttest vom Entwickler abgenommen. Detaillierte Alpha-Umsetzung folgt in Themenchats; eine feste Reihenfolge ist noch nicht beschlossen.

## Pflege

- Erledigtes entfernen, sobald Ergebnis und nötige Testevidenz am passenden Ort dokumentiert sind.
- Weitere Releasearbeit bleibt in der Roadmap; unverbindliche Ideen in [BACKLOG.md](BACKLOG.md).
- Neue Aufgaben erst bei tatsächlicher Priorisierung hier aufnehmen.
- Wiedereinstieg: [HANDOFF.md](HANDOFF.md). Historische Aufgaben und Einzeltests: [Archivübersicht](docs/archive/README.md).

