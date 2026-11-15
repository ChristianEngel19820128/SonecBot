# SonecBot – TODO und Meilensteine

**Dokumentstatus:** Version 1.2  
**Stand:** 15. November 2026  
**Branch:** `develop`  
**Ziel:** Kleine, überprüfbare Schritte zur spielbaren HTML5-Alpha

---

## Legende und Arbeitsweise

- `[x]` – Im Code umgesetzt oder als lokaler Meilenstein bestätigt; der tatsächliche Testumfang steht jeweils dabei.
- `[ ]` – Offen, geplant oder noch nicht ausreichend geprüft.
- Die Aufgabenliste ist **keine pauschale Änderungsfreigabe**. Für Codeänderungen gilt weiterhin `AGENTS.md`; die Prüfung erfolgt bevorzugt in kleinen Commits auf `develop`.
- Neue technische Befunde gehören in `TECHNICAL.md`, grundlegende Projektentscheidungen in `PROJECT.md`.

## 1. Walker – aktueller Schwerpunkt

### Abgeschlossener IK-Meilenstein (13. November 2026)

- [x] Die frühere direkte Beinwinkelanimation durch eine 2-Knochen-IK mit gemeinsamer Winkelumrechnung ersetzen.
- [x] Unterschiedliche Beinlängen anhand von `Proto.Offset → Proto.Anchor` berechnen, statt für beide Glieder 31 px anzunehmen.
- [x] Bilddrehpunkte und Anschlusspositionen mit weißem Skelett, roten Offset- und türkisen Anchor-Markierungen untersuchen.
- [x] Weiße Debug-Linien (2 px) und Gelenkmarkierungen (5 × 5 px) korrekt nach Offset positionieren.
- [x] Corpus-Anchor an die unveränderte IK-Hüfte und den Turm-Offset an den Corpus-Offset anbinden (Referenz-Commit `deb8b74`).
- [x] Stabile Standpose mit 30 px Hüfthöhe und zwei Fußzielen bei ±10 px im lokalen Screenshot des Entwicklers grundsätzlich bestätigen. **Das bestätigt nicht automatisch die fertige Laufanimation.**
- [x] Historische ±45°-Proto-Rotationen für Thigh und Shank als Altwerte identifizieren; aktuelle Testwerte bleiben 0°.

### Abgeschlossener Laufanimations-Meilenstein (14. November 2026)

- [x] Standpose-Diagnosemodus deaktivieren: `WALKER_STAND_POSE_TEST = 0`.
- [x] Getrennte Fußziele von −10/+10 px auch während der Schritte beibehalten.
- [x] Standbein auf der Plattform fixieren und Schwungbein mit an die Reichweite angepasstem Schrittziel bewegen (180° pro 15 px Weg).
- [x] Füße beim Anhalten sanft zur Grundhaltung zurückführen.
- [x] An Plattformkanten über `TurnPending` erst zur Standpose zurückkehren, dann die Blick- und Laufrichtung wechseln.
- [x] Einheitliches, langsameres Lauftempo `0.05` für vergleichbare Tests setzen.
- [x] Fußgelenke 8 px über der Plattformoberkante platzieren; die tatsächlichen Fußsohlen liegen im lokalen Screenshot optisch passend auf.
- [x] Weißes Debug-Skelett, Proto-Markierungen und Winkelanzeige standardmäßig deaktivieren; Diagnoseroutinen erhalten.
- [x] Gangbild, Pausen, Richtungswechsel und Animation ohne Debug in lokalen Screenshots/Videos grundsätzlich prüfen. **Bewertung des Entwicklers: Laufanimation alpha-tauglich.** Das ersetzt keinen umfassenden HTML5-/Randfalltest.

### Walker-Bewaffnung – nächster Schwerpunkt

