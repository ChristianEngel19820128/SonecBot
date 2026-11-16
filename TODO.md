# SonecBot – Aktuelle Aufgaben und Meilensteine

**Dokumentstatus:** Version 4.2 – itch.io-Embed-Neustart und Links bestätigt  
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

## 3. Später – gesammelt, nicht als Pre-Alpha-Blocker

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

## 4. AGK Knowledge Base – eigener freizugebender Arbeitsschritt

Die [agk-knowledge-base](https://github.com/ChristianEngel19820128/agk-knowledge-base) bleibt ohne gesonderte Vereinbarung **read-only**.

- [ ] Kandidaten gesammelt halten: HTML5-Gamepad-Index/Initialisierung, Browser-ESC/QUIT, XAMPP-Cache/Hard-Reload, Timer/FPS-abhängiges Spawning, Sprite-/Float-/Integer-Division, Random-Grenzen, verschachtelte Konstanten und Turm-Schwenkprojektion.
- [ ] Für jeden Kandidaten zuvor genaue Quelle/Revision, beobachtetes Symptom, Gegenprobe, Status (bestätigt/Hypothese) und wiederverwendbaren Nutzen prüfen; keine unbestätigten Enginebugs behaupten.

## 5. Vorgehensweise

Kleine einzeln vereinbarte Schritte, echter Test durch Entwickler in AGK Studio/Apache, Resultat und Grenzen dokumentieren, danach nächsten Punkt auswählen. `develop` ist die aktive Spielcode-Branch; `main`, Legacy und Lizenz nur nach ausdrücklicher Vereinbarung ändern. Keine ungefragten Änderungen an bereits akzeptierten Walker-Pivots, IK oder Kampfsystemen. Historische Detailprotokolle bleiben in [TECHNICAL.md](TECHNICAL.md), [HANDOFF.md](HANDOFF.md) und Git.
