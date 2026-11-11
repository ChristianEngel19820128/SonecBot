# SonecBot – Technische Dokumentation

**Dokumentstatus:** Bestandsaufnahme 0.1  
**Branch:** `develop`  
**Engine:** AppGameKit Studio (AGK)  
**Erste Zielplattform:** HTML5  
**Prüfmethode:** Statische Quellcodeanalyse; kein Build oder Laufzeittest

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

In `main.agc` sind Fenstergröße 1350 × 675, virtuelle Auflösung 900 × 450 und `SetSyncRate(60,1)` eingestellt. Ein älterer Stand verwendete 120 FPS; das ist eine dokumentierte Abweichung, noch kein Fehler.

Die Hauptschleife unterscheidet Intro/verlorenen Spielzustand, laufendes Spiel und Pause. Im aktiven Spiel werden `GameInput`, `GameActionInput`, `GameDo`, `GameAnimate` und `GameDraw` aufgerufen. Die interne Zeit wird anhand von `GetMilliseconds()` fortgeschrieben; bei Pause wird `CurrentNow` nicht weitergezählt.

**Pflichtprüfung:** Zeitsystem, Zeitdifferenzen, Timer, Pause, Bewegungs- und Animationsberechnungen sowie Verhalten bei variabler Bildrate. Diese Untersuchung hat vor einer vertieften Walker-Fehlersuche Priorität.

Aus dem Projekt *Columns* liegt die Erfahrung vor, dass eine VSync-orientierte Synchronisierung für HTML5 und dessen Architektur den Spielfluss verbessern kann. Die dortige konkrete Lösung ist noch nicht geprüft; `SetSyncRate(60,1)` wird nicht ohne Analyse geändert.

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

**Bestätigt:** In `game.agc` ist `WalkerAdd(...)` auf `develop` aktiv. Bewegung, Regeneration und Animation werden im Spielablauf aufgerufen. Der Walker ist somit in die Spielschleife eingebunden.

**Offen:** In `WalkerNew` sind Zuweisungen für Breite und Höhe auskommentiert, obwohl Größenwerte für Radius und Kollisionsgrenzen verwendet werden. Es ist zu prüfen, ob die Größen anderswo korrekt gesetzt werden. Das ist ein Verdacht, kein bestätigter Bug.

**Offen:** Bewaffnung, Kollisionen und tatsächliche Funktionsfähigkeit des Walkers müssen weiter untersucht werden. Der Walker ist Pflichtbestandteil der Alpha.

### Kisten und Orbs

`chest.agc` und `orb.agc` sowie zugehörige Kollisions- und Verwaltungsaufrufe sind vorhanden. Nach Erinnerung des Entwicklers liefern zerstörte Kisten beziehungsweise kleinere Objekte zahlreiche Upgrades oder Sammelobjekte. Exakte Auslöser, Mengen und Belohnungen sind noch zu verifizieren.

## 6. Steuerung und HTML5

`controls.agc` bietet Tastatur- und Gamepad-Hilfen; die Gamepad-Abfragen prüfen zunächst, ob der Joystick vorhanden ist. `GetStartPressed` berücksichtigt Enter und Gamepad-Start. `main.agc` behandelt HTML5 bei der Programmbeendigung gesondert.

**Erfahrungsbefund des Entwicklers:** Die derzeitige Gamepad-Abfragemethode wird unter HTML5 voraussichtlich erhebliche Probleme verursachen. Die Tastatursteuerung ist derzeit praktisch nicht sinnvoll nutzbar.

Im Projekt *Columns* wurden HTML5-spezifische Probleme bereits gelöst. Der Dokumentationsstand dort ist unbekannt. Die konkrete Implementierung muss vor einer Übernahme geprüft werden; sie gilt noch nicht als in SonecBot umgesetzt.

**Priorität:** Hoch für die HTML5-Alpha. Ein Browsertest steht aus.

## 7. Kollisionserkennung

Die bestehende Kollisionserkennung arbeitet nach bisherigem Kenntnisstand überwiegend mit selbst implementierten Prüfungen einfacher geometrischer Formen beziehungsweise Begrenzungen. `collision.agc` enthält eine entsprechende Hilfsfunktion; weitere objektspezifische Prüfungen befinden sich in den jeweiligen Modulen.

AGK bietet eigene Kollisionsfunktionen. Vor einem möglichen Einsatz muss untersucht werden, ob diese mit der bestehenden Objekt-, Sprite- und Bewegungsarchitektur vereinbar sind. **Keine pauschale Umstellung beschlossen.**

## 8. Spätere Online-Highscores

Für die Beta ist ein Online-Highscore-System vorgesehen. Nach Angaben des Entwicklers existieren bereits produktive Lösungen; voraussichtlich genügt eine Online-Tabelle als Datenbasis. Die bestehende Lösung soll geprüft und möglichst wiederverwendet werden. Nicht Bestandteil der ersten Alpha.

## 9. Prüfstatus

| Bereich | Statischer Befund | Laufzeittest |
|---|---|---|
| Hauptschleife | Vorhanden | Ausstehend |
| Zeitsystem | Vorhanden, eingehende Prüfung erforderlich | Ausstehend |
| Sonec, Waffen und Schild | Funktionen vorhanden | Ausstehend |
| Plattformen und Minen | Funktionen vorhanden | Ausstehend |
| Kisten und Orbs | Module vorhanden; Belohnungsmechanik ungeklärt | Ausstehend |
| Walker-Erzeugung | Aktiv in Spielschleife | Ausstehend |
| Walker-Bewegung/Animation | Aufrufe vorhanden | Ausstehend |
| Walker-Kampfsystem | Ungeklärt | Ausstehend |
| HTML5-Steuerung | Potenzielle Inkompatibilität laut Projekterfahrung | Ausstehend |
| Kollisionen | Primitive/Box-Prüfungen vorhanden; AGK-Alternativen ungeprüft | Ausstehend |

„Vorhanden“ bedeutet nicht „fertig“ oder „fehlerfrei“.

## 10. Nächste Untersuchungen

1. Zeitsystem, Pause, Bildratenabhängigkeit und Synchronisierung
2. HTML5-Gamepad-Steuerung im Vergleich mit Columns
3. Walker: Prototyp, Größen, Gelenke, Animation, Bewegung, Bewaffnung und Kollision
4. Kollisionserkennung und mögliche AGK-Alternativen
5. Kisten, Orbs und Upgrade-Mechanik
6. Wiederverwendung der Highscore-Lösung für die Beta

Die Punkte sind Untersuchungsaufgaben, keine Änderungsfreigaben. Es werden keine Codeänderungen ohne ausdrückliche Zustimmung vorgenommen.

## 11. Quellen und Gültigkeit

Statisch gesichtet auf `develop`: `main.agc`, `game.agc`, `def_game.agc`, `sonec.agc`, `walker.agc`, `mine.agc`, `plate.agc`, `controls.agc`, `def_joypad.agc`, `world.agc`, `collision.agc`, `sound.agc`.

Aussagen über Columns, die praktische Tastaturbedienung, den Upgrade-Regen und das Highscore-System stammen vorerst aus dem Erinnerungsprotokoll des Entwicklers und sind noch nicht anhand der betreffenden Implementierungen verifiziert.
