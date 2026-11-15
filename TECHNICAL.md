# SonecBot – Technische Dokumentation

**Dokumentstatus:** Bestandsaufnahme 1.1 (Walker-Waffenstand und erste Plattformdiagnose, 15. November 2026)  
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

**Umgesetzt auf `develop`:** HTML5 verwendet `SetVSync(1)` (Commit `94f84f0`). Für Windows wurde `WINDOWS_VSYNC_TEST` als Umschalter ergänzt (Commit `46419f0`): bei `1` ebenfalls `SetVSync(1)`, bei `0` wie bisher `SetSyncRate(60,1)`; andere Plattformen verwenden weiter `SetSyncRate(60,1)`. **Lokaler Windows-Ersttest vom 14. November 2026:** konstante 59/60 FPS, kein auffälliges Tearing bei Sonecs freiem Fall mit hoher Endgeschwindigkeit. VSync bleibt für Windows vorerst aktiv. Die Ursache zuvor beobachteter horizontaler Bildverschiebungen ist **nicht abschließend bestätigt**; Langzeitbeobachtung und andere Monitorraten bleiben offen. VSync ist **keine Korrektur** der bildratenabhängigen Physik.

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

### Walker – prozedurales Skelett und Laufanimation (13.–14. November 2026)

`walker.agc` enthält Erzeugung, Plattformbindung, Bewegung, 2-Knochen-IK, Körperanbindung, Darstellung und Diagnosehilfen. `game.agc` erzeugt Walker auf Plattformen; die Erzeugungswahrscheinlichkeit steigt mit der Plattformbreite (35 % bei 200 px, maximal 85 %). Die bestehende Plattformbindung und die Richtungswechsel an Plattformrändern sind implementiert. Das Umkehren an Kisten ist noch zu prüfen.

**Lokal bestätigte Meilensteine:** Am 13. November wurden durch mehrere kleine Tests eine stabile Standpose und die funktionierende Corpus-/Turmanbindung erreicht (Referenz-Commit `deb8b74`). Am 14. November wurden Gang, schrittweiser Richtungswechsel, einheitliches Lauftempo, Fußhöhe und die Darstellung ohne Debug-Marker anhand lokaler Videos und Screenshots des Entwicklers geprüft. Die Laufanimation gilt nach Bewertung des Entwicklers als **alpha-tauglich**; ein vollständiger HTML5-Test oder ein eigener AGK-Laufzeittest des Assistenten fand nicht statt.

#### Proto-Daten und Gelenkgeometrie

- `protowalker.json` beschreibt für linke/rechte Sprites `Offset` (lokaler Drehpunkt), `Anchor` (lokaler Anschluss zum nächsten Gelenk) und `Rotation`. Diese Bildkoordinaten stammen aus den ungedrehten Originalgrafiken.
- Die IK-Knochenlänge ergibt sich aus `WalkerProtoBoneLength()`: `sqrt((Anchor.x-Offset.x)^2 + (Anchor.y-Offset.y)^2)`. Sie ist **nicht** mehr für beide Segmente pauschal 31 px. Der linke/rechte Oberschenkel misst ungefähr 12,17 px; die Unterschenkel ungefähr 29,07/30,07 px. Die Längen sind nicht identisch.
- Die Knieposition wird in `WalkerIKBindSprites()` per Schnitt zweier Kreise für unterschiedlich lange Knochen berechnet. Unerreichbare Fußziele werden auf die Reichweite begrenzt. Fußziele und Standhöhe müssen zu diesen Längen passen.
- Die Hüfte liegt aktuell 30 px über der Plattform; beide Füße haben getrennte horizontale Standzielpositionen von ±10 px. Die IK-Fußgelenke werden mit `WALKER_FOOT_JOINT_LIFT 8.0` gegenüber der Plattformoberkante angehoben, damit die tatsächlichen Fußsohlen optisch korrekt aufliegen. Die 8-px-Korrektur wurde lokal am Screenshot überprüft (Commit `328c5e0`). Ein früherer Hüfthöhentest mit 29 px und die Paint.NET-Referenz bleiben gestalterische Vergleichswerte.

