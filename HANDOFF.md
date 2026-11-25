# SonecBot – Aktuelle Übergabe

**Stand:** 25. November 2026 · **Arbeitszweig:** develop

## Einstieg

- AGENTS.md und diese Übergabe lesen, tatsächlichen develop-HEAD prüfen.
- Entwickler entscheidet Design, übernimmt Grafik/Sound, lokale Tests und reine Parameterfeinjustierung.
- Assistent implementiert vereinbarte Pakete, prüft Quellen und pflegt betroffene Dokumentation.
- Develop ist nicht der veröffentlichte itch.io-Build.

## Aktueller Projektstand

- Real Alpha, Arbeitsblock A weiterhin aktiv; A5 fachlich abgestimmt: J1 (Jumppod und gemeinsame Sockelmechanik) lokal abgenommen, 10/10 am 25.11.2026 auf bb16236; J1a (automatischer Aufwärts-Stufenwechsel, oberer Trigger, Mini-Hop abwärts) lokal abgenommen, 9/9 am 25.11.2026 auf ddc24e8; J2–J4 noch nicht implementiert. [A5-Spezifikation](docs/JUMPPOD_SPEC.md).
- Minen, Walker, Drohne, Bomber, Flarak/Flak, Warnungen und zentrale Rewards im bisherigen Umfang umgesetzt und lokal geprüft.
- Bewegungsumstellung A–G2d einschließlich Jetstream am 25.11.2026 abgeschlossen und vom Entwickler akzeptiert.
- Gemeinsamer Kontaktresolver, Restweg, Trägerbewegung, Tiefenebenen, Fuß-/Kistenkanten, Mini-Hop, Sprung/Jetpack und Rückstoß implementiert.
- Fachliche Endfassung und Abnahme: [Bewegungsspezifikation](docs/SONEC_MOVEMENT_SPEC.md).
- Langzeitbeobachtung und weitere Parameterfeinjustierung möglich; keine separate HTML5-/Langzeitabnahme oder vollständige Randfallmatrix behauptet.
- Schadensgeometrie mit zwei Körperkreisen bleibt von mechanischer Bewegung getrennt.
- Offene Fehler und Verdachtsfälle stehen in [KNOWNBUGS.md](KNOWNBUGS.md), nicht als parallele TODO-Liste. J1-Test identifizierte den bekannten Neustart-Spritefehler als Flarak-Rakete; fehlender Flarak-Reset in GameInit quellenbelegt, Korrektur noch offen.
- Energieüberschuss, Overload und Gegnergefährlichkeit im nachgelagerten Gameplay-Balancing behandeln.
- Debug-Masterschalter und Diagnosemöglichkeiten erhalten; keine beiläufigen Änderungen.
- Keine Deadline; HTML5, Deployment, Balancing und Fehleranalyse getrennt behandeln.

## Arbeitsprozess

- Paketorientierte Entwicklung und gebündelte Tests gemäß AGENTS.md sind bewährter Standard.
- Keine erneuten Freigaben innerhalb vereinbarter Pakete; neue Designentscheidungen abstimmen.
- Statische Prüfungen und lokale AGK-Evidenz unterscheiden.
- Dokumentation aktualisieren statt Testchronik anhängen; Routineberichte kompakt halten.
- Prozessretrospektive abgeschlossen: verbliebene Bewegungsphasen in einem Chat ohne Limit, Entwickler berichtet etwa doppelte Effizienz.

## Genau ein nächster Schritt

J2 (Landmine als Attrappe) gemäß [docs/JUMPPOD_SPEC.md](docs/JUMPPOD_SPEC.md) umsetzen; die gemeinsame Sockel- und Treppenmechanik ist lokal abgenommen. Bestehender Flarak-Neustartfehler ausdrücklich zurückgestellt; keine Korrektur im A5-Paket.

## Referenzen

- [TODO.md](TODO.md): unmittelbar anstehende Arbeit.
- [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md): Releaseumfang.
- [KNOWNBUGS.md](KNOWNBUGS.md): offene Fehler.
- [BACKLOG.md](BACKLOG.md): Ideen.
- [PROJECT.md](PROJECT.md), [TECHNICAL.md](TECHNICAL.md): Fachreferenzen.
- Historische Übergabe und Bewegungsprotokolle: Git-Stand 0ba2ee8c665325f25a9e7da38a86c9ca49cb7e5a.
