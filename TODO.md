# SonecBot – Aktuelle Aufgaben und Meilensteine

**Dokumentstatus:** Version 3.22  
**Stand:** 16. November 2026  
**Branch:** `develop`  
**Aktueller Auftrag:** HTML5-Pre-Alpha für ausgewählte Tester kontrolliert vorbereiten; itch.io bleibt Draft  
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

## 2. Jetzt: HTML5-Pre-Alpha im itch.io-Draft (ohne Zeitdruck)

- [x] **HTML5-Export lokal erstellt (Entwicklermeldung, 16.11.2026).** Export gelang; genaue exportierte Code-Revision/ZIP hier nicht separat geprüft.
- [x] **Erster lokaler Browserstart:** Über lokalen Apache/XAMPP und vorhandenen Run-Frame startet das Spiel laut Entwickler. Audio, alle Assets und Eingaben damit **noch nicht einzeln bestätigt**.
- [x] **HTML5-Gamepad-Funktionstest (Entwicklermeldung):** Xbox-kompatibler Controller, Index-1-Workaround (erste Eingabe, eventuell 2–3 s). D-Pad/Analogstick, linke/rechte Trigger für Rückwärtsbewegung, L1 Energieanziehung, rechter Schulterbutton Schild, X Flammenwerfer, Y Plasma-Blitz, A Maschinengewehr, B Granatwerfer, Start Pause – laut Entwickler alle funktionsfähig. **Bezeichnung geklärt:** „R2 Schild“ war ein Schreibfehler; Schild RB/R1, untere Trigger LT/L2 und RT/R2 für Rückwärtsbewegung. Tastatur ist keine zumutbare Alternative.
- [x] **Spielrunde: Kernablauf laut HTML5-Entwicklertest bestanden:** Bewegung/Jetpack/Waffen/Schild-Aktivierung/Energieaktionen, Walker-Kampf, Pause/Fortsetzen sowie mehrfach Tod (Minen und Walker-Beschuss) und **mehrfacher Neustart innerhalb derselben weiterhin laufenden Browsersitzung**. Schild-Wirkung gegen Kugeln bleibt separat defekt; andere Browser/Export-SHA nicht dokumentiert.
- [x] **Gameplay-Smoketest für aktuelle Browser-Sitzung positiv:** 60 Hz/VSync flüssig (75 Hz kurz ebenfalls), Controlleraktionen und Pause bestätigt. **Tod durch Minen und Walker-Beschuss plus mindestens zwei Neustarts in derselben Sitzung** bestätigt. Langzeit-/andere Browser-/Schild-Detailtests bleiben getrennt.
- [ ] **HTML5-Beenden einordnen:** ESC/QUIT beenden den Browserbuild nicht; Code schließt HTML5-QUIT bewusst aus, ESC-Helfer ist Windows-spezifisch. UX/Einbettung bewerten, nicht als Enginebug behaupten.
- [ ] **Fehlende Kollisionsabfragen gezielt untersuchen:** Prüfen, welche vorgesehenen Treffer ohne Reaktion bleiben und ob das die Pre-Alpha spielerisch stört; konkrete Codepfade/Absicht vor Fix prüfen. Noch kein bestätigter einzelner Fehler oder Freigabe für Änderungen.
- [ ] **Nur konkrete Releaseblocker korrigieren:** kleinster nachvollziehbarer Eingriff mit tatsächlichem Nachtest, kein weiterer Walker-/IK-Umbau.
- [ ] **Bekannte Mechanikgrenzen bewerten/benennen:** feindliche Bullets gegen Schild, vorläufige Ressourcenbalance. Keine große Schadens-/Physik-Neuentwicklung ohne bestätigten Bedarf.
- [ ] **README/itch.io-Text final abgleichen:** tatsächliche getestete Controls, Pre-Alpha-Status, Browser-/Gamepad-Hinweise, bekannte Grenzen; passende Screenshots/Cover.
- [ ] **Im itch.io-Draft bereitstellen und über Secret URL eingebettet nachtesten.** Nutzer verwaltet Upload und Seite manuell; Secret URL im neuen Chat klären. **Kein Published-Wechsel.** Die öffentliche Index-Veröffentlichung bleibt bewusst für Beta 0.9 oder 1.0 offen.

