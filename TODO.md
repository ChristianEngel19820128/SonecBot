# SonecBot – Aktuelle Aufgaben und Meilensteine

**Dokumentstatus:** Version 5.0 – Back nur aus Pause und Pausenhinweise ergänzt; Hover-Befund offen  
**Stand:** 16. November 2026  
**Branch:** `develop`  
**Aktuelles Ziel:** Funktionierende HTML5-Pre-Alpha auf itch.io im **Draft per Secret URL** für eingeladene Community-Tester bereitstellen, Feedback sammeln. **Nicht auf Published umstellen**; den einmaligen öffentlichen Index-Push für einen späteren, noch nicht beschlossenen Release bewahren. Keine Deadline.

> Bei Chatwechsel zuerst [HANDOFF.md](HANDOFF.md) und den echten `develop`-HEAD lesen. Historische Arbeits- und Testdetails stehen in [TECHNICAL.md](TECHNICAL.md), in [dieser ausführlichen TODO-Version vor der Konsolidierung](https://github.com/ChristianEngel19820128/SonecBot/blob/b1d7da8f4bad6255e612948e833a39ab60a48243/TODO.md) und in Git. Datierte ältere „offen“-Einträge bezeichnen frühere Zwischenstände, **nicht** die heutige Aufgabenpriorität.

## 1. Abgeschlossen und für die Pre-Alpha akzeptiert

- [x] **Alpha-Walker** mit komplexer Bein-IK, Kanten-/Kistenverhalten, Turmschwenken, Zielvorbereitung, Zwei-Schuss-Salve, Barrel-/Turmrückstoß und Grafikstand lokal akzeptiert. Den Charakter des Gegners erhalten; **kein weiteres IK-/Grafik-Polishing**. Historische abgeschlossene Code-Referenz: [`18f92a9`](https://github.com/ChristianEngel19820128/SonecBot/commit/18f92a965810763b552bd96649607c112f966238), **nicht** aktueller Branch-HEAD.
- [x] **Erste Spielerwaffen-Kollisionsmatrix** implementiert: Maschinengewehr, Flammen, Plasma-Blitz, direkter Granatenaufprall und Explosion treffen die vorgesehenen Ziele einschließlich der Walker-Turmzone. Schmale neue Pfade wurden anschließend vom Entwickler lokal positiv geprüft; keine vollständige automatisierte Testmatrix behaupten.
- [x] **Schild gegen feindliche Walker-Kugeln:** vorhandene `ShieldAbsorbDamage()`-Logik angebunden. Entwickler bestätigt Schaden ohne Schild und mit Schild Ladungsverbrauch samt roter Schadensspur; alle vereinbarten Schildtests als bestanden gemeldet.
- [x] **Walker stoppt vor Sonec:** beidseitig geeigneter Abstand laut zwei Screenshots, hält an und feuert weiter. Weg-/Überfliegen funktioniert. **Separate Einschränkung:** Sonec selbst kann in den Walker hineinspringen.
- [x] **HTML5-Browserbasis lokal geprüft:** Export über AGK Studio, Start über Apache/XAMPP, 60 Hz/VSync spielbar (75 Hz kurz ebenfalls), Xbox-kompatibles Gamepad mit D-Pad/Stick, LT/RT für Rückwärtsbewegung, L1 Energie anziehen, R1/RB Schild, X Flammen, Y Plasma-Blitz, A Maschinengewehr, B Granatwerfer, Start Pause. HTML5-Controller-Index 1; erste Eingabe benötigt mitunter 2–3 Sekunden. Vollständige Tastatursteuerung nicht bestätigt.
- [x] **Tod und Reinitialisierung in einer HTML5-Sitzung:** mehrfach durch Minen bzw. Walkerbeschuss gestorben, mehrfach neu gestartet und weitergespielt; Pause bestätigt. Kein Nachweis für alle Browser oder Langzeit-Speicherverhalten.
- [x] **HUD in laufenden Sichttests angepasst und akzeptiert:** Energiehöhe proportional zu HP/Schild (43 grüne + 7 rote Plätze, zusammen ca. 350 px); grüne Normalenergie 4.000, Startenergie 4.500 als vorläufiges Testsetup, Overload-Anzeigeskala 1.500, `HUD_BAR_ALPHA = 100`. Entwickler hat 80/100/120 in Screenshots verglichen und **100 ausdrücklich als besten Kompromiss beibehalten**. Keine weiteren HUD-Änderungen ohne neuen Befund.
- [x] **Minenspawn untersucht und vor der Pre-Alpha bewusst akzeptiert:** `GameDo()` würfelt pro Spielupdate; `MineAdd()` setzt bei tatsächlichem Spawn den 1.000-ms-Timer zurück und prüft Y-Abstand. Die Mehrfachversuchsschleife erzeugt nicht sofort ein ganzes Rudel. Frameabhängigkeit ist im Code erkennbar, aber **kein beobachteter Releaseblocker**. **Keine Spawn-Änderung vor Testerfeedback.**

**Testnachweis:** Alle praktischen Spielergebnisse sind Meldungen/Screenshots des Entwicklers; der Assistent hat keinen eigenen AGK-Compile oder HTML5-Browserlauf ausgeführt. Der exakte SHA einzelner lokal exportierter Builds wurde nicht jeweils festgehalten.

## 2. Aktueller Meilenstein: itch.io-Draft-Pre-Alpha läuft

- [x] **Windows-/AGK-Compile und frischer HTML5-Export erfolgreich (Entwicklermeldung 16.11.2026).** Lokaler Apache-Nachtest erfolgreich, kein sichtbares Tearing berichtet. ZIP mit HTML5-`index.html` erstellt und auf itch.io hochgeladen; keine vom Assistenten unabhängig geprüfte ZIP-Datei. Exakter exportierter Code-SHA nicht protokolliert.
- [x] **itch.io-Draft-Embed lädt das Spiel:** Screenshot zeigt das Menü und FPS-Anzeige 60; anschließend Entwickler-Smoke-Test direkt im eingebetteten Spiel. Controller erkannt, Pause funktioniert, alle Waffen, Schild, Energieanziehung und alle Lauf-/Bewegungsfunktionen funktionieren; Tod durch erschöpfte Energie und Absturz getestet. ESC/QUIT sind bewusst im HTML5-Build deaktiviert. **Entwicklerbericht**, kein vom Assistenten ausgeführter Browserlauf.
- [x] **README und englische itch.io-Seitenbeschreibung aktualisiert.** Promo-Cover/-Banner ergänzt; AI-Disclosure auf Text/Dialog, Code und aufgrund KI-generierter Promografiken auch Graphics ausgelegt (tatsächlich gesetzte Formularhäkchen nicht unabhängig geprüft). 💚 bleibt Projektkennzeichen.
- [x] **Secret-URL-Seite im Draft bereitgestellt:** Entwickler bestätigt Upload und gespeicherte Beschreibung; vorliegender Screenshot zeigt Seite in Draft. Die Secret URL darf an ausgewählte Community-Tester weitergereicht werden. **Keine öffentliche Published-Freigabe und kein öffentlicher Release.**
- [x] **Neustart im itch.io-Embed laut Entwickler erfolgreich:** Im Anschluss an die bisher dokumentierten eingebetteten Funktionen wurde der Neustart als „soweit ok“ bestätigt. Keine Aussage über mehrere Neustartzyklen oder Langzeitstabilität speziell im Embed; die mehrmaligen Neustarts im lokalen HTML5-Browser waren bereits bestanden.
- [x] **GitHub-Links auf itch.io ergänzt (Entwicklerbericht):** zwei separate Links zu `main` und `develop`; `main` bleibt bis zum ausdrücklich beschlossenen Merge unverändert.
- [ ] **Feedback der ersten externen Spieler abwarten und sammeln:** tatsächliche Browser-/Controller-Unterstützung, Start/Pause/Neustart, Balance, Minen, Verständlichkeit. Nur reproduzierbare und relevante Probleme einzeln korrigieren; **kein Minenspawn-Umbau vor Testerfeedback.**
- [ ] **Später gesondert über `develop` → `main` entscheiden:** nach akzeptiertem Draft-Meilenstein, eventuell am Abend. Merge **nicht ausgeführt**; vorher Änderungen/Branch-Differenz gemeinsam prüfen. GitHub-Merge und itch.io-Status sind unabhängig; itch.io bleibt Draft bis ausdrücklicher späterer Publish-Entscheidung.

### Bekannte Grenzen für Release-Text oder bewusste Akzeptanz

- **HTML5-ESC/QUIT:** Browserbuild schließt das Spiel nicht wie die Windows-Version; bei eingebettetem HTML5 kein belegter Enginebug. Spieler können die Seite verlassen; Hinweise bei Bedarf.
- **Tastatursteuerung und Browser-Funktionstasten:** Keyboard nur unvollständig; F-/Debug-Tasten werden im Browser teilweise vom Browser abgefangen. Gamepad-only-Pre-Alpha klar benennen.
- **Sonec springt in die Walkergeometrie:** Walker selbst hält korrekt vor Sonec an. Separater Sonec→Walker-Körperkontakt ist noch nicht implementiert; **nur bei konkreter Spielbeeinträchtigung vor dem Draft korrigieren**.
- **Startenergie 4.500 bei Normalmaximum 4.000:** bewusste aktuelle Testwerte, +500 Overload; Overload kann Gesundheitskosten verursachen. Keine endgültige Spielbalance behaupten.
- **Minen-Frameratenabhängigkeit und Gruppenwahrnehmung:** untersucht, für die Pre-Alpha unverändert akzeptiert.

## 3. Erstes Community-Feedback und Post-Pre-Alpha-Patchplanung (16.11.2026, Abend)

**Schritt 1 lokal bestätigt:** Der Entwickler hat `def_input.agc` erfolgreich in AGK Studio kompiliert (Parse Time 61,70 ms, 11.920 Zeilen, 76.514 Tokens); dies bestätigt Syntax/Include, kein neuer Eingabe-Laufzeittest.

**Schritt 2 vom Entwickler bestätigt:** AGK Studio meldet `Compilation finished successfully.` für die Standardbelegung / `InputSetDefaultBindings()`. Kein vollständiger Gameplay-Regressionstest behauptet.

**Schritt 3 lokal bestätigt:** Entwickler meldet `Compilation finished successfully.` nach Hinzufügen der digitalen Action-Abfragen.

**Schritt 4 / 4b vom Entwickler erfolgreich getestet:** AGK Studio kompiliert; alle sechs Tastaturaktionen J/K/L/I/U/O sowie die Gamepad-Regressionsaktionen A/B/X/Y/LB/RB laut Entwickler erfolgreich. Weitere Funktionen dadurch noch nicht bestätigt.

**Schritt 5 vom Entwickler erfolgreich getestet:** AGK-Compile und sechs Bewegungstests einschließlich Stick, D-Pad und Trigger bestanden (Entwicklerbericht). Keine neue HTML5-Bestätigung.

**Schritt 6a vollständig vom Entwickler bestätigt:** AGK-Compile erfolgreich, Enter und Gamepad-Start/A im Intro, Enter und Gamepad-Start zum Pausieren/Fortsetzen, keine unbeabsichtigte Sofortpause, keine weiteren Auffälligkeiten (sechs Prüfpunkte bestanden).

**Schritt 6b implementiert, AGK-Compile und Funktionstest offen:** Die alte `GetJoyPressed(...JoystickButtonBack)`-Abfrage in `GameInput()`, die direkt aus dem laufenden Spiel zum Intro führte, ist entfernt. In `main.agc` wird `InputActionPressed(Keys,Game.JoystickIndex,ACTION_BACK)` nur bei `Game.IsPause = TRUE` ausgewertet. Backspace/Select setzt dann `Game.IsLost = TRUE` und `Game.IsPause = FALSE`; im selben Durchlauf werden keine Game-Updates/Draws ausgeführt. Back hat Vorrang vor gleichzeitigem Start. Unter PAUSE stehen jetzt die Zeilen `ENTER / START - RESUME` und `BACKSPACE / SELECT - MAIN MENU`. Restliche Menü-/Hover-/Action-Logik nicht geändert. **Nächster Schritt:** AGK-Compile und Test: Backspace und Gamepad-Select im aktiven Spiel ohne Wirkung; beide aus Pause führen zum Menü; Enter/Start pausieren und setzen weiter fort; Menü-Neustart funktioniert, Hinweise lesbar. Nicht als bereits getestet markieren.

**Schritt 6a implementiert, AGK-Compile/Test offen:** In `intro.agc` nimmt `IntroDo()` jetzt `Keys ref as TKeys` an und verwendet `InputActionPressed(...ACTION_START)` für Enter/Gamepad-Start; die zusätzliche Gamepad-A-Bestätigung bleibt bestehen. `main.agc` verwendet dieselbe Action für Pause/Fortsetzen und reicht `Keys` ins Intro durch. Der Intro-/Spielzustandszweig bleibt getrennt (keine absichtliche Sofortpause nach Start). **Noch nicht geändert:** Backspace/Select (alter Select-Menüsprung während aktivem Spiel besteht weiterhin), Hover, Menünavigation, Optionsmenü, Cookie. **Nächster einzelner Test:** AGK-Compile; Enter im Menü, Gamepad Start/A im Menü, Enter und Start zum Pausieren/Fortsetzen, keine Doppelauslösung.

**Separater Hover-Befund aus Schritt-5-Test (Entwicklerbeobachtung, noch nicht reproduziert/analysiert):** Bei Ctrl/Hover scheint Sonec gelegentlich auf Höhe einzurasten und erst bei Down wieder zu sinken. Ursache, Bedingungen, Einfluss von Stick/Button 9 und tatsächliche Zustandsänderungen noch ungeprüft. **Nicht im Patch 6a beheben**; isoliert testen und analysieren, bevor Eingriff. Für folgende Tests Rückmeldungen mit optionalem Freitextfeld und einem einzigen bewussten Sende-Button anbieten, damit Abhaken keine Nachricht auslöst.

**Schritt 5 implementiert, AGK-Compile und Bewegungstests offen:** In `SonecInput()` lesen alle sechs Bewegungsaktionen (W/S/A/D/Q/E) nun die `TKeys`-Abfragen über `InputActionState`. D-Pad ist dabei über die bereits hinterlegten vier digitalen Pad-Bindings abgedeckt; direkte redundante D-Pad-Abfragen in diesen Bedingungen entfernt. Analoge Gamepad-Achsen und Trigger (`GetJoyX/Y/Z/RZ`) sowie Timing, Jetpack-Energie, Ducken, Rückwärtslaufen und Blickrichtungsberechnung nicht absichtlich verändert. `GameInput(Game,Keys,Now)` und `main.agc` geben das vorhandene `Keys` weiter. **Hover über Ctrl/Button 9 bleibt unverändert**, ebenso Start, Back, Intro, Pause, Menüs. Gamepad-Select kehrt weiterhin außerhalb der vereinbarten künftigen Pausenregel direkt ins Menü zurück – separate spätere Änderung; nicht bereits als gelöst ansehen. **Nächster Test:** AGK-Compile, danach WASD+Q/E, Jetpack/Flug, Blickrichtung und Gamepad-Stick/D-Pad/Trigger; HTML5 noch ausstehend.

**Schritt 4 implementiert, AGK-Compile und Gameplay-Test offen:** Sechs vorhandene Sonec-Eingabefunktionen (MG, Granatwerfer, Flamme, Plasma, Energieanziehung, Schild) lesen `TKeys` über `InputActionState()` (vier Waffen, weiterhin Dauerfeuer und MG-Burst-Logik) bzw. `InputActionPressed()` (zwei Umschaltaktionen). `GameActionInput()` erhält `Keys` vom in `main.agc` initialisierten lokalen Datensatz und reicht ihn an die sechs Sonec-Funktionen weiter. Standardtasten: J MG, K Granate, L Flamme, I Plasma, U Energieanziehung, O Schild. Bestehende A/B/X/Y/LB/RB-Gamepad-Belegung soll unverändert arbeiten. Bewegung, Start, Back, Menüs, Pause, Hover und Trigger/Achsen blieben unangetastet. **Nächster Test:** AGK-Compile, dann sechs Aktionen mit Tastatur sowie Gamepad-Regression; dies wurde vom Assistenten nicht ausgeführt. Cookie/Optionsmenü bleiben spätere Schritte.

**Schritt 3 implementiert, Compile offen:** `input.agc` erweitert um `InputActionState(Keys,JoystickIndex,Action)` und `InputActionPressed(Keys,JoystickIndex,Action)`: sichere Prüfung der Aktionsindizes, keine Abfrage unzugewiesener 0-Codes, Verknüpfung der vorhandenen Tastatur- und digitalen Gamepad-Wrapper. Hover übernimmt in den Defaultdaten den **bereits von SonecBot verwendeten** `JoystickButtonPadLeft = 9`; physische Identifikation (L3?) und Button 11 bleiben offen. Gamepad-Analogachsen und Trigger weiter im alten Eingabecode; keine Gameplay-Abfrage wurde umgestellt. **Nächster Schritt:** AGK-Compile durch Entwickler, dann Testmigration nur nach Freigabe.

**Schritt 2 implementiert, Compile offen:** `source/sonec/input.agc` enthält `InputSetDefaultBindings(Keys ref as TKeys)` und initialisiert alle 15 Einträge auf Standardwerte (zuerst nullen). Links W/S/A/D/Q/E, rechts J (MG), K (Granate), L (Flamme), I (Plasma), U (Energie), O (Schild), zusätzlich Ctrl (Hover), Enter (Start) und Backspace (Back). Für Gamepad: D-Pad-Richtungen sowie bisheriges A/B/X/Y/LB/RB/Start/Back; Analogsticks und Trigger bleiben im alten Code, L3/Hover bleibt unzugewiesen bis Geräte-/Browser-Test. `main.agc` bindet `input.agc` ein und initialisiert ein noch nicht von der Spiellogik verwendetes lokales `TKeys`. Kein Rebinding, Cookie, Optionsmenü oder geänderte Eingabeabfrage. **Nächster Schritt: AGK-Compile durch Entwickler.**

**Neuer Implementierungsschritt (16.11.2026):** Auf `develop` wurde `source/sonec/def_input.agc` angelegt und unmittelbar nach `def_keys.agc` in `main.agc` eingebunden. Enthalten: 15 Aktionskonstanten (6 Bewegung, 6 Aktionen, Hover, Start, Back), `TActionBinding` mit `Key`/`PadButton`, `TKeys` mit Versionsnummer und festem Bindings-Array `[14]`. **Nur Strukturen; noch keine Standardbelegung, keine Umstellung der Abfragen, kein Optionsmenü, kein Cookie und kein Test durch AGK Studio.** Die sechs plus sechs Hauptaktionen, zusätzlich Hover (Gamepad-L3 als unbestätigter Kandidat), Enter/Start, Backspace/Select und Back zum Menü nur aus der Pause sind die vereinbarten Designziele. Gamepad-Remapping und Maus später. **Nächster kleiner Schritt:** die Datenstruktur lokal kompilieren, bevor wir Standardbelegungen initialisieren. Das aktuelle Gamepad-Verhalten wurde nicht absichtlich geändert.



**Beobachtung, keine Vermutung:** Der Entwickler berichtet, dass **drei Personen SonecBot wegen der fehlenden vollständigen Tastatursteuerung nicht spielen können**. Das ist eine bestätigte **Zugangshürde** für Tester ohne Gamepad, noch kein getesteter Implementierungsfehler. Gamepad-only war als Grenze im Pre-Alpha-Text offengelegt, aber die Rückmeldung macht Tastaturunterstützung zum ersten konkreten Kandidaten der Post-Pre-Alpha-Patches. Bestehende funktionierende Gamepad-Belegung unangetastet lassen.

- [x] **Bestandsaufnahme SonecBot ↔ Crystals/Columns abgeschlossen; gemeinsame Actions festgelegt.**
- [x] **Reine Eingabestrukturen angelegt:** 15 Aktionskonstanten und `TKeys`/`TActionBinding` in `def_input.agc`; Include in `main.agc`. Kompilierung noch offen.
- [x] **Nach Abschluss des Main-Merge-Meilensteins read-only Inventur** der vorhandenen Tastaturabfragen in `sonec.agc`, `intro.agc`, `controls.agc`, `main.agc` und Eingabekonstanten: Bewegung/Jetpack, MG, Granaten, Flamme, Plasma, Schild, Energieanziehung, Menü, Bestätigung, Pause, Neustart. Insbesondere historische Doppelbelegung `KEY_2` für MG/Granate beachten.
- [ ] **Dann gemeinsam minimalistisches Keyboard-Layout definieren**, das im Browser nutzbar ist und nicht mit browserreservierten Tasten kollidiert. Keine automatische Implementierung und noch kein vollständiges Options-/Remapping-System.
- [ ] **Kleine Post-Pre-Alpha-Patches einzeln freigeben und unter Windows, Apache-HTML5 und itch.io-Embed testen.** Testkriterium: ohne Gamepad Start → Spiel → Bewegung/Kampf/Schild → Pause → Tod/Neustart; Gamepad-Regression prüfen.
- [x] **Meilenstein-Merge `develop`→`main` abgeschlossen über PR #1** (Merge-Commit `0ee6710`); initialer README-Konflikt durch Übernahme der BlitzBasic-/BlitzMax-Historie und Branch-Erklärung aufgelöst. Historischer Ausgangsvergleich: vom 16.11.2026 hat `main` zwei eigene Commits (README-Anpassungen), `develop` 413 zusätzliche Commits. [PR #1](https://github.com/ChristianEngel19820128/SonecBot/pull/1) wurde zur Mergeprüfung eröffnet, **GitHub meldete ursprünglich mergeable=false**; Konflikt inzwischen gelöst, Merge durchgeführt; kein Force-Push. Die neue Input-Definitionsarbeit erfolgt wieder nur auf `develop`.

## 4. Später – gesammelt, nicht als Pre-Alpha-Blocker

### Gameplay, KI und Kollisionen

- [ ] **Regelbasierte Minengruppen/Rudelspawns** erst nach Spielerfeedback konzipieren: Ereignisbedingungen, Anzahl, räumliche Abstände, Zeitbasis, Fairness und ggf. Warnungen definieren, dann gezielt implementieren und testen. Nicht nur zur kosmetischen „Reparatur“ des bisherigen Zufallsverhaltens umstellen.
- [ ] **Informationsavatar / Warnmeldungen** (bestehende Projektidee): zunächst optional roter, fett gesetzter Text oben, z. B. `MINEFIELD DETECTED`; später Symbol/Portrait und Sprachausgabe. Auslöser, Anzeigedauer, Prioritäten und Spam-Unterdrückung vorher vereinbaren.
- [ ] **Sonec→Walker-Sprungkontakt** und gegebenenfalls zusätzliche Walker-Körperteil-Trefferzonen prüfen. Erfolgreichen Turm-Hitbox-Fokus, IK und Gegnercharakter schützen.
- [ ] **Drei Fraktionen** Player (ggf. zweiter Spieler), Enemy, Neutral sowie geplante Schadensarten Plasmaexplosion, Plasmaflamme, kinetisch, Plasma-Blitz und passende Panzerungen nach Konterprinzip modellieren; **jetzt keine Widerstandswerte oder Multiplikatoren**.
- [ ] Waffen-/Energie-/Drop-Balance nach externem Spielerfeedback bewerten; u. a. Flammenenergie, Aufladung/Verbrauch beim Plasma-Blitz, kinetische Granate plus Explosion, Minen-/Kistenfestigkeit, Jetpack-Reserve und Overload-Kosten.
- [ ] Schnelle Projektil-Randfälle, mögliche AABB-Ecktreffer, Kettenreaktionen und Fairness bei Bedarf konkret reproduzieren. Beobachtete Walker→Mine→Walker-Explosion ist derzeit **kein Bug**.
- [ ] Rundenziel, Score, Achievements („Waffenschein für alle“ bisher nur Scherz), weitere Gegner, optionale Top-Down-/Draufsicht und spätere Multiplayer-Ideen einzeln planen.

### Bedienung, Präsentation und Technik

- [ ] Vollständige Tastaturbelegung, Options-/Hilfemenü, Key-Rebinding und HTML5-Speicherung nach Bedarf planen; ESC-/Browser-Ende und browserfreundliche Debug-Tasten getrennt beurteilen.
- [ ] **Sounds in die fachlich passenden allgemeinen Ereignisfunktionen verlagern**, nicht nur in Sonec-spezifischen Aufrufen; zuerst Sound-Trigger inventarisieren und doppeltes Abspielen vermeiden.
- [ ] Grafik-/HUD-/IK-Politur, größen-/panzerungsabhängige Trefferzonen, zusätzliche Upgrades und Ressourcenanzeige nur auf konkreten Bedarf.
- [ ] Längere Aufnahmen bei Gelegenheit: GifCam-/RAM-Hypothese prüfen und ggf. Aufnahmealternative suchen; nicht in den aktuellen Releasefluss ziehen.
- [ ] Hochscores/Online-Anbindung aus Crystals, Speicherformat, weitere AGK-/Renderer-/VSync-/FPS-/Browser-Tests und Performancebeobachtung später gezielt bearbeiten.

## 5. AGK Knowledge Base – eigener freizugebender Arbeitsschritt

Die [agk-knowledge-base](https://github.com/ChristianEngel19820128/agk-knowledge-base) bleibt ohne gesonderte Vereinbarung **read-only**.

- [ ] Kandidaten gesammelt halten: HTML5-Gamepad-Index/Initialisierung, Browser-ESC/QUIT, XAMPP-Cache/Hard-Reload, Timer/FPS-abhängiges Spawning, Sprite-/Float-/Integer-Division, Random-Grenzen, verschachtelte Konstanten und Turm-Schwenkprojektion.
- [ ] Für jeden Kandidaten zuvor genaue Quelle/Revision, beobachtetes Symptom, Gegenprobe, Status (bestätigt/Hypothese) und wiederverwendbaren Nutzen prüfen; keine unbestätigten Enginebugs behaupten.

## 6. Vorgehensweise

Kleine einzeln vereinbarte Schritte, echter Test durch Entwickler in AGK Studio/Apache, Resultat und Grenzen dokumentieren, danach nächsten Punkt auswählen. `develop` ist die aktive Spielcode-Branch; `main`, Legacy und Lizenz nur nach ausdrücklicher Vereinbarung ändern. Keine ungefragten Änderungen an bereits akzeptierten Walker-Pivots, IK oder Kampfsystemen. Historische Detailprotokolle bleiben in [TECHNICAL.md](TECHNICAL.md), [HANDOFF.md](HANDOFF.md) und Git.