#### Winkelkonvention und Sprite-Transformation

Die ursprüngliche `CalcAngle()` in `math.agc` bleibt unverändert. Die neue `CalcAngleIK(dx,dy)` verwendet die IK-Konvention 0° = oben (12 Uhr), 90° = rechts, 180° = unten, 270° = links und behandelt auch achsenparallele Richtungen.

`WalkerIKSpriteAngle()` richtet die lokale Bildrichtung von `Offset → Anchor` auf die berechnete IK-Richtung aus. Die Grundformel lautet:

```agk
ReferenceAngle = CalcAngleIK(Proto.Anchor.x-Proto.Offset.x, Proto.Anchor.y-Proto.Offset.y)
SpriteAngle = NormalizeAngle(IKDirection-ReferenceAngle+Proto.Rotation)
```

Für ein Endglied ohne gerichteten Anschluss (`Offset = Anchor`, hier der Fuß) gibt es keine solche Referenzrichtung. Die Implementierung übernimmt in diesem Fall die Proto-Rotation. **Aktuell experimentell:** Bei der endgültigen Fußwinkelzuweisung in `WalkerIKBindSprites()` kommt richtungsabhängig noch −90° (links) beziehungsweise +90° (rechts) hinzu. In der aktuellen JSON stehen die Fuß-Proto-Rotationen wieder auf 0°. Diese Korrektur ist kein endgültig verallgemeinertes Endglied-Konzept.

`WalkerIKPartSetup()` übernimmt die unveränderten lokalen Sprite-Offsets. `SpriteDraw()` setzt sie mit `SetSpriteOffset()` und zeichnet bei `Data.Center = TRUE` mit `SetSpritePositionByOffset()`. Seit `96dccfd` wird der skalierte Offset bei jedem Zeichnen gesetzt; die Änderungsprüfung für Winkel und Skalierung bleibt erhalten. Die ursprünglichen Proto-Rotationen von ±45° bei Thigh und Shank wurden für die IK-Tests in Commit `fcf20db` auf null gesetzt. Blindes Wiederherstellen würde die bereits aus der IK berechneten Spritewinkel zusätzlich verdrehen; die historischen Werte beschreiben eine frühere Pose, nicht automatisch eine heute erforderliche Korrektur.

#### Corpus, Turm und Hüftgelenk

Die alte `WalkerPartsCalculate()`-Kette setzte Oberschenkel und Corpus über `AnchorPosition` zusammen. Beim frühen IK-Umbau wurde die Hüfte stattdessen direkt aus `Walker.ObjectData.Position` genommen; der Corpus-Anchor wurde für die Beinverbindung nicht mehr berücksichtigt. Dadurch konnte das Skelett richtig sein, während Körper und Turm am falschen gemeinsamen Ursprung saßen.

**Korrigierte Anbindung (Commit `deb8b74`):** `Walker.ObjectData.Position` bleibt der feste IK-Hüftpunkt. `WalkerBodyPartAttach()` berechnet den gedrehten lokalen Abstand `Corpus.Anchor - Corpus.Offset` und setzt den Corpus so, dass **sein Anchor genau auf der Hüfte** liegt. Anschließend wird der Turm mit seinem `Offset` am Corpus-`Offset` befestigt. Die Turm-`ObjectData` werden mitverschoben, sodass die bestehende Trefferzonenberechnung seine Position verwenden kann. Die originalen Corpus-, Turm- und Beinpunkte in der JSON blieben unverändert.

#### Debug-Methodik und Erkenntnisse aus der Fehlersuche