- [ ] **Spawn-Zeitbasis untersuchen (Hypothese):** Zufallsentscheidungen innerhalb `GameDo()` wirken möglicherweise frameabhängig. Tatsächlichen Codepfad, Zeit-/FPS-Abhängigkeit und Release-Relevanz prüfen, Alternativen gemeinsam abwägen; erst nach Entscheidung ändern und lokal nachtesten. Keine pauschale Balancekorrektur.
- [ ] **Englische itch.io-Texte als Markdown** zusammenstellen; 💚 als vereinbarte Kennzeichnung in README/itch.io verwenden.

### Erster Kollisionsschritt – lokal bestanden

- [x] **Flammenwerfer → Walker-Turm, lokaler Entwicklertest bestanden (16.11.2026):** `FlameCollideWalkers()` ist eingebunden; Entwickler bestätigt erwartete Trefferwirkung und Zerstörung aller geprüften Objektarten einschließlich Walker. Flammenwerfer wirkt dabei **sehr stark** (qualitative Beobachtung, kein Balancingtest). Einzelne Flash-/Drop-Details wurden nicht separat bestätigt. **Schritt abgeschlossen; erst gemeinsam nächste Kombination wählen.**
- [ ] Anschließend Treffermatrix gemeinsam schrittweise erweitern: derzeit unter anderem Plasma-Blitz→Mine/Kiste (implementiert, Test offen), Plasma-Blitz→Walker (lokal positiv), Granate→Walker (lokal positiv), Explosion→Walker (lokal positiv) und Flamme→weitere vorgesehene Ziele. Sonec-Waffen sollen grundsätzlich alle beschädigbaren Ziele erreichen. Weitere Schadensarten/Panzerungsmodelle bleiben Zukunftsentwurf.
- [ ] Für das Fraktionskonzept Player (ggf. Player 2), Enemy, Neutral zunächst Verhalten klären; keine automatische Fraktions- oder Balancing-Umstellung.

### Abgeschlossener Einzeltest: Plasma-Blitz → Minen und Kisten

- [x] **Windows- und HTML5-Nachtest nach Codeänderung laut Entwickler erfolgreich:** `PlasmaBlitzCollideMine()` und `PlasmaBlitzCollideChest()` implementiert; gemeinsamer 50-ms-Timer nach Orb-/Minen-/Kistenprüfung zurückgesetzt. Große Kisten zeigen geringe Wirkung pro Blitz. Einzelne Zerstörungsfälle/Mehrfachtrefferintervalle nicht separat protokolliert; keine eigenen Tests des Assistenten.
- [ ] **Energie- und Wirkungsgefühl später beurteilen:** Blitz muss aufladen und entlädt sich, wirkt stark und verbraucht vermutlich viel Energie; längere Flammenwerfernutzung konkurriert mit Flugenergie. Qualitative Entwicklerbeobachtung, kein Messwert oder sofortiger Balanceauftrag. Keine Schadensarten-/Rüstungserweiterung in diesem Schritt.

- [x] **Direkter Granatenaufprall → Walker:** lokaler Volltreffer positiv bestätigt. **Nächster Prüfpunkt:** Explosion → Walker getrennt bewerten; möglichen Doppelschaden durch Aufprall plus Explosion beachten, noch keine Freigabe für Codeänderung.
- [ ] **HTML5-Debugtasten später überprüfen:** Browser-Funktionstasten lösen laut Entwickler Browserereignisse statt AGK-Diagnose aus; Windows-Debugging reicht für aktuelle Tests. Keine kurzfristige Neubelegung.

### Abgeschlossener Einzeltest: Plasma-Blitz → Alpha-Walker