- [x] Erste horizontale Walker-Testschüsse in Blickrichtung mit einem Timer von 1800 ms über `BulletAdd(...,TYPEENEMY,...)` eingebunden; Mündungsposition wirkt im lokalen Test plausibel. Schüsse treffen Sonec und verursachen Schaden.
- [x] Walker-Turmtreffer auf Spielerprojektile (`TYPEPLAYERONE`) begrenzt, damit Walker-Geschosse nicht ihre eigenen Artgenossen beschädigen.
- [x] **Zwei-Schuss-Salve im Code implementiert:** Walker startet nur während einer normalen Standpause mit ruhig stehenden Füßen eine Salve aus zwei Geschossen (150 ms Abstand). Während `FireState` aktiv ist, darf weder die Laufbewegung noch eine Wendung beginnen; nach dem zweiten Schuss bleiben 200 ms Erholungszeit für einen späteren Rückstoß/eine Animation. Bestehender Schussabstand zwischen Salven 1800 ms. **Der Entwickler hat das Salventempo lokal als passend bewertet; vollständiger Test von Bewegungslock und Pausenlogik bleibt offen.**
- [ ] **Nächster Test:** Im Spiel prüfen, ob der Walker die Bewegung für beide Schüsse und bis zum Ende des Feuerzustands festhält, erst anschließend weiterläuft, nicht während des Wendens schießt und der Feuertimer bei längeren Standphasen sinnvoll bleibt.
- [x] **Float-Zeichenpfad lokal erstmals geprüft:** `SpriteDraw()` gibt Positionen ohne `Floor()` an AGK weiter (`fb45a28`). Der Entwickler berichtet, dass das originale 2-px-Walker-Rohr in den neuen Screens wieder ungefähr 2 px hoch erscheint und Kisten sauber aufliegen. Erste Screens zeigen keine auffällige neue Verschiebung; **kein abschließender Qualitätsnachweis**, der Langzeitvergleich bleibt offen.
- [ ] **Float-/Sprite-Langzeittest:** `SpriteDraw()` zeichnet ohne `Floor()`; seit `96dccfd` werden `*0.5`-Halbierungen und bei jedem Rendern korrekte skalierte Offsets verwendet. Kistenkante und Rohrlage wirken in den jüngsten Screens besser; ruckelfreies Scrollen und HTML5 sind nicht bewiesen. Bei Problemen gezielt und isoliert gegen die vorige Variante testen.
- [x] **Walker-Mündung links/rechts lokal ausgerichtet (15. November):** In `protowalker.json` sitzt `Barrel[0]` rechts bei `Offset=(1,35), Anchor=(1,-6)` (`b5cc35b`) und links bei `Offset=(1,35), Anchor=(1,-8)`; die linke X-Offset-/Anchor-Korrektur (`7047fba`) brachte die sichtbare Rohrgrafik auf Höhe der F1-Markierungen. Mit `48ce0dd` starten Bullet **und** Flash jetzt am ersten Barrel-Anchor, ohne separaten ±30-px-Turmursprung. Die Seiten und Größenverhältnisse von Sonec und Walker wirken laut Entwickler in lokalen Screens plausibel. **Kein HTML5-/Randfallnachweis.** Sonecs eigene Referenzradien bleiben Bullet 25 px und Flash 33 px.
- [ ] **Optionaler isolierter Kanonen-Sprite-Test (ohne bestehende Logikänderung):** Als zusätzliche, per Debug-Schalter ein-/ausblendbare Grafik ausschließlich das **original 2 px hohe Rohr** aus den Walker-Turmgrafiken herauslösen; sämtliche bisherigen Turm-Anschlüsse/Pivots und `WalkerFireShot()` unverändert lassen. Damit Rohrkante, Skalierung, Seiten-Symmetrie und Flash-Overlay vergleichen. Grafikvorbereitung übernimmt der Entwickler, falls dieser Test beschlossen wird; **kein regulärer Umbau des Turms**.
- [x] **Walker-Flash mit bewegter Plattform gekoppelt:** Gemeinsamer Flash-Pool wird weiterverwendet; `TFlash.AttachedWalkerIndex` und `WalkerFlashFollowAll()` aktualisieren aktive Walker-Flashes nach der Plattform-/Walker-Bewegung (`36072dd` bis `134e6ac`). Flashgröße/Lebensdauer und Bullet-Flug bleiben unverändert; visuelle Lokaltests unauffällig, gezielte Mehrfach-Walker-/bewegte-Plattform-Randfälle noch offen.
- [ ] **Schuss-Sound entkoppeln:** `SoundPlay(Sound.MGunSound)` wird derzeit aus `SonecMGunInput()` aufgerufen; eine wiederverwendbare Feuer-/Effekt-Funktion für Sonec und Walker überlegen. Sound nicht automatisch bei jedem rein visuellen Flash auslösen (auch spätere Effektvarianten beachten). Bei Umsetzung Sonec-Verhalten beibehalten.
- [ ] **Späterer Waffen-Grafikpass (nicht Alpha-blockierend):** Statt einer optisch einzelnen Kanone könnten zwei separate, in der Perspektive überlappende Kanonen-Sprites verwendet werden. Bei einer Zwei-Schuss-Salve rückt abwechselnd die jeweils feuernde Kanone kurz zurück, sodass die hintere Kanone insbesondere beim ersten Schuss sichtbar wird. Die ersten 1×2 bzw. 2×2 Pixel der beiden Rohre gestalterisch differenzieren, damit die Überlagerung lesbar bleibt; zusätzlich darf der gesamte Turm einen kleinen Rückstoß erhalten. **Grafikänderungen übernimmt der Entwickler**; bestehende Turmposition und bereits geplante einfache Turm-Rückstoßanimation sind wiederverwendbar. Noch keine Entscheidung für separate Sprites oder neuen Pivot. Beim möglichen Aufteilen kann die optische Rohrhöhe in der Darstellung z. B. von 3 px auf 4 px wechseln; Mündungspunkt und Mündungsfeuer müssen dann erneut geprüft werden.
- [x] **Walker-F1-Diagnose lokal geprüft:** IK-Linien, Proto-Punkte und Positionsmarker per F1 (Windows, auch bei Pause); fester Textblock rechts oben, bis zu drei Walker mit IK/Pivot/Bullet/Flash/Barrel/Winkel/`FireState` (`3833668`, `202a045`). Durch `48ce0dd` wurde Gelb als äußerer 11 × 11 Marker sichtbar gemacht, während Blau/Orange die überlagerten Barrel-Anchors zeigen. Entwickler-Screens bestätigen die grundsätzliche Anzeige. HTML5- und Mehrfach-Neustartfälle ausstehend.
- [ ] **F1-Randfälle:** Neuinitialisierung/Neustart, mehrere Walker gleichzeitig, volle Bildschirmhöhe und HTML5-/Browser-Keybindung testen; die grundlegende Windows-Anzeige im lokalen Spiel ist bestätigt.
- [x] **Thematische Debug-Trennung im Code:** `F1` (Walker/IK/Waffen) und `F2` (Plattform/Bewegung) unter Windows gegenseitig exklusiv umschaltbar, auch in Pause (`57d6044`). F1 reagiert bei Platzbedarf mit kleinerer Textgröße (`49145a1`). Der neue F2-Code ist statisch geprüft, aber noch nicht im AGK-Lauf getestet. Spätere F3-Performanceanzeige oder Logfile erst bei Bedarf; `WALKER_STAND_POSE_TEST` bleibt eine separate Testbetriebsart.
- [x] **Fairness-Regel Orbs:** Orbs sind keine neutralen Ziele für Geschosse: Nur `TYPEPLAYERONE` darf sie per `BulletCollideOrbs()` treffen; Walker-/Feind-Bullets werden ignoriert. Statisch eingecheckt, lokaler Test offen. Weitere Schadensquellen (Explosionen usw.) separat betrachten.
- [ ] **Trefferregel-Matrix festlegen:** Welche Geschosse (Spieler, Walker/Feind) dürfen Sonec, Schild, Walker, Minen, Orbs, Kisten oder andere Objekte treffen? Kistenschaden durch Walker ist aktuell möglich und eventuell akzeptabel, Entscheidung offen. Bei allen Gegnerfähigkeiten auf **faire Computergegner** achten: erkennbare Angriffsmuster, realistische Reaktionszeiten und keine unbeabsichtigte Zerstörung spielerrelevanter Ressourcen.
- [ ] Sehr schnelle Bullets (derzeit ungefähr 300 virtuelle px/s) auf **Tunneling** zwischen Kollisionsprüfungen testen; ggf. Strecke zwischen alter und neuer Position statt nur Endposition prüfen. Der gelegentliche Eindruck minimal verfehlter Treffer bei Sonec ist noch kein bestätigter Fehler.
- [ ] Prüfen, wie feindliche Geschosse mit Sonecs Schild interagieren; `BulletCollide()` zieht derzeit unmittelbar Gesundheit ab.
- [ ] Diagonal schießende Bullets, inklusive Projektilgrafik und korrekt rotierter Trefferbox, erst **nach** dem horizontalen Waffen-Grundtest entwickeln.
- [ ] **Walker: faire, sich verbessernde Zielgenauigkeit (Konzept, noch nicht implementiert):** Erste Salve mit kontrollierter zufälliger Abweichung. Mit weiteren Salven wird die Zielschätzung schrittweise besser, bleibt aber bewusst nie perfekt. Die Ungenauigkeit soll nachvollziehbare Ausweichmöglichkeiten lassen und nicht durch reine Zufalls-Treffer unfair wirken.
- [ ] **Bewegungsprognose als Walker-Eigenschaft prüfen:** Sonecs Bewegungsrichtung und Geschwindigkeit beim Zielen teilweise berücksichtigen, ggf. mit begrenztem Vorhalt in seine Flugrichtung. Kein allwissendes Echtzeit-Tracking; Lernfortschritt nach Zielverlust/Unterbrechung wieder reduzieren oder zurücksetzen. Erkennungsbedingungen, maximale Zielkorrektur, Reaktionszeit und Schwierigkeitsgrad später festlegen.
- [ ] **Technische Reihenfolge beachten:** Aktuell kann der Walker nur horizontal schießen; für echtes Zielen auf bewegte/anders hoch liegende Ziele zuerst diagonale Bullet-Flugbahnen und passende Kollisionserkennung zuverlässig testen. Aim-System in kleinen Schritten entwickeln; keine Änderungen an der funktionierenden Bein-IK.
- [ ] Danach Zielwahl/Erkennungsbedingungen und optional eine begrenzte Turm-/Torso-Neigung separat planen, ohne die funktionierende Bein-IK zu verändern.