- Weiße IK-Linien sind 2 px breit und am Linienanfang über `SetSpritePositionByOffset()` befestigt. Weiße Gelenkquadrate sind 5 × 5 px groß und über `SetSpriteOffset(2.5,2.5)` zentriert. Anfangs war die Debug-Referenz selbst nicht konsequent nach Offset positioniert; dies wurde korrigiert.
- Rot markiert das gedrehte Sprite-Pivot (`Offset`), Türkis den gedrehten `Anchor`. Dadurch ließ sich prüfen, ob die vorgesehenen Bildanschlüsse die weißen IK-Gelenke erreichen. Der Vergleich der Original-PNGs mit der JSON war entscheidend.
- `SpriteAngle - IKAngle` muss **nicht** 0° sein: Der Unterschied enthält die lokale Referenzrichtung der Grafik. Ebenso war das zuvor angezeigte `Error: 0` mathematisch tautologisch und kein unabhängiger Beweis für optische Passung.
- Das vorübergehende Erzwingen von `SetSpriteAngle()` vor dem Zeichnen brachte keine überzeugende Abhilfe. Die bestehende Sprite-Cache-Optimierung sollte erhalten bleiben.
- Die Fehlersuche verlief von alten ±90°-/±45°-Winkelannahmen und gleich langen 31-px-Beinen über den Vergleich von Knie- und Fußpunkten bis zur gemeinsamen Proto/IK-Transformation und schließlich zur korrekten Corpus-Anbindung. Die funktionierenden Zwischenstände sind über Git-Commits nachvollziehbar. Die Originalgrafiken und manuell ermittelten Proto-Anker sollten nicht aufgrund eines bloß visuellen Verdachts pauschal verändert werden.

#### Gangsteuerung und aktueller Teststand (14. November 2026)

- `WALKER_STAND_POSE_TEST = 0`: normale Laufbewegung aktiv. Die Standpose mit festen Fußzielen bleibt als zuschaltbarer Diagnosemodus erhalten.
- `WalkerSkeletonUpdate()` hält den Standfuß während seiner Standphase auf einer **plattformrelativen X-Position**; der Schwungfuß wird angehoben, nach vorne geführt und wieder abgesetzt. Beide Füße besitzen getrennte Ausgangsversätze (−10 und +10 px). Die Schrittlänge wurde auf die tatsächliche Reichweite der unterschiedlich langen IK-Knochen abgestimmt (180° Schrittphase pro 15 px Körperweg; `WALKER_GAIT_DEGREES_PER_PIXEL 12.0`).
- Beim Anhalten nähern sich beide Füße über einen zeitabhängigen Übergang ihrer jeweiligen Standposition. An der Plattformkante hält `TurnPending` die bisherige Blickrichtung fest, bis beide Füße wieder unter dem Körper stehen; erst danach erfolgt der Richtungswechsel.
- Die anfänglich zufällige horizontale Geschwindigkeit `random(35,100)*0.001` wurde für vergleichbare Tests durch eine **einheitliche Geschwindigkeit von `0.05`** ersetzt (Commit `20b2d7d`). Der Schrittrhythmus bleibt an den zurückgelegten Weg gekoppelt.
- `WALKER_FOOT_JOINT_LIFT = 8.0` hebt dieselben Gelenkziele in `WalkerIKBindSprites()` und `WalkerSkeletonDraw()` an. Der ursprüngliche Testwert 7 px ließ die Sohle im Screenshot etwa ein Pixel zu tief erscheinen. Eine zusätzlich beobachtete mögliche allgemeine 1-px-Visualisierungsabweichung bei Plattformen, Kisten und Sonec ist noch getrennt zu untersuchen. Die frühere `Floor()`-Rundung in `SpriteDraw()` wurde in `fb45a28` entfernt; das garantiert keine ruckelfreie Pixelrasterdarstellung.
- Die früheren konstanten Anzeigen-Schalter `WALKER_SKELETON_DEBUG`, `WALKER_PROTO_POINTS_DEBUG` und `WALKER_ANGLE_DEBUG` wurden mit Commit `7b8ce8d` durch den **Laufzeit-Schalter `WalkerDebugEnabled`** ersetzt. Dieser startet deaktiviert und wird unter Windows mit `F1` (`GetKeyPressed(KEY_F1)` in `main.agc`, auch bei Pause) umgeschaltet. Der Schalter betrifft IK-Skelettlinien, Proto-Offset-/Anchor-Punkte, Winkeltext und die Turm-/Mündungsmarker. `WALKER_IK_SPRITES = 1` und `WALKER_STAND_POSE_TEST = 0` bleiben unverändert; F1 verändert weder Gangmechanik noch Standpose-Diagnosebetrieb.
- Die Debug-Sprites und der Text werden in `WalkerSkeletonInit()` einmalig angelegt. Der über F1 steuerbare, oben rechts am Bildrand verankerte Diagnoseblock (`3833668`, `202a045`) zeigt für bis zu drei aktive Walker getrennt IK-Winkel, `Pivot`, `Bullet`, `Flash`, `Barrel0/1`, Schusswinkel und `FireState` (weitere Walker werden gezählt). Magenta markiert den Tower-Pivot, gelb (11 × 11 px) den Bullet-/Flash-Start, blau/orange die beiden derzeit überlagerten Barrel-Anchors. Die Marker werden nach den Effekten gezeichnet. **F1, Anzeige und beide Seiten wurden vom Entwickler lokal mit Screenshots geprüft; HTML5-Bedienung und alle Randfälle sind nicht getestet.**

