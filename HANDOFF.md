# SonecBot – Aktuelle Übergabe

**Stand:** 24. November 2026 · **Arbeitszweig:** `develop`

## Einstieg

- [AGENTS.md](AGENTS.md) und diese Übergabe lesen, tatsächlichen develop-HEAD prüfen.
- Entwickler entscheidet Design gemeinsam, erstellt Grafik/Sound und übernimmt lokale AGK-Tests sowie gegebenenfalls Parameteranpassungen.
- Assistent implementiert vereinbarte Pakete, prüft Quellcode und aktualisiert betroffene Dokumentation.
- Develop nicht mit veröffentlichtem itch.io-Build gleichsetzen.

## Aktueller Auftrag: Bewegungsumstellung

Verbindliche Grundlage: [SONEC_MOVEMENT_SPEC.md](docs/SONEC_MOVEMENT_SPEC.md).

- Phase A abgeschlossen und lokal geprüft.
- Phase B: gemeinsamer Kontaktresolver und Restwegschleife implementiert, Compile und Plattformtests bestätigt. Die damaligen Kistentunnelbefunde sind im B/C-Nachtest nicht mehr aufgetreten; gezielte Kontaktreihenfolge/Restwegfälle bleiben Integrationsprüfung.
- Entwickler meldet am 24.11.2026: Spiel verhält sich nachvollziehbar für den aktuellen Stand. B3h im kompilierten Paket enthalten. Anschließender Test: schnelle Plattformlandung und Randverhalten erwartungsgemäß; Kistenseiten beim Laufen und Springen/Fallen links nach rechts durchlässig, rechts nach links blockierend. Direkt vor der Kiste Bewegung und Sprung beidseitig blockierend.
- Phase C: Frontlinie ±25 Welteinheiten am Boden, zwei Luftkreise, relative Seitenblockade. B/C-Test `0d0d7a0` 8/9, Nachtest `b1a21dd` 5/5 einschließlich AGK-Compile, Fallen und Springen beidseitig, Landungen/Unterseitendurchflug bestanden. Entwickler akzeptiert Grundverhalten. Luft-Gewehrüberdeckung links unterschiedlich weit, rechts nicht beobachtet; Bodenabstand korrekt. Kreisgeometrie beabsichtigt, Ursache der Richtungsdifferenz nicht bewiesen. Kleiner optischer Rückversatz beim Lauf rechts nach links aus vorherigem Test in Phase D nicht mehr aufgetreten; Luft-Gewehrüberdeckung nicht gesondert rückgemeldet.
- Seitliches Tunneln, Zurückwerfen und unbegrenzte Luftbeschleunigung sind bekannte Ausgangsprobleme; keine vorzeitige Abnahme.
- Phase D implementiert: additiver tatsächlicher Trägerweg, Eigen-/Weltgeschwindigkeit bei Bodenkontaktwechsel umgerechnet, relative Wandgeschwindigkeit und kombinierte Weltgrenze. Umrechnungsmaßstab: letzter Sonec-Timerschritt. Entwickler bestätigt `36a7f23` 9/9, Gesamtergebnis bestanden, einschließlich Mitnahme, Gegenlaufen, Absprung ohne Geschwindigkeitssprung, Kistenkontakt ohne Zurückwerfen, Luftkontakt, Weltrand und Landungen. Neues Sonderproblem: bei schnellem Fallen mit aktiviertem Jetpack vor Umkehr der Fallgeschwindigkeit kann Sonec durch Plattformen fallen. Jetpack-Nachkorrektur implementiert: Oberseitenprüfung bei fehlendem Bodenkontakt unabhängig vom Fall-Flag; Landung beendet Fly. AGK-Nachtest `be7dc31` 6/6 bestanden: Compile, schnelle Jetpack-Landungen auf Plattform/Kiste, erneutes Abheben bei gehaltenem Up, normale Landungen und Durchflug von unten. Phase D einschließlich Nachkorrektur im getesteten Umfang abgeschlossen. E–G folgen.

## Vereinbarter Arbeitsmodus für die Bewegungsumstellung

- Zusammenhängende Änderungen als Paket bearbeiten; nachvollziehbare Commits nach technischen Grenzen.
- Keine isolierten Compiler-Tests für reine vorbereitende Strukturänderungen; gemeinsame Prüfung am sinnvollen Paketende.
- Statische Quellprüfung von tatsächlichen lokalen AGK-Tests unterscheiden.
- Keine zusätzlichen Freigaben für notwendige Teilschritte im vereinbarten Umfang.
- Bei neuer Designentscheidung oder wesentlicher Umfangserweiterung Rücksprache.
- Dokumentation aktualisieren statt chronologisch anhängen; historische Nachweise bleiben in Git.
- Allgemeine Repository-Regeln bleiben unverändert.

## Weitere Projektstände

- Walker, einfache Minen, Drohne, Bomber, Nachrichten und zentrale Rewards wurden in früheren Entwicklungsrunden lokal geprüft; historische Einzelabnahmen in Git.
- Flarak/Flak einschließlich abschießbarer Raketen vom Entwickler als funktionsfähig bestätigt (siehe bisheriges TODO).
- Zwei-Kreis-Schadensgeometrie für Gegnergeschosse, direkte Bomberbomben, Minen, Explosionen und Drohnenlaser lokal geprüft; mechanische Bewegungsgeometrie davon getrennt.
- Frühere Kistenlandungs-, Seitenkontakt- und Mini-Hop-Tests gelten für damalige Revisionen; spätere Bewegungsregressionen sind Gegenstand der aktuellen Umstellung.
- Sporadisches Sprite nach Neustart und gelegentlich fehlende Granatwerfer-Direkttreffer bleiben separate Fehlerverdachte.
- Flammenwerfer/Kistendeckung bleibt Designfrage; Plasma-Blitz-Balancing und Rauchwolken später separat.
- Debug-Masterschalter und bestehende Diagnosemöglichkeiten erhalten; keine beiläufigen Änderungen.
- Keine neue Deadline; Alpha, Balancing, Deployment und HTML5 getrennt behandeln.

## Genau ein nächster vereinbarter Schritt

Phase E gemeinsam beginnen: Tiefenebenen und Durchflug fremder Plattformen einschließlich aller zugehörigen Kisten gemäß Bewegungsspezifikation umsetzen; Ebenenwechsel erst bei gültiger Landung. Keine neue Codefreigabe allein aus Testergebnis.

## Referenzen

- [TODO.md](TODO.md): unmittelbar offene Aufgaben.
- [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md): Releaseumfang.
- [BACKLOG.md](BACKLOG.md): spätere Ideen.
- [PROJECT.md](PROJECT.md), [TECHNICAL.md](TECHNICAL.md): relevante Fachabschnitte.
- [Archivübersicht](docs/archive/README.md): historische Langfassungen.
- Frühere Übergabe vollständig in Git vor diesem Bereinigungscommit erhalten.
