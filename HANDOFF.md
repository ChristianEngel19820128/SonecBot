# SonecBot – Aktuelle Übergabe

**Stand:** 25. November 2026 · **Arbeitszweig:** `develop`

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
- Phase D implementiert: additiver tatsächlicher Trägerweg, Eigen-/Weltgeschwindigkeit bei Bodenkontaktwechsel umgerechnet, relative Wandgeschwindigkeit und kombinierte Weltgrenze. Umrechnungsmaßstab: letzter Sonec-Timerschritt. Entwickler bestätigt `36a7f23` 9/9, Gesamtergebnis bestanden, einschließlich Mitnahme, Gegenlaufen, Absprung ohne Geschwindigkeitssprung, Kistenkontakt ohne Zurückwerfen, Luftkontakt, Weltrand und Landungen. Neues Sonderproblem: bei schnellem Fallen mit aktiviertem Jetpack vor Umkehr der Fallgeschwindigkeit kann Sonec durch Plattformen fallen. Jetpack-Nachkorrektur implementiert: Oberseitenprüfung bei fehlendem Bodenkontakt unabhängig vom Fall-Flag; Landung beendet Fly. AGK-Nachtest `be7dc31` 6/6 bestanden: Compile, schnelle Jetpack-Landungen auf Plattform/Kiste, erneutes Abheben bei gehaltenem Up, normale Landungen und Durchflug von unten. Phase D einschließlich Nachkorrektur im getesteten Umfang abgeschlossen.
- Phase E implementiert: Durchflugstatus pro aktiver Plattform (neutral, Passage, freigegeben), gemeinsame Höhenfreigabe für sämtliche zugehörigen Kisten; relative Höhenfreigabe als Ereignis im Resolver. Alte Einzelkisten-Ausnahme bleibt nur für die eigene Ebene. Ebenenwechsel nur bei Landung; ungültige gelöschte Ebene wird auf -1 gesetzt. Entwicklertest `f2acaae` 9/9 bestanden einschließlich Compile. Beobachtungen: Plattformübernahme situationsabhängig unfair, noch nicht genau reproduzierbar; bei vertikal bewegter potenzieller Plattform scheint die Übernahmeberechtigung trotz veränderter absoluter Höhe unverändert; Plattform unter Umständen nicht betretbar, obwohl aktuell weit oben. Ursache offen. Y-Snapshots werden aktualisiert; gespeicherter Passagezustand bleibt im Höhenband zwischen Plattform und höchster Kiste erhalten. E-Beobachtungen werden gemeinsam auf den Gesamtspieltest G verschoben; E bleibt in F unverändert.
- Phase F implementiert: Mini-Hop ausschließlich beim tatsächlichen Verlust eines Kistensupports, unabhängig von Eingabe und Anfangsgeschwindigkeit. Vertikalimpuls 1,5 (bisheriger Wert), relative X-Mindestgeschwindigkeit 1,0 (vorläufiger Testwert), Trägerimpuls einmalig, Restweg erneut geprüft. Entwicklertest `f4424a1` 9/9 bestanden inkl. Compile, langsame/schnelle beidseitige Hops, Ausrollen, einmalige Auslösung, bewegte Kisten, Sprünge/Plattformkanten, Landungen/Seitenkontakte/Weltrand. Zusätzliche Beobachtung: beim Fallen auf Kistenrand etwa halbe vertikale Durchdringung, offenbar keine Kollision und kein Hop. Mittelpunktlage zum tatsächlichen Fußkontakt und Tiefenebene noch nicht eindeutig; mögliche Ursache ist strikte Mittelpunktprüfung der Oberseite. G gezielt prüfen.
- Phase G1 implementiert: normaler Sprung erhält X-Schwung bis Landung/Jetpack, expliziter horizontaler Schubzustand statt Recoil-/Move-Flag, aktiver Luftschub bis ±5 (vorläufiger Testwert; vorhandenes stärkeres Momentum nicht gekappt), Jetpack bremst Fall kontinuierlich statt Abwärtskappung. CSV-Diagnose für relative Fußkreuzung und E/F-Auffälligkeiten ergänzt. E-Höhenregel und F-Randgeometrie unverändert. Entwicklertest `093c173` technisch bestanden, 9/9 angekreuzt; normale Sprünge laut Freitext wegen Energieüberschuss noch nicht gezielt prüfbar. Keine Gesamtspielgefühl-Abnahme. Elf Nacharbeitsbeobachtungen mit Aufwand/Priorität in Bewegungsspezifikation Abschnitt 13; keine neue Codefreigabe. Start außerhalb + Jetpack, schwacher vertikaler Schub, Tiefenebenen und Luft-/Bodengeometrie zuerst; Kanten, Rückstoß und Tippen/Halten gemeinsam abstimmen; alte Hop-Anzeige entfernen; Flammenwerfer separat.
- G2a implementiert nach Abstimmung: alle Sonec-Eingaben bis vollständigem Welteintritt gesperrt, getrennte Schwerkraft/Bruttoschub/Sprungimpuls/Grenzen, optionales Fallmaximum zunächst aus. Zentrale Konstanten in sonec.agc; alte Hop-Anzeige entfernt, CSV erhalten. Entwicklertest `a41162c` 8/8 bestanden inkl. AGK-Compile. Beobachtung: Sonec weniger träge und relativ flott in der Luft; Feinjustierung vereinbarungsgemäß G2d, vorläufige Werte unverändert.
- G2b implementiert: sofortiger Sprung bei neuer Hoch-Eingabe am Boden, Jetpack nach 180 ms Halten, Energiezufluss weiter wirksam; kein Dauersprung. Horizontaler Mindestimpuls optional (0 deaktiviert), vorhandenen Gegenschwung erhalten. Granatwerferrückstoß additiv (1,0), keine Eingabeflag-Änderung; Richtung umkehrbar. Entwicklertest `6c53fac` 11/11 bestanden inkl. AGK-Compile, Tippen/Halten, Fall, Loslassen, kein Dauersprung, Schwung, Rückstoß und bisherige Kontakte. Keine zusätzlichen Beobachtungen. Optionaler Mindestimpuls bleibt 0; Nichtnullwerte im G2d-Balancing prüfen.
- G2c nach Abstimmung implementiert: Fußgrenze, richtungsabhängige Kistenrandlandung, Plattformfall ohne Hop, kombinierte Seitenlinie/Kreise und begrenzte Abstandskorrektur; horizontale Ebenenlösung und lokale dynamische Freigabehöhe (100). Entwicklertest `d87a2f6` 13/13 bestanden inkl. AGK-Compile; keine offenen Prüfpunkte. CSV erhalten. Neue Beobachtungen: kleine Sprungkorrekturen nötig, Sprunghöhe zu hoch, Jetpack ohne Verzögerung außerhalb des normalen Sprungs, vertikalen Jetpack-Bruttoschub 0.04 auf 0.02 halbieren, Schwerkraft 0.01 und horizontale Flugbeschleunigung 0.005 unverändert; Energieüberschuss/Overload-Tode, Gegner gefährlich, Drohne vergleichsweise harmlos. Steuerungsnacharbeit vor G2d-Balancing abstimmen; Energie/Gegner als eigener TODO-Punkt separat.