**Getestetes Ergebnis:** Mehrere kurze Videos mit und ohne Debug-Skelett zeigen nachvollziehbare Schritte, eine stabile Verbindung von Beinen, Corpus und Turm sowie einen plausiblen Richtungswechsel. Der Entwickler akzeptiert die aktuelle Gangmechanik für die erste Alpha. Die bestehende richtungsabhängige ±90°-Fußwinkelkorrektur bleibt ein dokumentierter Implementierungsdetailpunkt, soll aber **nicht ohne konkreten visuellen Fehler** erneut verändert werden.

**Nicht Alpha-blockierendes grafisches Polishing (später):** Ggf. Oberschenkel-/Unterschenkel-Silhouetten etwas schlanker gestalten und punktuelle Gelenk-, Kontur- oder Lichtdetails in den Sprites ergänzen. Die aktuelle kräftige Beinoptik bleibt zunächst erhalten. Änderungen der Grafik erfordern eine erneute Prüfung der handgesetzten Proto-Offsets und -Anchors, falls die Bildgeometrie verändert wird. Ein Werkzeug wie Spriter bleibt für komplexe Spezialanimationen optional; das prozedurale Skelett ist derzeit die Referenz.

**Waffentest, lokal bestätigt (14. November 2026):** Einfache horizontale Walker-Schüsse über `BulletAdd()` mit `TYPEENEMY` erscheinen nach Sichtprüfung an einer plausiblen Turmmündungsposition und verursachen bei Sonec Schaden. Feindliche Geschosse treffen derzeit auch Kisten; ob dies eine endgültige Spielregel wird, ist offen. Walker selbst nehmen über `BulletCollideWalkers()` nur Spieler-Geschosse (`TYPEPLAYERONE`) an; Orbs werden über `BulletCollideOrbs()` ebenfalls nur durch `TYPEPLAYERONE` getroffen, um die Fairness für Spieler und KI zu erhalten.