### Walker – spätere Arbeiten und Polishing

- [ ] Verhalten an Kisten und auf besonders schmalen Plattformen überprüfen; Plattformkanten sind bereits berücksichtigt.
- [ ] Größeninitialisierung in `WalkerNew` und die daraus abgeleiteten Begrenzungs-/Kollisionswerte prüfen.
- [ ] Explosionstreffer für Walker ergänzen, wenn die allgemeine neutrale Explosionskollision erweitert wird.
- [ ] Später entscheiden, ob eine zusätzliche Corpus-Trefferzone sinnvoll ist.
- [ ] **Grafisches Polishing (nicht alpha-blockierend):** Beinsegmente bei Bedarf etwas schlanker zeichnen und Knie-/Gelenkdetails, Konturlinien oder kleine Highlights ergänzen. Dabei Sprite-Offsets und Anchors nur bei wirklicher Änderung der Bildgeometrie nachmessen.
- [ ] Die vorhandene richtungsabhängige ±90°-Fußwinkelzuweisung für ein künftiges verallgemeinertes Skelett-/Endglied-Konzept dokumentiert lassen; nur bei konkretem Fehler anfassen.
- [ ] Allgemeine, beobachtete 1-px-Darstellungsabweichung bei Plattformen/Kisten/Sonec gesondert untersuchen; Ursache durch `Floor()` ist noch nicht bestätigt.
- [ ] Langfristig IK-Grundfunktionen und Debug-Skelett vereinheitlichen und bei Bedarf für weitere Gegnertypen auslagern; aktuelle Walker-Implementierung nicht vor der Alpha destabilisieren.
- [ ] Spriter oder ein vergleichbares Keyframe-Werkzeug optional für Spezialanimationen evaluieren.

