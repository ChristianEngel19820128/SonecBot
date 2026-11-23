# SonecBot – Nächste Aufgaben

**Stand:** 22. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] **Flarak/Flak Plasma-Blitz abschließen:** Nutzer kann beide Varianten damit bislang nicht zerstören; Trefferintervall, tatsächliche Kontaktzeit, Schaden pro Aktivierung und ggf. Geometrie untersuchen. Erst nach Fix erneut lokal testen. Der bisherige Plasma-Blitz hat 10 Schaden pro Tick, 25 Lebenszyklus-Schritte à 10 ms und trifft nach vorhandenem Intervall; 150 HP können damit je Einsatz deutlich zu hoch sein.
- [ ] **Flarak/Flak Trefferfeedback lokal prüfen:** 150-ms-Rotblitz nach Schaden ergänzt; keine AGK-Kompilierung durch Assistenten.
- [ ] **Kistenkollision beim Laufen/Springen untersuchen:** Nutzer meldet mögliches Regressionsverhalten, noch nicht reproduziert.
- [ ] **Flammenwerfer/Kisten Designentscheidung:** Soll Feuer durch Kisten hindurchtreffen dürfen? Vor Änderung entscheiden.
- [ ] **Plasma-Blitz Balancing nach Fehlerbehebung:** Aufwand der Bedienung vs. geringe Wirkung; Dauer und regelmäßigen Schaden überprüfen, ohne vorab Werte festzulegen.

## Danach / beobachten

B5c Plattform-Schutzgrenze bei reproduzierbarer Auffälligkeit prüfen; Drohnen-/Minen-/Belohnungsbalancing und Menü-Hilfetexte später bündeln.

## Abgeschlossen / Nachweise

- **Drohne D1–D6:** frühere Funktionstests abgenommen; Scan-/Laserverhalten und kürzeres Scanintervall vom Entwickler positiv beurteilt. Temporäre gelbe Scan-Diagnose entfernt. 10° optische Flugneigung und drei mitrotierende Jetstream-Auslässe anhand Screenshot positiv beurteilt (22.11.2026). Kein vollständiger neuer Regressionstest für diese Optik behauptet.
- **Sonec-Zwei-Kreis-Treffer S1–S4:** Gegnergeschosse, direkte Bomberbomben, Minenkontakt und Explosionen lokal getestet (S2 7/7, S3 7/7, S4 8/8). Zentrale Debug-Treffermarkierung für weitere Schadensquellen bleibt eine spätere Option.
- **Nachrichten N1/N2, T4 und F1:** lokal abgenommen; detaillierte Nachweise bleiben in Git und Fach-/Übergabedokumentation.

Weitere Real-Alpha-Arbeit: [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md). Unverbindliche spätere Ideen: [BACKLOG.md](BACKLOG.md). Übergabe: [HANDOFF.md](HANDOFF.md).