**Neu implementiert und teilweise lokal getestet:** Der Walker beginnt eine Zwei-Schuss-Salve nur in einer regulären Standpause und erst dann, wenn beide Füße ihre neutrale Standpose erreicht haben. `TWalker.FireState` (0 = frei, 1 = zweiter Schuss ausstehend, 2 = Erholung) und `FireStateUntilMs` steuern 150 ms Schussabstand und eine 200-ms-Abschlussphase. `WalkerMove()` blockiert das Wiederanlaufen, solange der Feuerzustand aktiv ist, auch wenn die normale Pause bereits endete. Die Plattformbewegung bleibt davon unabhängig. `WALKER_FIRE_INTERVAL_MS = 1800` begrenzt den Beginn weiterer Salven. **Der Entwickler hat den Salvenrhythmus lokal als gut bewertet; die gesamte Übergangslogik bleibt noch gezielt zu testen.** Rückstoß, diagonale Schüsse und Zielverfolgung sind nicht implementiert.

**Walker-Waffenstand, aktualisiert am 15. November 2026:** `WalkerFireShot()` erzeugt horizontal (90° rechts / 270° links) eine Zwei-Schuss-Salve über `BulletAdd(...,TYPEENEMY,...)` und `FlashAdd(...,FlashType=0,...)`. Beide starten seit Commit `48ce0dd` am **gleichen Weltpunkt `Walker.WalkerObjectData.Barrel[0].AnchorPosition`** mit zusätzlichem Radius 0. Der ältere symmetrische Bullet-Start `Tower.Position.x ± 30` ist **historisch und nicht mehr aktiv**. Flash-Effekte werden nach Walker und Bullet gezeichnet; der bestehende Sonec-Effekt-Pool wird weiterverwendet. Die optische Ausrichtung beider Richtungen und die Größenrelation Sonec/Walker wurden vom Entwickler anhand lokaler Screenshots als passend bewertet, jedoch nicht unter sämtlichen Spielbedingungen untersucht.

**Barrel-Kalibrierung (`source/sonec/media/data/protowalker.json`):** Die Rohre sind 2 × 40 px groß, beide besitzen nach der lokalen Prüfung `Offset.x = Anchor.x = 1`; rechts gilt `Offset.y=35, Anchor.y=-6` (Commit `b5cc35b`), links `Offset.y=35, Anchor.y=-8` (geänderte X-Werte in `7047fba`). `WalkerBodyPartAttach()` dreht die lokale Differenz `Anchor - Offset` um ±90°. Links wurde die Rohrgrafik dadurch um 2 virtuelle Pixel zur korrekten Höhe ausgerichtet, ohne den Welt-Ankerabstand zu verändern. Bei gleicher Position aller Mündungen zeigen sich die farbigen F1-Marker verschachtelt. Eine spätere echte Trennung der zwei grafisch derzeit überlagerten Kanonen erfordert erneute Mündungsprüfung.

**Bewegter Walker und Flash-Pool:** Seit den Folge-Commits `36072dd`, `47cc3d4`, `b1ae159`, `134e6ac` verwaltet `TFlash.AttachedWalkerIndex` die Zuordnung der Effektinstanz zu einem Walker. Ungebundene Effekte erhalten bei `FlashNew()` den Wert -1; Sonecs `FlashRefresh()` aktualisiert nur ungebundene Effekte. `WalkerFlashFollowAll()` führt aktive Walker-Flashes **nach Plattform- und Walker-Bewegung** der aktuellen Barrel-Position nach. Flash-Größe/Lebenszeit, Bullet-Flugbahn und die Zwei-Schuss-Salve wurden dabei nicht absichtlich geändert. Die letzte lokale Sichtprüfung war unauffällig; eine gezielte Belastungsprüfung mit mehreren Walkern/Flash-Slots auf vertikal bewegten Plattformen bleibt sinnvoll.

**Sonec als eigenständige Referenz:** `SonecMGunInput()` verwendet einen Radius von 25 virtuellen px für die Bullet und 33 px für den Flash-Mittelpunkt, mithin 8 px Abstand zwischen diesen Ursprüngen. Sonecs Standbild ist 50 × 50 px, der `flash.png`-Sprite 10 × 12 px. Durch die zentrierte, animiert skalierte Flamme ist der sichtbare Abstand zur Grafik kleiner und zeitabhängig. Sonecs Flash wird durch `SonecRefreshAnimations()` nach der Spielbewegung erneut positioniert. Ein zuvor gelegentlich berichteter Versatz während des Fallens ist **noch kein bestätigter, reproduzierter Fehler**.