### Plattformen – aktueller Diagnose-Schwerpunkt (15. November 2026)

- [x] **Plattform-Messung erweitert:** Erster F1-Plattformscreenshot (vom Entwickler geprüft) zeigte 3 Plattformen mit 17 ms und `CalcRange=17`, aber nur einen Standbild-Moment. Aktueller F2-Code: bis zu drei sichtbare Plattformen mit `P#`, X/Y, dX, Timer-`dt`/`CalcRange`/Step und eine 60-Frame-Historie für dX sowie Game-Frame-ms mit Min/Avg/Max und Step-Zählung (`e3aa594`, `05fac96`, `57d6044`). **F2-Version noch nicht lokal getestet.** Bewegungsgleichungen unverändert.
- [ ] **Nächster lokaler Test:** In AGK F1/F2 umschalten und Pause prüfen; mit F2 eine links ruckelnde und eine ruhig fahrende Plattform vergleichen. Die 60-Frame-Statistik (dX-Min/Avg/Max, Frame-ms-Min/Avg/Max, Steps/Frames) per Screenshot sichern und beobachten, ob Aussetzer/Zeitsprünge auffallen. Keine Bewegungskorrektur ohne klaren Befund.
- [ ] **Timer-Float-Vergleich:** Crystals/`source/crystals/timer.agc` nutzt `1000.0/Span`, SonecBot/`source/sonec/timer.agc` noch `1000 / Span`. Der Entwickler hat ungenaue Integer-Divisionen in AGK praktisch beobachtet. Prüfen, wo nichtganzzahlige Timer-Spans auftreten und ob Float-Operationen erforderlich sind; **separater, gezielter Commit nach Diagnose**, keine ungeprüfte Übernahme von Crystals. VSync-/Geschwindigkeitsänderungen nicht vorwegnehmen.

