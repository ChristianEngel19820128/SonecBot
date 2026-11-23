# SonecBot – Nächste Aufgaben

**Stand:** 22. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] **Flarak/Flak Plasma-Blitz Wirkung/Balancing:** Nutzer bestätigt, dass Plasma-Blitz Schaden an beiden Varianten verursacht. Keine bestätigte Kollisionstörung; bisher reicht die Wirkung für die Zerstörung offenbar nicht aus. Trefferintervall, tatsächliche Kontaktzeit und Schaden pro Aktivierung vor einer Balanceentscheidung messen; 150 HP pro Geschütz, derzeit 10 Schaden pro Tick.
- [ ] **Raketen der Raketenstellung – lokaler AGK-Test offen:** Bomberbomben-Konzept für alle vier Spielerwaffen auf aktive Flarak-Raketen übertragen (`2cb2282`, `aa58fba`): ein Treffer entfernt die Rakete und erzeugt einmalig eine rote Typ-1-Explosion; Radius vorläufig 7 px. Maschinengewehr verwendet Geschoss-Sweep; Flamme/Granate verbrauchen ihr Projektil; Plasma bleibt bestehen. Auch bereits abgefeuerte Raketen zerstörter Stellungen sind erfasst. Compiler und Spieltest noch ausstehend. **Rauchende Wracks:** kleine, dezente Rauchwolken nach Zerstörung von Flarak/Flak als spätere Optikaufgabe. Wrack-Grünstich RGB (57,79,57) lokal bestätigt.
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