**Float-/Sprite-Zeichenpfad:** Seit `fb45a28` geben `SetSpritePositionByOffset()` und `SetSpritePosition()` die Float-Position ohne `Floor()` weiter. In `sprite.agc` werden seit `96dccfd` die halbierten Abmessungen mit `*0.5` statt `/2` bestimmt und die skalierten Offsets in jedem Zeichendurchlauf konsequent gesetzt. **Wichtiger AGK-Praxisbefund des Entwicklers:** `/` ergab in eigenen AGK-Tests unerwartet Integer-Ergebnisse; für benötigte Nachkommagenauigkeit daher `*0.5` oder explizit Float-Operationen (z. B. `*1.0`) bevorzugen. AGK-Dokumentationsvarianten gelten nicht als gleichwertiger Beleg für dieses konkrete Laufzeitverhalten. Eine umfassende Prüfung aller Divisionen und die Randfälle der Darstellung bleiben offen. Die Fenstergröße beträgt 1350 × 675, virtuelle Auflösung 900 × 450; Skalierungsfaktor in beiden Achsen **1,5**, nicht 2.

**Neue Beobachtungen (15. November 2026):** Die Kiste zeigt laut Entwickler an der Plattformauflage wieder die dunkle Kantenlinie – eine positive visuelle Beobachtung, kein pauschaler Kollisionsnachweis. Einige nach links laufende Plattformen ruckeln gelegentlich. `PlateMove()` verwendet `MoveSpeed.x * MoveTimer.CalcRange` bei einem 10-ms-Timer; das kann zu unregelmäßig sichtbaren Schritten führen, ist aber **als Ursache noch nicht gemessen**. Ebenso ist eine Subpixel-/Pixelrasterwirkung denkbar. **Instrumentierung jetzt implementiert (Commits `56df895`, `58f20d5`, `bf6ecf5`):** `TPlate` enthält ausschließlich für die Diagnose `DebugDeltaX`, `DebugDeltaY`, `DebugCalcRange`, `DebugElapsedMs`, `DebugUpdated`. `PlateMove()` setzt diese Werte zu Beginn jedes Aufrufs zurück und zeichnet nach einem echten Timer-Schritt den berechneten Positionsunterschied auf; bei ausgelassenem Schritt ist `DebugUpdated=0` und `dX/dY=0`. Die ursprünglichen Bewegungs- und Zeitformeln bleiben unangetastet. Die Windows-F1-Anzeige zeigt **unten rechts** bis zu drei sichtbare Plattformen samt Index `P#`, X/Y-Weltposition, delta-X/delta-Y, `CalcRange`, vergangener Zeit `dt` und Step-Flag. Zusätzliche sichtbare Plattformen werden gezählt. **Statische Codeprüfung erfolgt, ein AGK-Laufzeit-/Screenshot-Test dieser neuen Plattformanzeige steht noch aus.** Zuerst Daten erfassen, erst danach eine ursächliche Änderung erwägen.

**Künftige Effekte und Sound:** Der derzeit aus `SonecMGunInput()` ausgelöste `SoundPlay(Sound.MGunSound)` ist noch nicht für Walker generalisiert. Eine gemeinsame Schuss-/Effektroutine wäre zu prüfen; `FlashNew()` selbst ist nicht zwingend der richtige Ort für Sound, da Flashes auch als rein visuelle Effekte dienen können. Für spätere getrennte Kanonen ist abwechselnder Rückstoß samt farblich unterscheidbarer Rohrspitzen geplant; dabei kann sich die dargestellte Rohrhöhe und damit der Mündungs-Referenzpunkt ändern.