## 2. HTML5-Alpha – hohe Priorität

- [ ] Aktuellen HTML5-Build in einer Browserumgebung praktisch testen; Ziel für die erste Veröffentlichung ist itch.io.
- [ ] Gamepad-Eingaben mit dem bestehenden HTML5-Index-1-Workaround verifizieren; bei Problemen mit dem Referenzprojekt Crystals vergleichen.
- [ ] **Alpha:** Tastatur als zuverlässig spielbare Alternative zum Gamepad prüfen und vollständige Standardbelegung für Bewegung, Jetpack, Waffen, Schild und Pause festlegen und testen.
- [ ] **Alpha-Optionen (Minimalumfang):** Entscheiden, ob ein kleines Optionsmenü vor der Veröffentlichung nötig ist (zumindest Steuerung anzeigen, Audio/Anzeige falls relevant); alternativ Standardbelegung im Spiel/Hilfetext dokumentieren. Kein komplexes Menü als automatische Alpha-Voraussetzung.
- [ ] **Beta:** Frei belegbare Tastatursteuerung (Key-Rebinding) mit Konfliktprüfung, Standardwerte wiederherstellen und dauerhafter Speicherung als eigene Aufgabe vorsehen.
- [ ] **Beta:** Optionsmenü um Eingabe-/Audio-/Grafikeinstellungen entsprechend tatsächlichem Bedarf erweitern.
- [x] **Windows-VSync-Ersttest ohne Auffälligkeiten:** `WINDOWS_VSYNC_TEST = 1` liefert nach lokalem Bericht konstante 59/60 FPS und beim schnellen Fallen von Sonec kein sichtbares Tearing. Einstellung vorerst beibehalten (`46419f0`); kein Beweis für die frühere Ursache horizontal verschobener Bildbereiche.
- [ ] **Windows-VSync-Langzeittest:** Später horizontale Plattform-/Gebäudekanten, schnelles Scrollen, andere Monitore/Bildraten sowie mögliche Auswirkung auf Spielgefühl vergleichen. `WINDOWS_VSYNC_TEST = 0` stellt `SetSyncRate(60,1)` als Vergleich wieder her; HTML5 bleibt unverändert.
- [ ] Freien Fall, Sprung, Jetpack, Landungen, Waffen und Plattformen bei unterschiedlichen Bildraten testen.
- [ ] Offene bildratenabhängige Bewegungsberechnungen (insbesondere Sonec) bewerten; nicht allein wegen aktiviertem VSync als gelöst einstufen.
- [ ] Spielrunde, Pause, Tod, Neustart und minimale Alpha-Abschlussbedingungen festlegen.
- [ ] **Einfaches Punktesystem für die Alpha prüfen:** Vorhandene Punkte-/Score-Anzeige und Punktvergabe im aktuellen SonecBot-Code inventarisieren; minimale Regeln für Treffer, zerstörte Ziele, Ressourcen und Spielende festlegen und testen.
- [ ] **Online-Highscore-Tabelle prüfen:** Bestehende Lösung aus Crystals und ihre technische Anbindung/Datenschutz/Fehlerfälle prüfen; entscheiden, ob eine einfache Online-Tabelle bereits mit der Alpha sinnvoll und zuverlässig ist oder erst mit der Beta veröffentlicht wird.
- [ ] **Schwierigkeitsgrade für die Veröffentlichung vormerken:** mindestens das gewünschte Standard-Spielgefühl und mögliche Varianten prüfen; Spawnrate, Gegnerpräzision, Feuerpausen, Ressourcenverfügbarkeit und Fairness berücksichtigen. Kein sofortiger Umbau der Balance.
- [ ] Alpha-Umfang bewusst klein halten: ein zuverlässig spielbarer Walker ist Pflicht, zusätzliche Gegner nicht automatisch.

