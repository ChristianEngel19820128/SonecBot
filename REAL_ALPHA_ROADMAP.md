# SonecBot – Real Alpha Roadmap

**Stand:** 25. November 2026 · **Arbeitsbranch:** `develop`
**Status:** A5-Grundumfang und Bewegungsumstellung abgeschlossen; A5c Darstellungsnacharbeit und A6 als letzte Ergänzungen von Arbeitsblock A aufgenommen, separater Flammenwerfer-Bug-Chat vereinbart, Arbeitsblock B offen.
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

### A5 – Jumppod, Landmine, Sockel und Rauch (Grundumfang abgenommen; A5c offen)

- J1: hilfreicher Jumppod mit verstärktem normalen Sprungimpuls ohne Energiekosten; zwei Frames, auslösbar durch Kontakt von oben. Ursprünglich Faktor 2,0; Entwickler-Balancing a2db24a Faktor 1,6 bei normalem Impuls 6.
- J1a: automatischer Aufstieg über beide Sockelstufen mit oberem Trigger, Mini-Hop beim Abstieg; lokal AGK-bestanden (9/9, ddc24e8, 25.11.2026).
- J2: Landmine als erkennbare Attrappe (blinkendes Quadrat in der Nähe), sofortige stärkere Schadensexplosion, 25 % der regelmäßigen Testspawns; lokal AGK-bestanden (12/12, 517763f, 25.11.2026).
- J3: gemeinsame Zweirechteck-Sockelmechanik auch für Flak/Flarak; Sockel bleiben nach Zerstörung bestehen; bestehende Luftabwehrfunktion erhalten; lokal AGK-bestanden (10/10 am 25.11.2026 nach Compile-Korrektur ec23637 (Testformular c2858e9; lokale SHA nicht separat bestätigt)).
- J4: wiederverwendbare Rauch-Unit; kontinuierliche Emission an zerstörten Objekten bis zum Weltende; lokal funktional bestanden (15/15), Entwickler-Feinjustierung ba4be02/a2db24a und vertikale Trägergeschwindigkeitsübernahme f591fc7 abschließend zusammenfassend akzeptiert; keine weitere Rauchänderung.
- Details, Interaktionen, Parameterrahmen und Abnahme in [docs/JUMPPOD_SPEC.md](docs/JUMPPOD_SPEC.md). Fachlich abgestimmt am 25.11.2026; J1 lokal AGK-bestanden (10/10, bb16236, 25.11.2026), J2 lokal AGK-bestanden (12/12, 517763f, 25.11.2026), J3 lokal AGK-bestanden (10/10), J4 lokal funktional bestanden (15/15, nach Compile-Korrektur e17440a; lokale SHA nicht separat bestätigt). Separater bestätigter Flarak-Neustartfehler in KNOWNBUGS; keine HTML5-/Langzeitabnahme.

Legacy-Grafiken (`rakstellung.png`, `spacejet.png`, `falle.bmp`) sind Vorlagen, kein Beweis fertig implementierter Altmechaniken.
`falle.bmp` bezeichnet den Jumppod. Neue Grafikfassungen können separat entstehen; alte Konzepte müssen nicht unverändert übernommen werden.

- A5c: Entwicklerbefund im A6a-Test 1a3f642 (25.11.2026): Flak, Flarak, Landmine und Jumppod müssen zusammen mit ihrer Trägerplatte entsprechend der Zeichnungsreihenfolge dargestellt werden; derzeit falsche gegenseitige Überdeckung mit anderen Plattformen. Quellbefund: Pod/Mine bereits in PlateAndChestDrawAll je Platte, Flak/Flarak dagegen separat in GameAnimate über FlarakDrawAll; die genaue Ursache der Pod-/Minenbeobachtung noch prüfen. Befund in KNOWNBUGS.md; eigener Darstellungsschritt, keine Änderung an KI, Waffen, Kollision oder Rauch geplant. Abgefeuerte Raketen bleiben eigenständige Flugobjekte; angedockte Raketendarstellung gesondert beachten. Umsetzung noch offen.

