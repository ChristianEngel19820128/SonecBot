# SonecBot – Technische Dokumentation

**Dokumentstatus:** Bestandsaufnahme 0.3  
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

### Walker

`walker.agc` enthält unter anderem `ProtoWalkerLoad`, `WalkerNew`, `WalkerAdd`, `WalkerPartsCalculate`, `WalkerMove`, `WalkerAnimate` und `WalkerDraw`.

**Quellcodebefund:** In `game.agc` sind Walker-Erzeugung, Bewegung, Regeneration und Animation eingebunden. Die Laufanimation bewegt Oberschenkel, Unterschenkel und Füße zeitabhängig. `BulletCollideWalkers(...)` prüft Maschinengewehr-Projektile gegen die aus Bildgröße, Offset und Rotation berechnete Turm-Trefferzone; Treffer verringern die Gesundheit, löschen das Projektil und setzen `HitFlashUntil` für einen etwa 150 ms langen roten Trefferblitz.

**Lokaler Spieltest des Entwicklers (November 2026):** Walker bewegt sich mit bewusst mechanisch wirkender Bein-/Fußanimation; Treffer werden nur am Turm erkannt; nach genügend Treffern wird der Walker zerstört und Energie-Bubbles entstehen. Nach Umstellung der Walker-Bilder auf Graustufen und Änderung der Standardfarbe in `WalkerPartCalculate` auf Grün wird der Turm bei einem Treffer sichtbar rot. Diese Aussagen beruhen auf dem Testbericht des Entwicklers, nicht auf einem eigenen Laufzeittest des Assistenten.

**Offen:** In `WalkerNew` sind Zuweisungen für Breite und Höhe auskommentiert, obwohl Größenwerte für Radius und Kollisionsgrenzen verwendet werden. Es ist zu prüfen, ob die Größen anderswo korrekt gesetzt werden. Das ist ein Verdacht, kein bestätigter Bug.

**Offen:** Eine eigene Walker-Bewaffnung ist nicht als funktionierend bestätigt. Eine zusätzliche Torso-Trefferzone und Feinabstimmung der Kollisionen sind mögliche spätere Verbesserungen, nicht Voraussetzung für den aktuellen Teststand. Der Walker ist Pflichtbestandteil der Alpha; die grundlegenden Funktionen sind lokal bestätigt.

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
| Walker-Bewegung/Animation | Mechanische Bein-/Fußanimation implementiert | Vom Entwickler lokal bestätigt |
| Walker-Kampfsystem | Turm-Hitbox, Projektilschaden, roter Trefferblitz, Zerstörung und Energie-Drops implementiert; Walker-Bewaffnung offen | Turmtreffer und Zerstörung vom Entwickler lokal bestätigt |
| HTML5-Steuerung | Index-1-Workaround auf develop umgesetzt; ungetestet | Ausstehend |
| Kollisionen | Primitive/Box-Prüfungen; Schild-Shape-Prototyp mit Vergleichszählern | Schild-Shape-Test lokal durchgeführt; nicht für Schaden aktiv |

„Vorhanden“ bedeutet nicht „fertig“ oder „fehlerfrei“.

## 10. Nächste Untersuchungen

1. Zeitsystem, Pause, Bildratenabhängigkeit und Synchronisierung
2. HTML5-Gamepad-Steuerung im Vergleich mit Columns
3. Walker: Spawn auf Plattformen, Kanten und Kisten als Umkehrpunkte, eigene Bewaffnung über Bullet, mögliche Turm-/Torso-Neigung bis etwa 30°, ungeklärte Gesamtgröße und später ggf. Torso-Hitbox
4. Schild-Shape-Kollision weiter testen; allgemeine Kollisionserkennung und mögliche AGK-Alternativen
5. Kisten, Orbs und Upgrade-Mechanik
6. Wiederverwendung der Highscore-Lösung für die Beta

Die Punkte sind Untersuchungsaufgaben, keine Änderungsfreigaben. Es werden keine Codeänderungen ohne ausdrückliche Zustimmung vorgenommen.

## 11. Quellen und Gültigkeit

Statisch gesichtet auf `develop` (ergänzt durch lokale Testberichte des Entwicklers zum Walker): `main.agc`, `game.agc`, `def_game.agc`, `sonec.agc`, `walker.agc`, `mine.agc`, `plate.agc`, `controls.agc`, `def_joypad.agc`, `world.agc`, `collision.agc`, `sound.agc`.

Der Vergleich mit Crystal Columns/Crystals erfolgte anhand von `main.agc`, `def_joypad.agc`, `input.agc`, `controls.agc`, `timer.agc` und `highscore_online.agc` auf `main`. Angaben zur praktischen Tastaturbedienung und zu Upgrade-Belohnungen bleiben noch zu verifizieren. Die vorhandene PurpleToken-Online-Highscore-Integration in Crystals wurde im Quellcode bestätigt, aber nicht auf Erreichbarkeit getestet.
