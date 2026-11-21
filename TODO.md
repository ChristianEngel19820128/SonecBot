# SonecBot – Nächste Aufgaben

**Stand:** 21. November 2026 · **Arbeitszweig:** `develop`

Hier stehen nur unmittelbar nächste, gemeinsam zu bearbeitende Schritte. Höchstens 3–5 offene Einträge; keine Releasehistorie und keine Sammlung aller Ideen.

## Jetzt

- [ ] **Bomber B4b – 20 TP als Testwert lokal prüfen.** B4a 2/7 bestätigt (Compile und roter Trefferblitz). Zerstörung, Explosion, weitere Abwürfe, fallende Bomben und Regressionen noch offen; Jet war bei 100 TP zu widerstandsfähig.
- [ ] **PlasmaBlitz gegen Spacejet links/rechts untersuchen.** Entwickler beobachtet Schaden nur nach links; Code zeigt keine absichtliche Richtungsbeschränkung. Mit Effektposition und Jet-Bewegung reproduzieren, Ursache noch offen.
- [ ] **Später: Touchdown-Countdown beim Spielstart.** 'Touchdown in 3 Sekunden.' mit 3→2→1, Sonec erst danach sichtbar und verwundbar; noch nicht implementieren.

**Drohne D1–D6 abgeschlossen:** D6-Funktionstest 8/8 lokal bestanden. Jetstream-Feinschliff (30 ms, Skalierung 0,65, Auslässe −10/0/+10 px, Y+13 px) zuletzt per Screenshot optisch bestätigt; kein erneuter vollständiger Funktionstest nach der letzten Höhenkorrektur. Chat B ersetzt später den provisorischen Spawn-Timer. Testdetails stehen in [HANDOFF.md](HANDOFF.md).

## Pflege

- Erledigtes entfernen, sobald Ergebnis und nötige Testevidenz am passenden Ort dokumentiert sind.
- Weitere Releasearbeit bleibt in der Roadmap; unverbindliche Ideen in [BACKLOG.md](BACKLOG.md).
- Neue Aufgaben erst bei tatsächlicher Priorisierung hier aufnehmen.
- Wiedereinstieg: [HANDOFF.md](HANDOFF.md). Historische Aufgaben und Einzeltests: [Archivübersicht](docs/archive/README.md).