**Später:** Zielwahl, Fairness- und Schwierigkeitsbewertung, Kisten als Umkehrhindernis, zusätzliche Corpus-/Turm-Neigung, ggf. separate Corpus-Trefferzone sowie Feinausrichtung und Dauer des bereits integrierten `FlashAdd()`-Mündungsfeuers. Die funktionierende Bein-IK bleibt unangetastet.

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
| Plattformen und Minen | Plattformbewegung mit `CalcRange`, optional vertikal; zufälliges Ruckeln nach links beobachtet | Plattformruckeln lokal berichtet, Ursache und Messungen offen; Minenprüfung ausstehend |
| Kisten und Orbs | Module vorhanden; Belohnungsmechanik ungeklärt | Ausstehend |
| Walker-Erzeugung | Aktiv in Spielschleife | Vom Entwickler lokal bestätigt |
| Walker-Bewegung/Animation | Zweiknochen-IK, getrennte Fußziele, Stand-/Schwungbein, sanfte Standrückkehr, `TurnPending` und 8-px-Fußhöhe; rechts verankerte F1-Diagnose unter Windows | Stand, Gang, Wende sowie F1-Darstellung lokal bewertet; HTML5-/Randfalltests ausstehend |
| Walker-Kampfsystem | Horizontaler `TYPEENEMY`-Schuss, Zwei-Schuss-Salve, Barrel-Anchor als gemeinsamer Start für Bullet und Flash, Flash-Nachführung auf bewegten Plattformen; Orb-Kollision nur durch Spieler-Bullets | Schussschaden, Salventempo und optische Mündungsposition links/rechts lokal plausibel; Übergangslogik, Extremfälle und Orb-Schutz weiter zu prüfen |
| HTML5-Steuerung | Index-1-Workaround auf develop umgesetzt; ungetestet | Ausstehend |
| Kollisionen | Primitive/Box-Prüfungen; Schild-Shape-Prototyp mit Vergleichszählern | Schild-Shape-Test lokal durchgeführt; nicht für Schaden aktiv |

„Vorhanden“ bedeutet nicht „fertig“ oder „fehlerfrei“.

## 10. Nächste Untersuchungen

1. **Jetzt:** Neu eingecheckte F1-Plattformdiagnose **lokal kompilieren und testen**; bei links ruckelnder Plattform `P#`, X/Y, dX/dY, `CalcRange`, `dt` und Step-Flag im Screenshot notieren und mit einer ruhig fahrenden vergleichen. Keine Physikänderung ohne Messung.
2. Danach weitere lokale Tests der Walker-Salve, des Flash-Folgens bei vertikal bewegten Plattformen, der Schuss-/Trefferregeln und möglicher Projektil-Tunnelung.
3. Zeitsystem, Pause, Bildratenabhängigkeit, Sonec-Bewegung und Float-Divisionen gezielt untersuchen.
4. HTML5-Build und Gamepad-/Tastatursteuerung praktisch testen.
5. Schild-Shape-Kollision, Kisten/Orbs/Upgrades und Alpha-Punktesystem danach priorisieren; Sound-Entkopplung, diagonale Walker-Schüsse, Zielverhalten und Doppelrohr-Polishing später.

Die Punkte sind Untersuchungsaufgaben, keine Änderungsfreigaben. Es werden keine Codeänderungen ohne ausdrückliche Zustimmung vorgenommen.

## 11. Quellen und Gültigkeit

Statisch erneut gesichtet auf `develop` bis Commit `48ce0dd` (15. November 2026), mit den Aktualisierungen `3833668`, `202a045`, `b5cc35b`, `36072dd`–`134e6ac`, `96dccfd` und `7047fba`; ergänzt durch lokale Screenshots und Tests des Entwicklers. Ein eigener AGK-Build des Assistenten und HTML5-Tests stehen aus: `main.agc`, `game.agc`, `def_game.agc`, `sonec.agc`, `walker.agc`, `mine.agc`, `plate.agc`, `controls.agc`, `def_joypad.agc`, `world.agc`, `collision.agc`, `sound.agc`.