## Vereinbarter Arbeitsmodus für die Bewegungsumstellung

- Zusammenhängende Änderungen als Paket bearbeiten; nachvollziehbare Commits nach technischen Grenzen.
- Je G2-Paket fachliche Abstimmung, Implementierung, statische Prüfung, gebündelter lokaler Compile/Funktionstest. Vorläufige Parameter nur ändern, wenn der Funktionstest sonst nicht aussagekräftig ist; finale Feinjustierung lokal in G2d, gesammelt übernehmen. Prozess-/Dokumentationsauswertung separat am Ende.
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

G2d vorbereiten: kleine horizontale Sprungkorrektur und unmittelbare Jetpack-Aktivierung im freien Flug/Fall fachlich abstimmen; Haltezeit beim normalen Sprung und Begrenzung der Sprungkorrektur klären. Gewünschte Schubhalbierung ist geklärt: nur vertikaler Bruttoschub 0.04 auf 0.02, lokal balancieren. Danach gezielte Steuerungsnacharbeit und lokales Bewegungsbalancing mit gesammelt übernommenen Konstanten; Energie/Gegner separat.

## Referenzen

- [TODO.md](TODO.md): unmittelbar offene Aufgaben.
- [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md): Releaseumfang.
- [BACKLOG.md](BACKLOG.md): spätere Ideen.
- [PROJECT.md](PROJECT.md), [TECHNICAL.md](TECHNICAL.md): relevante Fachabschnitte.
- [Archivübersicht](docs/archive/README.md): historische Langfassungen.
- Frühere Übergabe vollständig in Git vor diesem Bereinigungscommit erhalten.
