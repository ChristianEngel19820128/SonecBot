# SonecBot – Nächste Aufgaben

**Stand:** 22. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] **Flarakstellung – Konzept anhand der Entwicklergrafiken abstimmen.** Bilder abwarten, dann Aussehen/Animationsphasen, Aktivierungsdistanz, Zielerfassung, Raketenverhalten und faire Reaktionszeit gemeinsam festlegen. **Noch keine Implementierungsfreigabe.**

## Danach / beobachten

- [ ] **B5c – Plattform-Schutzgrenze langfristig beobachten (kein Blocker).** Der frühere Teiltest 4/5 konnte die Situation direkt unter einer getroffenen Plattform nicht reproduzieren; kein bestätigter Fehler. Nur bei beobachteter Auffälligkeit erneut untersuchen.
- [ ] **Balancing später bündeln.** Drohne: 1,5–3 s Scanintervall, 100-px-Erkennungsmaximum (50 % ohne/75 % mit Ansaugung); Space Jet: Aktivierung im hohen Luftraum; außerdem Minen, Belohnungen und Pickup-Grenzfälle.
- [ ] **Menü-Hilfetexte bei passendem Qualitätsschritt erweitern.** Kein aktueller Implementierungsauftrag.

## Abgeschlossen / Nachweise

- **Drohne D1–D6:** frühere Funktionstests abgenommen; Scan-/Laserverhalten und kürzeres Scanintervall vom Entwickler positiv beurteilt. Temporäre gelbe Scan-Diagnose entfernt. 10° optische Flugneigung und drei mitrotierende Jetstream-Auslässe anhand Screenshot positiv beurteilt (22.11.2026). Kein vollständiger neuer Regressionstest für diese Optik behauptet.
- **Sonec-Zwei-Kreis-Treffer S1–S4:** Gegnergeschosse, direkte Bomberbomben, Minenkontakt und Explosionen lokal getestet (S2 7/7, S3 7/7, S4 8/8). Zentrale Debug-Treffermarkierung für weitere Schadensquellen bleibt eine spätere Option.
- **Nachrichten N1/N2, T4 und F1:** lokal abgenommen; detaillierte Nachweise bleiben in Git und Fach-/Übergabedokumentation.

Weitere Real-Alpha-Arbeit: [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md). Unverbindliche spätere Ideen: [BACKLOG.md](BACKLOG.md). Übergabe: [HANDOFF.md](HANDOFF.md).
