# SonecBot – Nächste Aufgaben

**Stand:** 21. November 2026 · **Arbeitszweig:** `develop`

Hier stehen nur unmittelbar nächste, gemeinsam zu bearbeitende Schritte. Höchstens 3–5 offene Einträge; keine Releasehistorie und keine Sammlung aller Ideen.

## Jetzt

- [ ] **D3b/3 – Drohnen-Aktionspausen lokal prüfen.** D3b/2-Laserprojektil vom Entwickler mit **6/6 bestanden** bestätigt (Compile, Aufladung, beide Flugrichtungen, Start-/Flughöhe, Geschwindigkeit, Bildschirmrand). Beobachtung: Scan und Aufladung wechseln teilweise zu schnell. Testwerte: Scanintervall 3,5–6,5 s statt 2,4–5 s; Ladeintervall 6–10 s statt 4,5–8 s; mindestens 1,2 s gemeinsame Ruhe nach Scan bzw. Schuss, bevor eine neue Scan-/Ladephase beginnt. **Aufladung 900 ms / 3 Frames und Lasergeschwindigkeit bleiben unverändert.** Kurzer AGK-Test: natürlicherer Rhythmus, keine unmittelbaren Wechsel, bestehende Effekte weiterhin sichtbar. Danach Treffer-/Schadenslogik separat abstimmen.

Die Roadmap-Besprechung ist abgeschlossen. Das Paintball-Easter-Egg ist nach dem Windows-Sichttest vom Entwickler abgenommen. Detaillierte Alpha-Umsetzung folgt in Themenchats; eine feste Reihenfolge ist noch nicht beschlossen.

## Pflege

- Erledigtes entfernen, sobald Ergebnis und nötige Testevidenz am passenden Ort dokumentiert sind.
- Weitere Releasearbeit bleibt in der Roadmap; unverbindliche Ideen in [BACKLOG.md](BACKLOG.md).
- Neue Aufgaben erst bei tatsächlicher Priorisierung hier aufnehmen.
- Wiedereinstieg: [HANDOFF.md](HANDOFF.md). Historische Aufgaben und Einzeltests: [Archivübersicht](docs/archive/README.md).

