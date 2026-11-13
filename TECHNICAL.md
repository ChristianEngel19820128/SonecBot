# SonecBot – Technische Dokumentation

**Dokumentstatus:** Bestandsaufnahme 0.4 (Walker-IK-Meilenstein, 13. November 2026)  
**Branch:** `develop`  
**Engine:** AppGameKit Studio (AGK)  
**Erste Zielplattform:** HTML5  
**Prüfmethode:** Statische Quellcodeanalyse sowie vom Entwickler berichtete lokale Spieltests; kein eigener Build- oder Laufzeittest durch den Assistenten

## 1. Projektstruktur

Der aktive AGK-Code liegt in `source/sonec/`, der historische BlitzBasic-Code in `source/legacy/`.

| Datei | Zuständigkeit |
|---|---|
| `main.agc` | Programmeinstieg, Hauptschleife, Fenster und Synchronisierung |
| `game.agc` | Spielinitialisierung, Prototypen, Aktualisierung und Darstellung |
| `def_game.agc` | Gemeinsame Datentypen und Objektstrukturen |
| `sonec.agc` | Spielfigur, Waffen, Bewegung und Kollisionen |
| `walker.agc` | Walker-Erzeugung, Bewegung, Animation und Darstellung |
| `mine.agc` | Minen und Interaktionen |
| `plate.agc` | Plattformen |
| `chest.agc`, `orb.agc` | Kisten und Orbs |
| `world.agc` | Initialisierung der Spielwelt |
| `collision.agc` | Allgemeine Kollisionshilfen |
| `controls.agc`, `def_joypad.agc` | Eingaben und Joystick-Auswahl |
| `timer.agc` | Zeit- und Timer-Hilfen; eingehende Prüfung ausstehend |
| `sound.agc` | Laden und Abspielen von Sounds |

Weitere Module betreffen Hintergrund, Wolken, Türme, Energie, Waffen, Effekte, Benutzeroberfläche und Intro.

## 2. Hauptschleife und Zeit

In `main.agc` sind Fenstergröße 1350 × 675, virtuelle Auflösung 900 × 450 und ursprünglich `SetSyncRate(60,1)` eingestellt; die HTML5-Ausnahme ist unten dokumentiert. Ein älterer Stand verwendete 120 FPS; das ist eine dokumentierte Abweichung, noch kein Fehler.

Die Hauptschleife unterscheidet Intro/verlorenen Spielzustand, laufendes Spiel und Pause. Im aktiven Spiel werden `GameInput`, `GameActionInput`, `GameDo`, `GameAnimate` und `GameDraw` aufgerufen. Die interne Zeit wird anhand von `GetMilliseconds()` fortgeschrieben; bei Pause wird `CurrentNow` nicht weitergezählt.

**Weiterhin offen:** Zeitsystem, Zeitdifferenzen, Timer, Pause sowie Verhalten bei variabler Bildrate im Laufzeittest prüfen. Die erste statische Untersuchung ist erfolgt; die grundlegende Walker-Funktion wurde inzwischen separat lokal getestet.

Aus dem Projekt *Columns* liegt die Erfahrung vor, dass eine VSync-orientierte Synchronisierung für HTML5 und dessen Architektur den Spielfluss verbessern kann. Die konkrete Lösung wurde inzwischen im Repository Crystals geprüft; die HTML5-Ausnahme ist inzwischen umgesetzt.

### Ergänzung: Untersuchung der Zeit- und HTML5-Synchronisierung (November 2026)

**Quellcodebefund:** In `SonecMove` werden Beschleunigung und Bremsen teilweise mit `MoveTimer.CalcRange` skaliert, die Positionsänderungen (`Position.x += MoveSpeed.x`, `Position.y += MoveSpeed.y`) dagegen nicht. Daher ist die Bewegung bei unterschiedlichen Aktualisierungsraten voraussichtlich nicht gleich. Vereinfachte Rechenbeispiele zeigten Unterschiede zwischen 30 und 60 FPS; dies sind **keine Laufzeitmessungen**. Sprung, Jetpack und Landungen hängen zusätzlich von Eingabe-, Bewegungs- und Kollisionszuständen ab und müssen praktisch getestet werden.