Der Vergleich mit Crystal Columns/Crystals erfolgte anhand von `main.agc`, `def_joypad.agc`, `input.agc`, `controls.agc`, `timer.agc` und `highscore_online.agc` auf `main`. Angaben zur praktischen Tastaturbedienung und zu Upgrade-Belohnungen bleiben noch zu verifizieren. Die vorhandene PurpleToken-Online-Highscore-Integration in Crystals wurde im Quellcode bestätigt, aber nicht auf Erreichbarkeit getestet.

## 12. Übergabe bei Chatlimit oder neuem Chat

**Verlässlicher Startpunkt:** GitHub-Repository `ChristianEngel19820128/SonecBot`, Branch `develop`. Zuerst `AGENTS.md`, `PROJECT.md`, `TECHNICAL.md` und `TODO.md` lesen, anschließend den tatsächlichen Branch-HEAD und die betroffenen AGK-/JSON-Dateien **neu abfragen**. Dokumente können gegenüber neueren Commits veralten; immer Code und dokumentierten Teststatus abgleichen. Der Code-Stand dieser Bestandsaufnahme ist **`bf6ecf5`** (Plattformdiagnose implementiert, noch nicht lokal getestet); bitte stets den echten aktuellen Branch-HEAD prüfen.

**Bisherige lokale Freigaben:** Walker-Gangbild alpha-tauglich bewertet, horizontaler Zwei-Schuss-Test plausibel, linke/rechte Mündungsoptik inklusive identischem Bullet-/Flash-Start am ersten Barrel-Anchor für den aktuellen Teststand passend. Der rechts positionierte F1-Diagnoseblock funktioniert laut Entwickler; Sonec/Walker-Größenrelation und Kistenauflage wirken gut. Einzelne fehlende Randfalltests nicht als abgeschlossen ausgeben.

**Sofort offener Punkt:** Gelegentliches Plattformruckeln **beim Bewegen nach links**. Die erste F1-Plattformdiagnose ist bis Commit `bf6ecf5` implementiert, **lokales Kompilieren und Testen steht aus**. Danach anhand von echten Delta-/Timerdaten Ursachen eingrenzen. Nicht gleichzeitig Timings oder Geschwindigkeiten verändern. Außerdem offen: Langzeit-/HTML5-Test, volle Salven-Zustandsübergänge, Trefferregeln, eventuelle Flash-Skalierungsartefakte und Float-Divisionen außerhalb der reparierten `sprite.agc`.

**Zusammenarbeitsregeln:** Aktive Änderungen nur nach Freigabe auf `develop`, kleine nachvollziehbare Commits, keine Eingriffe in `main` oder `source/legacy/`, keine eigenmächtige Anpassung der laufenden IK/Schussgeometrie. Der Entwickler übernimmt AGK-Kompilierung und visuelle Tests; der Assistent kann Code auf GitHub statisch prüfen. Übliche kleine Commit-/Testschritte dauern nach Angabe des Entwicklers etwa **5–20 Minuten**, abhängig vom Problem. Bei Chatwechsel nicht auf automatische Kontextübernahme vertrauen: Diese Dokumente plus GitHub-HEAD sind die gemeinsame, wiederlesbare Übergabe. Keine Behauptungen über eine garantiert automatische Chat-Übergabe.

**Empfohlener neuer Chat-Einstieg:** „Bitte lies `AGENTS.md`, `PROJECT.md`, `TECHNICAL.md` und `TODO.md` aus `ChristianEngel19820128/SonecBot` auf `develop`; prüfe den aktuellen HEAD und den neuesten dokumentierten Prüfstand. Wir arbeiten nach den Projektregeln weiter und untersuchen derzeit das Plattformruckeln mithilfe der F1-Diagnose. Ändere nichts ohne mein Okay.“