## 3. Kampf, Energie und Kollisionen – mittlere Priorität

- [ ] Explosionen gegen Walker und weitere zerstörbare Objekte auf neutrale Schadenswirkung sowie gewünschte Kettenreaktionen ausbauen.
- [ ] Schildkollisionen mit AGK-Shape-Diagnose weiter bewerten; bisherige Radius-/Schadenslogik nicht ungeprüft ersetzen.
- [ ] Schildladung langfristig von Animationsframes entkoppeln; Schadensarten kinetisch, Explosion, Plasma und Flamme fachlich trennen.
- [ ] Gewünschte höhere Energie- und Schildkapazitäten inklusive späterer Upgrades und HUD-Balkenproportionen konkret festlegen.
- [ ] Transparenz für HUD, Inenergie-Animation und abhängig vom Energiewert dargestellte Sammelobjekte einführen.
- [ ] Energieverbrauch bei Energieaufnahme als mögliche ältere Designentscheidung überprüfen.
- [ ] Belohnungen durch zerstörte Kisten und Orb-/Upgrade-Verhalten anhand des aktuellen Codes und Spieltests verifizieren.

## 4. Spätere Erweiterungen – niedrige Priorität

- [ ] Weitere Gegnertypen und besondere Bewegungs-/Angriffssysteme erst nach stabiler Alpha-Basis planen.
- [ ] **Gegner sollen individuelle Charaktere haben:** Jeder Gegnertyp erhält ein eigenes, klar erkennbares Verhalten statt eines unnötig komplexen universellen KI-Systems. Für den Walker sind beispielsweise Stand-Salven, begrenzter Vorhalt und allmählich verbesserte, aber unperfekte Zielgenauigkeit vorgesehen. Unterschiede einzelner Exemplare nur bei tatsächlichem spielerischem Nutzen vorsehen; unnötige Sonderfälle und Doppelarbeit vermeiden.
- [ ] Informationsavatar sowie mögliche Aufgaben/Missionen konkretisieren.
- [ ] Vorhandene Online-Highscore-Lösung als Option für Alpha/Beta prüfen (erste Prüfung und mögliche frühere Alpha-Integration im Abschnitt HTML5-Alpha).
- [ ] Weiteren Grafik-, Sound- und UI-Feinschliff nach stabiler Kernmechanik priorisieren; Walker-Beindetails sind bewusst auf später verschoben.

