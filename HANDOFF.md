# Übergabe: Alpha-Walker abgeschlossen → HTML5-Pre-Alpha

**Stand:** 16. November 2026  
**Ziel:** HTML5-Pre-Alpha kontrolliert testen und ausgewählten Personen über itch.io-Draft/Secret-URL zugänglich machen; öffentliche Veröffentlichung später entscheiden  
**Status:** Alpha-Walker abgeschlossen; HTML5-Compile/Export, lokaler Apache-Test und **itch.io-Draft-Upload samt eingebettetem Gameplay-Smoke-Test laut Entwickler erfolgreich**; Gamepad, Bewegung, Waffen, Schild/Energieanziehung, Pause und Tod im itch.io-Embed bestätigt. Neustarts lokal mehrfach geprüft; anschließend ein Neustart direkt im itch.io-Embed vom Entwickler als „soweit ok“ bestätigt. **Draft / Secret URL, nicht Published**; externer Community-Test beginnt. Merge nach `main` offen.  
**Repository:** ChristianEngel19820128/SonecBot  
**Arbeitsbranch:** `develop`  
**Historischer, lokal akzeptierter Walker-Abschluss-Codecommit:** [`18f92a965810763b552bd96649607c112f966238`](https://github.com/ChristianEngel19820128/SonecBot/commit/18f92a965810763b552bd96649607c112f966238)

> Der Nutzer bestätigt nach dem letzten 3-px-Turmrückstoß: „test bestanden. funktioniert alles wie erwartet.“ Anschließend ausdrücklich: „aufgabe Alpha Walker abgeschloßen.“
> Jetzt Deployment fortsetzen, nicht die Walker-Entwicklung neu beginnen. Der tatsächliche develop-HEAD muss neu abgefragt werden; diese Übergabe selbst ist ein nachfolgender Dokumentationsstand.

> **Aktuelle gemeinsame Entscheidung (16. November 2026; ersetzt ältere Termin-/Veröffentlichungsformulierungen unten):** Kein hektischer öffentlicher Release am 16. November. Die HTML5-Pre-Alpha ist für die AGK-Community und ausgewählte Personen bestimmt. Die itch.io-Seite bleibt absichtlich **Draft**; der **Secret-URL-Link** ermöglicht den Zugang für alle, die ihn besitzen. Die Umstellung auf **Published** wird bewusst zurückgehalten, weil laut Entwickler der einmalige itch.io-Index-Push dadurch ausgelöst wird und später nicht erneut verfügbar ist. Veröffentlichung eventuell zu Beta 0.9 oder 1.0, **noch offen**. Kein Publish ohne ausdrückliche Freigabe. Der Besitzer pflegt itch.io manuell; Texte dafür **in englischem Markdown**. 💚 ist das vereinbarte Zeichen für README und itch.io.
>
> **Arbeitsweise:** In kleinen gemeinsam freigegebenen Schritten vorgehen. Nutzer exportiert/kompiliert in lokalem AGK Studio, testet mit lokalem Apache im Browser/Gamepad und pflegt itch.io; Assistent prüft GitHub-Quellen und dokumentiert präzise, ohne lokale Tests zu behaupten. Besonderheiten mit Nachweisstatus festhalten, aktuellen Schritt beenden, erst danach über Folgearbeit bzw. Knowledge-Base-Eintrag entscheiden. Crystals 1.0 ist die bewährte Prozesserfahrung. GitHub-HEAD bei jedem Einstieg neu lesen; Snapshot vor dieser Dokumentationsänderung: `3840bfa545aeec6df6902180415d22efdd58f3ba`.
> **Prüfkandidat, noch kein bestätigter Bug:** Spawn-Zufallsentscheidungen liegen in `GameDo()` und könnten pro Frame statt pro Zeit erfolgen. Vor jeder Änderung tatsächliche Frequenzen/Spielwirkung bewerten; keine pauschale Balancingmaßnahme.

## Post-Pre-Alpha: Menü-Navigation 7a/7a.1 abgenommen (17.11.2026)

**Ergebnis vom Entwickler:** Schritt 7a (W/S und Pfeiltasten, Menü-Umlauf, Enter zum Start, Gamepad-D-Pad und Start/A) erfolgreich. 7a.1 Analogstick-Nachrüstung vollständig bestanden, AGK-Compile und **10 von 10 Testpunkten**: Stick hoch/runter ein Schritt, bei Halten keine Wiederholung, nach Neutralstellung erneut auslenkbar, Wrap über START/OPTIONS/QUIT, D-Pad, W/S/Pfeiltasten, Enter/Start/A und normaler Spielstart. Keine Auffälligkeiten. Beide Schritte abgeschlossen. Die Tests stammen ausschließlich vom Entwickler (AGK-Spieltest), nicht vom Assistenten oder aus einem frischen HTML5-Browserlauf.

**Neuer nächster Schritt – noch NICHT freigegeben:** OPTIONS wird im bestehenden `IntroDo()` durch `Intro.IsOption = TRUE` gesetzt, aber `main.agc` behandelt diesen Zustand noch nicht als eigenes Menü. Gemeinsame Planung eines kleinen Options-Unterbildschirms inklusive Rückweg zum Hauptmenü, bevor Hover-Modus (bevorzugtes Toggle / optionales Hold) und Speicherung getrennt implementiert werden. Eingabebindings Space/Button 9, kostenlose Hover-Luftbremse, Jetpack-Vorrang bleiben unverändert. Keine Implementierung ohne nächste ausdrückliche Freigabe.

## Post-Pre-Alpha: Schritt 7a.1 Analogstick-Navigation im Intro (17.11.2026)

**7a Testbericht des Entwicklers:** AGK-Compile, W/S, Pfeiltasten, Menü-Wrap und Enter→Spiel erfolgreich; Gamepad-Steuerkreuz funktioniert. Die zunächst unscharfe Rückmeldung „Pad geht nicht“ wurde geklärt: Gamepad Start/A funktionieren, **nur linker Analogstick** navigiert nicht. Dies war vor 7a.1 im Intro nicht implementiert; damit ist kein Rückschritt bei Start/A belegt. 7a bleibt bis zum Analog-Ergänzungstest offen.

**7a.1 explizit freigegeben und auf `develop` implementiert, AGK-Compile/Gamepad-Test ausstehend:** `TIntro.AnalogMenuHeld as integer` in `source/sonec/def_game.agc`; `IntroCreate()` initialisiert den Zustand mit FALSE. `IntroDo()` liest pro Aufruf `GetJoyY(JoystickIndex)`: bei Y kleiner -0.5 genau einmal nach oben, bei Y größer +0.5 einmal nach unten, dann wird bis zur neutralen Stick-Position zwischen -0.3 und +0.3 gesperrt. Für den Schritt wird die bestehende Hoch-/Runter-Menülogik mit Wrap, Sound und Markierung wiederverwendet. W/S, Pfeile, Gamepad-D-Pad und Enter/Start/A unverändert; keine Modifikation von `main.agc`, OPTIONS oder Hover.

**Nächster einzelner Test:** Entwickler AGK-Compile, Stick nach oben/unten jeweils genau ein Schritt, Halten bewirkt keine Wiederholung, Rückkehr neutral und erneute Auslenkung bewirkt nächsten Schritt; D-Pad, Tastatur, Enter/Start/A weiter funktionsfähig. Den freien Beobachtungstext und bewussten „Testergebnis senden“-Knopf anbieten. Erst nach bestandenem Test mit Planung des Optionsmenüs beginnen. Keine HTML5-/Browserprüfung durch Assistenten, keine Änderung an itch.io oder separater Knowledge Base.

## Post-Pre-Alpha: Schritt 7a Tastaturnavigation im Intro (17.11.2026)

**6e vom Entwickler vollständig bestanden:** AGK-Compile und 8/8 Checks: Space-Hover halten/loslassen, WASD/QE+Space, W+Space mit Jetpack-Vorrang, Ctrl ohne Hover, Button 9 intakt, Space-Release während Pause korrekt; keine Auffälligkeiten. Somit Space als Hover-Default im Windows/AGK-Test akzeptiert. Keine neue HTML5-Prüfung.

**7a auf `develop` umgesetzt, AGK-Compile und Menü-Gameplay-Test noch ausstehend:** In `source/sonec/intro.agc` wurden ausschließlich zwei Menü-Abfragen ersetzt: hoch über `InputActionPressed(Keys,JoystickIndex,ACTION_MOVE_UP) = 1 or GetKeyPressed(KEY_UP) = 1`, runter entsprechend `ACTION_MOVE_DOWN` bzw. `KEY_DOWN`. Da die vorhandenen Action-Defaults W/S und D-Pad-Up/Down enthalten, bleiben Gamepad-D-Pad und bestehende Wrap-Navigation erhalten. Enter/Start/Gamepad-A-Confirm unverändert; die `OPTIONS`-Auswahl setzt weiterhin nur `Intro.IsOption = TRUE`, tatsächlich bedienbare Optionen noch nicht gebaut. Es gibt keine Änderung an Hover-Modus, Space/Pad-Bindings, Gameplay, Dateien/Speicherung oder itch.io.

**Nächster einzelner Test:** Entwickler kompiliert neuesten `develop`-HEAD und prüft W/S, Pfeil hoch/runter, Menü-Wrap START→OPTIONS→QUIT, Enter als Startbestätigung, D-Pad hoch/runter und Gamepad A/Start. Testbericht mit Freitext und ausdrücklichem Senden. Danach erst den schmalen Beginn eines Optionsmenüs gemeinsam festlegen. Keine Änderungen anderer Repositories.

## Post-Pre-Alpha: Schritt 6e Space als Hover-Default (17.11.2026)

**Schritt 6d vom Entwickler vollständig bestanden:** AGK-Compile und sämtliche acht Jetpack/Hover-Prüfpunkte: W allein, Ctrl allein, W+Ctrl mit normalem Jetpack-Aufstieg, W loslassen bei gehaltenem Ctrl zu Hover, beide loslassen normal fallen, Gamepad-Stick hoch + Button 9 sowie Bewegung/Waffen weiterhin funktionsfähig. Zusätzlicher positiver Befund: Ctrl loslassen während Pause bewirkt bei Fortsetzen normalen Fall.

**Schritt 6e auf `develop` implementiert, AGK-Compile/Gameplay noch offen:** In `source/sonec/input.agc` nur Keyboard-Default `Keys.Binding[ACTION_HOVER].Key = KEY_SPACE` statt `KEY_CONTROL`. Kein anderer Codepfad geändert. Weiterhin Hover durch Halten, Pad-Button 9, Jetpack-Vorrang, unveränderte Energie-/Physikregeln. Noch keine Bestätigung, dass Space im Spiel mit W/A/S/D/Q/E gut zu bedienen ist. Ctrl darf in der Standardbelegung Hover nicht mehr aktivieren.

**Nach dem Test separat entscheiden:** Geplanter bevorzugter Hover-Modus `Umschalten` als Standard im Optionsmenü, `Halten` als Alternative; Optionsmenü und gespeicherte Settings noch nicht implementiert. Kostenloser Hover bleibt vorerst bewusste Designentscheidung; tatsächliches Spielerfeedback abwarten. Gamepad-Button 9 ist technisch als bestehender Hover-Button bestätigt, physische Tastenidentität/Ergonomie weiter offen.

**Nächster Schritt:** Entwickler kompiliert neuen `develop`-HEAD und testet Space halten/loslassen, WASD/QE+Space, W+Space, Ctrl keine Hover-Funktion, Pad-Button 9, Pausen-Release. Berichte per Checkliste mit Freitext und explizitem Senden. Keine Änderungen an main, itch.io oder anderen Repositories.

## Post-Pre-Alpha: Hover/Jets Schritt 6d (17.11.2026)

**6c technisch vom Entwickler bestanden:** AGK-Compile und sämtliche 8 Hover-Tests erfolgreich: mit/ohne A/D halten, Ctrl/Button 9 loslassen beendet Hover, Jetpack und Bewegung weiterhin funktionsfähig. Der Testbericht enthielt neue Design-Beobachtungen statt durchgefallener Prüfpunkte.

**Nutzerpräferenzen nach 6c:** Hover bleibt zunächst kostenlos und ohne eigenen Jet; mögliche Übermächtigkeit und Entdeckung durch Spieler beobachten. Geplante spätere Standardtaste **Space** statt Ctrl, da Ctrl ergonomisch schwer bedienbar. Späteres Optionsmenü soll **Umschalten als Standard** und **Halten als Alternative** anbieten, einschließlich Speicherung/Reset und klarer Zustände. Gamepad-Hover-Taste künftig auf Ergonomie untersuchen; bisher Button 9. Diese Optionen sind NICHT implementiert, nicht Teil von 6d.

**6d ausschließlich auf `develop` implementiert, AGK-Compile/Runtime offen:** In `source/sonec/sonec.agc` wird die bereits vorhandene Luftbremsung mit Faktor 0.20 in `SonecMove()` nur noch ausgeführt, wenn `Sonec.State.Hover = TRUE and Sonec.State.Fly = FALSE`. So hat aktiver Jetpack-Flug Vorrang; nach W/Stick-Up loslassen und weiterhin gehaltenem Hover bremst Hover wieder den Fall. Keine Änderung der Hover-Eingabe, Defaultbelegung Ctrl/Button 9, Energie, Auftrieb, Grafik oder restlicher Physik. Bei fehlendem Jetpack-Schub (z. B. zu wenig Energie) bleibt Hover als Luftbremse erlaubt. Quelltext geprüft, aber bisher nicht lokal kompiliert.

**Nächster kleiner Test:** Entwickler kompiliert aktuellen `develop`-HEAD, vergleicht Jetpack-Aufstieg W allein gegen W+Ctrl, prüft Ctrl allein während freien Fallens, Übergang W+Ctrl → Ctrl halten/W loslassen → beide loslassen, Gamepad-Stick hoch + Button 9 sowie normale Bewegung. Beobachtungen mit Freitext notieren, kein automatisches Absenden. Danach erst Space-Key-Default oder Hover-Modus separat freigeben.

## Post-Pre-Alpha: Hover-Fix 6c – gehaltene Eingabe (16.11.2026, spät)

**6b vollständig vom Entwickler bestätigt:** AGK-Compile und alle acht Testfälle bestanden (Backspace/Select außerhalb Pause ohne Wirkung, aus Pause zum Menü, Enter/Start fortsetzen, Neustart, Hinweise); keine Auffälligkeiten.

**Hover reproduzierbarer Symptombefund:** A+Ctrl oder D+Ctrl → langsames Fallen; Ctrl loslassen bei gehaltenem A → normal; A loslassen bei gehaltenem Ctrl → ungefähr gleiche Höhe; S drücken → weiter langsames Schweben. Code erklärt einen möglichen latched State: `Sonec.State.Hover` wurde nur in seitlichen Bewegungszweigen geändert. Die genaue Bedienungsverbesserung (Space oder Shift; alternative Pad-Taste) ist bewusst **nicht** Teil dieses Fixes.

**Freigegebener minimaler Fix auf `develop` implementiert, AGK-Compile und Test offen:** `source/sonec/sonec.agc` ruft nun genau einmal innerhalb des vorhandenen `Sonec.InputTimer`-Gates `Sonec.State.Hover = InputActionState(Keys,JoystickIndex,ACTION_HOVER)` auf. Die beiden identischen Setzer innerhalb von Links-/Rechtsbewegung wurden entfernt. Ctrl und Pad-Button 9 bleiben in `InputSetDefaultBindings()` unverändert. `SonecMove()` und Multiplikator 0.20, Jetpack, sonstige Bewegung, Waffen und UI unverändert. Die tatsächliche An-/Aus-Reaktion folgt dem bisherigen Eingabe-Timer und der Bewegungsaktualisierung, nicht einer garantierten sofortigen Physikänderung im selben Frame.

**Nächster Test:** Entwickler kompiliert neuen `develop`-HEAD, prüft getrennt Ctrl und Pad-Button 9 während freiem Fall, Loslassen beim A/D-Bewegen und ohne Seitwärtsbewegung, normales Fallen nach Loslassen sowie bisherigen Jetpack/Waffen-Pfad. Erst danach neue Hover-Tastenbelegung besprechen. Keine Änderung an `agk-knowledge-base`, anderen Projekten oder itch.io.

## Post-Pre-Alpha: Schritt 6b Back nur aus Pause (16.11.2026, spät)

**Schritt 6a vollständig vom Entwickler getestet und bestanden:** AGK-Compile, Enter für Intro-Start, Gamepad-Start und A als Menübestätigung, Enter/Gamepad-Start für Pause/Fortsetzen, keine Sofortpause nach Spielstart; keine Auffälligkeiten. Sechs von sechs Prüfpunkten bestätigt.

**Schritt 6b auf `develop` umgesetzt, AGK-Compile/Spieltest steht noch aus:** In `game.agc` wurde die direkte Gamepad-Back-Abfrage aus `GameInput()` entfernt. In `main.agc` wird `InputActionPressed(...ACTION_BACK)` nur ausgewertet, wenn `Game.IsPause = TRUE`. Beim Drücken von Backspace bzw. Select im Pausenzustand wird `Game.IsLost = TRUE` gesetzt und `Game.IsPause = FALSE`; Back hat bei gleichzeitiger Start-/Back-Eingabe Vorrang. Es wird in diesem Pfad keine Spiellogik oder GameDraw mehr ausgeführt, Intro erscheint im nächsten Durchlauf. Unter der PAUSE-Überschrift werden die neuen Texte `ENTER / START - RESUME` und `BACKSPACE / SELECT - MAIN MENU` gezeichnet. Der Intro-Gamepad-A-Confirm, Waffen, Bewegung und Hover blieben unverändert. **Kein bestätigter AGK-Compile oder HTML5-/Gamepad-Test dieses neuen Stands.**

**Hover-Beobachtung weiterhin separat offen:** Ctrl/Hover scheint laut Entwickler gelegentlich einzurasten, bis Down gedrückt wird. Nicht mit Back-Patch vermischen, Ursache unbestätigt. Gemeinsame Test-Rückmeldungen mit optionalem Freitext und explizitem Senden-Button, nicht durch Abhaken auslösen.

**Nächster einzeln zu testender Schritt:** Nutzer kompiliert den aktuellen `develop`-HEAD und bestätigt Backspace/Select ohne Wirkung im laufenden Spiel, Backspace/Select aus Pause ins Intro, Pausenhinweise und funktionierenden Neustart aus Intro. Danach erst Hover-Diagnose/Schritt 6c gesondert freigeben.

## Post-Pre-Alpha: Schritt 6a Start/Pause (16.11.2026, spät)

**Schritt 5 bestätigt:** Entwickler meldet erfolgreichen AGK-Compile und sechs Bewegungstests inklusive Stick, D-Pad und Trigger. Neues HTML5-Ergebnis bisher nicht berichtet.

**6a auf `develop` umgesetzt, AGK-Compile offen:** `IntroDo(Intro,Sound,Keys,JoystickIndex,Now)` nutzt `InputActionPressed(Keys,JoystickIndex,ACTION_START)` für Enter/Gamepad-Start; A bleibt alternative Gamepad-Menübestätigung. In `main.agc` wird `Keys` an `IntroDo` gegeben; bestehende Pause-Umschaltlogik verwendet `InputActionPressed(...ACTION_START)` statt unmittelbarem Joystick-Start. Intro und aktive Game-Logik bleiben als getrennte if/else-Zweige. Keine Bewegung, Waffen oder Gamepad-A-Menüfunktion geändert. **Back bleibt alt** (Select während Gameplay springt noch zum Intro); Pausenhinweis folgt ausschließlich in 6b nach eigenem Test. Hover folgt 6c.

**Neuer Beobachtungsbefund (noch nicht isoliert bestätigt):** Entwickler berichtete während des Bewegungstests, dass Ctrl/Hover manchmal auf einer Höhe „einrastet“ und Sonec erst nach Down wieder sinkt. Kein automatischer Fix, keine Ursachenzuschreibung. Für separaten reproduzierbaren Test vor Hover-Änderung merken, auch eventuelle Tastendruckfolge/Hover-Status beim Loslassen notieren. `JoystickButtonPadLeft=9` ist im bisherigen Code Hover, physische Taste noch unbestätigt; Button 11 weiter unbenannt.

**Testkommunikation:** Checklisten künftig mit frei beschreibbaren Beobachtungen und einem bewussten „Testergebnis senden“-Knopf, kein sofortiges Abschicken beim bloßen Abhaken.

**Nächster einzelner Schritt:** Nutzer kompiliert aktuellen `develop`-Stand und prüft Enter/Start im Intro und für Pause/Fortsetzen, zusätzlich A als Menübestätigung; Testergebnis mit Freitextbefunden. Danach erst 6b.

## Post-Pre-Alpha: Schritt 5 Bewegung auf Actions umgestellt (16.11.2026, Abend)

**Schritt 4 und 4b vom Entwickler bestätigt:** AGK-Compile erfolgreich; sechs Tastaturaktionen J/K/L/I/U/O sowie Gamepad A/B/X/Y/LB/RB erfolgreich im Spiel getestet. Dies bestätigt die erste produktive `TKeys`-Verwendung für die sechs Waffen-/Energieaktionen.

**Schritt 5 auf `develop` implementiert, AGK-Compile und Gameplay noch offen:** Nur sechs Bewegungsabfragen in `source/sonec/sonec.agc` auf `InputActionState(Keys,JoystickIndex,ACTION_MOVE_UP/DOWN/LEFT/RIGHT/BACK_LEFT/BACK_RIGHT)` umgestellt, mit Datenweitergabe über `GameInput(Game,Keys,Now)` und `main.agc`. Bisherige D-Pad-Abfragen sind in den ersetzten Bedingungen durch digitale Pad-Bindings abgedeckt; Stick-/Triggerachsen `GetJoyX/Y/Z/RZ`, Jetpack-Energiekosten, Sonec-Animations-/Blickrichtungslogik und übrige Bedingungen bleiben unangetastet. `GetJoyZ(1)` und `GetJoyRZ(1)` im alten Blickrichtungszweig wurden absichtlich **nicht** umgeschrieben; bestehender möglicher Index-1-Randfall separat prüfen, nicht ohne Befund ändern. Hover (Ctrl / Gamepad Button 9), Menü/Start/Pause, Gamepad-Back-Verhalten und restliche Spielmechanik bleiben unverändert. **Bekannte noch offene Designentscheidung:** Back/Select darf zukünftig nur aus Pause zum Menü führen, aktuell ist die ältere Live-Funktion noch vorhanden. Weitere Entwicklung (Optionsmenü, Cookie, spätere Pad-/Maus-Bindings) nicht Teil dieses Commits.

**Nächster kleiner Schritt:** Entwickler kompiliert den neuen `develop`-Stand in AGK Studio, dann prüft WASD+Q/E, Jetpack, Ducken, korrekte Laufrichtung und entgegengesetzte Blickrichtung bei Rückwärtsbewegung sowie Gamepad-Stick, D-Pad, Trigger; Schild/Waffen sollten weiter funktionieren. Noch kein neuer HTML5-Test bestätigt.

## Post-Pre-Alpha: Schritt 4 erste aktive Action-Migration (16.11.2026, Abend)

**Schritt 3 vom Entwickler erfolgreich kompiliert:** `Compilation finished successfully.` Die beiden Funktionen `InputActionState` und `InputActionPressed` sind vom AGK-Compiler akzeptiert.

**Schritt 4 auf `develop` umgesetzt, derzeit noch NICHT vom Entwickler kompiliert/gespielt:** Die sechs Kampf-/Energieaktionen in `source/sonec/sonec.agc` verwenden jetzt `InputActionState(Keys,JoystickIndex,ACTION_FIRE_*)` für MG, Granatwerfer, Flamme, Plasma und `InputActionPressed(...ACTION_SHIELD/ACTION_ATTRACT_ENERGY)` für Schild und Energieanziehung. Bestehende MG-Burst-, Energie-/Munitions- und Timing-Bedingungen wurden beibehalten. `GameActionInput(Game,Keys,Now)` reicht die bereits initialisierten `TKeys` weiter, `main.agc` ruft diese Funktion mit `Keys` auf. Tastaturstandard J MG / K Granate / L Flamme / I Plasma / U Energie anziehen / O Schild. Gamepad A/B/X/Y/LB/RB soll weiterhin funktionieren. **Alle Bewegungs-/Hover-/Start-/Back-/Pause-/Menü-Routinen sind unverändert.** Keine Cookies, kein Optionsmenü, kein Speichern, keine Maus. Nur Quelltextverifikation durch Assistenten, kein AGK-/Browserlauf.

**Nächster Schritt:** aktuelles `develop` in AGK Studio kompilieren, anschließend Windows-Gameplay mit sechs Tastaturaktionen einzeln und parallel Gamepad; Shield/Attract je zweimal drücken (an/aus), MG/Plasma beim Gedrückthalten prüfen. Bei Problemen Fehlermeldung oder reproduzierbares Verhalten besprechen, nicht blind weiterpatchen. Referenz `Crystals` bleibt unverändert; itch.io Draft bleibt unveröffentlicht.

## Post-Pre-Alpha: Schritt 3 digitale Action-Abfragen (16.11.2026, Abend)

**Schritt 2 vom Entwickler erfolgreich kompiliert:** `Compilation finished successfully.` Die Standards in `input.agc` und ihre Initialisierung in `main.agc` sind syntaktisch akzeptiert.

**Schritt 3 auf `develop` implementiert, AGK-Compile ausstehend:** `InputActionState(Keys ref as TKeys,JoystickIndex as integer,Action as integer)` und `InputActionPressed(...)` in `source/sonec/input.agc` hinzugefügt. Beide prüfen `0..ACTION_LAST`, ignorieren nicht belegte Key-/Pad-Werte (0), führen Tastatur- und digitale Gamepad-Eingaben über bestehende `GetKeyState/GetKeyPressed/GetJoyState/GetJoyPressed` zusammen. Kein direkter Anschluss an `sonec.agc`, `intro.agc`, `game.agc` oder die Pausensteuerung; bisheriges Spielverhalten bleibt bestehen. Achsen und Trigger absichtlich noch nicht eingebunden. `ACTION_HOVER` verwendet nun in den Defaultdaten `JoystickButtonPadLeft = 9`, den die alte Hover-Routine bereits abfragt; **nicht belegt**, ob das physisch L3 ist. Gamepad Button 11 existiert, ist nicht zugeordnet. Die geplante Tastatur-Cookie-Speicherung, Optionsmenü und Gamepad-Remapping bleiben offen.

**Nächster einzeln freizugebender Schritt:** Entwickler kompiliert den aktuellen `develop`-HEAD in AGK Studio. Anschließend einzelne Input-Aufrufstellen umstellen und Spieltests vereinbaren; keine weitergehende Änderung ohne neue Freigabe.

## Post-Pre-Alpha: Schritt 2 Standardbelegung (16.11.2026, Abend)

**Schritt 1 vom Entwickler erfolgreich kompiliert:** 61,70 ms Parse Time, 11.920 Zeilen, 76.514 Tokens. Das bestätigt die Definitionen in `def_input.agc` und ihren Include, nicht einen neuen Gameplay- oder HTML5-Test.

**Schritt 2 – auf `develop` umgesetzt, AGK-Compile steht aus:** `source/sonec/input.agc` neu mit `InputSetDefaultBindings(Keys ref as TKeys)`. Die Funktion setzt `TKeys.Version`, nullt alle 15 Bindings und weist Standardbelegungen zu: W/S/A/D/Q/E für 6 Bewegung, J MG, K Granatwerfer, L Flammenwerfer, I Plasma, U Energieanziehung, O Schild, Ctrl Hover, Enter Start, Backspace Back. Gamepad-Daten: D-Pad-Richtungen, A/B/X/Y, LB/RB, Start/Back wie bisher; analoge Achsen/Trigger bleiben im unveränderten alten Eingabecode. L3-Hover noch unbestätigt und NICHT als Default hinterlegt. `main.agc` inkludiert `input.agc` nach `controls.agc` und initialisiert ein lokales `Keys as TKeys`. **Noch keine Spielroutine liest `Keys`, keine Veränderung der aktiven Steuerung, kein Optionsmenü, keine Cookies.** Nutzer muss diesen neuen Stand lokal mit AGK Studio kompilieren; bei Fehler genau die Meldung prüfen, bevor weitergearbeitet wird.

**Nächster einzelner Schritt:** AGK-Compile-Test für die neue Initialisierungsfunktion. Danach Eingabeabfragen schrittweise auf Actions umstellen, erst mit gesonderter Freigabe.

## Post-Pre-Alpha: Eingabestrukturen angelegt (16.11.2026, Abend)

**Meilenstein:** [PR #1](https://github.com/ChristianEngel19820128/SonecBot/pull/1) wurde nach gesonderter Auflösung des README-Konflikts erfolgreich nach `main` gemergt (Merge-Commit `0ee67107641f7eeb5f4471241bc0ac145fd0e41c`). `main` enthält den akzeptierten Pre-Alpha-Meilenstein; **neue Arbeit wieder nur auf `develop`**. itch.io bleibt Draft/Secret URL und wurde nicht verändert.

**Freigegebener erster Implementierungsschritt:** `source/sonec/def_input.agc` neu erstellt und in `source/sonec/main.agc` eingebunden. Reine Definitionsdatei mit 15 Aktionskonstanten (6 Steuerung, 6 Aktionen, Hover, Start, Back), `TActionBinding.Key`, `TActionBinding.PadButton`, `TKeys.Version` und `TKeys.Binding[14]`. **Keine Defaultwerte, keine aktive Input-Umschaltung, keine Cookies, kein Menü, keine Spielcodeänderungen im Eingabeverhalten; noch kein AGK-Compile/HTML5-Test durch Entwickler.** Joystick-Achsen bleiben bis zur späteren Input-Ebene im bestehenden Code; Gamepad-Remapping und Maus sind spätere Patches. Getestete Crystals/Columns-Referenz: getrennte `controls.agc`/`input.agc` und `SaveSharedVariable`/`LoadSharedVariable` für kompakte Highscore-Cookies; nur passende Prinzipien verwenden.

**Vereinbarte Eingabe-Designziele:** 6 Bewegungstasten WASD+Q/E links, sechs rechte Aktionstasten im Block U/I/O+J/K/L (Zuordnung noch nicht implementiert), Hover als Zusatzaktion (L3 nur Kandidat, erst testen), Enter/Start und Backspace/Select; Back ins Menü nur aus Pause und entsprechender Hinweis unter `PAUSE`. Tastaturbelegung später separat in kompakter HTML5 Shared Variable speichern, bei ungültigen/nicht gespeicherten Werten Standard verwenden. Für Windows zuerst Lauffähigkeit testen; keine neue Windows-JSON-Speicherung geplant.

**Nächster einzeln zu prüfender Schritt:** Nutzer kompiliert den aktuellen `develop`-Stand in AGK Studio, um die reine Typ-/Include-Syntax zu bestätigen. Danach erst Standardwerte/Action-Mapping gesondert freigeben. Keine anderen Repositories verändern. Retro-Menü-Aim-Trainer mit aufsteigenden Energiekugeln und Paintball-Spritebändern ist nur eine Zukunftsidee (Schatzkiste).

## Neue Priorität und Mergeprüfung (16.11.2026, Abend)

**Neu eingetroffenes erstes Community-Feedback:** **Drei Personen** konnten mangels Tastatursteuerung die Gamepad-only-Pre-Alpha nicht spielen. Der Entwickler möchte bewusst erst Dokumentationsprüfung, dann den getesteten `develop`-Meilenstein nach `main` bringen, **danach** die bestehenden Tastaturabfragen inventarisieren, Feedback priorisieren und kleine Post-Pre-Alpha-Patches planen. Keine aktuelle Freigabe zur Implementierung. Die separate AGK Knowledge Base hat offene Themen, soll aber nicht nebenbei verändert werden.

**GitHub-Mergeprüfung:** Vor Merge meldete `compare(main,develop)` divergierte Historien: `develop` **413 Commits voraus**, `main` **2 Commits voraus**; die main-exklusiven Änderungen betrafen im Dateivergleich die alte `README.md` (frühere Formulierung der BlitzBasic-Plus-/BlitzMax-Herkunft und zwei Branch-Links). [Pull Request #1: Pre-alpha milestone](https://github.com/ChristianEngel19820128/SonecBot/pull/1) von `develop` nach `main` wurde zur Prüfung eröffnet und meldete **`mergeable=false`**. **Kein Merge ausgeführt, kein Force-Push und `main` unverändert.** README-Konflikt gezielt auflösen, bevor weiter gemergt wird. Beachten: `develop` erhielt nach PR-Erstellung einen reinen TODO-Dokumentationscommit für Feedback und Konflikt, daher PR-Head beim nächsten Versuch frisch prüfen.

**Aktueller Arbeitsfokus:** Zuerst Branch-Konflikt sicher lösen (historischen README-Inhalt berücksichtigen), danach Merge und erst anschließend read-only Tastaturbestandsaufnahme. Aktuelle Planpunkte in [TODO.md](TODO.md). itch.io bleibt Draft/Secret URL. Kein Editieren oder Verwenden öffentlicher Secret-URLs in Repo-Dokumentation.

## Letzte Rückmeldung vor der Pause (16.11.2026)

**Entwickler bestätigt zwei separate GitHub-Links auf der itch.io-Draft-Seite:** einer zu `main`, einer zu `develop`. **Der Neustarttest direkt in der itch.io-Einbettung ist laut Entwickler „soweit ok“.** Das ergänzt den bereits vollständig bestandenen mehrfachen lokalen HTML5-Neustarttest; keine Behauptung über mehrfache eingebettete Neustarts, andere Browser oder Langzeitstabilität. Der Entwickler verteilt nun die **Secret URL** an die Community. Die Seite bleibt **Draft**, kein öffentlicher Published-Wechsel. Ein `develop`→`main`-Merge wurde lediglich für möglicherweise heute Abend oder später erwogen und **nicht ausgeführt**. Keine Spielcodeänderung; jetzt Pause/Feedback abwarten. Diese Meldung ist aktueller als ältere Statusabschnitte weiter unten.

## Aktuellster Stand – erfolgreiches itch.io-Draft-Deployment (16.11.2026, Vormittag)

**Entwicklermeldung und Screenshot:** AGK-/Windows-Compile erfolgreich; HTML5-Export erfolgreich; erneuter Apache-Test erfolgreich und dabei **kein sichtbares Tearing**. `index.html` wurde erzeugt, ein ZIP erstellt, hochgeladen und die englische Seitenbeschreibung gespeichert. Die bestehende itch.io-Seite zeigt den neuen KI-generierten Banner, das Spielmenü und eine 60-FPS-Anzeige und bleibt sichtbar als **DRAFT / Secret URL** markiert. Der Entwickler darf den geheimen Link an ausgewählte Community-Mitglieder verteilen; **keine Änderung auf Published**. Dass im Embed 60 FPS angezeigt werden, ersetzt keinen plattformübergreifenden Performance-Nachweis. Die ursprüngliche Crystals-Testdatei hat der Entwickler zuvor entfernt.

**Direkt im itch.io-Embed laut Entwickler bestanden:** Controller erkannt, Pause, **alle vier Waffen**, Schild, Energieanziehung, alle Lauf-/Bewegungsfunktionen; Tod durch fehlende Energie/Absturz möglich. ESC und Quit sind im HTML5-Build absichtlich deaktiviert. **Wichtig:** Tod und mehrfacher Neustart waren bereits im *lokalen* HTML5-Browser erfolgreich; ein Neustart **nach Game-over im itch.io-Embed** ist aus der letzten Rückmeldung nicht separat belegt. Andere Browser/Controller und längeres Laufzeitverhalten ebenfalls nicht. Kein eigener Browserlauf durch Assistent; exakter Binär-Export-SHA nicht dokumentiert.

**Seitenpflege:** Englische Beschreibung eingebaut; KI-generierte Promo-Cover-/Bannerinterpretationen verwendet (nicht die Original-Ingame-Sprites), AI-Disclosure wurde gemeinsam mit Code, Text/Dialog und Graphics formuliert; tatsächliche gesetzte Häkchen nicht unabhängig geprüft. 💚 ist der feste Markenhinweis. Ein GitHub-Link zur aktiven `develop`-Branch wird vom Entwickler noch selbst auf itch.io ergänzt. Den geheimen Query-Parameter **nicht in öffentliche Repo-Dokumentation kopieren**.

**Nächster Arbeitsschritt:** Dokumentation fertigstellen, danach Ruhe und erstes Community-Feedback. Optional den letzten Embed-Neustart einmal testen. `develop` nach `main` ist **erst für später/am Abend zur gemeinsamen Entscheidung** vorgesehen und **nicht** erfolgt. Die separate Veröffentlichung der itch.io-Seite bleibt bewusst zurückgestellt. Keine Spielcode-, Minenspawn- oder Walker-Änderung ohne neuen konkret getesteten Befund. Für aktuelle Prioritäten [TODO.md](TODO.md) verwenden; ältere Status-/Release-Gate-Abschnitte in diesem Dokument sind historische Momentaufnahmen.

## Aktuelle Priorität nach TODO-Konsolidierung (16. November 2026)

Die [aktive Aufgabenliste](TODO.md) wurde nach den gemeinsamen Tests bereinigt; **sie ist jetzt die verbindliche Reihenfolge**, nicht die älteren datierten Zwischenstands-Abschnitte weiter unten. **Keine weiteren Spielcodeänderungen ohne konkreten neuen Fehler.**

**Abgeschlossen/akzeptiert:** Alpha-Walker und erste Waffen-Kollisionsmatrix, Schildabsorption gegen Walker-Bullets, Walker-Stopp vor Sonec (Sonecs eigenes Hineinspringen separat bekannt), Gamepad/Spielrunde/Pause/Tod/Mehrfachneustart in einer HTML5-Sitzung, HUD-Skala 43+7/Overload-Anzeigebereich 1500 und vom Entwickler visuell ausgewähltes `HUD_BAR_ALPHA=100`. Normalenergie `4000`, Start `4500` als derzeitige Testwerte. **Minenspawn rein aus dem Code untersucht; für die Pre-Alpha ausdrücklich keine Änderung.** `GameDo()` würfelt pro Frame, aber ein erfolgreicher `MineAdd()` setzt 1000-ms-Timer zurück, sodass die Mehrfachversuchsschleife kein sofortiges Rudel erzeugt. Ein späterer, bewusst regelbasierter Gruppen-/Rudelspawn ist eine Zukunftsdesignidee, erst nach externem Feedback.

**Jetzt nächster konkreter Schritt:** README und englischen itch.io-Draft-Text auf den inzwischen tatsächlich getesteten Stand bringen; vorher gegebenenfalls den frischen HTML5-Export/Screenshots als Basis verifizieren. Danach manuell auf bestehende itch.io-Seite im **Draft** hochladen und über deren Secret URL testen; **niemals Published aktivieren**. Beim nächsten Export den genauen `develop`-Codecommit notieren. Weitere Themen (Sound-Funktionen, Avatarwarnung, Sprung-Körperkontakt, Balancing, Knowledge Base, GifCam, vollständige Tastatur) sind keine aktuellen Freigaben. Frühere Tests/Entscheidungen weiter unten sind historisch und können überholte Aufgabenformulierungen enthalten.

## README für Tester aktualisiert; Merge erst nach Draft-Nachtest (16.11.2026)

Die englische `README.md` wurde auf den tatsächlich beobachteten HTML5-Pre-Alpha-Stand gebracht: Spielbeschreibung, Xbox-kompatible Gamepad-Belegung, Controller-Initialisierung, bestätigte lokale Spielrunde/Pause/Tod/Neustarts, Walker-/Schild-/Waffenfunktionen, aktuelle Energiewerte 4000 normal/4500 Start, bekannte Grenzen und Einladung zu reproduzierbarem Feedback. Das **itch.io-Draft-Embed ist noch nicht getestet**, externe Browser-/Controller-Kompatibilität nicht behaupten. 💚 ist enthalten. Besitzer öffnet die bestehende itch.io-Draft-Seite und ermittelt ihren vorhandenen Inhalt; HTML5-ZIP, itch.io-Text und Secret-URL-Nachtest sind noch offene nächste Schritte.

**Branch-Entscheidung zur Diskussion, nicht ausgeführt:** Entwickler möchte erwägen, nach erfolgreichem Test der Draft-Seite den akzeptierten `develop`-Stand nach `main` zu mergen. Diese Reihenfolge wird unterstützt: erst Export und echter Draft-Embed-/Controller-Smoke-Test, dann gemeinsam den Mergepunkt beschließen. **Kein Merge durchgeführt.** Ein GitHub-Merge berührt nicht den Status der itch.io-Seite; **Draft bleibt Draft**, kein öffentliches Published ohne separate ausdrückliche Freigabe.

## Aktueller HTML5-Testbefund (Entwicklermeldung, 16. November 2026)

- **Bestanden:** HTML5-Export mit lokalem AGK Studio; Browserstart über lokalen Apache/XAMPP im gemeinsam entwickelten Frame mit Run-Knopf (vergleichbar mit der geplanten itch.io-Einbettung). Spiel startet.
- **Darstellung:** Entwickler berichtet flüssiges Gameplay bei 60 Hz mit VSync und auch bei einer kurzen Umstellung auf 75 Hz. Für weitere Tests bleibt die Windows-Bildwiederholrate **60 Hz**. Das sind subjektive lokale Beobachtungen, kein unabhängiger Browser-/Performance-Benchmark.
- **Gamepad im HTML5-Browser grundsätzlich erfolgreich genutzt (Entwicklermeldung):** Xbox-Controller oder kompatibles Modell; der HTML5-Workaround verwendet Index 1. Nach einem ersten Tastendruck kann es 2–3 Sekunden dauern, bis Controller 1 initialisiert ist. Die Windows-Geräteerkennung funktioniert so nicht im HTML5-Pfad. Sämtliche Tasten wurden zuvor im Windows-Compile geprüft, **nicht** im HTML5-Build. Tastaturbedienung derzeit unvollständig und unzumutbar als Releasealternative. Noch keine vollständige HTML5-Aktionsprüfung.
- **Noch offen:** genaue exportierte Code-Revision nicht separat bestätigt; Browser-/Controller-Modell im Detail, vollständige Eingaben, Pause, Tod, zwei Neustarts und itch.io-Einbettung nicht als bestanden markieren.
- **XAMPP-Cache-Hinweis als Knowledge-Base-Kandidat:** Nach Austausch der HTML5-Dateien während des Entwickelns Browser-Cache deaktivieren (z. B. DevTools/Network „Disable cache“, wirksam bei geöffneten DevTools) und neu laden, sonst kann die alte Version weiter erscheinen. Entwicklerbeobachtung, noch kein separater plattformübergreifender Nachweis oder eigenständiger KB-Eintrag.
- **Nächste fachliche Prüfung (noch kein Änderungsauftrag):** Welche fehlenden Kollisionsabfragen wirken im Test widersprüchlich, wenn Treffer keine Wirkung zeigen? Relevante Aufrufpfade, Absichten und Priorität untersuchen, bevor Code verändert wird. Spawn-Zeitbasis bleibt separater Kandidat.
- **Arbeitsregel:** Beobachtung festhalten, aktuellen Prüfschritt abschließen, anschließend **gemeinsam** den nächsten Schritt wählen. Kein neues Walker-Polishing.

## Abgeschlossener HTML5-Controller-Funktionstest – Entwicklermeldung 16. November 2026

**Ergebnis:** Der Entwickler hat den Gamepad-Funktionstest im lokalen HTML5-Build beendet. Xbox- bzw. Xbox-kompatibler Controller, Apache/XAMPP, 60-Hz-Testreferenz mit VSync. Getestet und funktionierend: untere linke/rechte Trigger für Rückwärtsbewegung nach links/rechts, linke obere Schultertaste für Energieanziehung, rechte Schultertaste für Schild (vom Entwickler als „R2“ bezeichnet; **abweichende Benennung mit Code prüfen**), X Flammenwerfer, Y Plasma-Blitz, A Maschinengewehr, B Granatwerfer, Start Pause, D-Pad und linker Analogstick für Bewegung. Nicht belegte andere Tasten haben derzeit keine Funktion. Es wird keine vollständige Tastatursteuerung für die Pre-Alpha angeboten.

**Abgleich mit Quellcode:** `sonec.agc:SonecShieldInput` nutzt `JoystickButtonRR` (in `def_joypad.agc` Taste 6; normalerweise rechte obere Schultertaste/RB/R1); in `SonecInput` werden die unteren Trigger über Z/RZ-Achsen für Rückwärtsbewegung gelesen. Die Angabe „R2 Schild“ **nicht ohne Rückfrage als tatsächliche Belegung übernehmen**. Keine Codeänderung allein aufgrund der Benennung.

**HTML5-Beenden:** ESC und QUIT beenden den Browserbuild nicht. Quellcodeprüfung: `GetESCPressed()` ist Windows-gebunden; `main.agc` berücksichtigt `Intro.IsQuit` beim Verlassen ausdrücklich nur außerhalb HTML5. Nicht ungeprüft als Releaseblocker oder AGK-Enginebug werten; bei Browser-Einbettung kann dies gewollt sein.

**Knowledge-Base-Kandidaten:** HTML5-Gamepad-Index-1-Workaround, erste Tasteneingabe und 2–3-s-Verzögerung; Desktop-vs.-Browser-Beenden; XAMPP-Cache-Stolperfalle. Bestehende KB `topics/timing-and-frame-rates.md` enthält die Spawn-Frameabhängigkeit bereits als Codeprüfkandidat. Kandidaten dokumentieren, erst nach dem aktuellen Projektschritt eine eigene KB-Ergänzung freigeben. Einzelne AGK-/Browser-Version und getesteter Build-SHA sind noch nicht protokolliert.

**Noch offen für vollständige Releaseprüfung:** Tod und mindestens zwei Neustarts, Browserkompatibilität außerhalb dieses lokalen Testaufbaus, späterer itch.io-Draft/Secret-URL-Test. Nächste fachliche Entscheidung gemeinsam: Kollisionstreffermatrix auf fehlende Reaktion prüfen, zunächst read-only.

## Erster Kollisionsschritt abgeschlossen – nächster gemeinsam festzulegen

**Neue Entscheidung (16. November 2026):** Sonec soll grundsätzlich allen beschädigbaren Objekten mit allen Waffen Schaden zufügen können, keine Waffe pauschal ausschließen. Geplante Fraktionen: Player/Sonec (ein zweiter Spieler war vorgesehen), Enemy, Neutral; genaue Nutzung noch offen. Spätere Schadensarten: Plasma-Explosion, Plasma-Flammen, kinetisch (auch Granatenaufprall), Plasma-Blitz, dazu unterschiedliche Panzerung/Schild; Konterprinzip wie Stein/Schere/Papier/Brunnen (Flammen gegen kleine schnelle Minen). **Noch keine Schadenstypen/-resistenzen implementieren.**

**Erster isolierter Codepfad auf `develop` abgeschlossen:** Flamme gegen Alpha-Walker-Turm in `flame.agc` (`FlameCollideWalkers`) und Aufruf in `game.agc`. Entwickler meldet am 16.11.2026: „der flammenwerfer scheint sehr stark zu sein. und er funktioniert wie erwartet. alle objekte wurde zerstört ;)“. Treffer-/Zerstörungswirkung der geprüften Objekte inklusive Walker lokal bestätigt; starke Wirkung nur qualitativ beobachtet, **kein Balancingauftrag**. Flash/Drop nicht einzeln berichtet. Assistent hat nicht selbst kompiliert/getestet. **NÄCHSTER SCHRITT:** gemeinsam eine folgende Kollisionskombination auswählen und isoliert prüfen; noch keine weiteren Codeänderungen. `TECHNICAL.md` und `TODO.md` enthalten Details.

**Controller-Bezeichnung geklärt:** Der zuvor genannte Schild auf „R2“ war ein Schreibfehler. R1/RB (obere rechte Schultertaste) = Schild; LT/L2 und RT/R2 (untere Trigger) = rückwärts links/rechts. Im HTML5-Browsertest funktionieren Schild und Rückwärtsbewegung wie erwartet.

## Vorheriger Einzeltest: Plasma-Blitz gegen Minen und Kisten (16. November 2026; anschließend lokal bestanden)

**Gemeinsam als nächster Schritt festgelegt:** Nur die zuvor leeren `PlasmaBlitzCollideMine()` und `PlasmaBlitzCollideChest()` ergänzen. Implementiert in `source/sonec/plasmablitz.agc` und in `GameDo()` verdrahtet. Die vorhandene 50-ms-Kollisions-Taktung wird **für Orbs, Minen und Kisten gemeinsam** geprüft und erst danach in `PlasmaBlitzCollisionTimerReset()` zurückgesetzt. Andernfalls hätte die Orb-Prüfung den Timer bereits verbraucht und die neuen Zielklassen könnten nicht reagieren. Alle drei verwenden bestehende Boxkollision, Gesundheitsabzug über `BulletData.Damage` und Rotfärbung. **Nur statisch geprüft; AGK-Compile/HTML5-Lauf beim Entwickler offen.**

**Testanweisung:** Aktuellen `develop` in AGK Studio kompilieren/exportieren und im lokalen HTML5-Browser prüfen: Plasma-Blitz trifft/beschädigt/zerstört Minen und Kisten; Orb-Treffer funktionieren weiterhin; dieselbe Blitzentladung kann passende Ziele innerhalb desselben Zeitfensters treffen; keine auffälligen mehrfachen Treffer pro Renderframe oder Abstürze. Den genauen Testumfang zurückmelden, nicht aus der Quellprüfung ableiten.

**Spielbeobachtung:** Plasma-Blitz muss aufladen und entlädt sich dann, ist stark und vermutlich energieintensiv; der Flammenwerfer verbraucht bei längerem Einsatz ebenfalls viel Energie, die für das Fliegen gebraucht wird. **Noch keine Werte gemessen; weder Energieverbrauch noch Schadenswerte/Balance in diesem Schritt ändern.** Die 50-ms-Kollisionsperiode ist vorhandene Mechanik, keine neu eingeführte Schadensart.

**Nach bestandenem Test:** Schritt als abgeschlossen dokumentieren und erst dann die nächste Kollisionskombination gemeinsam wählen. Walker-Politur ausgeschlossen. Der Browser-Tod-/Mehrfachneustarttest und die spätere itch.io-Draft-Prüfung sind separate Release-Gates.

## Abschluss Plasma-Blitz Mine/Kiste – Entwicklermeldung 16. November 2026

**Testergebnis:** Entwickler meldet den neuen Plasma-Blitz-Pfad zunächst unter Windows lokal und anschließend unter HTML5 erfolgreich geprüft („html5 geht auch“). Große Kisten reagieren nur schwach auf eine Entladung; der Blitz ist sehr teuer (Energie) und schwierig zu handhaben. **Das ist eine qualitative Balancebeobachtung, kein bestätigter Kollisionsdefekt.** Der genaue Zerstörungsnachweis für jede einzelne Minen-/Kisten-/Orb-Kombination sowie exakte Energiewerte und Trefferintervalle wurde nicht separat aufgeschlüsselt; keine unabhängigen Compile- oder Laufzeittests durch den Assistenten. Der gemeinsame 50-ms-Treffertimer ist im aktuellen Code eingebunden.

**HTML5-Debugtasten:** Entwickler meldet, dass Debug-Funktionstasten im Browser Browserereignisse auslösen und für das Spiel nicht brauchbar sind. Windows-Diagnose genügt für die aktuelle Pre-Alpha; browserfreundliche Debugbelegung als späteren UX-/Knowledge-Base-Kandidaten notieren, nicht im Releasefluss pauschal umbauen.

**Bestätigter Bestand:** Walker reagiert aktuell auf Bullets und Flammen; fehlende aktive Trefferpfade Walker←Plasma-Blitz, Walker←direkter Granatenaufprall und Walker←Explosion. Andere Zielklassen verfügen für alle vier Waffen und Explosionen über Kollisionspfade, allerdings mit unterschiedlichen Wirkungen/Testtiefen.

**Nächster Vorschlag, noch nicht implementiert:** Plasma-Blitz → Walker als isolierter dritter Kollisionsschritt. Danach Granatenaufprall/Explosion getrennt bewerten, um ungewollten Doppelschaden zu vermeiden. Kein Balancing, keine IK-/Walker-Politur; vor Codeänderung gemeinsam nächsten Schritt festlegen.

## Vorheriger Einzeltest: Plasma-Blitz als Walker-Blitzableiter (16. November 2026; lokal positiv)

**Gemeinsam freigegebener nächster Schritt:** `PlasmaBlitzCollideWalkers()` in `source/sonec/plasmablitz.agc` ergänzt und nach Orb/Mine/Kiste, **vor** dem gemeinsamen `PlasmaBlitzCollisionTimerReset()` in `game.agc` aufgerufen. Trefferzone ist dieselbe Walker-Turm-AABB wie beim Maschinengewehr; BoxInBox, vorhandener `BulletData.Damage`, `HitFlashUntil=Now+150` und roter Turmflash werden verwendet. Der Blitz bleibt wie bei den bisherigen anderen Zieltypen während der Entladung aktiv. Keine Änderungen an Aufladung, Energiekosten, Schäden, Walker-IK/AI oder Fraktionen.

**Status: nur statisch geprüft, KEIN AGK-/HTML5-Test.** Besitzer soll lokal Windows/HTML5 prüfen: Walker-Turm wird bei Blitzentladung rot und nimmt Schaden; kann bei genügenden Treffern zerstört werden; Orb/Mine/Kiste funktionieren weiter; keine übermäßig schnelle Schadensfolge oder sonstige Regression. Erst nach Ergebnis dokumentieren und nächsten Schritt vereinbaren.

**Noch fehlend aus der Grundmatrix:** direkter Granatenaufprall → Walker und Explosion → Walker; bei späterer Umsetzung Doppelschaden getrennt entscheiden. Plasmaenergie und hohe Wirkung sind weiterhin qualitative Balancebeobachtungen, kein aktueller Balanceauftrag.

## Vorheriger Einzelschritt: direkter Granatenaufprall → Alpha-Walker (16. November 2026; lokal positiv)

**Vorheriger Blitz-Schritt bestanden:** Entwickler bestätigt „gut das funktioniert =)“ für Plasma-Blitz → Walker. Kein detaillierter Messwert oder explizit getrennte Windows-/HTML5-Angabe zu diesem konkreten Test. Plasma-Blitz gegen Walker als lokal funktionierend gemeldet; nicht weiter an Energiekosten oder Balancing drehen.

**Jetzt umgesetzt, echter Test offen:** `GrenadeCollideWalkers()` in `source/sonec/grenade.agc` ergänzt; Aufruf in `GameDo()` zwischen Kisten- und Plattformkollision. Wie beim Maschinengewehr die bestehende `WalkerCollisionData.Tower`-Box mit `BoxInBox` prüfen; vorhandenen direkten Granatenschaden abziehen, roten Turmflash setzen, dann über bestehendes `GrenadeDestroy()` eine reguläre Explosion erzeugen und Granate löschen. **Walker-Explosionsschaden ausdrücklich noch nicht ergänzt.** Keine Änderungen an Explosionen, Zielpanzerung, IK oder Balancing.

**Nächster konkreter Test durch Entwickler:** Windows-AGK-Compile, direkter Granatentreffer auf Walker-Turm (Trefferreaktion und Explosion), ausreichend viele Treffer können Walker zerstören; andere Granatenkollisionen gegen Kisten/Orbs/Minen/Plattformen bleiben korrekt. Danach HTML5 prüfen. Die Explosion trifft den Walker auch bei direktem Granatenaufprall noch **nicht** als eigene Schadensquelle. Erst nach Ergebnis nächste Entscheidung zum separaten Explosionspfad und möglichem Doppelschaden treffen.

## Granaten-Aufpralltest abgeschlossen – Entwicklermeldung 16. November 2026

**Ergebnis:** Entwickler berichtet einen direkten Volltreffer auf den Alpha-Walker-Turm: „alles wie erwartet“. Der neu ergänzte `GrenadeCollideWalkers()`-Pfad gilt für diesen lokalen Versuch als **bestanden**. Ob genau dieser Versuch im Windows- oder HTML5-Build stattfand und welcher konkrete Export-SHA verwendet wurde, wurde nicht ausdrücklich zugeordnet. Keine unabhängige Laufzeitprüfung des Assistenten; Walker-Zerstörung durch wiederholte Granaten, einzelne Flash-/Drop-Details und sämtliche Regressionen nicht getrennt bestätigt.

**Beobachtete Granatenmechanik:** Rückstoß kann Sonec zurückversetzen; Granaten folgen einer gekrümmten, nach unten fallenden Bahn, treffen auf Distanz gelegentlich zuerst den Plattformboden und explodieren dort. Abschuss verbraucht Munition („Plasmagranaten“). Das sind bewusst zu erhaltende spielerische Eigenschaften; vorerst **keine** Physik-, Munitions- oder Balanceänderung.

**Stand der Treffermatrix:** Bullet, Flamme, Plasma-Blitz und direkter Granatenaufprall sind jetzt als Kollisionen mit Walker-Turm implementiert; die jeweiligen zuletzt berichteten Tests waren positiv. **Nur Explosion → Walker fehlt** als separater Schadenspfad. Vor Änderung die bestehende `ExplosionCollide*`-Zeitsteuerung und die Überlappung mit dem Granatenaufprall prüfen, um Doppelschaden bewusst zu gestalten. Dies ist der nächste **Prüf- und Entscheidungsgegenstand**, noch keine Implementierungsfreigabe.

**Referenzpflege:** Der im Dokumentkopf verlinkte Hash `18f92a9` ist der historische **Walker-Abschlussstand**, nicht der aktuelle Branch-HEAD und nicht der neueste Kollisions-Build. Den tatsächlichen `develop`-HEAD bei jedem Einstieg erneut abfragen; aktueller getesteter lokaler Export-Commit für den Granatentest wurde nicht separat festgehalten.

## Vorheriger Einzeltest: Explosion → Alpha-Walker (16. November 2026; lokal positiv)

**Gemeinsam freigegeben und auf `develop` implementiert, AGK-/HTML5-Nachtest offen.** Eine Explosion soll alle getroffenen Walker über die **bestehende Turm-AABB** beschädigen; der Explosionsradius wird als Kreis gegen den nächstgelegenen Punkt dieser Box geprüft. Ergänzt: `LastWalkerHitMs[-1]` in `TExplosion` (`def_game.agc`), Initialisierung in `ExplosionNew()`, neue `ExplosionCollideWalkers()` in `explosion.agc` und Aufruf in `GameDo()` nach den bisherigen Explosion-Mine-Kollisionen. Jeder Walker hat pro Explosion einen eigenen Trefferzeitstempel, entsprechend den bestehenden Kisten/Orb/Minen-Pfaden. Die aktuellen Konfigurationen **30 Schaden je mindestens 100 ms** sowie die vorhandenen Radien und Animationen bleiben unverändert. Vorhandenen roten Turm-Trefferflash wiederverwenden; keine neue Schadensklasse und keine Walker-IK-/KI-Änderung.

**Zu testen:** AGK unter Windows und HTML5; eine Granate kann den Turm direkt treffen, ihre Explosion verursacht danach ggf. **zusätzlichen Schaden**; eine auf dem Plattformboden neben dem Walker explodierende Granate kann ihn ohne Direkttreffer durch Radiuswirkung beschädigen; Explosionsschaden soll Walker bei mehreren/ausreichenden Treffern zerstören. Bestehende Explosionen gegen Sonec, Kisten, Orbs, Minen und der direkte Granatenaufprall dürfen nicht regressieren. **Besonderheit:** Auch andere Explosionsquellen (z. B. Walker-Zerstörung) benutzen denselben globalen Explosionspfad; mögliche Kettenreaktionen prüfen statt unbeabsichtigt als Bug zu klassifizieren. Die Explosion wird in `GameDo()` vor Granaten- und Walker-Bewegung verarbeitet; frisch erzeugte Granatenexplosionen erreichen den Walker-Kollisionspfad erst beim nächsten Update.

**Spielgefühl bewahren:** Entwickler berichtet, dass SonecBot nun als Spiel mit Gegnern und Gegenwehr bereits Spaß macht und nicht mehr nur eine technische Demo ist. In diesem Test die bestehende Spielmechanik erhalten; erst nach lokalem Nachtest gemeinsam entscheiden, ob Explosionen zu stark oder zu schwach wirken. Das itch.io-Projekt bleibt Draft.

**Nächster Schritt:** Besitzer testet diesen einen Explosionspfad und meldet sichtbare Wirkung/Regressionsstatus. Keine weiteren Änderungen bis zur Auswertung.

## Erster Waffen-Kollisionsdurchgang abgeschlossen – Entwicklertest (16. November 2026)

**Letzter Test erfolgreich:** Entwickler meldet zum neuen `ExplosionCollideWalkers()`-Pfad ausdrücklich „sprengtest erfolgreich“: **direkter Granatentreffer und passive/nahe Explosion zerstören den Walker**. Damit sind die ursprünglich betrachteten Trefferpfade Maschinengewehr, Flammenwerfer, Plasma-Blitz, direkter Granatenaufprall und Explosion gegen Walker eingebaut; die schrittweisen lokalen Tests waren positiv. Für den jüngsten Explosionsversuch wurde Windows/HTML5 **nicht separat** benannt; keine eigenen Laufzeitprüfungen des Assistenten und kein vollständiger Regressionstest aller Zielkombinationen behaupten. **Keine weitere Kollisions- oder Balanceänderung als Folge dieses Erfolgs.**

**Spielgefühl wichtig:** Walker prägt das Spiel laut Entwickler besonders: nicht generischer Gegner, unter Umständen leichter zu zerstören als große Kisten, aber der Spieler muss die **Turm-Trefferzone** erreichen. Das bestehende Spiel mit echter Gegenwehr macht bereits Spaß. Unterschiedliche Trefferzonen je Walker-Körperteil waren früher angedacht, sind **Zukunftsdesign** und ausdrücklich kein Pre-Alpha-Umbau.

**Später, nicht jetzt:** Entwickler möchte nach Abschluss der ausstehenden Releaseprüfungen ein längeres Gameplayvideo versuchen. GifCam streikt mitunter, nach Einschätzung des Entwicklers eventuell wegen zu hoher RAM-Auslastung bei vielen gleichzeitig laufenden Programmen (Vermutung, nicht verifiziert). Eine Alternative bei Gelegenheit recherchieren, ohne die laufende Releaseprüfung aufzuhalten. Achievements existieren noch nicht; als mögliche spätere Erweiterung notiert. Humorvolle „Waffenschein für alle freigeschaltet“-Bemerkung ist **kein implementiertes Achievement**.

**Nächster gemeinsamer Fokus:** Wieder die separaten HTML5-Pre-Alpha-Release-Gates priorisieren (insbesondere Tod und mindestens zwei Neustarts; anschließend itch.io **Draft**/Secret-URL, nicht Published), ohne neue Systeme zu beginnen. Erst Umfang und Teststatus zusammen klären.

## Neuer Spieltest: drei Auffälligkeiten beim HTML5-Release-Smoke-Test (16. November 2026)

**Entwickler meldet während wiederholter Tode (Tod-/Neustartprüfung noch NICHT als beendet gemeldet):**
1. Walker läuft durch Sonec hindurch, statt vor ihm stehen zu bleiben und zu schießen.
2. HUD-Energiebalken (grün) soll mit angemessenem roten Overload-Anteil **ungefähr so hoch wie HP plus Schild** angezeigt werden; Entwickler liefert Screenshot. Keine Änderung an Energie-/Gesundheitswerten angefordert.
3. Schild muss auf seine **tatsächliche Schutzwirkung** geprüft werden; Gamepad-Aktivierung allein war zuvor positiv.

**Quellprüfung am `develop`-HEAD `a313b080` (keine Codeänderungen):**
- `game.agc` ruft `WalkerMoveAll(...PlateList,ChestList,...)` auf und `SonecCollidePlate(...PlateList,ChestList,...)`, aber keine Walker/Sonec-Körperkollision. `walker.agc:WalkerMove()` prüft vorwärts Kisten und Kanten, jedoch keine Sonec-Hinderniszone. Problem am Spielverhalten lokal beobachtet, Ursache auf Codeebene plausibel.
- `gui.agc:GuiEnergyDraw()`: HP proportional zu **150 kleinen Segmenten**, Schild max. **25**, Energie normal max. **20 große Segmente** plus Overload mit `ceil(EnergyOverload*10.0/Energy.StateMax)`; grafische Abstände unterschiedlich. Screenshot ist Referenz für spätere Layoutänderung; Ziel optische Gesamthöhe nahe HP+Schild, einschließlich Reserve für Overload, ohne Ressourcen-Balancing.
- `shield.agc:ShieldAbsorbDamage()` ist für Explosionen eingebunden (`explosion.agc:ExplosionCollideSonec`). `bullet.agc:BulletCollide()` zieht bei feindlichen Kugeln Sonec.Health direkt ab und ruft **kein** `ShieldAbsorbDamage()` auf. Damit schützt der Schild im aktuellen Code nicht gegen Walker-Kugeln, obwohl er aktivierbar ist. Dieser technische Befund ist noch nicht durch separaten A/B-Laufzeittest quantifiziert.

**Arbeitsregel:** Befunde dokumentieren, keine ungeprüften KI-, Kollisions-, HUD- oder Schildänderungen auf einmal. Jeden Punkt einzeln gemeinsam auswählen, kleinste Änderung und Entwicklernachtest. Offene HTML5-Release-Gates Tod + mindestens zwei Neustarts und itch.io-Draft weiterhin separat; itch niemals Published schalten. Screenshot im Chat, nicht als dauerhaftes Repo-Artefakt behaupten.

## HTML5-Tod-/Mehrfachneustart-Gate bestanden; neue Idee (16. November 2026)

**Bestanden laut Entwickler in derselben noch laufenden Browsersitzung:** Mehrfach durch Minen und Walkerbeschuss gestorben, danach mehrfach neu gestartet und weitergespielt. Pause verfügbar; Sitzung zum Zeitpunkt der Meldung weiterhin offen, Screenshots bei Bedarf möglich. **Damit Tod und mindestens zwei Neustarts im laufenden HTML5-Test praktisch bestätigt.** Keine frische Browserladung, anderer Browser oder vollständige Reinitialisierungs-/Memory-Leak-Analyse daraus ableiten. Der konkrete exportierte Code-SHA bleibt unbekannt. Bitte nicht weitere Tode für diesen Test verlangen.

**Offene aktuelle Befunde:** Walker/Sonec-Überlappung, HUD-Energie/Overload-Proportion und fehlende Schildabsorption für Walker-Kugeln bleiben einzelne Aufgaben; nur die Schildlücke wurde durch Quellprüfung bereits direkt bestätigt. **Nächster vorgeschlagener enger Code-Schritt:** bestehende `ShieldAbsorbDamage()` in `BulletCollide()` für feindliche Walker-Kugeln integrieren, danach mit/ohne aktiven Schild im laufenden Spiel testen. Noch **nicht** implementiert, Entscheidung gemeinsam.

**Neue Designidee für später:** Bestehender geplante Informationsavatar (`PROJECT.md`) könnte zunächst nur **auffällige rote Warnmeldungen in Großbuchstaben oben im HUD** zeigen, z. B. „MINEFIELD DETECTED“, sobald Minen spawnen; Avatarbild und spätere Sprachausgabe sind Optionen, derzeit nicht implementiert. Vor Warnlogik Bedingungen und Spam/mehrfaches Auftauchen prüfen. Entwickler beobachtet Minen oft in Rudeln. **Separater Prüfpunkt:** `game.agc`-Minenspawnwahrscheinlichkeit, Anzahl pro Ereignis und mögliche Frameabhängigkeit analysieren, aber keine ungefragte Spawn-Korrektur. Kein unmittelbarer Pre-Alpha-Releaseblocker.

**Weitere Release-Gate:** itch.io **Draft**-Upload und Secret-URL-Browser-Einbettung weiterhin offen; niemals Published aktivieren.

## Abgeschlossener enger Code-Schritt: Schild absorbiert feindliche Walker-Kugeln (16.11.2026; lokal bestanden)

**Freigabe:** Nach bestandenem HTML5-Tod-/Mehrfachneustart-Test haben wir vereinbart, die drei Befunde nacheinander zu bearbeiten; der Entwickler schließt die bisherige Browsersitzung. Schritt 1 **Schild gegen Walker-Geschosse** ist auf `develop` implementiert, aber **noch nicht lokal kompiliert oder im Browser getestet**. `bullet.agc:BulletCollide()` erhält jetzt zusätzlich `Shield ref as TShield, Now as integer` und verwendet im `TYPEENEMY`-Trefferpfad `Damage - ShieldAbsorbDamage(Shield,Sonec,Damage,Now)`; `game.agc:GameDo()` reicht `Game.Shield,Now` weiter. Die bereits für Explosionen genutzte `ShieldAbsorbDamage()` bleibt unverändert. Auch Bullet-Geometrie, Waffenwerte, Schildenergie-Kosten, Walker-Animation und HUD sind unverändert.

**Konkreter Nachtest:** Neu kompilierter Windows-/HTML5-Build des aktuellen `develop`: (1) Ohne Schild bei Walker-Beschuss normale Lebensabnahme. (2) Bei geladenem/aktivem Schild gleicher Feindbeschuss: weniger direkte HP-Abnahme, sichtbare Schildladungs-Abnahme/rote Schadensspur. (3) Entladener oder deaktivierter Schild bietet keinen Kugelschutz; (4) Schild gegen Explosionen funktioniert weiterhin; (5) Spiel startet normal, keine AGK-Signatur- oder Laufzeitprobleme. Schutz ist proportional und bis zum bisherigen `SHIELD_MAX_PROTECTION_PERCENT`-Wert begrenzt, **keine volle Unverwundbarkeit** erwarten. Dies ist kein eigener Laufzeittest des Assistenten.

**Erst nach positiver Rückmeldung** Punkt 2 (Walker hält vor Sonec an) gemeinsam detaillieren und dann als eigenen Schritt ändern; Punkt 3 (Energie-/Overload-HUD-Proportion) bleibt offen. Informationsavatar/Minenwarnung sind später. itch.io bleibt **Draft**, Secret-URL-Test ist noch offen.

## Schild gegen Walker-Geschosse: Entwicklertest vollständig bestanden (16.11.2026)

**Bestätigung nach aktuellem Codepatch:** Entwickler meldet „alle tests als bestanden markiert“. Walker verursacht ohne aktiven Schild Gesundheitsschaden; bei aktivem Schild wird dessen Ladung unter sichtbarer **roter Schadensspur über der Schildanzeige** abgebaut, bis sie verbraucht ist. Die vereinbarte Testliste (Schild an/aus/leer, Explosionsregression) gilt nach Nutzerbestätigung insgesamt als bestanden; nicht einzelne, ungenannte Messzahlen behaupten. Änderungen in `bullet.agc` und `game.agc` sind damit **lokal akzeptiert**. Kein weiterer Schildcode notwendig.

**Zusätzliche emergente Spielsituation:** Ein Walker traf eine Mine mit seinem Schuss und wurde durch die Explosion selbst zerstört. Vom Entwickler beobachtet und humorvoll berichtet; derzeit als plausible **neutrale Kettenreaktion/Gameplay-Ereignis**, **kein bestätigter Bug**. Kein sofortiger Eingriff in Explosionen oder Fraktionen.

**Nächster bereits vereinbarter Punkt:** Walker soll **vor Sonec stoppen, nicht durch ihn hindurchlaufen und weiter feuern können**. Vor Umsetzung den vorhandenen Walker-Stoppmechanismus an Kisten und `FireState` ansehen und eine minimale Erkennung für Sonec diskutieren; IK, Turm-/Schussverhalten und die erfolgreiche Kollisionsmatrix erhalten. Danach Energie-/Overload-HUD separat bearbeiten. Für den Walker-Körperkontakt liegt noch **keine** Codeänderung vor.

## Abgeschlossener Einzeltest: Walker stoppt vor Sonec und kann weiter feuern (16.11.2026; positiv)

**Gemeinsam freigegebener Code-Schritt 2 der drei Gameplay-Befunde:** `source/sonec/walker.agc` enthält jetzt `WalkerSonecDistanceAhead()`, das eine horizontale Distanz zwischen der **bereits vorhandenen Walker-Hülle** (±50 px plus 5 px Freiraum, oben 50/unten 35 px) und Sonecs Kreisregion über `ObjectData.Position` und `ObjectData.Radius` ermittelt. Nur bei vertikaler Überlappung hält Sonec den Laufweg auf, damit Überfliegen weiter möglich ist. `WalkerMove()` beschränkt den aktuellen `StepX` auf den verbleibenden Abstand und setzt bei Kontakt `PauseUntilMs = Now + 1200` für die **bestehende Stand-/Schusslogik**; es wird **kein** `TurnPending` ausgelöst. `WalkerMoveAll()` und `game.agc:GameDo()` reichen Sonec als Parameter weiter. Die Kisten- und Kantenstoppregeln, FireState, IK, Turm/Pose, Geschwindigkeit und Bullet-Kollisionen bleiben unverändert. **Nur statisch geprüft; AGK-/HTML5-Test offen.**

**Explizit vor der Änderung geprüft:** `SonecInit()` setzt `ObjectData.Size.Width = GetSpriteWidth(ProtoSonec.AnimRight.Stand.Sprite.ID)`, `ObjectData.Radius = ObjectData.Size.Width * 0.5` und `Sonec.SpriteData.Scale = 1`. Im gesamten geprüften `sonec.agc` wird der Radius nicht ein zweites Mal mit Scale multipliziert. **Kein Hinweis auf doppelte Radiusverkleinerung in dieser Initialisierung.** Ob der visuelle Spritebereich genau zum Kollisionsradius passt, erfordert Sicht-/Spieletest, nicht bloß Quellinspektion.

**Testauftrag:** Neuer Windows-/HTML5-Build von `develop`: Walker läuft auf Sonec zu und bleibt vor ihm stehen statt hindurchzugehen; beide Richtungen testen; Walker zielt und feuert aus der Standpause weiterhin; verlässt Sonec die Laufbahn, setzt Walker nach normaler Pause seine Bewegung fort; beim Flug oberhalb/unterhalb keine unplausible horizontale Blockade; Kistenstopp, Plattformkanten, Stand-/Gangpose, Turm/Salve bleiben wie zuvor. Falls eine unangemessene Distanz oder Feuerausfall auftritt, erst nach Rückmeldung lokal korrigieren. **Punkt 3 Energie-/Overload-HUD bleibt unangetastet.**

## Walker-Stopp: Test bestanden, Sprung-Körperkollision separat offen (16.11.2026)

**Entwicklertest positiv:** Walker hält beim Annähern von beiden Seiten mit optisch passendem Abstand vor Sonec an (zwei Screenshots geliefert), schießt dabei weiterhin und verursacht Trefferschaden. Nach Wegfliegen bzw. Überfliegen funktioniert die Bewegung wie erwartet. Entwickler bewertet den aktuellen Schritt ausdrücklich als erfolgreich. Kisten-/Kantenregressionen wurden in dieser Meldung nicht separat beschrieben; nicht erfinden.

**Neuer eigenständiger Befund:** Sonec kann **in den Walker hineinspringen**, obwohl der Walker selbst bei horizontaler Annäherung anhält. Die Implementierung ist eine Walker-Bewegungsbremse, **keine** bidirektionale Sonec-Körperkollision. Für später als separaten Kollisionsfall prüfen und ggf. klein ergänzen, ohne den bestandenen Walker-Stopp, das Turmziel oder die IK umzubauen. Kein aktueller Code-Fix.

**Weiterer Entwicklerhinweis:** Sounds sollen langfristig in den jeweils richtigen, gemeinsam verwendbaren Ereignis-/Funktionspfaden ausgelöst werden, nicht nur in Sonec-spezifischen Routinen. Konkrete Sound-Quellen und Abspielereignisse vor Änderung inventarisieren; kein Sound-Umbau im laufenden Schritt.

**Nächster vereinbarter der drei Punkte:** HUD-Energiebalken mit angemessenem rotem Overload-Anzeigebereich visuell an Höhe von HP plus Schild annähern. Referenz-Screenshot aus dem Chat. Nur Anzeige, keine Ressourcen-/Schadenswerte ändern; erst Codepfad/Abmessungen und dann eigenen lokalen Test.

## Aktueller einzelner HUD-Schritt: Energie-/Overload-Skala (16.11.2026)

**Gemeinsam freigegeben, lokal noch nicht getestet:** In `source/sonec/gui.agc:GuiEnergyDraw()` wurde **nur die Visualisierung** geändert. Das grüne Energielimit hatte zuvor 20 große Segmente, Overload 10 je weiterem `Energy.StateMax`. Die Bilddaten im Repository zeigen: `bar_horizontal_small.png` für HP/Schild **16×2 px**, `bar_horizontal.png` für Energie **32×5 px**, Energie zeichnet mit **2 px zusätzlichem vertikalem Abstand**. Die aufgerundete/gerundete proportionale Zielskala zum vorhandenen HP+Schild-Bereich `150+25` kleinen Segmenten ergibt **43 grüne und 7 rote Plätze**, bzw. ca. 301+49=350 px Gesamthöhe. Der Dreisatz wird in `GuiEnergyDraw()` anhand der tatsächlichen Spritehöhen berechnet, statt die Zahlen fest einzuprogrammieren. Die Energieanzeige skaliert den Lade- und Overload-Wert anteilig zum jeweiligen Platzmaximum; **die Overload-Anzeige wird zur maximalen Höhe gekappt**, überhöhte Überladung kann nicht das HUD überschießen. Rot ist nur sichtbar, wenn `Energy.State > Energy.StateMax`.

**Testauftrag:** Neuer Windows-/HTML5-Build: voller normaler grüner Energiebalken ungefähr so hoch wie der volle HP-Bereich; bei Überladung rote Segmente unmittelbar darüber, insgesamt ungefähr bis HP plus Schild. Verbrauch/Regeneration sollen weiter proportional angezeigt werden und nicht verändert sein. Auch Niedrigenergie, Start nach Neustart und keine Bildschirmüberschreitung prüfen. Schaden, Energieverbrauch, `StateMax`, Wiederaufladung, Schild- und Munition-Sprites bleiben unverändert.

**Reihenfolge:** Walker-Stopp und Schildwirkung sind vorher positiv getestet. Sonec kann noch in den Walker hineinspringen (separater Befund), Sound-Event-Entkopplung ist später. **Keine zusätzlichen Änderungen vor dem HUD-Nachtest.** itch.io-Seite bleibt Draft; Secret-URL-Test offen.

## HUD-Overload-Sichttest: 4000 + 500 Energie (16.11.2026)

**Neue konkrete Entwicklerentscheidung nach positivem Screenshot der proportionalen HUD-Anzeige:** `Sonec.Energy.StateMax = 4000`, `Sonec.Energy.State = 4500` beim Start/Neustart, also **500 Overload** für den nächsten visuellen Test. Die separate rote HUD-Skala in `gui.agc` ist so angepasst, dass **500 überschüssige Energie alle sieben roten Reserve-Segmente** füllt. Die normale Energie füllt 43 grüne Segmente. Beide bleiben proportional (volle 43+7 Slots ca. 350 px ≈ HP+Schild). Anders als beim vorigen Stand ist das ein **bewusstes Startwerte- und Anzeigeskalen-Testsetup**. Die tatsächliche Energiekapazität wird auf 4000 reduziert; Waffen-/Jetpack-/Schild-Verbrauch, Regeneration, Überladungsschaden und Energieaufnahme wurden nicht geändert.

**Wichtig für den Nachtest:** `SonecHealthRegenerate()` behandelt Overload weiterhin als gesundheitsschädlich (`Overload/100` pro Gesundheitsregenerationstakt, multipliziert mit `COSTOVERLOAD`). Die rote Reserve kann daher beim Spielen verschwinden bzw. Lebenspunkte kosten; idealerweise unmittelbar nach dem Start einen Screenshot machen, auch Verbrauch und eventuellen Overload-Gesundheitseffekt beobachten. **Nur GitHub-Code geprüft; lokaler Windows-/HTML5-Test noch offen.** Erst nach Entwicklerbefund den HUD-Schritt abhaken. Bildreferenz vom Entwickler im laufenden Chat, nicht als Datei im Repository behaupten.

## Aktueller HUD-Sichttest: Overload-Skala 1500 und Alpha 170 (16.11.2026)

**Freigegeben und in `source/sonec/gui.agc` implementiert, Entwickler-Nachtest offen:** Nach dem Screenshot des 4000+500-Tests meldet der Entwickler, dass kurzer Jetpack-Flug rund drei der sieben roten HUD-Segmente verbrauchte. Deshalb ist der **rote Anzeigemaßstab** von 500 auf **1500 zusätzliche Energiepunkte für sieben Segmente** erweitert. `Sonec.Energy.StateMax = 4000` und `Sonec.Energy.State = 4500` beim Start/Neustart bleiben unverändert. Bei Start mit +500 werden rechnerisch `ceil(500*7/1500)=3` rote Segmente angezeigt, nicht mehr sieben. Der verbleibende Overload-Bereich ist eine *Anzeigereserve*, kein zusätzlich gewährter Energievorrat. Keine Änderung an echter Überladungsschwelle, Energieverbrauch, Jetpack, Regeneration oder Gesundheitsschaden.

**Zweiter ausdrücklich gewünschter Sichttest:** Alle **zehn** `ColorSet(Data.Color,...)`-Aufrufe in `GuiEnergyDraw()` verwenden Alpha **170 statt 255**: HP normal/kritisch, Schild (inkl. roter Schadensspur), Energie grün, Overload rot, MG-Munition und Granatenmunition. Andere Sprites, Hintergrund, Partikel und Spielcode sind unverändert. Dies ist *globale HUD-Balkentransparenz*, nicht globaler Sprite-Alpha-Wert.

**Nachtest:** Neu kompilierter Windows-/HTML5-Build: beim Start volle 43 grüne und ungefähr drei rote Energiebalken, Transparenz 170 auf allen HUD-Balken, lesbare rote Schildspur und kritische Anzeigen, proportionaler Verbrauch. Overload von 1500 würde sieben Slots füllen; normale Startenergie bleibt 4500. Screenshot und optisches Urteil des Entwicklers abwarten. **Nur statische GitHub-Codeprüfung erfolgt, kein eigener Laufzeittest.** itch.io bleibt Draft; Secret-URL-Test weiterhin offen.

## HUD-Transparenz: gemeinsamer Wert 100 zum visuellen Nachtest (16.11.2026)

**Ausdrücklich freigegeben:** Der Entwickler beurteilt die zwei Screenshots des vorherigen Standes mit HUD-Alpha 170 und Overload-Skala 1500 als funktional, wünscht jedoch deutlich weniger HUD-Überlagerung des Spielbildes. In `source/sonec/gui.agc` steht nun zentral `#constant HUD_BAR_ALPHA 100`, und alle zehn `ColorSet(Data.Color,...)`-Aufrufe in `GuiEnergyDraw()` nutzen diese Konstante statt des zuvor fest eingetragenen `170`. Betrifft HP, Schild mit roter Schadensspur, Energie/Overload, MG- und Granatenmunition; keine anderen Sprite-/Grafikkomponenten geändert.

**Unverändert:** Normalenergie 4000, Startenergie 4500, sieben rote Overload-Slots für die Anzeige bis +1500 (beim Start ca. drei rote), alle Energiekosten und Spielmechaniken. **Status: nur statisch geprüft, neuer AGK-/HTML5-Sichttest offen.** Nach frisch gebautem Stand die Lesbarkeit der grünen, roten und blauen Balken vor verschiedenen Spielhintergründen vergleichen. Bei zu wenig Kontrast genügt künftig **eine** Anpassung der Konstante, z. B. auf 120. Kein weiteres Feature parallel.

## 1. Sofortiger Einstieg im neuen Chat

1. `AGENTS.md`, diese Datei, `PROJECT.md`, die aktuelle `TODO.md` und den aktuellen Status/Übergabeabschnitt in `TECHNICAL.md` lesen. Alte datierte Technikabschnitte sind Historie, keine neue Aufgabenfreigabe.
2. Tatsächlichen `develop`-HEAD und benötigte Dateien direkt von GitHub neu lesen. `main` und `source/legacy/` unangetastet lassen.
3. Klären, ob der Nutzer bereits den aktuellen HTML5-Export hat. Bisher wurde dem Assistenten kein Export-ZIP und keine laufende Browserfassung bereitgestellt. Falls noch kein Export vorliegt, erstellt der Nutzer ihn in AppGameKit Studio.
4. Den echten HTML5-Build im Browser testen lassen bzw. bei bereitgestelltem Build selbst prüfen. Keine Windows-Ergebnisse als Browsertest ausgeben.
5. Nur gemeinsam bestätigte konkrete Releaseblocker beheben. Danach englische Beschreibung/Controls/bekannte Grenzen und manuellen Upload im itch.io-**Draft** samt Test des Secret-URL-Builds vorbereiten. Nicht auf Published umstellen.

**Nächste sinnvolle Nachricht:** „Der Alpha-Walker ist abgeschlossen. Hast du den aktuellen HTML5-Export schon erstellt? Wenn ja, prüfen wir damit zuerst Start, Gamepad, Pause, Tod und Neustart im Browser.“

Keine Annahme automatischer Übernahme des alten Chats, Videos, lokaler Dateien oder einer itch.io-Anmeldung. Falls Export/Projektseite gebraucht wird, muss der Nutzer sie im neuen Chat verfügbar machen.

## 2. Was abgeschlossen und eingefroren ist

| Bereich | Aktueller Stand |
| --- | --- |
| Name | **Alpha-Walker**; Gegnername, nicht Umbenennung des ganzen Spiels oder der Quellcodedateien |
| Unterkörper | Komplexe Zweiknochen-IK, Gang/Stand/Anhalten/Kantenwenden lokal optimal bzw. alpha-tauglich bewertet; erhalten |
| Corpus | Neigt um den roten Hüftpunkt, an dem der Corpus-Anchor fixiert ist |
| Turmanschluss | Corpus-Offset = `Corpus.Position`; nicht mit Corpus-Anchor verwechseln |
| Zielvorbereitung | 400 ms, gemeinsamer Neigungswinkel von Corpus/Turm/Rohren, maximal ±30° |
| Schwenken | Turm unabhängig von Laufrichtung, 800 ms; fünf Breitenstufen 100/85/70/55/40 %, Seitenbildwechsel in der Mitte; keine neue Draufsicht |
| Zielwinkel | Vor Salve einmal erfasst, mit Mündungsbewegung durch Neigung korrigiert; kein Nachführen während Vorbereitung/Salve |
| Streuung | ±3° anfangs, 0.5° Lernschritt pro Salve, mindestens ±1°; `(random(0,200)-100)*AimErrorMax/100.0` |
| Salve | Zwei Schüsse, 150 ms Abstand; 1800-ms-Timer; danach 300 ms Recovery |
| Rohrimpulse | Erst vorderes Rohr `[1]`, dann hinteres `[0]`; 5/10/5/0 px über 60/120/120 ms, je 300 ms; Überlappung beabsichtigt |
| Turmimpuls | Pro Schuss 3 px entgegen Schussrichtung; 60 ms halten + 90 ms Rücklauf, nach 150 ms neutral; keine Aufsummierung |
| Flash | Bleibt am neutralen Mündungspunkt, ohne Rohr- oder Turmrückstoß; folgt weiterhin Eltern-/Plattformbewegung |
| Grafik/Proto | Eigener Entwicklercommit [`0051b8b`](https://github.com/ChristianEngel19820128/SonecBot/commit/0051b8bee28b43f1f5cce787fbc5b412889bfa60), Rohrquelle 3×40 px, getestet/akzeptiert |
| Fairness | Gilt ausdrücklich für Sonec und Computergegner; Regel in PROJECT.md |

**Tatsächlich eingecheckte Barrel-Proto-Werte:** rechts Offset `(0,35)`, Anchor `(1.5,-6)`; links Offset `(0,35)`, Anchor `(1.5,-8)`. Diese sind bewusst vom Entwickler angepasst und lokal akzeptiert. Nicht auf alte 2-/4-px- oder vermeintlich „symmetrischere“ Werte normalisieren.

Letzter Zusatz ist im lokal getesteten Commit `18f92a9` enthalten. Der Nutzer hat ihn abschließend positiv geprüft. Assistentenprüfungen waren statische Analysen, mathematische Modelle und teilweise übersetzte AGK-Funktionslogik, **kein eigener AGK-Compile**. Ein ca. 10-s-Windowsvideo wurde anhand extrahierter Frames beurteilt. Ein vollständiger HTML5-Test ist nicht erfolgt.

## 3. Reihenfolge bis zum kontrollierten Draft-Testrelease

| Priorität | Aufgabe | Freigabekriterium / Stand |
| --- | --- | --- |
| 1 | HTML5 exportieren | Aktueller develop-Stand, Assets vollständig; Build noch nicht verfügbar |
| 2 | Browserstart und Eingabe | Laden, Intro, Start, Bewegung, Jetpack, Waffen, Schild/Energieaktionen und Pause mit dem angebotenen Eingabegerät funktionieren |
| 3 | Spielablauf | Kurzer Kampf, Pause/Fortsetzen, Tod und mindestens zwei Neustarts ohne unspielbaren Zustand |
| 4 | Nur Blocker korrigieren | Konkreter reproduzierter Fehler → kleinster Fix + tatsächlicher Nachtest; Walker nicht neu entwerfen |
| 5 | README/itch.io fertigstellen | Ehrliche Pre-Alpha-Kennzeichnung, tatsächliche Controls, Browser/Gamepad-Hinweise, bekannte Grenzen |
| 6 | Draft-Upload + eingebetteter Test | Besitzer lädt auf die bestehende Draft-Seite hoch und testet über deren Secret URL; kein Published-Wechsel |

Die frühere Zielmarke **16. November 2026** wurde als feste Deadline aufgehoben; Sorgfalt geht vor Geschwindigkeit. Spieltitel ist vorläufig SonecBot; Alpha-Walker bezeichnet den Gegner. Keine Veröffentlichung, fertige ZIP-Datei oder getestete Browser-/Controllerkombination behaupten, bevor diese tatsächlich vorliegt. itch.io-Seite ist im Draft; Secret URL und Zugriff sind hier noch nicht dokumentiert.

## 4. Eingabe: wichtigste bekannte Releasefrage

- `def_joypad.agc`: Für HTML5 ist `Game.JoystickIndex=1` fest; der Workaround wurde aus Crystals übernommen. **Grundsätzliche Controllerfunktion im SonecBot-HTML5-Browser vom Entwickler bestätigt**; erste Eingabe zur Initialisierung erforderlich, diese kann 2–3 Sekunden dauern. Einzelaktionen noch nicht vollständig getestet.
- `intro.agc: IntroDo()`: Menüwahl und Bestätigung verwenden aktuell Gamepad (D-Pad, Start/A).
- `main.agc`: Pause/Fortsetzen verwendet Gamepad-Start.
- `controls.agc` enthält einen Enter-Helfer, aber IntroDo benutzt ihn derzeit nicht.
- `sonec.agc` besitzt Tastaturteile; Maschinengewehr und Granatwerfer verwenden beide KEY_2. Kein vollständig spielbarer Tastaturpfad bestätigt.
- **Aktuelle Testausrichtung:** Gamepad-only für die Pre-Alpha; Tastaturpfad nicht zumutbar und unvollständig. Hinweis „Gamepad required“ plus mögliche 2–3 Sekunden Initialisierungszeit nach erster Eingabe klar kommunizieren; genaue HTML5-Aktionsbelegung nachtestbar halten.
- Fällt Gamepad im Browser aus, ist das bei Gamepad-only ein echter Blocker. Dann gezielt mit [Crystals](https://github.com/ChristianEngel19820128/Crystals) vergleichen, nicht alle Controls pauschal umbauen.

## 5. Bekannte Grenzen: bewerten, nicht ungefragt ausbauen

- Sonec-Energie derzeit Maximum/Start **5250**, ausdrücklich Testhilfe und keine endgültige Alpha-Balance. Nicht automatisch zurücksetzen.
- Feindliche Bullets ziehen in `BulletCollide()` direkt Gesundheit ab; Schildwirkung gegen diese Schadensart ist kein bestätigter vollständiger Schutz.
- Neutrale Explosionstreffer gegen Walker sind noch nicht vollständig ergänzt. Bekannte Einschränkung statt großer Last-Minute-Kampfsystemumbau; nur bei konkretem Releaseblocker eingreifen.
- Walker-Feindbullets sollen eigene Walker und Orbs nicht treffen, Kisten/Minen vorläufig schon. Weitere Treffermatrix und Tunneling-Randfälle später.
- Windows-Arbeitsrenderer ist `#renderer "Basic"` (OpenGL); diese lokale Wahl ist keine allgemeine Browser-/GPU-Empfehlung. Nicht nur wegen alter „temporary“-Kommentare zurückändern.
- F1/F2 und F4/F5/F6 sind Windowsdiagnosen, kein Browser-Erfolg. Der HUD-Text „Flash“ ist vereinfacht, kein Messwert des tatsächlichen Pool-Flashes.
- Unbestätigte frühere Ruckel-/Timing-Hypothesen nicht als bewiesene neue Blocker behandeln. Erst am aktuellen HTML5-Build beobachten.
- Keine neue Aufräumaktion an Integer-Divisionen. Bei benötigten Bruchteilen Float-Operand **vor** Division; Float-Zielvariable allein genügt nach Entwicklererfahrung nicht.

## 6. Bewusst später / reguläre Alpha oder darüber hinaus

Draufsicht/weitere Grafik- und IK-Politur, zusätzliche Gegner, dynamisch winkelabhängige Zielzeiten, Vorhalt-KI, Optionsmenü und Key-Rebinding, neues Punktesystem/Online-Highscores, vollständige Energie-/Schadensbalance, zusätzliche Schild-/Explosionssysteme und ausführliche Kompatibilitäts-/Rendererstudien.

Die Knowledge Base [agk-knowledge-base](https://github.com/ChristianEngel19820128/agk-knowledge-base) soll mit den Projekten wachsen. Kandidaten bleiben dokumentiert: Schwenkprojektion ohne Zusatzsprite, Integer-/Float-Auswertung, negative Random-Grenzen und robustes Zentrieren, verschachtelte Konstanten, Zylinder für Himmel/Wolken in anderem Projekt. Kurzes Register mit Symptom/Muster/Status/Quelle ist vorgeschlagen. Negative Random-Grenzen sind **kein isoliert bewiesener Enginebug**: beim erfolgreichen 0°-Test wurden zugleich Streuung und Random-Eingaben geändert. Kandidaten ohne Druck dokumentieren; Knowledge-Base-Arbeit jeweils erst nach Abschluss des aktuellen Schritts gesondert priorisieren.

## 7. Arbeitsregeln und Quellen

- Aktive Änderungen nur auf `develop`; `main`, Legacy und Lizenz nicht ohne ausdrücklichen Auftrag verändern.
- Kleine nachvollziehbare Schritte, relevante Dokumente in jedem Commit mitpflegen. Untersuchung ist keine pauschale Implementierungsfreigabe.
- Nutzer kompiliert AGK und beurteilt das echte Spiel; Assistent kann Quellen/Modelle prüfen und bereitgestellte Browserbuilds bearbeiten.
- Unklarheiten vor Commit klären, bestätigte IK/Pivots/Spielmechanik schützen.
- Fairness für beide Seiten erhalten; keine perfekte laufende Zielverfolgung einführen.
- Vorherige ausführliche Entwicklungsnotizen sind über Git erhalten: [TODO vor dieser Übergabe](https://github.com/ChristianEngel19820128/SonecBot/blob/18f92a965810763b552bd96649607c112f966238/TODO.md), [TECHNICAL vor dieser Übergabe](https://github.com/ChristianEngel19820128/SonecBot/blob/18f92a965810763b552bd96649607c112f966238/TECHNICAL.md). Datierte historische Tests widersprechen nicht dem neuesten Abschlusstest; sie beschreiben ältere Stände.
- Der neue Chat beginnt beim **Deployment**, nicht beim nächsten optionalen Walker-Feature.
