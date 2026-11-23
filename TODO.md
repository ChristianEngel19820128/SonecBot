# SonecBot – Nächste Aufgaben

**Stand:** 23. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] **K3.3 – Ausgleichsschritt bei knapper Kistenlandung:** K3.2 (`568e2a2`) vom Entwickler lokal mit 6/6 bestanden; K3.2b Weltrandfix (`b83cc4f`) ebenfalls 6/6 bestanden. K3.3a Animationsgrundlage (`RepeatAnimation`, `Finished`) nach AGK-Reserviertwort-Korrektur vom Entwickler lokal mit 6/6 bestanden (23.11.2026). Als Nächstes K3.3b: kleinen automatischen Ausgleichsschritt bei geringer Geschwindigkeit gezielt umsetzen; schnellen Schwung und aktives Knieschliddern erhalten.
- [ ] **Granatwerfer/Flarak/Flak Direkttreffer:** Nutzer beobachtet gelegentliches Durchfliegen ohne Direkttreffer. Projektilbewegung und Kollisionsprüfung untersuchen; Explosionstreffer getrennt betrachten.
- [ ] **Schnelles Fallen durch Plattformen:** Gemeldeten möglichen Durchfallfehler untersuchen und priorisieren; zunächst reproduzieren und Fallgeschwindigkeit/Plattformprüfung prüfen.
- [ ] **Flammenwerfer/Kisten:** Deckungswirkung als Designentscheidung klären. Plasma-Blitz-Balancing und Rauchwolken an zerstörten Flarak/Flak später separat behandeln.

## Danach / beobachten

B5c Plattform-Schutzgrenze bei reproduzierbarer Auffälligkeit prüfen; Drohnen-/Minen-/Belohnungsbalancing und Menü-Hilfetexte später bündeln.

## Abgeschlossen / Nachweise

- **K3.3a – Wiederverwendbare Animationssteuerung:** Entwickler bestätigt lokalen AGK-Test mit 6/6 bestanden (23.11.2026): Kompilierung, Laufanimation links/rechts, Loop, Standbild beim Anhalten, Springen/Knieschliddern und Kistenlandungen. AGK-Reserviertwörter `Loop` und `Step` wurden in `RepeatAnimation` und `FrameIncrement` umbenannt (`9265f2c`, `9e7256c`).

- **K3.2/K3.2b – Kistenlandung und linker Weltrand:** Entwickler bestätigt beide lokalen AGK-Tests mit jeweils 6/6 bestanden (23.11.2026). Kleine/große Kisten, stabiler Stand, kein Einsinken, seitliches Anlaufen, K2-Ausnahme sowie kein Verlassen/Teleportieren am linken Weltrand. Commits `568e2a2`, `b83cc4f`.

- **K2 – Seitliche Kistenkollision:** Entwickler bestätigt lokalen AGK-Test mit 5/5 bestanden (23.11.2026): Kisten stoppen Sonec beim Anlaufen, schieben ihn nicht aktiv, dürfen ihn am linken Rand durchdringen; kein Herausschieben beim Sprung; Übersprunghilfe unverändert (`c7e1da8`).

- **K1 – Zerstörte Kisten:** Landekollision berücksichtigt nur aktive Kisten (`44783e0`); Entwickler bestätigt lokalen AGK-Test mit 4/4 bestanden (23.11.2026).
- **Flarak/Flak und Raketen:** Entwickler bestätigt beide Stellungen vollständig funktionsfähig, inklusive abschießbarer Raketen. Abfangexplosion auf Raketen-Typ 3 geändert (`3c0606a`). Granaten-Direkttreffer als separater neuer Fehler offen.

- **Drohne D1–D6:** frühere Funktionstests abgenommen; Scan-/Laserverhalten und kürzeres Scanintervall vom Entwickler positiv beurteilt. Temporäre gelbe Scan-Diagnose entfernt. 10° optische Flugneigung und drei mitrotierende Jetstream-Auslässe anhand Screenshot positiv beurteilt (22.11.2026). Kein vollständiger neuer Regressionstest für diese Optik behauptet.
- **Sonec-Zwei-Kreis-Treffer S1–S4:** Gegnergeschosse, direkte Bomberbomben, Minenkontakt und Explosionen lokal getestet (S2 7/7, S3 7/7, S4 8/8). Zentrale Debug-Treffermarkierung für weitere Schadensquellen bleibt eine spätere Option.
- **Nachrichten N1/N2, T4 und F1:** lokal abgenommen; detaillierte Nachweise bleiben in Git und Fach-/Übergabedokumentation.

Weitere Real-Alpha-Arbeit: [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md). Unverbindliche spätere Ideen: [BACKLOG.md](BACKLOG.md). Übergabe: [HANDOFF.md](HANDOFF.md).
