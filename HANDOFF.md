# SonecBot – Aktuelle Übergabe

**Stand:** 21. November 2026 · **Arbeitszweig:** `develop`

Diese Datei ermöglicht den nächsten Chatwechsel. Sie wird aktualisiert und gekürzt, nicht um Chatprotokolle erweitert.

## Einstieg und Arbeitsstand

- Zuerst [AGENTS.md](AGENTS.md) und diese Übergabe lesen, dann den tatsächlichen `develop`-HEAD abfragen.
- Code-Referenz der letzten Entwicklungsrunde: [`c2a2d4e`](https://github.com/ChristianEngel19820128/SonecBot/commit/c2a2d4ed1dd7b27de6aa13f1058a5431509b2d45).
- Dokumentationsbasis vor dieser Roadmap-Festlegung: [`87927e5`](https://github.com/ChristianEngel19820128/SonecBot/commit/87927e564d5ce1539878b84773c8f8ea40c258d5). Feste Quellenreferenz, kein dauerhaft aktueller HEAD.
- Die Real-Alpha-Richtung und die drei letzten Grundsatzfragen wurden am 20.11. gemeinsam geklärt und dokumentiert. Neue Funktionen sind geplant, noch nicht durch diese Dokumentation implementiert.
- Es gibt keine neue Deadline. Alpha-Entwicklung, Balancing, Deployment und HTML5-Themen dürfen getrennte Chats beanspruchen.
- Den aktuellen `develop`-Stand nicht mit dem auf itch.io hochgeladenen Build gleichsetzen; der Export-SHA wurde nicht durchgehend protokolliert.

## Implementiert und vom Entwickler geprüft

Die folgenden Angaben beruhen auf dokumentierten Entwicklertests. Der Assistent hat hier weder AGK kompiliert noch Windows-/HTML5-Laufzeittests durchgeführt.

| Bereich | Übernahmestand und Evidenz |
| --- | --- |
| Alpha-Walker | Vom Entwickler abgeschlossener Referenzstand. IK, Pivots, Grafikprototypen, Zielen und Rückstoß erhalten; keine erneute Politur als Standardauftrag. |
| Tastatur / Pre-Alpha | Belegung, Umbelegung und Wiederherstellung der Standardtasten umgesetzt; lokaler HTML5-Abschluss und itch.io-Draft-Smoke-Test gemeldet, letzterer am 18.11. mit 12/12. |
| Einfache Minen | S1–S3 umgesetzt und mit 9/9, 10/10, 12/12 unter Windows und lokalem HTML5 bestätigt. Minen verfolgen Sonec nicht und reagieren nicht auf Energieanziehung. |
| Warnsystem | S4-Minenfeldwarnung funktional unter Windows/HTML5 gesehen; daraus keine vollständige nummerierte S4-Abnahme ableiten. |
| Drohne D1–D6 | D1 ursprünglich 11/11 unter Windows/HTML5; D4b 6/6, D5a 7/7, D5b 7/7, D5c 8/8 und D6 8/8 lokal abgenommen. Aktueller Stand unten; letzter Jetstream-Feinschliff visuell bestätigt. |
| K1b / K1c | Zuverlässigere Projektiltreffer per Segmentprüfung gegen Zielklassen bzw. Sonec; jeweils 12/12 gemeldet, einschließlich lokalem HTML5. |
| E1b | Unabhängige Explosions-Schadenszeitpunkte für einfache/intelligente Minen; 9/9 einschließlich unabhängiger Treffer beider Minenarten innerhalb derselben Explosion und lokalem HTML5 gemeldet. |
| K1d | Zwei-Kreis-Körperkollision gegen Gegnerbullets aktiv; Waffenbereich ausgeschlossen. Frühere Diagnose-only-Notizen sind überholt. |

**Abendrunde 19./20.11.:** Der Entwickler bestätigt zusammenfassend, dass alle an diesem Abend implementierten Änderungen erfolgreich getestet wurden. Das gilt als Entwicklerabnahme; fehlende Einzelprotokolle werden weder erfunden noch als pauschal offene Tests behandelt.

Zusätzlich in dieser Runde umgesetzt:

- Debug-Tasten 1–7 und HTML5-Hinweise zu Canvas-Fokus und erster Gamepad-Eingabe.
- Grünes Sonec-Farbfeedback, rotes Aufblitzen bei tatsächlichem Health-Schaden und eisblaues Schildfeedback bei Absorption.
- Health-Regenerations-Upgrade-Timer, Boden-Laufgeschwindigkeitsbegrenzung/Bremsen und FIFO-Nachrichten mit Upgrade-Feedback korrigiert bzw. ergänzt.
- Mintfarbener Upgrade-Stern; ausgeschöpfte Burst-Pickups wechseln zu Fire-Rate-Upgrades.
- Paintball-Easter-Egg im Hauptmenü mit anklickbaren Energie-Orbs, bleibenden Spritzflecken und animierten Laufspuren.

## Aktueller Drohnenstand (21.11.2026)

- **D1–D6 funktional abgeschlossen:** Patrouille/Schweben, Scan, grüne Ladeanimation und Laser, 100 HP, Schaden durch Maschinengewehr, Flammen, Granaten, Plasma und Explosionen, rotes Trefferfeedback (RGB 255/0/0), einmaliger Zerstörungseffekt sowie drei Jetstreams.
- **Entwicklerabnahmen:** D4a 6/6, D4b 6/6, D5a 7/7, D5b 7/7, D5c 8/8 und D6-Funktionstest 8/8. Letzter Jetstream-Feinschliff: X-Offsets −10/0/+10 px, Y+13 px, 30-ms-Takt und Partikelskalierung 0,65. Der Entwickler bestätigt anhand eines Screenshots die optische Ausrichtung; kein zusätzlicher vollständiger Funktionstest nach der letzten 3-px-Verschiebung gemeldet.
- **Temporärer Spawn:** Der pausierbare 20–35-Sekunden-Timer bleibt vorerst aktiv. Der F6-Testhook wurde entfernt. Chat B soll später den Timer-Aufruf durch die zentrale Spawn-/Wellensteuerung ersetzen; `DroneSpawn` bleibt als API bestehen und lässt maximal eine aktive Drohne zu.
- **Bewusst offen:** Endgültiges Balancing und optionaler Art-Pass; Schadenshöhen-Farbspektrum und Drohnenschild sind nur BACKLOG-Ideen. Ein gelegentliches Biep ist geplant, aber nicht als implementiert bestätigt.
- **Nach Abschluss des Bombers vormerken (Entwicklerbeobachtung):** Drohnen-Jetstream sitzt optisch nicht optimal. Zuerst Auslasspositionen prüfen und anpassen; Drohnen-Sprite möglichst unverändert lassen. Kein aktueller Codeauftrag und keine Vermischung mit der behobenen Kamerakorrektur.

## Bomber B1 – Überflug und Doppeljet abgeschlossen

- **Quellstand auf `develop`:** `source/sonec/media/gfx/enemies/spacejet.png` (176×64 px); einzelner `TBomber`, noch keine Bomben/Schadenslogik.
- **B1 vom Entwickler lokal in AGK/Windows mit 6/6 bestanden:** Compile, Vorwarnung, Welt-Y-Höhenbereich, kompletter Überflug, Jetstream ohne Sonec-/Drohnenregression und höchstens ein Testanflug pro Spielstart bestätigt.
- **B1-Feinschliff vom Entwickler mit 4/5 geprüft:** 10–30 % Welt-Y, 0,40 px/ms, Grün RGB (80,232,80) und unveränderte Warnung/Einmal-Spawn bestätigt. Einzig der Jetstream ist im Screenshot noch lückenhaft.
- **B1-Jetstream-Nachbesserung vom Entwickler mit 5/5 bestanden:** Compile, dichte gleichmäßige Spur, Skalierung 1,0, vertikal mittiger Auslass und unveränderte übrige Spielfunktionen. Zwei Screenshots optisch beurteilt; Einzelstrahl ist die bewährte Referenz.
- **B1-Doppeljet-Experiment vom Entwickler mit 5/5 bestanden:** Compile, beide Heckstrahlen sichtbar/getrennt und proportional, keine Regressionen. Entwickler bevorzugt Doppeljet, wünscht beide Austritte 3 px tiefer. **Nur diese Korrektur im Code, Sichtvergleich offen:** oberer x=Breite−5/y=Mitte+1, unterer x=Breite−8/y=Mitte+11. Partikelverteilung, Größe 1,0 und Lebensdauer unverändert. Zwei Vergleichsscreenshots folgen.
- **Doppeljet-Optik anhand dreier Screenshots vom Entwickler bestätigt:** Die angepassten Auspufföffnungen passen zu den zwei Strahlen; diese Variante soll bleiben.
- **Jetfire-Kamerakorrektur vom Entwickler lokal mit 6/6 bestanden:** Compile, korrektes Mitscrollen bereits erzeugter Partikel, beide Spacejet-Auslässe, Sonec- und Drohnen-Jetfire sowie Pause/Lebensdauer bestätigt. Gemeinsame `JetfireDraw`-/`JetfireDrawAll`-Funktionen berechnen Bildschirmpositionen pro Zeichenframe aus Welt- und Kameraposition. B1 ist damit abgenommen.
- **Spätere Bombenentscheidung:** Fünf zeitversetzte Bomben mit Bomber-Anfangsgeschwindigkeit und Luftwiderstand. Direkttreffer: kinetischer Schaden **plus** Explosion; abgeschossene Bomben explodieren ebenfalls. Echte Plattformdeckung und gegebenenfalls sichtbar beschnittene Explosionsanimation erfordern eine gesonderte Erweiterung der allgemeinen Explosionsphysik. Bomber selbst soll abschießbar, sein Abschuss aber selten sein.

## Bestätigte Alpha-Planung

Verbindlicher Planungsrahmen und Details: [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md). Einzelne Codeeingriffe werden weiterhin im jeweiligen Themenchat vereinbart.

- Gegnervielfalt: Drohne mit kurzen grünen Laserprojektilen, Ladeanzeige und gelegentlichem Biep; stationäre Flarak; schneller Höhenbomber als einzelner Spawn. Walker bleibt akzeptierte Basis.
- Weitere Weltobjekte: hilfreicher Jumppod für sehr hohen kostenlosen Sprung; drei Minenformationen mit variabler Anzahl/Abständen. Warn-/Hilfekern ist bereits vorhanden und wird inhaltlich erweitert.
- Grundsysteme: Erfahrung, Ressourcen, Gefahrenbudget und kleine Spielziele. Überleben liefert einen kleinen Fortschrittsbeitrag; tatsächlicher Schaden, Zerstörung und sinnvoller Ressourcengewinn zählen stärker. Kein Perk-Kauf mit Erfahrung.
- Budget: erst Timer und aktive Gefahr `G < B` prüfen, dann zufälligen Spawn bestimmen. Gesamtpreis `P <= B` erforderlich; danach ist `G + P > B` erlaubt. Kein Nachwürfeln auf einen passend billigen Ersatz.
- Mit dem Level steigen Spitzen und Erholungsbudget; Vernichtung verdient eine Spawnpause, links verschwundene Gegner keine zusätzliche Pause. Genaue Werte/Zurechnung später.
- Auswählbare Spezialmunition und ein einfaches Panzerungs-/Schadensmodell gehören als testbare Basis zur Alpha. Bei voller Standardmunition ersetzt Spezialmunition einen entsprechenden Teil; volle Standardmunition plus Standardpickup erzeugt keinen Vorratsgewinn und wenig bis keine Erfahrung.
- Fairness gilt für Spieler und Gegner. Vorsichtiges Sammeln zählt; aufgebaute Vorteile dürfen später herausgefordert werden. Deckung, Ausweichen und Flucht bleiben gültig, kein allgemeiner Vernichtungszwang.
- Quadrokopter, Fallen-/Waffenvarianten, weitergehende Missionen, Punkte/Ranglisten und mögliche Schwierigkeitsauswahl bleiben im [BACKLOG.md](BACKLOG.md). Grafische Endfassungen und umfassendes Balancing sind kein Vorab-Gate für die Funktionsentwicklung.

## Letzter abgeschlossener Schritt

- **A3 – Zufälliges Minenrudel:** Code auf `develop` in [`74c7e9e`](https://github.com/ChristianEngel19820128/SonecBot/commit/74c7e9e34d1030fe66557ac86b0703f37b293975). Entwickler meldet am 20.11.2026 **9/9 bestanden** im lokalen AGK-Test: Compile, Rudelgrößen 3–6, unregelmäßige begrenzte Platzierung ohne Überlappung, gemeinsame Drift, vertikale Weltgrenzen, unveränderte Diagonalen/Keile, höchstens sechs aktive einfache Minen, Treffer und Kettenreaktionen. Keine Auffälligkeiten; kein eigener HTML5-Test gemeldet. Damit A1 (8/8), A2 (9/9), A3 (9/9) vollständig abgenommen. Balancing vor Alpha-Release.

- **A1/A2 – Minenformationen:** A1 (variable Diagonale, 2–4 Minen) vom Entwickler lokal in AGK mit **8/8 bestanden** bestätigt. A2 (linksgerichteter symmetrischer Keil mit 3/5 Minen) in [`252a320`](https://github.com/ChristianEngel19820128/SonecBot/commit/252a320bd39017bd3737dfcbf4a52cf4bf4266eb) umgesetzt und am 20.11.2026 vom Entwickler lokal in AGK mit **9/9 bestanden** bestätigt: Compile, beide Keilgrößen, Symmetrie, gemeinsame Bewegung, variable Abstände, Weltgrenzen, bestehende Diagonalen, maximal sechs aktive einfache Minen, Treffer/Kettenreaktionen. Keine Auffälligkeiten; kein eigener HTML5-Test gemeldet. Balancing vor Alpha-Release.
- **E1c – Animierter Explosionsradius:** Code auf `develop` in [`3c8a8cf`](https://github.com/ChristianEngel19820128/SonecBot/commit/3c8a8cf8f28fc00c589b9c140786f60bbca7a610). Zufallsskalierung entfernt; drei typabhängige Maximalradien wachsen und schrumpfen mit der Animation. Entwickler meldet am 20.11.2026 **7/7 bestanden** im lokalen AGK-Test: Compile/Start, Animation, alle drei Typen, Sonec-Schaden, beide Minentypen, Kettenreaktionen, Kisten/Walker. Keine Auffälligkeiten; keine eigenständige HTML5-Prüfung gemeldet. Schadensbalancing bleibt vor dem Alpha-Release gesondert.

## Offene oder zurückgestellte Punkte

- **M1 / Bewegungsruckeln:** Ursachenuntersuchung ausdrücklich zurückgestellt. Bei 75 Hz war das Ruckeln laut Entwickler nicht mehr vorhanden; Ursache und plattformübergreifende Wirkung sind unbewiesen. Umgang mit dem früher vereinbarten Alpha-Gate vor Release gesondert entscheiden; keine automatische Wiederaufnahme oder Abnahme.
- **Browserlaufzeit:** Nach längerem Testen half laut Entwickler ein Browserneustart gegen Performance-Einbußen. Bei Vergleichen frischen Start und längere Sitzung getrennt beobachten; ein Neustart klärt die Ursache nicht. Siehe [TECHNICAL.md](TECHNICAL.md).
- **Paintball-Optik abgeschlossen:** Entwickler bestätigt unter Windows mit Screenshot korrekte Fleckenausrichtung nach AGK-UV-Korrektur, ein Pixel breite farblich passende Laufnasen nach unten sowie normales Orb-/Menüverhalten. Kein weiterer Paintball-Schritt offen.
- **Drohne/Assets:** D1–D6 sind funktional abgeschlossen; optionaler Art-Pass bleibt getrennt. Legacy-Grafiken belegen keine fertigen früheren Gegnerfunktionen.
- Weitere Qualitätsbefunde und technische Detailentscheidungen stehen in der [Real-Alpha-Roadmap](REAL_ALPHA_ROADMAP.md); keine Wiederholung als zweite Aufgabenliste.

## Arbeitsaufteilung und Tests

- **Alpha-Entwicklung:** Themenchats für A Gegner/Weltobjekte, B Grundsysteme, C Spielziele und D Präsentation/Qualität. Abgestimmte Themenwechsel sind möglich; jeweils einen kleinen Schritt abschließen.
- **Balancing:** Eigener Chat für Gegnerdichte, Formationen, Ressourcen, Upgrades und Schwierigkeit; vorläufige Werte bleiben als solche erkennbar.
- **Deployment:** Eigener Chat für Build-Zuordnung, Upload und Release-Entscheidungen. itch.io bleibt nach bisheriger Vereinbarung Draft/Secret URL; `main` und Veröffentlichung brauchen einen eigenen Auftrag.
- **HTML5:** Plattformbezogene Fragen und ein gemeinsamer Meilensteincheck können in einem eigenen Chat gebündelt werden. Keine vollständige Windows-/HTML5-Wiederholung für jede Kleinigkeit.
- Tests richten sich nach der Änderung. Entwicklerberichte, statische Prüfung und tatsächliche Laufzeittests getrennt ausweisen; vereinbarte vertagte Prüfungen als solche erhalten.

## Genau ein nächster Schritt

**Bomber B2f – Plattformbewegung und seitliche Schadenswirkung lokal testen.** B2e/4 vom Entwickler **5/6 bestätigt**, rechte Kante nicht geprüft (kein Fehler). Neue Umsetzung: Bombenexplosion merkt sich die getroffene Plattform und folgt deren X-/Y-Bewegung; visuelle Scissor-Kanten und Schadensoberkante wandern mit. Bombenradius-Schaden unterhalb der Oberfläche ist jetzt seitlich **außerhalb** der Plattform möglich, unter ihr bleibt Schutz bestehen. Normale Explosionen unverändert. Plattform-Follow wird nach PlateMoveAll aktualisiert; bestehende Kollisionsrunde liegt davor, daher kann Schadensprüfung maximal einen Frame hinter der Plattformbewegung liegen. Lokaler AGK-Test offen: Compile, Mitwandern, linke/rechte Kante, Schutz und Regressionen. Vorab-Rendering nicht umgesetzt; kinetischer Schaden, Bombenabschuss und Bomberzerstörung offen; Drohnen-Jetstream später; `main` unberührt.

## Weiterführende Dokumente

- [TODO.md](TODO.md): nur die unmittelbar nächsten Aufgaben.
- [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md): Releaseumfang und offene Entscheidungen.
- [BACKLOG.md](BACKLOG.md): unverbindliche Ideen ohne Releasezusage.
- [PROJECT.md](PROJECT.md) / [TECHNICAL.md](TECHNICAL.md): nur passende Konzept- bzw. Technikabschnitte nachlesen.
- [Archivübersicht](docs/archive/README.md): frühere Langfassungen und historische Testdetails; kein Pflichtlesestoff beim Chatstart.