## 5. Dokumentation und Nachvollziehbarkeit

- [x] `PROJECT.md` auf Version 0.6 mit dem alpha-tauglichen Walker-Gangbild aktualisieren.
- [x] `TECHNICAL.md` auf Version 0.5 mit IK-Mathematik, Laufsteuerung, Fußhöhe, Debug-Verfahren und Testgrenzen aktualisieren.
- [x] `TODO.md` angelegt und auf Version 0.2 mit priorisierten Walker-Bewaffnungsaufgaben erweitert.
- [x] Ergebnis der lokalen Walker-Lauftests nachtragen; mögliche Randfälle und graphisches Polishing ausdrücklich später behandeln.
- [ ] **README.md für die Alpha aktualisieren:** Bestehende Kurzbeschreibung und veraltete Aussage „only with Joypad“ anhand des tatsächlich getesteten Steuerungsstands korrigieren; Spielkonzept, Controls, bekannte Grenzen, HTML5-Start, Lizenz/Projektstatus und itch.io-Link verständlich darstellen.
- [ ] **itch.io-Alpha-Seite vorbereiten:** Aussagekräftigen Titel, Kurz- und Langbeschreibung, Kategorie, Tags, Steuerung, Browserhinweise, Alpha-Stand und ehrliche bekannte Einschränkungen formulieren; README und Seite konsistent halten.
- [ ] **Alpha-Screenshots erstellen und auswählen:** 3–5 aussagekräftige Spielszenen, sinnvolles Cover/Banner; für eingebettete HTML5-Seiten ggf. Bilder zusätzlich in der Beschreibung platzieren.
- [ ] **Kurzen Gameplay-Trailer prüfen:** Video/MP4 bei Bedarf erstellen; itch.io unterstützt laut offizieller Dokumentation als Trailer derzeit Links zu extern gehosteten Videos (u. a. YouTube/Vimeo), keine direkte MP4-Einbettung als dokumentierte Trailer-Option. Veröffentlichung und Darstellung auf der HTML5-Seite testen.
- [ ] Vor der HTML5-Alpha offene Anforderungen und tatsächlichen Teststatus der Kernsysteme erneut abgleichen.
- [x] **Wiederlesbare Übergabe im Repository eingerichtet:** `TECHNICAL.md` enthält einen Abschnitt „Übergabe bei Chatlimit oder neuem Chat“ mit Branch-/Commit-Startpunkt, lokal getesteten Befunden, offenen Fragen, AGK-Besonderheiten, Arbeitsregeln und einer Startformulierung. Vor jedem weiteren Chatwechsel die Dateien und den HEAD **erneut** aktualisieren und vergleichen; automatische Kontextübernahme nicht voraussetzen.

**Aktueller Code-Übergabestand:** F1/F2-Diagnose mit 60-Frame-Historie bis `49145a1` (neue F2-Version noch nicht lokal getestet). Nach jedem weiteren Commit den Branch-HEAD neu prüfen. Bitte auch `TECHNICAL.md`, Abschnitt 12, lesen.

**Walker-Referenzstände:** Corpus-/Turmanbindung `deb8b74`; getrennte Fußziele `760c8c3`; angepasste Gangphase `20eced3`; Wendeverhalten `810d342`; einheitliche Geschwindigkeit `20b2d7d`; Fußhöhe 8 px `328c5e0`; Debug-Anzeigen aus `c6d47e6` (jeweils auf `develop`). Der Entwickler hat das lokale Gangbild als alpha-tauglich bewertet; ein eigener AGK-Build des Assistenten und ein HTML5-Praxistest stehen aus.