- [x] **Plasma-Blitz → Walker lokal positiv:** Entwickler meldet „gut das funktioniert =)“. Welcher Browser-/Windows-Nachtest im Detail durchgeführt wurde und welcher Einzelschaden entstand, wurde nicht separat angegeben; keine Werte extrapolieren.
- [ ] Nach Testentscheidung bleiben direkter Granatenaufprall → Walker und Explosion → Walker als zwei separate Trefferpfade. Unbeabsichtigten Doppelschaden berücksichtigen; keine automatische Schadensmodell-/Balanceänderung.

### Abgeschlossener Einzeltest: direkter Granatenaufprall → Walker

- [x] **Direkter Granatentreffer auf Walker-Turm laut Entwickler bestanden:** `GrenadeCollideWalkers()` implementiert; Volltreffer, Ablauf „alles wie erwartet“. Der konkrete getestete Windows-/HTML5-Kontext wurde nicht getrennt angegeben; keine eigenen Laufzeittests. Zerstörung nach vielen Treffern und Regressionen der übrigen Granaten-Ziele nicht einzeln nachgewiesen.
- [ ] **Separat implementiert:** Explosion → Walker nutzt bestehenden Radius/100-ms-Rhythmus; kein weiterer Granatenaufprall-Umbau. Test und Bewertung der kombinierten Wirkung offen.

- [ ] **Beobachtete Granatenmechanik erhalten:** Rückstoß kann Sonec zurückversetzen, gekrümmte Flugbahn fällt nach unten, Granaten explodieren ggf. vorher am Plattformboden; Munition („Plasmagranaten“) wird verbraucht. Keine ungefragte Änderung an Flugphysik oder Ressourcen.
- [x] **Erste Kollisionsmatrix abgeschlossen:** Explosion → Walker nach Implementierung im Entwicklertest positiv; direkter Aufprall und nahe Explosion können Walker zerstören. Kein Balancing-/Schadensmodellauftrag daraus ableiten.

### Abgeschlossener Einzeltest: Explosionswirkung → Walker

- [x] **Direkttreffer und nahe/passive Explosion → Walker lokal bestanden:** Entwickler meldet „sprengtest erfolgreich“; beide Situationen können Walker zerstören. Turm-AABB als Kreis-gegen-Box, `LastWalkerHitMs` pro Explosion/Walker und unveränderte 30 Schaden je mindestens 100 ms implementiert. Plattform-/Browserkontext des jüngsten Tests nicht einzeln bestätigt; keine eigenständige Komplett-Regression aller Ziele ableiten.
- [ ] **Nach Testentscheidung:** Doppelschaden aus Aufprall und Druckwelle sowie mögliche Walker-Zerstörungsketten anhand des Spielgefühls bewerten. Keine automatische Balance-/Panzerungsänderung.

### Kollisionsmatrix abgeschlossen – spätere Ideen, keine aktuelle Umsetzung

- [ ] Optionale separate Trefferzonen/Schadensreaktionen für Walker-Körperteile später gemeinsam gestalten. Der aktuelle gezielte Turmtreffer ist eine spielerische Besonderheit und soll jetzt erhalten bleiben.
- [ ] Nach den Release-Gates ein längeres Gameplayvideo aufnehmen; GifCam kann laut Entwickler unter hoher Speicherlast instabil wirken (RAM-Ursache Vermutung). Eine passende alternative Aufnahme-Lösung erst bei Gelegenheit vergleichen.
- [ ] Achievements als spätere Spielidee sammeln; derzeit keine implementiert. „Waffenschein für alle“ ist ein Scherz, kein Feature.
- [x] HTML5-Tod + mindestens zwei Neustarts im laufenden Browsertest bestätigt. **Weiter offen:** itch.io-Seite im **Draft** per Secret-URL eingebettet testen; **nicht öffentlich publishen**.

### Neue Spieltest-Befunde: Walker, Energie-HUD, Schild (16.11.2026)

