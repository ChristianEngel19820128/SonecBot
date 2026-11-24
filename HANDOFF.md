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
- Phase B: gemeinsamer Kontaktresolver und Restwegschleife implementiert; AGK-Compile des Code-Commits `18a6154` vom Entwickler bestätigt; Plattformtests bestanden, seitliches Kistentunneln links nach rechts bestätigt; vollständige funktionale Abnahme offen.
- Entwickler meldet am 24.11.2026: Spiel verhält sich nachvollziehbar für den aktuellen Stand. B3h im kompilierten Paket enthalten. Anschließender Test: schnelle Plattformlandung und Randverhalten erwartungsgemäß; Kistenseiten beim Laufen und Springen/Fallen links nach rechts durchlässig, rechts nach links blockierend. Direkt vor der Kiste Bewegung und Sprung beidseitig blockierend.
- Kontaktwahl: Kisten-/Plattformoberseite, Kistenseite, Durchflugeintritt und Stützverlust; zeitlich interpolierte Restwegprüfung, alte getrennte Resolver entfernt. Phasen C–F bleiben fachlich offen.
- Seitliches Tunneln, Zurückwerfen und unbegrenzte Luftbeschleunigung sind bekannte Ausgangsprobleme; keine vorzeitige Abnahme.
- Phasen C–G gemäß Spezifikation: mechanische Geometrie, Plattformmitnahme, Tiefenebenen, Mini-Hop, Integration/Balancing.

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

Phase-B-Testbefund gemeinsam bewerten: Plattformlandung im getesteten Umfang bestätigt; richtungsabhängiges Kistentunneln nicht abgenommen. Vorschlag: Seitenauflösung im Rahmen Phase C korrigieren, relative Mitnahme mit Phase D abstimmen und offene Kontaktreihenfolge/Restbewegung im gemeinsamen Regressionstest prüfen. Übergang gemeinsam entscheiden.

## Referenzen

- [TODO.md](TODO.md): unmittelbar offene Aufgaben.
- [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md): Releaseumfang.
- [BACKLOG.md](BACKLOG.md): spätere Ideen.
- [PROJECT.md](PROJECT.md), [TECHNICAL.md](TECHNICAL.md): relevante Fachabschnitte.
- [Archivübersicht](docs/archive/README.md): historische Langfassungen.
- Frühere Übergabe vollständig in Git vor diesem Bereinigungscommit erhalten.
