# SonecBot – Real Alpha Roadmap

**Stand:** 24. November 2026 · **Arbeitsbranch:** `develop`
**Status:** Gegnergrundversionen weitgehend abgeschlossen; Bewegungsumstellung in Arbeit; Jumppod und Grundsysteme offen.
**Quellenbasis:** Entwicklerentscheidungen im Gespräch; Dokumentstand [`87927e5`](https://github.com/ChristianEngel19820128/SonecBot/commit/87927e564d5ce1539878b84773c8f8ea40c258d5), letzte Code-Referenz [`c2a2d4e`](https://github.com/ChristianEngel19820128/SonecBot/commit/c2a2d4ed1dd7b27de6aa13f1058a5431509b2d45).
Nächste Aufgaben: [TODO.md](TODO.md) · Chatübergabe: [HANDOFF.md](HANDOFF.md) · Spätere Ideen: [BACKLOG.md](BACKLOG.md).
Die Roadmap legt den Entwicklungsrahmen fest. Einzelne Codeänderungen, `main`-Merge und Veröffentlichung werden separat vereinbart.

## 1. Ziel und gemeinsame Designregeln

Die Real Alpha soll unterschiedliche spielerische Situationen und testbare Grundsysteme für aussagekräftiges Spielerfeedback bieten.
Eigenständige Gegnerrollen haben Vorrang vor vielen Varianten desselben Gegners; fehlende Endgrafiken sind kein Entwicklungsblocker.
Es gibt keine feste Deadline. Umfangreiche Politur und endgültiges Balancing bis Version 1.0 bleiben spätere Arbeit.

- **Fairness für Spieler und Gegner:** Vorsichtige Spieler nicht grundlos überrollen; tatsächlich aufgebaute Vorteile und Vorräte sollen langfristig herausgefordert werden.
- **Wirkung zählt:** Erfahrung folgt bedeutsamen Leistungen und tatsächlichem Ressourcengewinn. Ein bloß ausgelöstes Ereignis ist noch kein Fortschritt.
- **Mehrere Überlebenswege:** Kämpfen, Sammeln, Deckung, Ausweichen und Fliehen sind sinnvoll; nicht jeder Gegner muss zerstört werden.
- **Rhythmus und Wachstum:** Belastung und begrenzte Erholung wechseln sich ab; mit dem Level steigen beide Gefahrenniveaus langfristig.
- **Zufall mit Reaktionsmöglichkeit:** Gegnerzusammenstellung und Belohnungen variieren; Angriffe bleiben erkennbar. Eine fehlende dominante Strategie ist ein Testziel, keine Garantie.

## 2. Bereits vorhandene Grundlage

| Bereich | Dokumentierter Bestand und Testevidenz |
| --- | --- |
| Pre-Alpha / Walker | Alpha-Walker abgeschlossen; akzeptierte IK, Pivots, Zielen und Rückstoß erhalten. Tastaturbelegung, Rebinding, Persistenz und Reset vorhanden; Draft-Embed am 18.11. mit 12/12 gemeldet. |
| Minen S1–S3 | Einfache Minen, diagonale Dreierformation und wiederkehrende Spawns; 9/9, 10/10 und 12/12 Entwicklertests. Einfache Minen verfolgen Sonec nicht und reagieren nicht auf Energieanziehung. |
| Warnungen / Drohne | Warn-/Hilfekern flexibel erweiterbar, Minenwarnung funktional unter Windows/HTML5 gemeldet. D1: unbewaffnete Patrouillenbasis, 11/11 gemeldet; 400-ms-Wende später positiv bewertet. |
| Treffer / Explosionen | K1b und K1c jeweils 12/12; K1d-Zwei-Kreis-Körperkollision aktiv. E1b: getrennte Explosions-Schadenszeitpunkte beider Minenarten, 9/9 gemeldet. |
| Abendrunde 19./20.11. | Debug-Tasten 1–7, HTML5-Eingabehinweise, Treffer-/Schildfarben, Regen-Timer-Fix, FIFO-Upgrade-Meldungen, Laufbegrenzung/Bremsen, Upgrade-Stern, Burst-Fallback und Menü-Paintball umgesetzt. |

Der Entwickler bestätigt alle implementierten Änderungen der Abendrunde zusammenfassend als erfolgreich getestet.
Fehlende Einzelmatrizen oder genaue Plattformzuordnungen werden nicht erfunden; der Assistent hat keine eigenen AGK-/Browserläufe durchgeführt.
Der Draft-Test vom 18.11. belegt keine Auslieferung späterer Alpha-Änderungen. Aktueller Arbeitsstand: [HANDOFF.md](HANDOFF.md); historische Einzelabnahmen bleiben in Git.

## 3. Arbeitsblock A – Gegner und hilfreiche Weltobjekte

### Minenformationen

- **Drei Formationen umgesetzt:** variable Diagonale (2–4 Minen, A1: 8/8 AGK-bestätigt), linksgerichteter symmetrischer Keil (3/5 Minen, A2: 9/9 AGK-bestätigt) und zufälliges Rudel (3–6 Minen in begrenztem Bereich, A3: 9/9 AGK-bestätigt). Abstände variieren; Balancing später.
- Bestehende Minentypen und ihre Unterschiede erhalten. Abstände dürfen unterschiedliche Kettenreaktionen ermöglichen.
- Aktuelle 18–30 Sekunden zwischen Spawnversuchen und maximal sechs einfache Minen sind vorläufige Ausgangswerte; das Gefahrenbudget wird später gemeinsam integriert.

### Drohne

- **D1–D6 als funktionsfähiger Luftgegner abgeschlossen:** Patrouille/Schweben, Scan, sichtbares Aufladen, kurze grüne Laserprojektile, Gesundheit und Treffer durch alle vorgesehenen Spielerwaffen, Zerstörung/Respawn sowie drei Jetstreams.
- **Teststand:** D4b 6/6, D5a 7/7, D5b 7/7, D5c 8/8 und D6 8/8 lokal abgenommen. Letzte Jetstream-Positionierung per Screenshot optisch bestätigt; ein vollständiger erneuter Funktionstest nach der letzten Höhenkorrektur ist nicht separat dokumentiert.
- **Integration später:** Provisorischer 20–35-Sekunden-Spawn-Timer wird durch Chat B bei der Wellensteuerung ersetzt; maximal eine Drohne gleichzeitig. Grafischer Art-Pass, Biep-Sound und Dauerlaser sind nicht als abgeschlossene Basisfunktionen belegt; Dauerlaser bleibt spätere Variante.

### Flarakstellung und Flak

- **Grundversion abgeschlossen:** Entwickler bestätigt beide Stellungen vollständig funktionsfähig, einschließlich abschießbarer Raketen (früheres TODO, vor Bereinigung 759298e).
- Stationäre Luftabwehr mit sichtbarer Aktivierung, Ausrichtung und Doppelraketen; Flak als Variante mit Viererschuss-Salve und explosiven Geschossen.
- Gelegentlich fehlende Direkttreffer des Granatwerfers bleiben separater Fehlerverdacht; keine erneute pauschale Öffnung der Gegnerabnahme.
- Massenraketenwerfer und missionsabhängige Luftunterstützung bleiben spätere Erweiterungen.

### Bomber

- **Grundversion abgeschlossen:** Überflug mit Vorwarnung, Doppeljetstream, Bombenabwurf, zerstörbare Bomben und abschießbarer Bomber umgesetzt; frühere Entwicklerabnahmen in Git.
- Plattformdeckung und Explosionsschaden wurden implementiert und lokal geprüft; abschließendes Balancing bleibt offen.
- Bomber-Abschüsse sollen selten bleiben; kein Vernichtungszwang. Charakteristischer Ankündigungssound und weitere Politur bei Bedarf prüfen.

### Jumppod – offen

- **Hilfreiches Weltobjekt:** löst einen deutlich höheren Sprung ohne Energieverbrauch aus. Die vorhandene Animation gehört zum Sprung.
- Kein Gegnertyp. Die seltene explodierende Täuschungsvariante ist optional und müsste rechtzeitig erkennbar sein; hilfreicher Jumppod bleibt die Basis.

Legacy-Grafiken (`rakstellung.png`, `spacejet.png`, `falle.bmp`) sind Vorlagen, kein Beweis fertig implementierter Altmechaniken.
`falle.bmp` bezeichnet den Jumppod. Neue Grafikfassungen können separat entstehen; alte Konzepte müssen nicht unverändert übernommen werden.

### Sonec-Bewegungsumstellung – in Arbeit

- Verbindliche Anforderungen und Phasen A–G: [SONEC_MOVEMENT_SPEC.md](docs/SONEC_MOVEMENT_SPEC.md).
- Phase A abgeschlossen und lokal geprüft; Phase B kompiliert (`18a6154`), Plattformtests bestanden, Kistentunneln bestätigt. Phase C implementiert; gemeinsamer B/C-Regressionstest und AGK-Compile offen.
- Mechanische Kontakte, Plattformmitnahme, Tiefenebenen, Mini-Hop und Integration gemäß Spezifikation abschließen.

## 4. Arbeitsblock B – Erfahrung, Ressourcen und Gefahr

### Erfahrung durch Leistung und Überleben – offen

- Erfahrung steuert den dauerhaften Level-/Gefahrenfortschritt; sie ist **keine Währung für einen Perk-Shop**.
- Tatsächlicher Schaden zählt, Zerstörung grundsätzlich mehr als bloßes Verletzen; eine besondere taktische Beeinträchtigung kann zusätzlich wertvoll sein.
- Derselbe bereits erreichte Zustand ist nicht bei jedem weiteren Treffer erneut ein neuer Erfolg. Ins Leere schießen bringt keine Erfahrung.
- Tatsächlich gewonnene Energie, Munition und sinnvolle Vorratsverbesserungen zählen ebenfalls; vorsichtigeres Sammeln ist eine gültige Spielweise.
- **Bloßes Überleben liefert einen kleinen Beitrag:** längeres Überleben soll sich lohnen. Sein Ertrag kann der kleinste Fortschrittsbeitrag sein; Sammeln notwendiger Energie ist wertvoller.
- Mehr bedeutsame Wirkung in kurzer Zeit bedeutet schnelleren Fortschritt. Eine zusätzliche kurzfristige Aktivitätskennzahl ist nicht beschlossen.
- Höhe und Takt der Zeitbelohnung, Erfahrungswerte und Levelschwellen bleiben Balancingfragen; kein bestimmter linearer oder beschleunigter Zeitbonus ist festgelegt.

### Ressourcen, auswählbare Munition und Panzerung – offen

- Eine **spielbare, erweiterbare Grundversion** von auswählbaren Munitionsarten und Schadens-/Panzerungswirkung gehört zur Real Alpha.
- Aktive Auswahl durch den Spieler wird gegenüber automatischer Munitionspriorisierung bevorzugt; Bedienung und erste Typenauswahl im Themenchat festlegen.
- Standardmunition unter Kapazität: auffüllen. Standardmunition bereits voll plus weiterer Standardpickup: kein Vorratszuwachs, wenig bis keine Erfahrung.
- Beispiel: voller Standardvorrat plus panzerbrechender Pickup **ersetzt die entsprechende Menge Standardmunition** durch Spezialmunition; keine künstliche Erhöhung der Gesamtkapazität.
- Explosiv- und panzerbrechende Geschosse sind besprochene Beispiele. Umrechnungsmenge, Kapazitäten und Umgang mit bereits gemischten Vorräten werden vor Umsetzung konkretisiert.
- Energie und Munition sind Belohnungen und Überlebensmittel. Aufbau von Vorräten darf spätere Herausforderung begründen; wirkungsloses Einsammeln erzeugt keinen künstlichen Fortschritt.
- Einfache Schadenskategorien/Widerstände ermöglichen später das Konterprinzip. Keine vollständige Rüstungsmatrix oder endgültigen Multiplikatoren für die Alpha verlangen.
- Walker-Beinschäden sind ein Beispiel für taktische Wirkung, kein beschlossener Umbau der akzeptierten Walker-Kollision.

### Gefahrenbudget und Erholung – offen

`G` ist die aktuelle Gefahr aus aktiven Gegnerkosten, `B` das momentan erlaubte Budget, `P` der Preis eines gewürfelten Gegners oder einer gesamten Formation.

- Das Budget wächst innerhalb einer Belastungsphase zum Levelmaximum; anschließend folgt eine begrenzte Erholungsphase mit niedrigerem Budget.
- Mit steigenden Levels wachsen sowohl Maximalbudget als auch Erholungsbudget: langfristig ansteigendes Sägezahn-/Wellenmuster.
- Erholung soll Gefahr weiterhin zulassen. Das niedrigere Budget ist keine Pflicht, sofort einen Mindestbesatz aufzufüllen; bestehende Gegner werden nicht allein wegen einer Budgetsenkung entfernt.
- Ein normaler Spawn-Timer begrenzt die Versuche. Erst wenn der Timer erlaubt und **`G < B`** gilt, wird Gegner/Formation einschließlich Anzahl gewürfelt.
- Der einzelne Spawn muss **`P <= B`** erfüllen. Ein für die gesamte aktuelle Stufe zu teurer Kandidat entfällt; keine Suche nach einem passend zugeschnittenen Ersatz.
- Bei zulässigem Preis wird gespawnt und `P` zu `G` addiert. **`G + P` darf `B` überschreiten**; danach blockieren weitere Spawns, solange `G >= B` ist.
- Beispiel ohne Balancevorgabe: `B=100`, `G=80`, `P=40` erlaubt den Anstieg auf 120; `P=140` ist unzulässig.
- Alle beteiligten Spawnquellen müssen dieselbe aktuelle Budgetlage berücksichtigen; Objekt-/Platzierungsbedingungen gelten zusätzlich.
- Verschwindet ein Gegner, wird sein Beitrag frei. **Vernichtung gewährt eine verdiente Spawnpause**; links aus der Welt verschwinden gewährt keine zusätzliche Pause zum normalen Timer.
- Zurechnung von Kettenreaktionen, konkrete Pausendauer und Umgang mit noch aktiven Bomben nach Gegnerabgang im technischen Entwurf klären.
- Gegnerpreise, Kurven, Erfahrung und Belohnungen werden gemeinsam getestet. Höhere Vorräte sollen helfen, ohne die langfristig steigende Herausforderung dauerhaft auszuhebeln.

## 5. Arbeitsblock C – Kleine Spielziele und Belohnungen

- **Zentrales Belohnungssystem: Grundversion abgeschlossen.** Vorhandene Drops zentralisiert und fehlende Drops für Kisten, Drohnen und Bomber ergänzt; Entwicklerabnahmen E2d/E2e in Git. Mengen und Ersatznutzen bleiben Balancingfragen.
- **Kleine Spielziele: offen.**

- Kleine, verständliche Ziele gehören zur Alpha-Grundlage; konkrete erste Ziele und Erfolgserkennung im eigenen Themenchat auswählen.
- Belohnungen können Ressourcen, Munition oder Upgrades sein. Sie müssen zur zunehmenden Gefahr passen; genaue Mengen bleiben offen.
- Ziele dürfen unterschiedliche Spielweisen berücksichtigen. Allgemeiner Spielfortschritt verlangt nicht, alle Gegner zu vernichten.
- Erfahrung und spätere Highscore-Punkte bleiben getrennte Größen. Punktesystem/Online-Rangliste folgen später; Schwierigkeitsauswahl ist ein dazugehöriger Vorschlag, noch keine festgelegte Alpha-Anforderung.
- Flaraks zerstören, um Luftunterstützung zu ermöglichen, und Hilfe gegen Bomber sind erweiterte Zielideen im [BACKLOG.md](BACKLOG.md).

## 6. Arbeitsblock D – Rückmeldung, Präsentation und Qualität

Warn-/Hilfesystem und positive Upgrade-Meldungen sind im Kern vorhanden. Weitere Ereignisse, Lesbarkeit, Priorität und Wiederholrate gezielt ergänzen.
Avatar/Sprachausgabe und umfangreiche Grafikpolitur sind keine Voraussetzung. Warnmeldungen und neue Angriffsvorbereitungen sinnvoll aufeinander abstimmen.

| Thema | Aktueller Umgang |
| --- | --- |
| M1 / Bewegungsruckeln | Untersuchung zurückgestellt; bei 75 Hz laut Entwickler nicht mehr vorhanden, Ursache unbewiesen. Behandlung des früher vereinbarten Release-Gates vor Release ausdrücklich entscheiden; keine automatische Migration. |
| K1 / Treffer | K1b/K1c abgenommen, K1d/Abendrunde erfolgreich rückgemeldet. Zwei spezielle K1a-Minenanordnungen waren nicht durchführbar; gezielten Nachtestbedarf festlegen, keine pauschale Wiederöffnung bestandener Tests. |
| Plattformen / Walker | Laufbegrenzung/Bremsen früher korrigiert; gemeldete Durchfall- und Seitenkontaktprobleme werden in der Bewegungsumstellung untersucht. Sonec kann in den Walker springen; konkreten Körperkontakt separat bewerten, IK und Turm-Schadenszone schützen. |
| Audio | Kratzen/Überlagerung mehrerer Sounds, etwa Kettenexplosionen, gezielt untersuchen. Kein bewiesener Enginefehler; Soundpolitur nach spielerischem Bedarf begrenzen. |
| Minen / Browser | Welt-Y-Korrektur positiv rückgemeldet, längere Randbeobachtungen nicht vollständig protokolliert. Minen-/Warnhäufigkeit ins Balancing; frische und längere Browsersitzung getrennt beobachten. |
| Paintball | Abgeschlossen und vom Entwickler unter Windows visuell bestätigt: ein Pixel breite farblich passende Laufnasen nach unten, korrekte Fleckenausrichtung nach AGK-UV-Korrektur und normales Orb-/Menüverhalten. Kein weiterer Grafikumbau. |

## 7. Themenchats, offene Details und Abschluss

| Arbeitsblock | Zweck und Abgrenzung |
| --- | --- |
| A – Objekte | Minen, Drohne, Flarak, Bomber und Jumppod einzeln spezifizieren, implementieren und prüfen. |
| B – Grundsysteme | Erfahrung, Ressourcen/Munition, Panzerung und Gefahrenbudget in kleinen abgestimmten Schritten aufbauen. |
| C – Ziele | Erste kleine Ziele samt Erfolgserkennung und Belohnung auswählen. |
| D – Qualität | Konkrete Befunde, Warnungen und begrenzte Präsentationsaufgaben bearbeiten. |
| Balancing | Eigener Chat: zunächst faire Testparameter, später mit ausreichender Gegnervielfalt vertiefen; umfassende Abstimmung bis 1.0. |
| HTML5 / Deployment | Eigene Chats für Browserfragen/Meilensteintest bzw. getestete Revision, Export, Upload und gesonderte Merge-/Publish-Entscheidungen. |

Die Alpha braucht mehrere Chats. Themenwechsel zur Abwechslung sind nach Abstimmung möglich; Abhängigkeiten und aktueller nächster Schritt bleiben sichtbar.
Pro Änderung passende Tests wählen, HTML5-relevante Änderungen dort prüfen und Integration gebündelt testen; keine vollständige Browserwiederholung für jedes Detail.

**Abschlussrahmen:** Die geplanten Grundversionen müssen spielbar zusammenwirken und brauchbares Feedback ermöglichen.
Gefahrenzulassung, Erholungsrhythmus, tatsächlicher Ressourcengewinn und Munitionsersatz sollen gezielt prüfbar sein; unterschiedliche Spielweisen werden praktisch beurteilt.
Bekannte Qualitätsfragen erhalten eine ausdrückliche Entscheidung bzw. dokumentierte Grenze; der integrierte Alpha-Build wird auf der Zielplattform geprüft.
Diese Kriterien sind Prüfaufträge für die Umsetzung, keine bereits bestandene Alpha-Abnahme. itch.io bleibt Draft/Secret URL bis zu einer gesonderten Entscheidung.

**Nächster Schritt:** Phase-C-Paket gemäß TODO lokal kompilieren und B/C-Funktionstest durchführen. Weitere Arbeitsblöcke nach Abstimmung auswählen; keine automatische Codefreigabe aus dieser Roadmap ableiten.

Spätere Varianten und Ideen stehen in [BACKLOG.md](BACKLOG.md). Frühere Langfassungen liegen im [Archiv](docs/archive/README.md); sie werden nur für konkrete historische Fragen gelesen.