- [ ] **Walker/Sonec-Körperkontakt:** Entwickler beobachtet, dass Walker durch Sonec läuft, statt anzuhalten und zu schießen. `WalkerMove()` berücksichtigt Kisten/Plattformkanten, nicht Sonec als Hindernis; `GameDo()` hat keinen direkten Walker↔Sonec-Körperkollisionspfad. Gewünschtes Verhalten vor Codeänderung genau festlegen, danach isoliert testen; bestehende KI, Fuß-/Turm-IK schützen.
- [ ] **Energie-HUD-Proportion:** Screenshot/Entwicklerwunsch: grüne Energie plus angemessener roter Overload-Bereich ungefähr so hoch wie HP plus Schild. Ist: in `GuiEnergyDraw()` HP=150 kleine Segmente, Schild bis 25, Energie=20 große Segmente, Overload proportional `EnergyOverload*10/Energy.StateMax`. Nur Darstellung anpassen, keine Ressourcenwerte/Balanceänderung; später eigene Sichtprüfung.
- [ ] **Schild gegen Walker-Geschosse – Codefix implementiert, Test offen:** `BulletCollide()` nutzt nun den vorhandenen Absorptionspfad für `TYPEENEMY`. Entwicklertest mit/ohne Schild und Explosionsregression steht aus; keine neue Schild-/Rüstungslogik.
- [x] **HTML5-Release-Gate bestanden:** Entwickler bestätigt mehrfachen Tod durch Minen/Walker, mehrfachen Neustart in derselben aktiven Browser-Sitzung, Spiel weiterhin lauffähig. Kein Beleg für Langzeit-Memory-Verhalten oder andere Browser.

### Spätere Helferwarnungen und Minenspawn-Prüfung

- [ ] **Informationsavatar (bereits im Projekt vorgesehen):** zuerst optional nur eine gut sichtbare rote Warnmeldung in Großbuchstaben oben, z. B. „MINEFIELD DETECTED“ bei neu auftauchender Minengruppe. Eventuell Bild/animiertes Porträt, später Sprachausgabe. Warnkriterium, Dauer, Priorität und Spam-Vermeidung vor Implementierung gemeinsam festlegen. Kein aktueller Codeauftrag.
- [ ] **Minen-Spawns gesondert prüfen:** Entwickler sieht meist gruppenartige Minenvorkommen. In `GameDo()` ist eine Zufallsprüfung pro Update mit anschließend zufälliger Anzahl vorhanden; Frameabhängigkeit ist plausibel, aber noch kein gemessener Defekt. Verteilung, Anzahl, Fairness und mögliche Warn-Signale erst analysieren; keine spontane Änderung.
- [ ] **Nächsten schmalen Funktionsschritt gemeinsam wählen:** favorisiert vorhandene Schildabsorption für feindliche Walker-Kugeln; anschließend Walker-Sonec-Körperkontakt und Energie-/Overload-HUD. Änderungen getrennt testen.

### Aktueller Einzelschritt: Schild gegen Feindkugeln – Nachtest offen

- [ ] **AGK-/HTML5-Test des neuen Builds:** `BulletCollide()` verwendet für `TYPEENEMY` jetzt `ShieldAbsorbDamage()` mit `Game.Shield,Now`. Ohne Schild normaler HP-Verlust; mit geladenem aktivem Schild geringerer HP-Verlust plus Ladungsverbrauch und rote Spur; Schild aus/leer kein Schutz. Explosionsschild unverändert prüfen. **Nur GitHub-Code geprüft, noch kein realer Compiler-/Laufzeittest.**
- [ ] **Danach getrennt:** Walker/Sonec-Überlappung (Walker soll halten und schießen), anschließend Energie-/Overload-HUD optisch anpassen. Keine parallele Spielcodeänderung.

## 3. Für später: reguläre Alpha / Fehler nur bei konkreter Reproduktion

### Eingabe und Spielablauf

