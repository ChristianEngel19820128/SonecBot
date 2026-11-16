# SonecBot – Aktuelle Aufgaben und Meilensteine

**Dokumentstatus:** Version 3.22  
**Stand:** 16. November 2026  
**Branch:** `develop`  
**Aktueller Auftrag:** HTML5-Pre-Alpha-Deployment  
**Alpha-Walker:** **abgeschlossen und lokal akzeptiert**, inklusive abschließendem 3-px-Turmrückstoßtest

> Start im neuen Chat: [HANDOFF.md](HANDOFF.md). Aktuellen HEAD neu prüfen.
> Diese Liste ist auf den Abschlussstand konsolidiert. Die vollständige frühere Schritt-/Testhistorie bleibt [im vorherigen TODO-Stand](https://github.com/ChristianEngel19820128/SonecBot/blob/18f92a965810763b552bd96649607c112f966238/TODO.md) und in Git erhalten. Alte „nächster Walker-Test“-Einträge sind kein aktueller Entwicklungsauftrag.

## 1. Erledigt: Alpha-Walker

- [x] Komplexe untere Zweiknochen-IK, Stand-/Schwungbein, getrennte Fußziele, Standrückkehr und Kantenwende; Beinbewegung vom Entwickler als optimal bewertet.
- [x] Kistenstopp und ausreichend freie Spawnpositionen lokal positiv getestet; 5-px-Sicherheitsabstand erhalten.
- [x] Corpus-Neigung um roten Hüftpunkt, Turm am Corpus-Offset; Basispivots und untere IK erhalten.
- [x] Unabhängiges Turmschwenken mit vorhandenen Seitenbildern: 800 ms, fünf Breitenstufen, 40 % Minimum.
- [x] 400-ms-Zielvorbereitung, maximal ±30°, einmaliger Zielwinkel pro Zwei-Schuss-Salve; 150-ms-Schussabstand und 300-ms-Recovery.
- [x] Nahbereichs-Zielgeometrie korrigiert; 0°-Test lokal positiv, anschließend ±3°..±1° mit 0.5° Lernschritt lokal plausibel bewertet.
- [x] Zentrierter Zufall aus `random(0,200)-100`; negative Random-Grenzen als unbewiesener Ursachen-/KB-Kandidat dokumentiert.
- [x] Abwechselnder Rohrrückstoß: vorn `[1]`, hinten `[0]`, 5/10/5/0 px über 300 ms.
- [x] Neutraler Flash ohne Rohr-/Turmrückstoß, mit Eltern-/Plattformbewegung.
- [x] Entwicklergrafik und Proto in `0051b8b` eingecheckt: Rohr 3×40 px, aktuelle Offset-/Anchor-Werte erhalten.
- [x] Letzter 3-px-Turmrückstoß pro Schuss (60 ms halten, 90 ms zurück) vom Entwickler abschließend getestet: **„test bestanden. funktioniert alles wie erwartet.“**
- [x] Gegnername **Alpha-Walker**, Fairnessregel für Sonec und Computergegner in PROJECT.md.

Der lokal getestete Code-Referenzcommit ist [`18f92a965810763b552bd96649607c112f966238`](https://github.com/ChristianEngel19820128/SonecBot/commit/18f92a965810763b552bd96649607c112f966238). Diese Dokumentationsaktualisierung folgt danach. Kein neuer HTML5-Nachweis und keine pauschale Behauptung, alle möglichen Randfälle seien getestet.

## 2. Jetzt: heutige HTML5-Pre-Alpha

- [ ] **Aktuellen HTML5-Export erstellen/bereitstellen.** Noch kein Exportpaket oder Browserlauf im Chat vorliegend.
- [ ] **Browserstart testen:** Laden/Assets, Intro, Start und Audio nach Interaktion.
- [ ] **Eine vollständige Eingabemethode nachweisen:** HTML5-Gamepad-Index 1 prüfen; Intro/Pause derzeit Gamepad, Tastaturpfad unvollständig. Minimalvorschlag Gamepad-only mit klarer Kennzeichnung, noch nicht abschließend entschieden.
- [ ] **Spielrunde testen:** Bewegung/Jetpack/Waffen/Schild/Energieaktionen, Walker-Kampf, Pause/Fortsetzen, Tod und mindestens zwei Neustarts.
- [ ] **Nur konkrete Releaseblocker korrigieren:** kleinster nachvollziehbarer Eingriff mit tatsächlichem Nachtest, kein weiterer Walker-/IK-Umbau.
- [ ] **Bekannte Mechanikgrenzen bewerten/benennen:** feindliche Bullets gegen Schild, Explosionen gegen Walker, vorläufige Ressourcenbalance. Keine große Schadens-/Physik-Neuentwicklung heute.
- [ ] **README/itch.io-Text final abgleichen:** tatsächliche getestete Controls, Pre-Alpha-Status, Browser-/Gamepad-Hinweise, bekannte Grenzen; passende Screenshots/Cover.
- [ ] **Export auf itch.io bereitstellen und eingebettet nachtesten.** Projekt-URL und Zugang im neuen Chat klären; Upload/Veröffentlichung noch nicht erfolgt.

## 3. Für später: reguläre Alpha / Fehler nur bei konkreter Reproduktion

### Eingabe und Spielablauf

- [ ] Vollständige Tastaturbelegung; derzeit u. a. KEY_2 für Maschinengewehr und Granatwerfer sowie Gamepad-only-Intro/Pause.
- [ ] Kleines Options-/Hilfemenü nur nach Bedarf; frei belegbare Tasten, Defaults und Speicherung später.
- [ ] Rundenziel, minimaler Score und Game-over-/Neustartdarstellung nach öffentlichem Pre-Alpha-Feedback bestimmen.
- [ ] Online-Highscore-Anbindung aus Crystals prüfen, keine Voraussetzung für heutigen Release.
- [ ] HTML5-Optionsspeicherung später anhand Crystals mit Defaults, Versionen und Speicherfehlern konzipieren.

### Kampf, Ressourcen und Kollisionen

- [ ] Energie gemeinsam neu balancieren: Maximum/Start aktuell 5250 als **Testhilfe**; Kosten, Regeneration, Aufnahme, Overload und HUD zusammen betrachten.
- [ ] Schildladung von Animationsframes trennen und Schadensarten differenzieren; vorhandene Explosionsabsorption nicht ungeprüft umstellen.
- [ ] Walker-/weitere Ziele für neutrale Explosionen, Kettenreaktionen und vollständige Treffermatrix ergänzen.
- [ ] Feindliche Bullets treffen vorläufig Kisten/Minen, nicht eigene Walker/Orbs; Schildwirkung gegen Bullets gezielt klären.
- [ ] Tunneling und großzügige AABB-Ecktreffer bei schnellen/diagonalen Geschossen nur gezielt prüfen, kein pauschaler Kollisionsumbau.
- [ ] Flammenradius-/Kistenfixes behalten; ältere/größere Flammen gegen Orbs/Minen bei Bedarf nachtesten.
- [ ] Kisten-/Orb-Belohnungen und kleinere Kisten mit potenziell besseren Drops als spätere Balanceaufgabe klären.
- [ ] Höhere Energie-/Schildkapazitäten/Upgrades, HUD-/Inenergie-/Energieobjekt-Transparenz später.
- [ ] Energieverbrauch bei Energieaufnahme als möglicherweise gewollte Altregel prüfen, nicht ungefragt entfernen.

### Technik und Walker-Backlog – kein aktueller Featureauftrag

- [ ] Browser-/Neustart-/Pause-/Mehrfach-Walker-/bewegte-Plattform-Randfälle im Release-Smoke-Test mitbeobachten.
- [ ] F1-HUD-Flashzeile bei späterer Debugpflege korrigieren; derzeit vereinfachter Barrel0-Wert, nicht echter Pool-Flash.
- [ ] Gemeinsamen Schusssound später entkoppeln; keine automatische Soundauslösung bei jedem rein visuellen Flash.
- [ ] Optionale direkte Draufsicht (noch kein Grafikkonzept), sonstige Grafik-/Gelenkdetails oder neue Gegner erst später.
- [ ] Vorhalt, Sichtlinie und winkelabhängige Zielzeit bei Bedarf getrennt prüfen; aktueller Salven-Lock bleibt.
- [ ] Zusätzliche Corpus-Trefferzone, Größeninitialisierung/engste Plattformen, verallgemeinerte IK/Spriter nur bei konkretem Bedarf.
- [ ] Float-/Sprite-/Renderer-/VSync-Langzeitverhalten, übrige Divisionen und F2/F4/F5/F6-Vergleiche gezielt statt global ändern.
- [ ] Bestehenden OpenGL-Arbeitsstandard unter Windows behalten; keine allgemeingültigen GPU-/Browserempfehlungen aus Einzeltests ableiten.

## 4. Knowledge Base nach dem dringenden Deployment

[agk-knowledge-base](https://github.com/ChristianEngel19820128/agk-knowledge-base) soll als Referenz mit den Projekten wachsen; entsprechende Regel steht in beiden AGENTS.md-Dateien.

- [ ] Sammlung gemeinsam sichten; kompaktes Register mit Symptom/Fallstrick, robustem Muster/Workaround, **Status**, Quelle/Revision und offenem Nachweis erwägen.
- [ ] Positiv bewertete Turm-Schwenkprojektion ohne Zusatzsprite auf allgemeine Erklärung prüfen.
- [ ] Integer-/Float-Division: Float-Zielvariable allein genügt nach Entwicklererfahrung nicht; Operand vor Division explizit Float, kleiner reproduzierbarer AGK-Test fehlt für eine neue präzise Ergänzung.
- [ ] Negative Random-Grenzen/UINT-Signatur und robustes Zentrieren getrennt minimal testen; kein isoliert bestätigter Enginebug.
- [ ] Verschachtelte Konstanten: früherer Compilefehler, direkte Literal-Faktoren als Workaround, genaue Version/Reproduktion ergänzen.
- [ ] Zylinder für Himmel/Wolken als Idee für anderes Projekt, noch keine geprüfte Implementierung.

## 5. Dokumentationsregel

Relevante Dokumente bei jedem Commit aktuell halten. [HANDOFF.md](HANDOFF.md) ist der direkte neue Chat-Einstieg; PROJECT.md beschreibt Konzept/Entscheidungen, TECHNICAL.md den aktuellen technischen Stand. Historische Unsicherheiten nicht als neue Blocker ausgeben, lokale Tests nicht als eigene AGK-/HTML5-Prüfungen behaupten.