### A6 – Letzte Weltobjekt-Ergänzungen (25.11.2026, A6a Grundtest bestanden)

- A6a: dunkle Hintergrundkisten als Mod der vorhandenen Kisten. Implementiert: `TChest.IsBackground` (bei jeder Neuanlage zurückgesetzt), 25 % der erfolgreich platzierten regulären Kisten werden als Variante gewürfelt, RGB 32/125/55, alpha 255; normale Kisten weiterhin 0/255/0. Kein zusätzlicher Spawnpool oder mehr Kisten. Stabile Fünfer-Slots der mechanischen Sonec-Liste: Hintergrundkisten bleiben dort leer, sodass Durchlaufen und Durchspringen ohne Landung/Seitensperre/Mini-Hop möglich sind. Hintergrundkisten werden vor Vordergrundkisten derselben Plattform und vor Sonec gezeichnet. Bestehende ChestList, Platzierungs-/Überlappungsregeln einschließlich Pod/Flak/Flarak, gegnerische und Spielerwaffen, Explosionen, Gesundheit/Regeneration und Rewards unverändert. Rote Trefferanzeige unverändert, Regeneration stellt Variantenfarbe wieder her. Gewählte Testwerte und unveränderte Interaktionen gemäß freigegebenem Variantenprinzip; Feinjustierung im lokalen Test. Lokaler AGK-Compile und Entwicklertest 10/10 bestanden am 25.11.2026 auf 1a3f642: beide Varianten, Durchlaufen/-springen/-fallen, normale Kisten, Waffen/Explosionen, Farbrestaurierung, Rewards, Platzierung/Plattformbindung, Sockel-/Treppenregression. Entwickler fordert zusätzlich Walker-Durchlässigkeit wegen zu wenig Bewegungsraum. Implementiert: WalkerChestAreaFree (Spawnprüfung) und WalkerChestDistanceAhead (Laufweg) ignorieren IsBackground; Vordergrundkisten bleiben Hindernisse. Spawnüberdeckung mit dunklen Kisten ist bewusst zulässig, übrige Platzierungs- und Schadensregeln unverändert. Gezielter lokaler Compile-/Lauftest der Ergänzung offen.
- A6b: größere und variablere Rudelformation einfacher Minen. A3-Grundversion bleibt abgenommen, aber ursprünglicher Backlog-Wunsch nach individuell variierenden Zeilenhöhen und Spaltenabständen ist nicht vollständig umgesetzt. Quellbefund ad063bf: SimpleMinePackAdd verwendet 2×3 Slots, 3–6 Minen, ein gemeinsames X-Intervall 32–48 px und Y-Intervall 48–72 px (auch für Diagonale und Keil) sowie ±8 px je Mine. Entwickler fordert größere Abstände und Zeilen-/Spaltengrößen. Freigegebene Testwerte: eigenes 3×4-Raster, je Spaltenabstand 64–96 px, je Zeilenabstand 80–120 px, unabhängiger X-/Y-Zufallsversatz ±16 px, 3–6 Minen ohne doppelte Slots. Umsetzung nach A6a-Abnahme; Diagonale, Keil, Minenzahl, Spawnzeit, Drift und Weltgrenzen nicht beiläufig verändern.
- Keine weiteren Weltobjekte aus dem Backlog für Arbeitsblock A ausgewählt. Rauchsystem bleibt abgeschlossen. Beide Ergänzungen sind Real-Alpha-Umfang und in der Reihenfolge A6a, A6b freigegeben; keine automatische Freigabe weiterer Varianten.

### Sonec-Bewegungsumstellung – abgeschlossen (25.11.2026)

