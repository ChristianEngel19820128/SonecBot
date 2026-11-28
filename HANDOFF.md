# SonecBot – Aktuelle Übergabe

**Stand:** 28. November 2026 · **Arbeitszweig:** develop

## Einstieg

- AGENTS.md und diese Übergabe lesen, tatsächlichen develop-HEAD prüfen.
- Entwickler entscheidet Design, übernimmt Grafik/Sound, lokale Tests und reine Parameterfeinjustierung.
- Assistent implementiert vereinbarte Pakete, prüft Quellen und pflegt betroffene Dokumentation.
- Develop ist nicht der veröffentlichte itch.io-Build.

## Aktueller Projektstand

- Real Alpha, Arbeitsblock A im vereinbarten Umfang abgeschlossen (25.11.2026); A6a Hintergrundkisten lokal AGK-bestanden (10/10, 1a3f642, 25.11.2026); Walker-Durchlässigkeit fd4c4ed anschließend zusammenfassend vom Entwickler akzeptiert (lokale SHA nicht separat bestätigt); A6b größere Rudelformation lokal AGK-bestanden (8/8, f4fd80a, 25.11.2026); Pod-/Minen-Spawnreserve 211fe09 vom Entwickler am 25.11.2026 mit Compile und Sichtprüfung zusammenfassend akzeptiert (lokale SHA nicht separat bestätigt); A5c plattformgebundene Zeichnungsreihenfolge implementiert, lokaler Teiltest 2/6 auf f77a8c3 (25.11.2026); zunächst vier Sichtpunkte mangels überlappender Plattformen offen; im A6b-Test f4fd80a bestätigt der Entwickler die korrekte Tiefendarstellung der Plattformen und ihrer Elemente zusammenfassend. A5c damit abgenommen, keine nachträglichen Einzelhaken oder gesonderte Raketen-/Wrackmatrix behauptet. A5: J1 (Jumppod und gemeinsame Sockelmechanik) lokal abgenommen, 10/10 am 25.11.2026 auf bb16236; J1a (automatischer Aufwärts-Stufenwechsel, oberer Trigger, Mini-Hop abwärts) lokal abgenommen, 9/9 am 25.11.2026 auf ddc24e8; J2 (Landmine als Attrappe) lokal abgenommen, 12/12 am 25.11.2026 auf 517763f; J3 (mechanische Flak/Flarak-Sockel) lokal abgenommen, 10/10 am 25.11.2026 nach Compile-Korrektur ec23637 (Testformular c2858e9; lokale SHA nicht separat bestätigt); J4 (universelle Rauch-Unit) funktional lokal abgenommen, 15/15 am 25.11.2026 nach Compile-Korrektur e17440a (Testformular d35a6e8; lokale SHA nicht separat bestätigt); visuelle Feinjustierung, vertikale Trägerübernahme f591fc7 und Entwicklerstand a2db24a am 25.11.2026 zusammenfassend akzeptiert. A5 einschließlich A5c und Platzierungskorrektur abgeschlossen; keine weiteren Rauchänderungen. [A5-Spezifikation](docs/JUMPPOD_SPEC.md).
- Minen, Walker, Drohne, Bomber, Flarak/Flak, Warnungen und zentrale Rewards im bisherigen Umfang umgesetzt und lokal geprüft.
- Bewegungsumstellung A–G2d einschließlich Jetstream am 25.11.2026 abgeschlossen und vom Entwickler akzeptiert.
- Gemeinsamer Kontaktresolver, Restweg, Trägerbewegung, Tiefenebenen, Fuß-/Kistenkanten, Mini-Hop, Sprung/Jetpack und Rückstoß implementiert.
- Fachliche Endfassung und Abnahme: [Bewegungsspezifikation](docs/SONEC_MOVEMENT_SPEC.md).
- Langzeitbeobachtung und weitere Parameterfeinjustierung möglich; keine separate HTML5-/Langzeitabnahme oder vollständige Randfallmatrix behauptet.
- Schadensgeometrie mit zwei Körperkreisen bleibt von mechanischer Bewegung getrennt.
- Bug-Chat: B1 (vollständiger Neustart-Reset) im geprüften Umfang abgeschlossen. B1.1 Flak/Flarak-Proto und Neustart lokal AGK-bestanden (11/11, a2ea2a8); B1.2–B1.4 MG-Salvenzähler, Plasmablitz-Ladestand und Drohnen-Zerstörungsereignis lokal AGK-bestanden (8/8, 7b9bb48), beide am 25.11.2026. Keine Auffälligkeiten in der zweiten Abnahme. Entwickler wünscht fortlaufende Langzeitbeobachtung beider Pakete bei normalen Spieltests; keine gesonderte Langzeit-/HTML5-Abnahme. Index-Recycling-Verdachtsfälle separat in [KNOWNBUGS.md](KNOWNBUGS.md).
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

B01b ergänzend implementiert: gemeinsame Schadens-/Verursachertypen, `damage.agc`, begrenzte Ereignis-Snapshots und Reset in `GameInit`. Keine aktiven Schadenspfade umgestellt. Lokaler AGK-Compile für B01b erfolgreich gemeldet (28.11.2026, lokale SHA nicht separat bestätigt). B01c1 lokal erfolgreich kompiliert (28.11.2026, lokale SHA nicht separat bestätigt). B01c2 lokal erfolgreich kompiliert (28.11.2026, lokale SHA nicht separat bestätigt). B01d1 lokale Abnahme a13893e bestanden (13/13, 28.11.2026). B01d2 lokale Abnahme 6d80fc9 bestanden (14/14). B01d3 restliche aktive Schadenspfade angebunden; lokale Abnahme offen. Nächster Schritt B01e (Ereignisdiagnostik und Gesamtabnahme). Phase B gemäß [PHASE_B_CONCEPT.md](docs/PHASE_B_CONCEPT.md); ausschließlich B01 bearbeiten. Vorherige ausführliche Übergabe bleibt im Git-Stand `8e59268` erhalten. Keine neuen Bugbefunde registriert.

## Referenzen

- [TODO.md](TODO.md): unmittelbar anstehende Arbeit.
- [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md): Releaseumfang.
- [KNOWNBUGS.md](KNOWNBUGS.md): offene Fehler.
- [BACKLOG.md](BACKLOG.md): Ideen.
- [PROJECT.md](PROJECT.md), [TECHNICAL.md](TECHNICAL.md): Fachreferenzen.
- Historische Übergabe und Bewegungsprotokolle: Git-Stand 0ba2ee8c665325f25a9e7da38a86c9ca49cb7e5a.