- [ ] Vollständige Tastaturbelegung; derzeit u. a. KEY_2 für Maschinengewehr und Granatwerfer sowie Gamepad-only-Intro/Pause.
- [ ] Kleines Options-/Hilfemenü nur nach Bedarf; frei belegbare Tasten, Defaults und Speicherung später.
- [ ] Rundenziel, minimaler Score und Game-over-/Neustartdarstellung nach öffentlichem Pre-Alpha-Feedback bestimmen.
- [ ] Online-Highscore-Anbindung aus Crystals prüfen, keine Voraussetzung für die Draft-Pre-Alpha.
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

## 4. Knowledge Base: nur nach abgeschlossenem aktuellem Arbeitsschritt

[agk-knowledge-base](https://github.com/ChristianEngel19820128/agk-knowledge-base) soll als Referenz mit den Projekten wachsen; entsprechende Regel steht in beiden AGENTS.md-Dateien.

- [ ] **HTML5-Gamepad-Kandidat:** Fester Index 1, Browserinitialisierung erst nach erster Controller-Eingabe (möglicherweise 2–3 s); mit Crystals vergleichen und browser-/AGK-versionsabhängig dokumentieren. Vorläufig SonecBot-Entwicklertest, nicht universell.
- [ ] **Browser-Beenden-Kandidat:** Windows ESC/QUIT gegenüber eingebettetem HTML5 ohne Programmende; Code-/UX-Entscheidung getrennt von AGK-Engineverhalten erklären.
- [ ] **HTML5/XAMPP-Cache-Kandidat:** Nach Ersetzen von HTML5-Dateien kann der Browser alte Dateien weiter ausliefern; beim lokalen Entwickeln in geöffneten DevTools „Disable cache“ aktivieren und hart neu laden, sonst drohen Scheindefekte. Aktuell Entwicklerbeobachtung, KB-Eintrag und genaue Bedingungen später prüfen.
- [ ] Sammlung gemeinsam sichten; kompaktes Register mit Symptom/Fallstrick, robustem Muster/Workaround, **Status**, Quelle/Revision und offenem Nachweis erwägen.
- [ ] Positiv bewertete Turm-Schwenkprojektion ohne Zusatzsprite auf allgemeine Erklärung prüfen.
- [ ] Integer-/Float-Division: Float-Zielvariable allein genügt nach Entwicklererfahrung nicht; Operand vor Division explizit Float, kleiner reproduzierbarer AGK-Test fehlt für eine neue präzise Ergänzung.
- [ ] Negative Random-Grenzen/UINT-Signatur und robustes Zentrieren getrennt minimal testen; kein isoliert bestätigter Enginebug.
- [ ] Verschachtelte Konstanten: früherer Compilefehler, direkte Literal-Faktoren als Workaround, genaue Version/Reproduktion ergänzen.
- [ ] Zylinder für Himmel/Wolken als Idee für anderes Projekt, noch keine geprüfte Implementierung.

## 5. Dokumentationsregel

Relevante Dokumente bei jedem Commit aktuell halten. [HANDOFF.md](HANDOFF.md) ist der direkte neue Chat-Einstieg; PROJECT.md beschreibt Konzept/Entscheidungen, TECHNICAL.md den aktuellen technischen Stand. Historische Unsicherheiten nicht als neue Blocker ausgeben, lokale Tests nicht als eigene AGK-/HTML5-Prüfungen behaupten.

**Prozessentscheidung (16. November 2026):** GitHub ist gemeinsame Referenz; Besitzer testet AGK Studio und lokalen Apache selbst, Assistent analysiert Quellcode. Kleine freigegebene Schritte, Besonderheiten zunächst mit Evidenzstand dokumentieren, Schritt abschließen und dann nächste Arbeit/Knowledge Base bestimmen. Crystals 1.0 dient als Erfahrung. Frühere Deadline ist kein Zwang; itch.io-Draft und einmaligen Index-Push schützen. Die Seite wird vom Besitzer manuell gepflegt, Release-Texte in englischem Markdown.