- Verbindliche Anforderungen und technische Abnahmen A–G2d: [SONEC_MOVEMENT_SPEC.md](docs/SONEC_MOVEMENT_SPEC.md). Gemeinsamer Kontaktresolver, Trägerbewegung, lokale Tiefenfreigabe, Fuß-/Kistenkanten, Mini-Hop, Sprung-/Jetpack-Steuerung und Rückstoß implementiert und im vereinbarten Umfang funktional abgenommen.
- G1 `093c173` technisch bestanden; Nacharbeit G2a `a41162c` 8/8, G2b `6c53fac` 11/11, G2c `d87a2f6` 13/13 und G2d-1 `3e6e07c` 8/8 bestanden. G2d-2 Entwickler-Balancing `ffe2e39` und Jetstream `4cba3e3` 7/7 bestanden; Abstand in `43f4a35` feinjustiert. Entwickler betrachtet Ziele als erreicht, Assistent stimmt zu. Keine weitere aktive Bewegungsaufgabe; Langzeitbeobachtung, weitere lokale Parameterfeinjustierung und übergreifende HTML5-/Meilensteintests bleiben möglich. Keine gesonderte Langzeitmessung oder vollständige Einzelmatrix behauptet.
- Energieüberschuss/Overload und Gegnergefährlichkeit im nachgelagerten Balancing; Flammenwerfer/Siloschutz in [KNOWNBUGS.md](KNOWNBUGS.md). Gemeinsame Jetstream-Erzeugung als unverbindliche Backlog-Idee.

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
| Plattformen / Walker | Laufbegrenzung/Bremsen früher korrigiert; Bewegungsumstellung abgeschlossen; erneute konkrete Befunde separat erfassen. Sonec kann in den Walker springen; konkreten Körperkontakt separat bewerten, IK und Turm-Schadenszone schützen. |
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
| Balancing | Eigener Chat nach den Alpha-Grundsystemen: Energiefluss, Startenergie, Overload, Pickup-Verteilung und Gegnergefährlichkeit (Drohne vergleichsweise harmlos); vorab nur notwendige Testparameter. Umfassende Abstimmung bis 1.0. |
| HTML5 / Deployment | Eigene Chats für Browserfragen/Meilensteintest bzw. getestete Revision, Export, Upload und gesonderte Merge-/Publish-Entscheidungen. |

Die Alpha braucht mehrere Chats. Themenwechsel zur Abwechslung sind nach Abstimmung möglich; Abhängigkeiten und aktueller nächster Schritt bleiben sichtbar.
Pro Änderung passende Tests wählen, HTML5-relevante Änderungen dort prüfen und Integration gebündelt testen; keine vollständige Browserwiederholung für jedes Detail.

**Abschlussrahmen:** Die geplanten Grundversionen müssen spielbar zusammenwirken und brauchbares Feedback ermöglichen.
Gefahrenzulassung, Erholungsrhythmus, tatsächlicher Ressourcengewinn und Munitionsersatz sollen gezielt prüfbar sein; unterschiedliche Spielweisen werden praktisch beurteilt.
Bekannte Qualitätsfragen erhalten eine ausdrückliche Entscheidung bzw. dokumentierte Grenze; der integrierte Alpha-Build wird auf der Zielplattform geprüft.
Diese Kriterien sind Prüfaufträge für die Umsetzung, keine bereits bestandene Alpha-Abnahme. itch.io bleibt Draft/Secret URL bis zu einer gesonderten Entscheidung.

**Nächster Schritt:** A6a Walker-Durchlässigkeit lokal kompilieren und prüfen, danach A5c und A6b bearbeiten; danach vereinbarter separater Flammenwerfer-Bug-Chat gemäß [KNOWNBUGS.md](KNOWNBUGS.md), anschließend Arbeitsblock B fachlich abstimmen. Sonstige Fremdbugs zurückgestellt; keine weiteren Rauchänderungen.

Spätere Varianten und Ideen stehen in [BACKLOG.md](BACKLOG.md). Frühere Langfassungen liegen im [Archiv](docs/archive/README.md); sie werden nur für konkrete historische Fragen gelesen.