Die Bewegung von Walker, Plattformen, Orbs, Minen, Türmen, Projektilen und PlasmaBlitz berücksichtigt `CalcRange` in der Positionsänderung. Kisten folgen ihren Plattformen. Bei Granaten und Wolken werden dagegen Teile der Geschwindigkeitsänderung ohne entsprechenden Zeitfaktor ausgeführt. Die Untersuchung bestätigt damit keine allgemeine Bildratenunabhängigkeit aller Objekte; Sonec ist der auffälligste Fall.

**Vergleichsprojekt:** [Crystal Columns / Crystals](https://github.com/ChristianEngel19820128/Crystals) verwendet in `source/crystals/main.agc` für HTML5 `SetVSync(1)` und sonst `SetSyncRate(120,0)`. Der grundlegende Timermechanismus ist ähnlich. Der Unterschied im Bewegungsmodell zwischen Rasterspiel und SonecBot bleibt relevant.

**Umgesetzt auf `develop`:** In `main.agc` wird für HTML5 `SetVSync(1)` gewählt; andere Plattformen behalten `SetSyncRate(60,1)`. Commit `94f84f032a2c6b45ee82570deef16c67016ea206`. VSync ist **keine Korrektur** der bildratenabhängigen Physik.

**Geplante Verifikation:** Sobald ein zuverlässig spielbarer HTML5-Build vorliegt, Sonecs freien Fall, horizontale Bewegung, Sprung, Jetpack, Plattformlandungen und Granaten bei verschiedenen Bildraten vergleichen. Das 60-FPS-Spielgefühl dient vorerst als Referenz. Keine Physikänderung beschlossen.

## 3. Daten und Objektverwaltung

`def_game.agc` definiert Datentypen für Position, Größe, Geschwindigkeit, Animation, Kollision und Objektzustand sowie spezifische Objekttypen und Listen. Prototypdaten werden überwiegend aus JSON unter `media/data` geladen, unter anderem `protosonec.json`, `protoplate.json`, `protomine.json` und `protowalker.json`.

`game.agc` initialisiert die Spielsysteme. In `GameDo` werden Objekte abhängig von Zufall und Obergrenzen erzeugt und anschließend aktualisiert. Die Reihenfolge der Aktualisierungen kann für das Verhalten relevant sein.

## 4. Sonec und Waffen

`sonec.agc` enthält Funktionen für Initialisierung, Animation, Bewegung, Jetpack, Regeneration von Gesundheit und Energie, Maschinengewehr, Flammenwerfer, Plasmawaffe, Granatwerfer, Schild, Energieaufnahme und Kollisionen mit Plattformen und Kisten.

**Befund:** Code vorhanden; vollständige Funktion nicht im Laufzeittest bestätigt.

## 5. Gegner und Objekte

### Minen

`mine.agc` enthält Erzeugung, Bewegung, Regeneration, Kollision, Zerstörung und Darstellung. Die Bewegung berücksichtigt Sonec und das Energieaufnahmesystem.

### Walker – prozedurales Skelett und Standpose (13. November 2026)

`walker.agc` enthält Erzeugung, Plattformbindung, Bewegung, 2-Knochen-IK, Körperanbindung, Darstellung und Diagnosehilfen. `game.agc` erzeugt Walker auf Plattformen; die Erzeugungswahrscheinlichkeit steigt mit der Plattformbreite (35 % bei 200 px, maximal 85 %). Die bestehende Plattformbindung und die Richtungswechsel an Plattformrändern sind implementiert. Das Umkehren an Kisten ist noch zu prüfen.

**Lokal bestätigter Meilenstein:** Nach mehreren kleinen Änderungen und Screenshottests am 13. November 2026 stehen die Walker-Beine in einer nachvollziehbaren, gelenkverbundenen Grundpose, und Corpus sowie Turm sitzen deutlich besser über der IK-Hüfte. Die letzte Körperanbindung ist in Commit `deb8b74` auf `develop` dokumentiert. Diese Bewertung beruht auf lokalen Screenshots des Entwicklers. Ein eigener AGK-Build durch den Assistenten ist nicht erfolgt; die Laufanimation **nach** dieser Änderung ist noch nicht praktisch freigegeben.

#### Proto-Daten und Gelenkgeometrie

- `protowalker.json` beschreibt für linke/rechte Sprites `Offset` (lokaler Drehpunkt), `Anchor` (lokaler Anschluss zum nächsten Gelenk) und `Rotation`. Diese Bildkoordinaten stammen aus den ungedrehten Originalgrafiken.
- Die IK-Knochenlänge ergibt sich aus `WalkerProtoBoneLength()`: `sqrt((Anchor.x-Offset.x)^2 + (Anchor.y-Offset.y)^2)`. Sie ist **nicht** mehr für beide Segmente pauschal 31 px. Der linke/rechte Oberschenkel misst ungefähr 12,17 px; die Unterschenkel ungefähr 29,07/30,07 px. Die Längen sind nicht identisch.
- Die Knieposition wird in `WalkerIKBindSprites()` per Schnitt zweier Kreise für unterschiedlich lange Knochen berechnet. Unerreichbare Fußziele werden auf die Reichweite begrenzt. Fußziele und Standhöhe müssen zu diesen Längen passen.
- Das Startziel ist ein fester Stand: Die Hüfte liegt aktuell 30 px über der Plattform, die beiden Fußziele bei ±10 px. Ein früherer Test mit 29 px und die Paint.NET-Referenz bleiben als gestalterische Vergleichswerte erhalten; 30 px ist der momentan eingecheckte Stand.

#### Winkelkonvention und Sprite-Transformation

Die ursprüngliche `CalcAngle()` in `math.agc` bleibt unverändert. Die neue `CalcAngleIK(dx,dy)` verwendet die IK-Konvention 0° = oben (12 Uhr), 90° = rechts, 180° = unten, 270° = links und behandelt auch achsenparallele Richtungen.

`WalkerIKSpriteAngle()` richtet die lokale Bildrichtung von `Offset → Anchor` auf die berechnete IK-Richtung aus. Die Grundformel lautet:

```agk
ReferenceAngle = CalcAngleIK(Proto.Anchor.x-Proto.Offset.x, Proto.Anchor.y-Proto.Offset.y)
SpriteAngle = NormalizeAngle(IKDirection-ReferenceAngle+Proto.Rotation)
```

Für ein Endglied ohne gerichteten Anschluss (`Offset = Anchor`, hier der Fuß) gibt es keine solche Referenzrichtung. Die Implementierung übernimmt in diesem Fall die Proto-Rotation. **Aktuell experimentell:** Bei der endgültigen Fußwinkelzuweisung in `WalkerIKBindSprites()` kommt richtungsabhängig noch −90° (links) beziehungsweise +90° (rechts) hinzu. In der aktuellen JSON stehen die Fuß-Proto-Rotationen wieder auf 0°. Diese Korrektur ist kein endgültig verallgemeinertes Endglied-Konzept.

`WalkerIKPartSetup()` übernimmt die unveränderten lokalen Sprite-Offsets. `SpriteDraw()` setzt sie mit `SetSpriteOffset()` und zeichnet bei `Data.Center = TRUE` mit `SetSpritePositionByOffset()`; die vorhandene Änderungsprüfung für Winkel und Skalierung bleibt erhalten. Die ursprünglichen Proto-Rotationen von ±45° bei Thigh und Shank wurden für die IK-Tests in Commit `fcf20db` auf null gesetzt. Blindes Wiederherstellen würde die bereits aus der IK berechneten Spritewinkel zusätzlich verdrehen; die historischen Werte beschreiben eine frühere Pose, nicht automatisch eine heute erforderliche Korrektur.

#### Corpus, Turm und Hüftgelenk

Die alte `WalkerPartsCalculate()`-Kette setzte Oberschenkel und Corpus über `AnchorPosition` zusammen. Beim frühen IK-Umbau wurde die Hüfte stattdessen direkt aus `Walker.ObjectData.Position` genommen; der Corpus-Anchor wurde für die Beinverbindung nicht mehr berücksichtigt. Dadurch konnte das Skelett richtig sein, während Körper und Turm am falschen gemeinsamen Ursprung saßen.

**Korrigierte Anbindung (Commit `deb8b74`):** `Walker.ObjectData.Position` bleibt der feste IK-Hüftpunkt. `WalkerBodyPartAttach()` berechnet den gedrehten lokalen Abstand `Corpus.Anchor - Corpus.Offset` und setzt den Corpus so, dass **sein Anchor genau auf der Hüfte** liegt. Anschließend wird der Turm mit seinem `Offset` am Corpus-`Offset` befestigt. Die Turm-`ObjectData` werden mitverschoben, sodass die bestehende Trefferzonenberechnung seine Position verwenden kann. Die originalen Corpus-, Turm- und Beinpunkte in der JSON blieben unverändert.

#### Debug-Methodik und Erkenntnisse aus der Fehlersuche

- Weiße IK-Linien sind 2 px breit und am Linienanfang über `SetSpritePositionByOffset()` befestigt. Weiße Gelenkquadrate sind 5 × 5 px groß und über `SetSpriteOffset(2.5,2.5)` zentriert. Anfangs war die Debug-Referenz selbst nicht konsequent nach Offset positioniert; dies wurde korrigiert.
- Rot markiert das gedrehte Sprite-Pivot (`Offset`), Türkis den gedrehten `Anchor`. Dadurch ließ sich prüfen, ob die vorgesehenen Bildanschlüsse die weißen IK-Gelenke erreichen. Der Vergleich der Original-PNGs mit der JSON war entscheidend.
- `SpriteAngle - IKAngle` muss **nicht** 0° sein: Der Unterschied enthält die lokale Referenzrichtung der Grafik. Ebenso war das zuvor angezeigte `Error: 0` mathematisch tautologisch und kein unabhängiger Beweis für optische Passung.
- Das vorübergehende Erzwingen von `SetSpriteAngle()` vor dem Zeichnen brachte keine überzeugende Abhilfe. Die bestehende Sprite-Cache-Optimierung sollte erhalten bleiben.
- Die Fehlersuche verlief von alten ±90°-/±45°-Winkelannahmen und gleich langen 31-px-Beinen über den Vergleich von Knie- und Fußpunkten bis zur gemeinsamen Proto/IK-Transformation und schließlich zur korrekten Corpus-Anbindung. Die funktionierenden Zwischenstände sind über Git-Commits nachvollziehbar. Die Originalgrafiken und manuell ermittelten Proto-Anker sollten nicht aufgrund eines bloß visuellen Verdachts pauschal verändert werden.

#### Momentaner Testmodus und offene Punkte

`WALKER_STAND_POSE_TEST = 1` ist derzeit aktiv. In diesem Modus bleibt der Walker stehen und erhält feste, ruhende Fußziele auf Plattformhöhe. Mit `0` kann die bisherige Laufsteuerung wieder erprobt werden. Die Winkel- und Gelenkdiagnose (`WALKER_SKELETON_DEBUG`, `WALKER_PROTO_POINTS_DEBUG`, `WALKER_ANGLE_DEBUG`) ist weiterhin aktiviert; die Diagnose-Schalter sollen für weitere Gegnertypen erhalten bleiben.

**Nächster Pflicht-Test:** Standmodus kontrolliert deaktivieren; Wechsel zwischen Stand- und Schwungbein, Bodenhaftung der Füße, Pausen, Richtungswechsel und Körper-Turm-Anbindung in Bewegung prüfen. Eine Neigung des Torsos beim Zielen (eventuell bis etwa 30°), eigene Geschosse über das Bullet-System sowie eine mögliche spätere Torso-Trefferzone sind noch keine bestätigten Funktionen. Für besondere Übergangsanimationen bleibt ein Keyframe-Werkzeug wie Spriter als optionale Ergänzung vorgemerkt.

**Bestehendes Kampfsystem:** `BulletCollideWalkers(...)` prüft Projektile derzeit gegen die aus Bildgröße, Offset und Rotation berechnete Turm-Trefferzone. Treffer verringern die Gesundheit und lösen einen kurzen roten Hitflash aus. Zerstörung und Energie-Drops wurden vom Entwickler lokal getestet. `WalkerNew` enthält weiterhin auskommentierte Zuweisungen für Breite und Höhe; ob die Größen anderweitig zuverlässig gesetzt werden, ist noch zu prüfen, kein bestätigter Fehler.

### Kisten und Orbs

`chest.agc` und `orb.agc` sowie zugehörige Kollisions- und Verwaltungsaufrufe sind vorhanden. Nach Erinnerung des Entwicklers liefern zerstörte Kisten beziehungsweise kleinere Objekte zahlreiche Upgrades oder Sammelobjekte. Exakte Auslöser, Mengen und Belohnungen sind noch zu verifizieren.

## 6. Steuerung und HTML5

`controls.agc` bietet Tastatur- und Gamepad-Hilfen; die Gamepad-Abfragen prüfen zunächst, ob der Joystick vorhanden ist. `GetStartPressed` berücksichtigt Enter und Gamepad-Start. `main.agc` behandelt HTML5 bei der Programmbeendigung gesondert.

**Erfahrungsbefund des Entwicklers:** Die derzeitige Gamepad-Abfragemethode wird unter HTML5 voraussichtlich erhebliche Probleme verursachen. Die Tastatursteuerung ist derzeit praktisch nicht sinnvoll nutzbar.

Im Projekt *Columns* wurden HTML5-spezifische Probleme bereits gelöst. Das Referenzprojekt liegt unter `ChristianEngel19820128/Crystals`. Die konkrete Implementierung wurde inzwischen mit Crystals verglichen. Für HTML5 wird in `def_joypad.agc` Index 1 fest gewählt; andere Plattformen behalten die bisherige Indexsuche (Commit `1f96fcb7981869238f0026a33a0c526630fdaa03`). Laut Entwickler lieferte die HTML5-Suche zuvor oft Index 4 und scheinbar unkontrollierte Eingaben. Die Ursache ist ungeklärt; ein Laufzeittest in SonecBot steht aus.

**Priorität:** Hoch für die HTML5-Alpha. Ein Browsertest steht aus.

## 7. Kollisionserkennung

Die bestehende Kollisionserkennung arbeitet nach bisherigem Kenntnisstand überwiegend mit selbst implementierten Prüfungen einfacher geometrischer Formen beziehungsweise Begrenzungen. `collision.agc` enthält eine entsprechende Hilfsfunktion; weitere objektspezifische Prüfungen befinden sich in den jeweiligen Modulen.

AGK bietet eigene Kollisionsfunktionen. Vor einem möglichen Einsatz muss untersucht werden, ob diese mit der bestehenden Objekt-, Sprite- und Bewegungsarchitektur vereinbar sind. **Keine pauschale Umstellung beschlossen.**

## 7a. Energieschild, Explosionen und HUD (November 2026)

**Implementiert und vom Entwickler lokal geprüft:** Der Schild absorbiert bei voller Ladung bis zu 80 % des eintreffenden Explosionsschadens. Die Absorption sinkt proportional zur verbleibenden Ladung und verbraucht Schildenergie. Der Restschaden trifft Sonecs Gesundheit. Nach dem letzten registrierten Schaden pausiert die Schildregeneration 500 ms; der Entwickler hat bestätigt, dass der Schild während einer vollständig laufenden Explosion nicht vorzeitig regeneriert. Schildgröße und HUD-Ladung folgen der Animation. Das erneute Aktivieren während des Abbaus funktioniert im lokalen Test.

**Rote HUD-Schadensspur:** Der blaue Schildbalken sinkt sofort; die rote Spur zeigt den verlorenen Ladungswert, nimmt über die Zeit bis null ab und berücksichtigt weitere Treffer. Die Grunddauer beträgt 1000 ms; jeder weitere Treffer addiert 1000 ms zur verbleibenden Dauer. Die Funktionsweise wurde vom Entwickler grundsätzlich getestet.

**Größe und mögliche Upgrades:** `TShield.SizeMultiplier` mit `SHIELD_DEFAULT_SIZE_MULTIPLIER 0.8` skaliert den Schild auf ungefähr 80 px statt zuvor 100 px. Diese Standardgröße wurde im Spieltest als optimal bestätigt und soll nicht weiter verkleinert werden. Spätere mögliche Upgrades: Faktoren 0.9 und 1.0; noch keine Upgrade-Mechanik implementiert. Das gewollte dynamische Schrumpfen bei Schaden oder Abbau bleibt bestehen.

**Shape-Prototyp:** Unter Windows ist `SHIELD_SHAPE_TEST` aktivierbar; `SetSpriteShape` und `GetSpriteCollision` prüfen Schild und Explosion und vergleichen das Ergebnis mit der bisherigen Radiusprüfung. Die Debug-Ausgabe verwendet Textobjekte (`CreateText`, `SetTextString`, `DrawText`) und das dynamische Array `TGame.DebugText`. Der Entwickler meldete zuletzt 119 Prüfungen, 99 Shape-Treffer, 73 Radius-Treffer, 26 nur durch Shape und 0 nur durch Radius erkannte Treffer. Diese Zähler sind diagnostisch; unterschiedliche Geometrien erklären möglicherweise die Abweichungen, ohne die Genauigkeit abschließend zu belegen. **Die echte Schadensberechnung wurde nicht auf Shape-Kollision umgestellt.** Ein späterer Ausbau des Debug-Systems ist vorgesehen.

**Explosionen:** `EXPLOSION_TIMED_DAMAGE 1` verwendet 30 Schaden pro Ziel in Intervallen von 100 ms; `0` stellt den alten Modus mit 5 Schaden pro überlappendem Frame wieder her. Explosionen sollen grundsätzlich neutral sein und alle zerstörbaren Ziele unabhängig vom Verursacher treffen; Kettenreaktionen sind erwünscht. Eine Walker-Kollision für Explosionen fehlt noch. Eine Windows-spezifische CSV-Messung (`explosion_measurements.csv`) dient der Diagnose. Die derzeitige Schadensbalance soll bis zur Integration weiterer Gegner unverändert bleiben.

**Noch offen:** Schildladung technisch von Animationsframes trennen; Shape-Kollision an Randfällen und bei skalierter Darstellung weiter prüfen; Schutz gegen weitere Schadensarten (geplant: kinetisch, Explosion, Plasma, Flamme). `BulletType` ist derzeit nicht mit diesen Schadensarten gleichzusetzen. Für Energieobjekte ist eine vom Energiewert abhängige, begrenzte Transparenz gewünscht; Inenergie-Animation und HUD sollen ebenfalls teilweise transparent werden. Die Energieaufnahme verbraucht aktuell selbst Energie, möglicherweise eine ältere Designentscheidung; keine Änderung beschlossen.

## 8. Spätere Online-Highscores

Für die Beta ist ein Online-Highscore-System vorgesehen. Nach Angaben des Entwicklers existieren bereits produktive Lösungen; voraussichtlich genügt eine Online-Tabelle als Datenbasis. Die bestehende Lösung soll geprüft und möglichst wiederverwendet werden. Nicht Bestandteil der ersten Alpha.

## 9. Prüfstatus

| Bereich | Statischer Befund | Laufzeittest |
|---|---|---|
| Hauptschleife | Vorhanden | Ausstehend |
| Zeitsystem | Erste Analyse abgeschlossen; Sonec-Position bildratenabhängig | Ausstehend |
| Sonec und Waffen | Funktionen vorhanden | Vollständiger Test ausstehend |
| Energieschild | Absorption, Regeneration, HUD-Schadensspur, 80-%-Größe und Abbau-Reaktivierung implementiert | Wesentliche Funktionen vom Entwickler lokal bestätigt |
| Plattformen und Minen | Funktionen vorhanden | Ausstehend |
| Kisten und Orbs | Module vorhanden; Belohnungsmechanik ungeklärt | Ausstehend |
| Walker-Erzeugung | Aktiv in Spielschleife | Vom Entwickler lokal bestätigt |
| Walker-Bewegung/Animation | Zweiknochen-IK, Proto-Längen und Sprite-Transformation; Standpose-Test aktiv, Laufsteuerung vorhanden | Stabile Grundpose und neue Körperanbindung per Screenshots lokal bestätigt; vollständiger Lauf- und Richtungswechseltest nach der letzten Änderung ausstehend |
| Walker-Kampfsystem | Turm-Hitbox, Projektilschaden, roter Trefferblitz, Zerstörung und Energie-Drops implementiert; Walker-Bewaffnung offen | Turmtreffer und Zerstörung vom Entwickler lokal bestätigt |
| HTML5-Steuerung | Index-1-Workaround auf develop umgesetzt; ungetestet | Ausstehend |
| Kollisionen | Primitive/Box-Prüfungen; Schild-Shape-Prototyp mit Vergleichszählern | Schild-Shape-Test lokal durchgeführt; nicht für Schaden aktiv |

„Vorhanden“ bedeutet nicht „fertig“ oder „fehlerfrei“.

## 10. Nächste Untersuchungen

1. Zeitsystem, Pause, Bildratenabhängigkeit und Synchronisierung
2. HTML5-Gamepad-Steuerung im Vergleich mit Columns
3. Walker: Standpose-Diagnosemodus ausschalten und neue IK-Anbindung in Bewegung testen; Fußkontakt, Pausen und Umkehr überprüfen; dann Kisten als Umkehrpunkte, eigene Bewaffnung über Bullet, mögliche Turm-/Torso-Neigung bis etwa 30°, ungeklärte Gesamtgröße und später ggf. Torso-Hitbox
4. Schild-Shape-Kollision weiter testen; allgemeine Kollisionserkennung und mögliche AGK-Alternativen
5. Kisten, Orbs und Upgrade-Mechanik
6. Wiederverwendung der Highscore-Lösung für die Beta

Die Punkte sind Untersuchungsaufgaben, keine Änderungsfreigaben. Es werden keine Codeänderungen ohne ausdrückliche Zustimmung vorgenommen.

## 11. Quellen und Gültigkeit

Statisch gesichtet auf `develop` (Walker-IK und neue Körperanbindung bis Commit `deb8b74` am 13. November 2026; ergänzt durch lokale Screenshots und Spieltests des Entwicklers): `main.agc`, `game.agc`, `def_game.agc`, `sonec.agc`, `walker.agc`, `mine.agc`, `plate.agc`, `controls.agc`, `def_joypad.agc`, `world.agc`, `collision.agc`, `sound.agc`.

Der Vergleich mit Crystal Columns/Crystals erfolgte anhand von `main.agc`, `def_joypad.agc`, `input.agc`, `controls.agc`, `timer.agc` und `highscore_online.agc` auf `main`. Angaben zur praktischen Tastaturbedienung und zu Upgrade-Belohnungen bleiben noch zu verifizieren. Die vorhandene PurpleToken-Online-Highscore-Integration in Crystals wurde im Quellcode bestätigt, aber nicht auf Erreichbarkeit getestet.
