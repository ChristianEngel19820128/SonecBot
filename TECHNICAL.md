# SonecBot – Technische Dokumentation

**Dokumentstatus:** Technische Referenz mit eingeordneten historischen Testnotizen  
**Stand:** 20. November 2026  
**Branch:** `develop`  
**Historische lokal akzeptierte Walker-Code-Referenz:** [`18f92a965810763b552bd96649607c112f966238`](https://github.com/ChristianEngel19820128/SonecBot/commit/18f92a965810763b552bd96649607c112f966238)  
**Status:** **Alpha-Walker abgeschlossen; HTML5-Pre-Alpha im itch.io-Draft eingebettet und laut Entwickler erfolgreich smoke-getestet.**

> Aktueller Wiedereinstieg: [HANDOFF.md](HANDOFF.md); Releaseplanung: [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md). Dieses Dokument enthält technische Referenzwerte und ausdrücklich datierte historische Notizen. Nur aufgabenrelevante Abschnitte lesen. Historische „Test offen“-/„nächster Schritt“-Angaben sind keine aktuellen Arbeitsaufträge. Ältere Stände bleiben in Git nachvollziehbar.

## 1. Abschluss und Evidenz

Der Entwickler bestätigt nach dem letzten 3-px-Turmrückstoß: **„test bestanden. funktioniert alles wie erwartet.“** Die Aufgabe Alpha-Walker ist ausdrücklich abgeschlossen. Grafikproportionen/Animationen, Gesamtgefühl und Beinbewegung wurden lokal positiv bis optimal bewertet. Referenzvideo ca. 10.18 s, 1342×698, nominell 33 FPS Aufnahme; anhand extrahierter Frames optisch beurteilt.

Der Assistent hat Quellcode statisch geprüft, geometrische Modelle berechnet und einzelne tatsächliche AGK-Funktionskörper in eine Prüfumgebung übersetzt. **Kein eigener AGK-Compile/-Lauf, kein HTML5-/Browserlauf und keine Veröffentlichung.** Abschlusstest des Entwicklers ist nicht mit einer lückenlosen Plattform-/Randfallregression gleichzusetzen. Für den Release keine neue Walker-/IK-Politur ohne konkreten Auftrag oder nachgewiesenen Blocker.

## 2. Architektur und Hauptschleife

Aktiver AGK-Code: `source/sonec/`; historische BlitzBasic-Quellen: `source/legacy/` (nicht bearbeiten).

| Datei | Zuständigkeit |
| --- | --- |
| main.agc | Einstieg, Fenster/virtuelle Auflösung, Sync, Intro/Spiel/Pause, Windowsdiagnosen |
| game.agc | Prototypen/Pools, Initialisierung, Eingabe, Update und Draw-Reihenfolge |
| def_game.agc | Gemeinsame Typen, Objekt-/Sprite-/Kollisionsdaten, Walker-/Flash-Zusatzfelder |
| sonec.agc | Spielfigur, Waffen, Ressourcen, Bewegung und objektspezifische Kollision |
| walker.agc | Alpha-Walker: Spawn, Bewegung/IK, Ziel-/Salvenlogik, Pose, Rückstoß, Darstellung |
| controls.agc / def_joypad.agc | Eingabehelfer und Joystick-Auswahl |
| timer.agc | Eigene Zeit-/Timerhilfen; nicht mit AGK-Physik gleichsetzen |
| sprite.agc | Geteilte Protosprites, SpriteData/Offsets und Zeichenpfad |
| plate.agc / chest.agc / orb.agc / mine.agc | Plattformen, Kisten, Orbs und Minen |
| bullet.agc / flame.agc / explosion.agc | Projektile, Flammen und Explosionsschaden |
| flash.agc | Gemeinsamer Mündungs-/Effektpool, Lebenszyklus und Zuordnung |
| shield.agc / energie.agc / inenergie.agc / gui.agc | Schild, Ressourcen, Energieaufnahme, HUD |
| world.agc / background.agc / tower.agc / cloud.agc | Welt, Hintergrund, Hochhäuser und Wolken |
| intro.agc / sound.agc | Intro/Menü und Sound |

Virtuelle Auflösung aktuell **900×450**, Windows-Fenster 1350×675. main.agc führt eine pausierbare virtuelle Zeit CurrentNow getrennt von der realen Millisekundenzeit. Während aktiver Pause werden Spielupdate/-eingabe ausgesetzt, Darstellung bleibt erhalten. GameInit setzt Pause/Lost zurück und initialisiert die Spielobjektpools. Tod und mehrfacher Neustart wurden vom Entwickler im lokalen HTML5-Browser bestätigt; Neustart auch im Draft-Embed. Langzeit-/Geräteabdeckung und exakter Export-SHA sind damit nicht vollständig belegt.

Objektverwaltung und Kollisionen bestehen weitgehend aus eigenen Strukturen/Pools und Kreis-/AABB-Hilfen. Keine pauschale Umstellung auf native Sprite-Physik beschlossen. Einzelne Sonec-Bewegungs-/Ereignispfade können noch bildratenabhängig sein; keine globale Zeit-/Physikänderung vor Veröffentlichung ohne konkreten Befund.


## Sonec-Treffergeometrie: verbindlicher Wiederverwendungsweg (S1–S4)

**Für neue gegnerische Angriffe keine eigene Sonec-Mittelpunkt-/Radius-Hitbox nachbauen.** Stattdessen die zentralen Funktionen in `source/sonec/sonec.agc` verwenden:

- `SonecHitCircleRadius(Sonec)`: gemeinsamer Radius der zwei Körperkreise, berücksichtigt Ducken.
- `SonecHitCircleY(Sonec,0)` und `SonecHitCircleY(Sonec,1)`: Y-Mittelpunkte der beiden Kreise; X-Mittelpunkt ist `Sonec.ObjectData.Position.x`.
- Bei neuen Schadensquellen **beide** Kreise prüfen und die Schadensauslösung pro Quelle/Ereignis zusammenfassen; ein Treffer beider Kreise darf nicht doppelt schaden. Für bewegte schnelle Projektile die Bewegungsstrecke (Sweep) berücksichtigen, nicht nur die Endposition.
- `drone.agc` / `DroneLaserDetectHit` verwendet seit S5 dieselbe Geometrie; die horizontale Laser-Sweep-Prüfung (einschließlich Sprite-Länge), die Einmal-Trefferbehandlung und die Schildlogik bleiben bestehen. **S5 vom Entwickler lokal 7/7 bestanden (22.11.2026).**
- Den Quellradius und die jeweilige Treffersemantik bewusst beibehalten: `bullet.agc` prüft Sweep, `bomber.agc` Bomben-Sweep mit Bombenradius, `mine.agc` Kreisüberlappung mit Minenradius; `explosion.agc` prüft die beiden Kreismittelpunkte gegen den Explosionsradius **ohne Addition des Sonec-Kreisradius**.
- Bei Explosionen `ExplosionDamageAllowed` **zusätzlich** aufrufen: Der Plattformschutz wird derzeit absichtlich mit `Sonec.ObjectData.Position` (bisherigem Körperzentrum) bewertet, damit der obere Kreis die Abschirmung nicht umgeht. Nicht ohne separaten Auftrag und gezielten Plattformtest ändern.
- Schild, Schadenstakt, Trefferfeedback, Rewards und Explosionserzeugung sind eigene Abläufe; nicht bei einer neuen Kollisionsquelle stillschweigend verändern. Die Taste-3-Kreisfärbung ist aktuell nur für Gegnergeschosse angeschlossen, nicht automatisch für Bomben/Minen/Explosionen.

**Evidenz:** Entwickler hat S1/S1b, S2 (7/7), S3 (7/7) und S4 (8/8) lokal bestanden gemeldet, einschließlich Plattformabschirmung direkt darunter und Treffer außerhalb der Plattformkanten. Kein eigener AGK-Compile durch den Assistenten. Bei neuen Gegnern oder Schadensarten diese Schnittstellen zuerst prüfen und die neuen Trefferfälle lokal testen.

### Sonec-Bewegung: Kisten-Seitenkontakt (Phase C, AGK-Compile bestanden)

- Zentraler Sweep/Resolver in `sonec.agc`: frühester gültiger Kontakt, danach Restweg gegen interpolierte Hindernispositionen. `LinkedPlateIndex` bleibt bei Sprung/Fall/Flug erhalten (ungültiger gelöschter Eintrag -1); Wechsel nur bei Landung. Phase E: `TPlate.SonecDepthState` je Plattform unabhängig, bei Spawn zurückgesetzt. Fremde Plattform samt allen Kisten in Passage bis Füße oberhalb höchster aktiver Kiste (ohne Kisten: Plattformoberkante). Freigabe im zeitlichen Resolver; fremde Seiten am Boden irrelevant, in ungestützter Bewegung nach Freigabe relevant. Fremde neutrale Oberseiten bleiben landbar; bisherige Einzelkisten-Unterseiten-Ausnahme nur eigene Ebene. Keine Jetpack-Sonderrelevanz. G1 ergänzt die bestehende `sonec_edge_diagnostics.csv` um `normal_jump`, `air_thrust_direction`, `top_contact_trace` für nahe tatsächliche Fußkreuzungen inklusive gefilterter Kandidaten (Schema in Bewegungsspezifikation); keine Regeländerung. 22 übersetzte Zustands-/Zeitrechenfälle; Entwicklertest `f2acaae` 9/9 bestanden. Situationsabhängig unfaire Übernahme und möglicherweise nicht aktualisierte vertikale Plattformbewegung als offene Beobachtungen dokumentiert. Y-Snapshots und aktuelle Trägeroberfläche werden quellsichtlich berücksichtigt; Entwickler meint Übernahmeberechtigung vertikal bewegter Fremdplattform. Passage bleibt im Höhenband zwischen Oberkante und höchster Kiste gespeichert, auch bei veränderter Höhe; tatsächliche Ursache im Spiel offen. Siehe Bewegungsspezifikation.
- Mechanische Bodenfront: `SONEC_MECHANICAL_FRONT_X=25` Welteinheiten beidseitig, volle Körperhöhe. Vorläufiger Abstand entspricht MG-Geschossstart; optisch lokal abgleichen. In der Luft weiterhin die zwei vorhandenen Körperkreise; Schadensgeometrie unverändert.
- Seitenreaktion berücksichtigt Restweg der Wand; keine Korrektur auf eine neue Frontposition bei schon vorhandener Überlappung. Nur eigene Bewegung in die Wand wird gelöscht; Gegenlenken bleibt frei. Kein separater Vorab-Wandstop; `BlockedChest*` dokumentiert den Kontakt im aktuellen Update und unterstützt die Weltrand-Ausnahme.
- Weltgrenze links wird eingehalten, dort kann die nach links fahrende Kiste passieren. Phase-D-Testmodell: `SonecPrepareSupportPath` addiert das tatsächliche Träger-X-Delta; `AutoSpeed` ist signierte Trägergeschwindigkeit in Einheiten des letzten Sonec-Timerschritts, `MoveSpeed` am Boden relativ und in der Luft Weltgeschwindigkeit. Übergänge rechnen einmal um, Seitenreaktion begrenzt relative Wandgeschwindigkeit. Balanceziel folgt dem Träger; Grenzen nach kombinierter Bewegung. Phase F: Hop nur bei gewähltem Kisten-Support-Exit, Richtung aus relativer Kante; vertikaler Impuls 1,5, relative X-Mindestgeschwindigkeit 1,0 als vorläufiger Testwert. Kein Eingabe-/Geschwindigkeits-Gate, keine Frame-End-Vorauslösung. Trägergeschwindigkeit einmalig übertragen, nur Impulsänderung auf Restweg anwenden, Weltgrenzen berücksichtigen. Plattformkanten ohne Hop. G1: `NormalJumpActive` erhält horizontalen Schwung des normalen Sprungs, `AirThrustDirection` trennt Energie-Schub von Rückstoß/Move-Flag; aktiver Luftschub vorläufig ±5, stärkeres vorhandenes Momentum bleibt; Fly-Y nur aufwärts begrenzt, Fall durch Schub kontinuierlich gebremst. 22 übersetzte Rechenfälle; G1-Entwicklertest `093c173` technisch 9/9 bestätigt, normale Sprünge laut Freitext nicht gezielt prüfbar. G2-Nacharbeitsplan in Bewegungsspezifikation §13. G2c (25.11.2026): `SONEC_FOOT_HALF_X=8.0` (bei schmalen Flächen höchstens 45% der Breite), `SONEC_GROUND_CLEARANCE_STEP_X=1.0` je Kollisionsframe, `SONEC_DEPTH_RELEVANCE_X=100.0` (Distanz Mittelpunkt zu nächster Kistenkante). Kistenoberseiten akzeptieren Fußüberdeckung; stabiler Supportbereich um Fußabstand eingerückt, Randlandung bei relativem Weg nach innen/Stillstand Balance, nach außen einmaliger Hop am gewählten Top-Ereignis. Relativer Restweg entscheidend, bei Weg null Richtung aus relativer Geschwindigkeit; kein Hop auf Plattform, Plattformlandung nur im stabilen Fußbereich. Ausgleichsschritt bleibt durch bewusste Eingabe abbrechbar, kein zusätzlicher dauerhafter Impuls; normale langsame Randbalance bleibt. Boden-/Luftfrontlinie für direkte Seiten, Luftkern zwischen Kreiszentren, bisherige Kreise für Ecken und Unterseiten; frühere Eckkontakte haben Vorrang vor späterer Linie. Schadensgeometrie unverändert. Seitliche Kreisreaktion benötigt weiterhin relative horizontale Annäherung; senkrechter Streifkontakt ohne Fußüberdeckung erzeugt keinen neuen künstlichen Seitenimpuls. Begrenzte Bodenabstandskorrektur vor nächstem Sweep, nur bei Mittelpunkt außerhalb der Kistenflanke; verhindert tieferen Eintritt, keine künstliche Geschwindigkeit, Weltrand-Ausnahme erhalten. `SonecDepthRefresh` nutzt tatsächliche horizontale Körperüberdeckung der interpolierten Plattform; lokale Höhe am jeweiligen X/FrameTime. Passage bleibt im überlappten Höhenband bis lokale Freigabe; außerhalb neutral bzw. freigegeben bei ausreichender Höhe. Nichtmechanische Ereignisse Kind 5 lokale Höhen-/Reichweitenfreigabe, Kind 6 vollständiger horizontaler Ebenenaustritt im freien Flug/Fall; neue Bindung nur bei gültigem Top-Kontakt. Vorhandene CSV-Struktur bleibt, HighestY nun lokal. 52 übersetzte Geometrie-/Zustandsfälle, 30 statische Prüfungen einschließlich 24 unveränderter Hilfsfunktionen. Entwicklertest `d87a2f615468e49d8ee558e0e22ffed7eb4db8c3` (25.11.2026) 13/13 bestanden: AGK-Compile, Kisten-/Plattformkanten, Randlandungen nach innen/außen/Stillstand, Seitenlinie und Eckkontakte/Abstandskorrektur, horizontale Ebenenlösung, entfernte hohe Kisten, vertikal bewegte Plattformen, Fremdplattform-Durchflug, Sprung/Jetpack/Rückstoß/Mitnahme. Keine offenen Prüfpunkte. Performance und CSV nicht separat rückgemeldet; Parameter vorläufig. Entwicklerbeobachtungen (25.11.2026): Sprung aus dem Stand direkt vor einer Kiste erlaubt keine Landung auf ihr; kleine horizontale Sprungkorrekturen gewünscht. Sprunghöhe zu hoch. Jetpack im freien Flug/Fall ohne Verzögerung, Haltezeit nur beim normalen Sprung gewünscht (genaue Regel für erneuten Druck im Sprung noch abstimmen). Flugbeschleunigung halbieren gewünscht (horizontal/vertikal bzw. Netto-/Bruttoschub noch präzisieren). Seit Einführung des Sprungs mehr Energie übrig, häufige Overload-Tode; Gegnerwelt sehr gefährlich, Drohne vergleichsweise harmlos. Steuerungsänderungen vor lokalem G2d-Balancing gemeinsam abstimmen, keine erneute Änderung der bestätigten G2c-Kollisionsregeln. Energie-/Gegnerbalancing separat; keine Parameteränderung durch Testbericht. G2b (25.11.2026): `SONEC_JETPACK_HOLD_MS=180`, `SONEC_JUMP_MIN_RELATIVE_X=0.0` (aus), `SONEC_GRENADE_RECOIL_X=1.0` in zentralem Balancingblock. `SonecTrackUpInput` erfasst kombinierte konfigurierbare Up-Aktion/Joystick-Y je aktivem Spielframe (inkl. Press-Flanke) mit virtueller Spielzeit; neuer Druck bei tatsächlichem Support löst unabhängig von Energie sofort normalen Sprung aus. `SonecInputVerticalState` aktiviert Jetpack erst nach Haltezeit und konsumiertem Sprungimpuls, Energiekosten/Schwellen und bisheriger getakteter Jetfire-Pfad unverändert. Loslassen beendet Schub sofort, erneutes Drücken startet Zeit neu; gehaltenes Up nach Landung erzeugt keinen neuen Sprung, darf bei erfüllter Zeit/Energie erneut Jetpack aktivieren. Energieaufnahme während Halten bleibt wirksam. Kein neuer Key-Binding. Optionaler horizontaler Mindestwert nur bei eindeutiger Richtung und gleichgerichtetem oder null relativem Schwung vor Trägerübernahme, niemals gegen vorhandenen Schwung; beide Richtungen zusammen keine Hilfe; 0 deaktiviert. Rückstoß genau einmal additiv entgegen Blick-/Schussrichtung in bestehende X-Geschwindigkeit, Richtungsumkehr zulässig, Eingabe-/Supportflags unverändert; aktive Randbalance bei Impuls beendet. Boden-Laufmaximum begrenzt nun analog Luft nur hinzugefügte Beschleunigung, damit Rückstoßüberschuss nicht sofort abgeschnitten wird. Passive Bremsung bleibt. Normale Sprung- und Kollisionsphysik, G2a-Kräfte, Waffenprojektil/Energie/Schaden unverändert. 44 übersetzte Rechen-/Zustandsfälle, 31 statische Prüfungen, 25 Hilfsfunktionen unverändert. Entwicklertest `6c53facb9ed63ea567af7cd674381ea17ffc145b` (25.11.2026) 11/11 bestanden: AGK-Compile, kurzer Hoch-Druck bei voller Energie, Halten mit Sprung und Jetpack, Jetpack im Fall, Loslassen, kein Dauersprung, horizontaler Schwung, Rückstoß bremsend/beschleunigend/im Stillstand und in der Luft, Plattformmitnahme/Kollisionen/Mini-Hop. Keine offenen Prüfpunkte oder Beobachtungen. Mindestimpuls weiterhin 0; Nichtnullwerte sowie Energiezufluss während Halten nicht gesondert im Testbericht bestätigt. Kein Parameterwechsel. G2a (25.11.2026): zentrale Bewegungsparameter am Anfang von `source/sonec/sonec.agc`, gruppiert nach horizontal, vertikal und Kanten/Balance. `SONEC_FALL_ACCELERATION=0.01`, `SONEC_JETPACK_THRUST_ACCELERATION=0.04` (Bruttoschub, netto 0.03 aufwärts), `SONEC_MAX_JETPACK_UP_SPEED=8`, `SONEC_MAX_FALL_SPEED=0` (deaktiviert; positive Werte begrenzen zusätzliche Abwärtsbeschleunigung), `SONEC_JUMP_IMPULSE_Y=8`. `SONEC_AIR_THRUST_ACCELERATION=0.005` getrennt von Bodenbeschleunigung gleichen bisherigen Werts; passive Luftbremsung behält bisherige Basis. Ober-/Fallmaximum begrenzen jeweils zusätzliche Beschleunigung, vorhandener Überschuss wird nicht abrupt abgeschnitten. Schwerkraft wirkt während Fall und Fly; Sprungimpuls einmalig, danach Schwerkraft. Globale `FALLACCELERATION` anderer Objekte unverändert. Beide zentralen Eingabepfade `GameInput` und `GameActionInput` gesperrt bei `SpawnEntering` oder `IsLost` (Bewegung, Hover, Waffen, Schild, Energieanzug); Freigabe erst nach vollständig eingetretener endgültiger Kollisionsposition, Countdown und passive Simulation bleiben. Untere Grenze bleibt bisherige Verlustregel, keine zusätzliche Sperre bei teilweisem Überstand unten. Alte sichtbare Hop-Anzeige einschließlich Overlay-Historie entfernt, CSV und andere Diagnosen unverändert. 24 übersetzte Physik-/Eintrittsfälle und statische Prüfung bestanden. Entwicklertest `a41162cdecaf50ca466191ba61959b4c7e499f1c` (25.11.2026) 8/8 bestanden: AGK-Compile, keine vertikale/horizontale Steuerung oder Waffen-/Schild-/Hover-Aktion vor vollständigem Eintritt, natürlicher Eintritt und Freigabe, kontinuierliche Fallbremsung und anschließender Auftrieb, Landungen/Mitnahme/Mini-Hop, alte Hop-Anzeige nicht mehr sichtbar. Keine offenen Prüfpunkte. Beobachtung: Sonec weniger träge, relativ flott in der Luft. Alle Werte unverändert vorläufig; endgültige lokale Parameterfeinjustierung G2d, gesammelt übernehmen. CSV-Ausgabe selbst nicht separat bestätigt. 22 übersetzte Rechenfälle; Entwicklertest F `f4424a1` 9/9 bestanden. Zusatzbeobachtung Randfall mit teilweiser vertikaler Kistendurchdringung und fehlendem Hop bleibt G-Prüfung; strikte Mittelpunktprüfung der Kistenoberseite ist mögliche Ursache, ohne Landung kein Support-Exit-Hop. Phase-D-Test `36a7f23` 9/9 bestanden; Rückversatz beim Laufen nicht mehr beobachtet. Sonderfall Jetpack während schneller Abwärtsbewegung: Plattform kann durchtunnelt werden, da Oberseitenprüfung Fall-Flag voraussetzt. Gezielte Korrektur vor E implementiert: Oberseitenfreigabe über fehlenden Bodenkontakt statt Fall-Flag; relative Fußkreuzung unverändert, Landung beendet Fly; gehaltenes Up wird regulär erneut geprüft. AGK-Nachtest `be7dc31` 6/6 bestanden (Compile, Plattform-/Kistenlandung mit aktivem Jetpack im Fall, erneutes Abheben, normale Landungen, Durchflug von unten). Phase D abgeschlossen im getesteten Umfang. Entwickler bestätigt Compile und 8/9 B/C-Prüfpunkte für `0d0d7a0`; Fallen beidseitig mit Hineinbewegen in Kisten, kleiner optischer Rückversatz rechts nach links offen. Siehe aktuelle Bewegungsspezifikation; vollständige Abnahme offen. C-Nachkorrektur: obere Luft-Eckkontakte beim Fallen mit horizontaler Eintrittskomponente nicht mehr allein wegen dominanter Y-Normale verwerfen; Nullnormalen am bereits erreichten Seitenrand bei t=0 berücksichtigen. Neun übersetzte Rechenfälle; AGK-Nachtest `b1a21dd` 5/5 bestanden (Compile, Fallen/Springen beidseitig, Landungen und Unterseitendurchflug). B/C-Grundverhalten bestätigt; Luft-Gewehrüberdeckung links bei korrektem Bodenabstand und früherer Rückversatz rechts nach links als D-Beobachtungen offen.

## 3. Alpha-Walker: unveränderter Referenzstand

### Pivots und IK

- Walker.ObjectData.Position ist die feste IK-Hüfte.
- Beide Thigh-Spritepivots liegen dort; der rote F1-Punkt ist dieser Hüftanschluss.
- WalkerPartsCalculate bindet den **Corpus-Anchor** an diese Hüfte. Die Corpus-Neigung hält diesen Punkt fest.
- **Corpus-Offset = Corpus.Position** trägt den Tower-Pivot. HUD „Pivot“ bezeichnet diesen Turmpunkt, nicht den roten Hüftpunkt.
- Feste lokale Fußziele, Zweiknochen-IK, Stand-/Schwungbein, sanfte Standrückkehr und Kantenwende sind akzeptiert. Walker-Testtempo 0.05; Fußgelenk liegt für optische Auflage 8 px über Plattformoberkante.
- Kistenstopp/freie Spawns sind lokal getestet. Hülle ±50 px plus 5 px horizontaler Freiraum; Spezialfälle nicht automatisch vollständig abgenommen.

### Aktuelle Parameter

| Parameter | Wert |
| --- | --- |
| Erkennungsreichweite | Game.Screen.Width, aktuell 900 virtuelle px |
| Zielvorbereitung | 400 ms |
| Maximale Zielneigung | ±30° |
| Anfangsfehler / Minimum | ±3° / ±1° |
| Verbesserung | 0.5° pro erfolgreicher Salve, Cap 5 |
| Zufall | (random(0,200)-100)*AimErrorMax/100.0 |
| Schussabstand innerhalb Salve | 150 ms |
| Timer zwischen Salvenaufnahmen | 1800 ms |
| Recovery nach Schuss 2 | 300 ms |
| Turmseiten-Schwenk | 2.0×400 = 800 ms |
| Schwenkbreiten | 100/85/70/55/40 % |
| Rohrrückstoß | 5 px 60 ms, 10 px 120 ms, 5 px 120 ms, danach 0; je Rohr 300 ms |
| Turmrückstoß | 3 px halten 60 ms, linear 90 ms zurück, insgesamt 150 ms je Schuss |

WALKER_TEST_FIRE=1 und WALKER_TARGET_AIM_TEST=1 bleiben aktiv: Trotz Namen sind sie Teil des akzeptierten aktuellen Salven-/Zielpfads. **Nicht als vermeintlich übrig gebliebene Diagnosen abschalten.** Alter fester Diagonaltest WALKER_DIAGONAL_TEST_FIRE=0; Standpose-Test=0; IK-Sprites=1.

### Ziel-/Salvengeometrie

Die Zielposition wird einmal vor der Salve gespeichert; keine fortlaufende perfekte Verfolgung. WalkerAcquireBurstAim nutzt die Reichweiten-/Vorne-Prüfung der neutralen Mündung und korrigiert den idealen Winkel aus Hüft-Zielvektor und Mündungs-Querversatz. Dadurch wird die anschließende gemeinsame Rotation des Corpus-/Waffenaufbaus berücksichtigt. Danach bleiben ±30°-Begrenzung, einmaliger Fehler und Lernfortschritt erhalten. Beide Geschosse verwenden denselben gespeicherten AimAngle.

Der frühere Tiefversatz wurde mathematisch eingegrenzt; der Entwickler meldete später bei 0° Streuung perfektes Zielen und bei kleinem Fehlerbereich plausibles Verhalten. Ursache negativer Random-Grenzen nicht isoliert bewiesen: im Diagnosecommit wurden zugleich Eingabebereich und Streuung verändert. Näherer räumlicher Trefferbereich entsteht bereits bei konstantem Winkelzufall; zusätzlicher Distanzfaktor/Vorhalt bleibt optional.

Turmseite kann unabhängig von Lauf-/Corpus-/Beinrichtung Sonec zugewandt werden. Begonnenes Schwenken wird beendet, währenddessen beginnt keine Salve; während Vorbereitung/Feuer/Recovery kein neuer Seitenwechsel. Optik erfolgt über horizontale Projektion der beiden vorhandenen Seitenbilder, keine zusätzliche Draufsicht.

### Rückstoß und Flash

Zeichenfolge: **Rohr[0] → Tower → Rohr[1]**. Erster Schuss vorne [1], zweiter hinten [0]. Eigene zeitbasierte Rohrimpulse werden nach Wiederaufbau der neutralen Teile addiert; keine Positionsakkumulation.

Der Turmimpuls wird pro Schuss neu gestartet, nicht addiert. Er verschiebt Tower samt beiden Rohrpositionen/-ankern entgegen FireAngle. Die Turm-AABB wird aus der bewegten Pose berechnet, danach der einzelne Rohrimpuls addiert. Corpus, Hüfte und Beine bleiben unbeeinflusst.

Bullet und Flash entstehen vor Rückstoß am Mündungspunkt des tatsächlich feuernden Rohrs. TFlash speichert AttachedWalkerIndex und AttachedBarrelIndex; FlashNew setzt beide auf −1, damit Poolreuse andere Effekte nicht übernimmt. WalkerFlashFollowAll rechnet den aktuellen Rohr- und Turmrückstoß aus dem Barrel-Anchor heraus: Flash bleibt neutral am Schussort, folgt aber Eltern-/Plattformbewegung. Nicht erneut an den rückwärts laufenden Rohrpunkt binden.

### Grafik/Proto: tatsächlicher eingecheckter Stand

Entwickler-Art-/Proto-Commit [0051b8b](https://github.com/ChristianEngel19820128/SonecBot/commit/0051b8bee28b43f1f5cce787fbc5b412889bfa60); aktuelles barrel.png **3×40 px**, Alpha-Grenzen (0,0)-(3,40).

| Seite | Barrel Offset | Barrel Anchor |
| --- | --- | --- |
| Rechts | (0,35) | (1.5,-6) |
| Links | (0,35) | (1.5,-8) |

Das sind die echten, lokal akzeptierten Entwicklerwerte, nicht die frühere 4-px-Zwischenlösung (2,35)/(2,...). Nicht auf vermeintlich ideale Mittelpunkte zurücksetzen. Die aktuelle Zielberechnung verwendet den tatsächlichen Mündungsversatz.

## 4. Zeichenpfad, Timer und Windowsdiagnosen

SpriteDraw verwendet Float-Positionen ohne Floor, Halbierungen mit *0.5 und in jedem Draw korrekt skalierte Offsets. Geteilte Protosprites werden nacheinander gezeichnet; der spezielle Schwenkpfad stellt veränderte Skalen/Offsets anschließend wieder her.

Timer-Multiplikator ist 1000.0/Span statt 1000/Span. Nach Entwicklerbefund können reine Integer-Operanden Bruchteile verlieren, auch bei Float-Zielvariable. Bei benötigter Genauigkeit Float-Operand **vor** Division einsetzen. Keine ungeprüfte globale Ersetzung: diskrete Schwellen können beabsichtigt sein.

Windows-Arbeitsrenderer ist #renderer "Basic" (OpenGL); die lokalen A/B-Tests favorisierten ihn gegenüber Vulkan auf RX 6600 XT/Lenovo T24t-20. Kein allgemeiner GPU-/HTML5-Nachweis. HTML5 fordert SetVSync(1), Windows je WINDOWS_VSYNC_TEST ebenfalls oder Fallback 60 FPS. Alte Kommentare zu zwingender Rückkehr auf Prefer Best sind nicht aktuelle Entscheidung.

Hochhausbewegung standardmäßig positiver dt-Pfad (B); Plattformbewegung im Normalbetrieb weiter bisheriger Timerpfad (A). In der Entwicklungsrunde 19./20.11. wurden die Debug-Funktionen auf die Zifferntasten 1–7 für Windows/HTML5 gelegt; ältere F-Tastenangaben sind historische Bezeichnungen. Die A/B-Diagnosen sind keine automatische Freigabe zur Bewegungsumstellung. M1 ist zurückgestellt; seine Behandlung vor Release wird in der Roadmap entschieden.

**Historische Walker-Diagnose-Einschränkung (damals F1):** Die Textzeile Flash ist noch vereinfacht aus Barrel0 gebildet; sie misst nicht den tatsächlichen neutralisierten Pool-Flash. Echte Markerbewegung wurde vom Entwickler bestätigt; Animation insgesamt akzeptiert. Debugtext später pflegen.

## 5. Weitere Mechaniken und bekannte Grenzen

- Sonec-Energie: normales Maximum 4000, Start 4500; vorläufige Testwerte, kein endgültiges Alpha-Balancing. HUD-Overload-Anzeigebereich 1500, Deckkraft `HUD_BAR_ALPHA=100`; die Anzeige erhöht keine tatsächliche Kapazität.
- Schild: lokal bestätigte proportional ladungsabhängige Explosionsabsorption bis 80 %, 500-ms-Regenerationspause nach Schaden, dynamische Größe und rote HUD-Schadensspur. Standardgrößenfaktor 0.8 akzeptiert; nicht weiter verkleinern. Stärkere Upgrades nicht umgesetzt.
- Schildradius und Körperkollision unterscheiden: K1d verwendet aktiv zwei Körperkreise mit Segment-Sweep gegen Gegnerbullets; die Waffe ist ausgenommen. Ein älterer Diagnoseprototyp ist kein aktueller Schadensstatus. Ladung/Animationsframe langfristig getrennt betrachten.
- Explosionen: zeitbasierter Modus 30 Schaden je 100 ms; neutraler Schaden/Kettenreaktionen beabsichtigt. Walker-Turm-Explosionstreffer sind ergänzt und lokal akzeptiert. E1b trennt die Schadenszeitpunkte einfacher/intelligenter Minen; 9/9 Entwicklertests gemeldet.
- Gegnerbullets nutzen die vorhandene `ShieldAbsorbDamage`-Berechnung; aktiver geladener Schild reduziert den Health-Schaden entsprechend der Absorption. Kein pauschaler Vollschutz. K1b/K1c-Segmentprüfungen wurden jeweils mit 12/12 Entwicklertests abgenommen.
- Walker-Bullets sollen eigene Walker/Orbs nicht treffen; Kisten/Minen vorläufig schon. Weitere Matrix/Tunneling/OBB-Fragen offen.
- K1b nutzt für Orb, Walker-Turm und Kiste einen Segmenttest gegen die um den Kugelradius erweiterte Ziel-AABB; dies ist keine pixelgenaue Formprüfung. Minen behalten den Kreissweep, Gegnerbullets den Sonec-Körpersweep.
- Doppelskalierung bei Kisten-/Flammenkollision korrigiert; wachsende Flammenkreise gegen Kisten lokal positiv. Spätere Orbs-/Minen-Radiusregression und reine Seiteneffekte getrennt prüfen. Spielerflammen-Sonec-Aufruf ist nicht automatisch aktiver Schadenspfad.
- Sonecs eigener Bullet-Radius 25 px / Flash-Radius 33 px ist vom Walker getrennt.
- Upgrade-/Dropbalance, Energieaufnahme-Kosten, Transparenz und Schusssound-Entkopplung sind spätere Aufgaben.
- Crystals ist Vergleichsquelle für HTML5-Controller/Highscore-/Speicherfragen, kein Auftrag zu Änderungen in dessen Repository.

## 6. HTML5, Testbedingungen und Performancebeobachtung

- Tastatursteuerung einschließlich Umbelegung, Speicherung und Restore Defaults ist umgesetzt. Der Entwickler meldete am 18.11. den aktualisierten itch.io-Draft-Embed mit 12/12 bestanden.
- HTML5-Gamepad-Funktion wurde mit Xbox- bzw. kompatiblem Controller gemeldet. Nach der ersten Eingabe kann die Erkennung etwa 2–3 Sekunden dauern; Tastatureingaben benötigen den Fokus im Spiel-Canvas. Hilfetexte dazu sind ergänzt.
- Entwicklungsstand, lokal getesteter Export und tatsächlich hochgeladener Build sind getrennte Angaben. Der genaue Export-SHA ist nicht durchgehend belegt; der Draft-Test vom 18.11. deckt spätere Alpha-Änderungen nicht automatisch ab.
- Prüfungen nach Änderung wählen: Browser-/Eingabe-/Timing-Themen gezielt in HTML5, übergreifende Prüfung an Meilensteinen oder im eigenen HTML5-Chat. Kein vollständiger Plattformtest für jede Dokumentations- oder Detailänderung.
- AGK-Compile, Export und Laufzeittests führt der Entwickler aus. Aktuelle Planung und der nächste Schritt stehen in HANDOFF/TODO; es gibt keine feste Release-Deadline.

### Browserneustart nach längeren Tests – Entwicklerbeobachtung vom 20.11.2026

Der Entwickler berichtet von Performance-Einbußen nach längerem Testen, die sich durch einen Browserneustart wieder besserten. Ursache und Reproduzierbarkeit wurden nicht isoliert nachgewiesen.

Für vergleichbare Tests dieselbe Build-Revision und Umgebung festhalten; Zustand direkt nach Browserneustart und nach längerer Sitzung getrennt beurteilen. Vor einem Vergleich bei auffälliger Trägheit eine frische Sitzung als Ausgangspunkt prüfen, die Auffälligkeit der längeren Sitzung aber ebenfalls dokumentieren. Ein flüssiger Neustart allein schließt ein Laufzeitproblem nicht aus.

Unabhängig davon verschwand das beobachtete Bewegungsruckeln laut Entwickler bei 75 Hz Monitorfrequenz. Die M1-Ursachenuntersuchung ist zurückgestellt; daraus weder eine bewiesene Ursache noch eine automatische Release-Gate-Abnahme ableiten.

## 7. Historische Entwicklungs- und Testnotizen vom 16. November 2026

Die folgenden datierten Zwischenstände bleiben als technische Belege erhalten. Spätere Ergebnisse innerhalb dieser Chronik und der aktuelle HANDOFF ordnen sie ein; alte Testaufträge oder „nächste Schritte“ nicht erneut ausführen.

### Lokaler HTML5-Smoke-Test – Entwicklermeldung vom 16. November 2026

- HTML5-Export in lokalem AppGameKit Studio erfolgreich; Spiel startet über Apache/XAMPP im gemeinsam erstellten Run-Frame. Der Frame entspricht im Prinzip der späteren itch.io-Einbettung, ist aber **kein dortiger Test**.
- Mit VSync bei Windows 60 Hz wird das Gameplay als flüssig beschrieben; kurze Umstellung auf 75 Hz ergibt laut Entwickler ebenfalls flüssiges Gameplay. Für weitere Prüfung wird 60 Hz bevorzugt. Keine eigenen Messdaten, keine unabhängige Browserkontrolle und keine Bestätigung aller Eingaben.
- Der aktuelle HTML5-Export wurde hier nicht als Datei bereitgestellt; sein exakter Codecommit wurde nicht eigens verifiziert. Vorheriger lokal getesteter **Walker-Codecommit** im Dokumentkopf bleibt als solcher gültig.
- Browsercache/XAMPP: Nach Dateiaustausch alte Assets/Skripte möglich; Entwickler empfiehlt in geöffneten DevTools die Cache-Deaktivierung während lokaler Tests. Noch Kandidat für reproduzierbare Knowledge-Base-Notiz, keine pauschale Aussage über AGK-Enginefehler.
- Weitere Browser-Release-Gates: alle Gamepad-Aktionen (Grundfunktion bestätigt), Pause, Tod, mindestens zwei Neustarts und itch.io-Draft/Secret-URL-Test. Geplante Untersuchung fehlender Kollisionsabfragen ist zunächst **Analyse**; nur bestätigte relevante Fehler mit gemeinsamer Freigabe beheben. Die Spawnwahrscheinlichkeiten sind separat auf Frame-/Zeitbasis zu prüfen.

### HTML5-Gamepad-Funktionstest abgeschlossen – Entwicklermeldung, 16. November 2026

Lokaler Apache/XAMPP-Browsertest mit Xbox-/kompatiblem Controller, 60 Hz/VSync als Referenz: Bewegung über D-Pad und linken Stick, Rückwärtsbewegung über beide unteren Trigger, Energieanziehung L1, Schild rechte Schultertaste, X Flammenwerfer, Y Plasma-Blitz, A Maschinengewehr, B Granatwerfer und Start Pause funktionieren laut Entwickler. Andere Tasten derzeit ohne zugewiesene Funktion. Nach erster Controller-Eingabe kann HTML5-Controller-Index 1 bis zu 2–3 s zur Erkennung benötigen; der Windows-Enumerationsweg gilt nicht als HTML5-Alternative. Die Tastatur ist unvollständig und nicht zumutbare Release-Eingabe.

**Offene Tastenbezeichnung:** Der Entwickler schrieb „R2 Schild“, zugleich R2 als unterer Trigger für Rückwärtsbewegung. `SonecShieldInput` liest jedoch `JoystickButtonRR` (6, gewöhnlich RB/R1), die Rückwärtssteuerung Z/RZ. Nicht als Code-Fehler werten; tatsächliche Beschriftung vor itch.io-Controls klären.

**HTML5-Ende:** Entwickler berichtet ESC/QUIT ohne Beenden. `GetESCPressed()` prüft ESC ausschließlich unter Windows, `main.agc` terminiert über `Intro.IsQuit` nur bei `Device$ <> "html5"`. Das ist im Quellcode nachvollziehbares Browserverhalten, kein bestätigter AGK-Bug. Mögliche Knowledge-Base-Themen: Browser-Gamepad-Aktivierung/Index-Workaround, Browser-vs.-Desktop-Ende und Cache bei XAMPP-Reloads. Knowledge Base zunächst nicht verändert.

**Nicht bestätigt:** exakter SHA des getesteten exportierten Builds, AGK-/Browser-Version, Tod und zwei Neustarts, itch.io-Draft-Einbettung, andere Browser/Controller.

### Kollisionsmatrix und erster schmaler Implementierungsschritt (16. November 2026)

**Entscheidung:** Sonecs Maschinengewehr, Flammen, Granaten (kinetischer Einschlag/Explosion) und Plasma-Blitz sollen prinzipiell alle beschädigbaren Ziele treffen können. Spätere Schadensarten (Plasmaexplosion, Plasmaflamme, Kinetik, Plasma-Blitz) und Gegenpanzerungen bleiben Design, **nicht** Teil dieses Patches. Faction-Planung: Player 1/optional Player 2, Enemy, Neutral; derzeitige Quellkonstanten `TYPEPLAYERONE`, `TYPEPLAYERTWO`, `TYPEENEMY` sind keine komplette neutrale Trefferlogik.

**Erster Codepfad implementiert und vom Entwickler lokal getestet (16.11.2026):** `FlameCollideWalkers()` in `flame.agc`, aufgerufen nach den bestehenden Flammenkollisionen in `GameDo()`. Verwendet `FlameCollisionRadius()` und Circle-vs-Nearest-Point auf Walkers **bestehender Turm-AABB**, zieht den bestehenden Flammenschaden ab, zeigt den vorhandenen 150-ms-Turmtrefferflash und verbraucht die Flamme. Kein Eingriff in Walker-Pose/IK, Projektilwerte, Faction-Matrix oder Panzerung. **Testmeldung:** Flammenwerfer funktioniert wie erwartet; sämtliche vom Entwickler geprüften Objekte einschließlich Walker wurden zerstört. Die Waffe erscheint sehr stark; keine quantitative Messung oder Balanceentscheidung. Die Rückmeldung differenziert Flash und Drops nicht separat. Kein eigener AGK-Compile oder Browserlauf durch den Assistenten. Der erste Kollisionsschritt ist abgeschlossen, weitere Kombinationen erst nach gemeinsamer Entscheidung.

**Bestand der übrigen aktiven Pfade (Codeprüfung am vorherigen HEAD `ff37a326`):** Maschinengewehr gegen Orb/Mine/Kiste/Walkerturm; Flamme gegen Orb/Mine/Kiste; direkte Granate gegen Orb/Mine/Kiste/Plattform (Explosion bei Einschlag); Explosion gegen Sonec/Orb/Mine/Kiste; Plasma-Blitz gegen Orbs. `PlasmaBlitzCollideMine` und `PlasmaBlitzCollideChest` waren leere Funktionskörper. Noch nicht umgesetzte Walker-Pfade für Granate/Explosion/Plasma-Blitz sowie weitere Ziele bleiben Folgeaufgaben. Jede vorhandene Funktion gegen ihren tatsächlichen Aufrufpfad prüfen; bloße Existenz ist kein aktiver Treffermechanismus.

### Plasma-Blitz → Mine/Kiste: kleiner Folgepatch, Windows-/HTML5-Test danach positiv (16. November 2026)

Vorher wurden nur Orb-Kollisionen implementiert, wobei `PlasmaBlitzCollideOrbs()` den bestehenden 50-ms-`CollisionTimer` am Ende bereits zurücksetzte. Nun prüfen drei einzelne Funktionen jeweils dieselbe `TimeGet(...,Now)>0`-Bedingung: `PlasmaBlitzCollideOrbs`, `PlasmaBlitzCollideMine`, `PlasmaBlitzCollideChest`. Der Reset wird **einmal nach diesen drei Aufrufen** in `PlasmaBlitzCollisionTimerReset()` ausgeführt. Die Reihenfolge ist bewusst und Teil dieses kleinen Patches; bei späteren zusätzlichen Zielklassen auch die Reset-Reihenfolge berücksichtigen. Minen und Kisten nutzen ihre bereits aktualisierten `CollisionData.Position1/Position2`, `BoxInBox`, vorhandenen `BulletData.Damage` und Rotfärbung; Blitz wird wie beim Orb-Treffer nicht gelöscht.

**Status:** Nur anhand der GitHub-Quelle auf `develop` geprüft; kein eigener AGK-Compile/Browser-Test. Zu prüfen: Kompilierung, Mine/Kiste tatsächlich treffbar und zerstörbar, Orb-Verhalten unverändert, korrekter 50-ms-Schadensrhythmus und keine neuen Timing-/Mehrfachtrefferprobleme.

**Keine Balanceänderung:** Entwickler beschreibt Plasma-Blitz als aufzuladende, anschließend entladene starke Waffe mit vermutlich hohen Energiekosten; Flammenwerfer zehrt ebenfalls stark an Energie, die zum Fliegen benötigt wird. Qualitative Meldung, noch keine quantitativ geprüfte Balance; getrennt von Kollisionsimplementierung behandeln.

### Plasma-Blitz-Folgepatch – lokaler Windows- und HTML5-Nachtest erfolgt

**Entwicklerbericht, 16. November 2026:** Neuer Trefferpfad für Plasma-Blitz gegen Minen/Kisten zunächst lokal unter Windows und anschließend HTML5 getestet; „html5 geht auch“. Große Kisten reagieren auf eine Entladung nur schwach, der Blitz ist schwer zu handhaben und kostet gefühlt viel Energie. **Kein quantifizierter Schadens-/Energienachweis**, keine separate Aufstellung jedes zerstörten Ziels, kein eigener Assistenten-AGK-Test; nicht als vollständige automatisierte Kollisionstestsuite ausgeben. Gemeinsamer 50-ms-Kollisionstimer für Orb, Mine, Kiste ist im Code eingebunden.

**Verbleibende Matrix-Lücken am Walker:** Plasma-Blitz, direkter kinetischer Granatenaufprall, Explosion. Granatenaufprall und Explosion sind getrennte Schadensereignisse; bei Integration auf unbeabsichtigten Doppelschaden achten. Bereits laufende Trefferpfade: Bullet und Flamme gegen Walker. Weitere Codeänderung erst nach gemeinsamer Entscheidung.

**Browser-Debugging:** F-/Debugtasten aktivieren laut Entwickler im HTML5-Browser Browseraktionen; Windows-Diagnose ist für den Pre-Alpha-Test ausreichend. Spätere Eingabeüberarbeitung möglich, kein aktueller Releaseblocker. Für Knowledge Base ggf. als platformspezifische Eingabe-/Browser-Shortcuts-Besonderheit prüfen.

### Plasma-Blitz → Alpha-Walker (16. November 2026; anschließend lokal positiv)

`PlasmaBlitzCollideWalkers()` implementiert in `plasmablitz.agc`, Aufruf in `GameDo()` nach Orb-, Mine- und Kistenprüfung und vor `PlasmaBlitzCollisionTimerReset()`. Benutzt `BoxInBox` mit der vorhandenen `WalkerCollisionData.Tower`-AABB als bestätigtem Trefferbereich, zieht den vorhandenen `PlasmaBlitz.BulletData.Damage` von Walker-Health ab, setzt `HitFlashUntil=Now+150` und färbt den Turm rot. Die Entladung wird beim Treffer nicht gelöscht; das gemeinsame bestehende 50-ms-Intervall gilt für alle vier Ziele. Keine neuen Schadensklassen, Multiplikatoren oder Energie-/Walker-Anpassungen.

**Nachweisstatus:** GitHub-Code überprüft, aber **noch kein eigener AGK-Compile und kein Entwickler-Nachtest** dieses neuen Pfads. Prüfen: Windows-Build und HTML5, rot blinkender Walker-Turm, Zerstörung bei ausreichend Treffern, alte Orb/Mine/Kiste-Kollisionen weiterhin wirksam; zeitliche Trefferwirkung und visuelle Rückmeldung. Nach erfolgreichem Test bleiben Granatenaufprall und Explosion als offene Walker-Trefferpfade.

### Direkter Granatenaufprall → Walker (16. November 2026; lokaler Volltreffer positiv)

**Blitz-Abschluss:** Entwickler bestätigt den zuvor eingebauten Plasma-Blitz→Walker-Trefferpfad mit „gut das funktioniert =)“. Keine Detailmessung oder präzise Browserzuordnung für diesen einzelnen Test; der Test ist Entwicklerbefund, nicht Assistenten-Compile.

**Neu:** `GrenadeCollideWalkers()` in `grenade.agc` in den `GameDo()`-Aufrufen nach Kisten und vor Plattform eingebunden. Ein aktives Granatenobjekt gegen einen aktiven Walker mit `BoxInBox` an der etablierten Turm-AABB. Direkter `Grenade.BulletData.Damage`-Health-Abzug; bestehender `HitFlashUntil`/rote Turmfarbe; anschließend `GrenadeDestroy()` für reguläre Explosion und Entfernung der Granate. Ein aktives Granatenobjekt wird nach dem Treffer nicht erneut gegen weitere Walker ausgewertet. Die eigene Explosion-Walker-Kollisionsroutine ist weiterhin **nicht** vorhanden: Der neue Schritt erzeugt keinen zusätzlichen Explosionsschaden am Walker.

**Nachweisstatus:** Nur GitHub-Quellprüfung. Entwickler soll den aktuellen Stand in AGK unter Windows und danach HTML5 testen; insbesondere Turmaufprall, Trigger/Explosion, mögliche Zerstörung und Regression gegen Orb/Mine/Kiste/Plattform. Explosion → Walker ist der **nächste getrennt zu entscheidende** Kollisionspfad, einschließlich Überlegungen zu Doppelschaden bei direktem Treffer und nachfolgender Druckwelle. Keine neuen Schadensarten oder Balancewerte.

### Direkter Granatenaufprall: bestätigter Entwicklertest und noch offene Explosionswirkung

**Entwicklermeldung, 16. November 2026:** Volltreffer direkt auf Walker-Turm, Reaktion „alles wie erwartet“. Der zuvor eingebaute `GrenadeCollideWalkers()`-Aufprall gilt als lokal positiv; das genaue Laufzeitsystem (Windows/HTML5) für diesen einzelnen Versuch und der exportierte Code-SHA wurden nicht ausdrücklich genannt. Keine unabhängige Prüfung von Flash-/Drop-Einzelereignissen oder Walker-Zerstörung nach mehreren Granaten.

**Spielmechanik laut Entwickler:** Granatenrückstoß kann Sonec zurückversetzen; geworfene/abgeschossene Granate fliegt in einem nach unten gekrümmten Bogen, kann auf langen Distanzen Plattformboden treffen und dort explodieren. Jeder Abschuss kostet Granatenmunition (vom Entwickler als „Plasmagranaten“ bezeichnet). Beobachtungen bewahren, nicht nebenbei Flugbahn, Schaden oder Munitionsverbrauch umstellen.

**Nächste begrenzte Untersuchung:** `ExplosionCollideWalkers()` ist noch nicht implementiert. Vor Ergänzung vorhandene `ExplosionCollideSonec/Chest/Orb/Mine`-Schadensintervalle und die Reihenfolge von `GrenadeDestroy()`/Explosion gegen direkten Aufprall prüfen. Der Aufprall kann Schaden auslösen, die nachfolgende Explosion würde zusätzlich Schaden verursachen; über kumulierte Wirkung und Timing gemeinsam entscheiden. Keine automatische Explosion-/Panzerungs-Balancereform.

**Hash-Klarstellung:** `18f92a9` in der Kopfzeile bezeichnet ausdrücklich den historischen Abschluss des Alpha-Walkers. Vorliegende Kollisionsänderungen wurden danach auf `develop` committet und anschließend lokal getestet; der SHA des konkret exportierten und getesteten Binär-Builds ist nicht separat protokolliert. Tatsächlichen HEAD jeweils frisch lesen.

### Explosion → Walker: letzter Kollisionspfad der ersten Matrix (16. November 2026; anschließend lokal positiv)

**Eingriff bewusst auf vorhandene Geometrie begrenzt:** `TExplosion.LastWalkerHitMs` als dynamisches integer-Array pro Explosion/Walker; Initialisierung auf `Length = -1` in `ExplosionNew()`. `ExplosionCollideWalkers()` prüft die Distanz vom Explosionszentrum zum nächsten Punkt der bereits vorhandenen `WalkerCollisionData.Tower.Position1/Position2`-AABB. Nur bei Distanz kleiner als `Explosion.ObjectData.Radius` gilt der Turm als getroffen. Damit zählen nahe Explosionen am Rand der Turmgeometrie; andere Walker-Kollisionen sowie IK/Pivots bleiben unberührt.

**Schaden:** Pro getroffener Kombination Explosion/Walker derselbe Mechanismus wie bei Chest/Orb/Mine: `EXPLOSION_TIMED_DAMAGE = 1`, `EXPLOSION_TIMED_DAMAGE_AMOUNT = 30`, `EXPLOSION_DAMAGE_INTERVAL_MS = 100`; `LastWalkerHitMs[k]` begrenzt den zeitlichen Abstand, `Health.State` sinkt und vorhandener 150-ms-Turmtrefferflash wird ausgelöst. Keine geänderten Schadenswerte, Radius-, Lebensdauer- oder Explosionstyp-Parameter. `GameDo()` ruft die Funktion direkt nach `ExplosionCollideMine()` auf, vor Walker-Bewegung/-Animation und Granaten-Update.

**Wichtige Konsequenzen:** Ein direkter Treffer einer Granate fügt kinetischen Schaden zu und löst die gewohnte Explosion aus, deren Radius im nachfolgenden Spielupdate zusätzlich Schaden am Walker verursachen kann. Auch Plattform-Bodenexplosionen und andere Explosionstypen sind dadurch potentiell gegen Walker wirksam; mögliche Kettenreaktion bei Walker-Zerstörung. Die Zahl der Treffer während einer Animation hängt von Überlappungsdauer und dem bestehenden Mindestintervall ab; das ist bewusst als bestehendes Schadensmodell übernommen, **noch nicht anhand eines aktuellen AGK-Builds gemessen**.

**Testauftrag:** Windows-Compile und lokaler HTML5-Test durch Entwickler; Walker-Turmtreffer durch Direktaufprall vs. Explosion in der Nähe vergleichen; rote Reaktion, Zerstörung, doppelte Wirkung und weitere Explosionen gegen Sonec/Kisten/Orbs/Minen auf Regression prüfen. Der Entwickler bewertet das Spielgefühl; keine vorschnelle Schadensbalance oder Panzerungsänderung. Kein eigener AGK-Compile des Assistenten.

### Kollisionsmatrix abgeschlossen – Explosions-Nachtest positiv (16. November 2026)

**Evidenz:** Entwickler bestätigt „sprengtest erfolgreich“. Eine Granate mit direktem Treffer am Walker-Turm und eine Explosion ohne direkten Aufprall können den Walker zerstören. Somit funktioniert `ExplosionCollideWalkers()` lokal in den beiden maßgeblichen Fällen. Genaue Windows-/HTML5-Ausführungsumgebung für diesen Einzeltest, Intervall-Messung, komplette Regression der übrigen Explosionstargets und Export-Commit nicht einzeln dokumentiert. Keine zusätzlichen Spielcodeänderungen nötig, solange keine neue konkrete Auffälligkeit auftritt. Bestehende Turm-AABB und Explosionsintervall bleiben unangetastet.

**Erste Matrix:** Player-Bullets, Flammen, Plasma-Blitz, direkter Granatenaufprall und Explosion haben implementierte Walker-Turmtrefferpfade. Erweiterte Kollision der Corpus-/Bein-/anderen Körperteile war als Zukunftsidee angelegt; ist kein Pre-Alpha-Releaseblocker. Der Entwickler hebt hervor, dass gerade die schwer erreichbare Turmzone den Walker als Gegner unverwechselbar macht und das Spiel mit Gegenwehr schon jetzt Spaß macht.

**Später:** Gameplayvideo nach den Kern-Releaseprüfungen erwünscht. GifCam-Probleme könnten laut Entwickler mit hohem RAM-Verbrauch bei vielen laufenden Programmen zusammenhängen; Hypothese, keine technische Diagnose. Alternativen gegebenenfalls später prüfen. Achievements sind eine Zukunftsidee, gegenwärtig nicht implementiert.

### Laufender Spieltest: Sonec/Walker-Körperkontakt, HUD-Skalierung und Schildprüfung (16.11.2026)

**Beobachtungen des Entwicklers:** (1) Alpha-Walker läuft durch Sonec statt vor ihm zu stoppen und zu feuern; (2) Energie-HUD soll mit grüner Füllung und angemessenem rotem Overload-Bereich ungefähr auf Höhe von HP+Schild kommen, Screenshot im Gespräch; (3) Schutzwirkung des aktivierten Schilds noch ungeprüft. Mehrfache Tode berichtet; kein ausdrücklicher Abschluss für Tod + zwei Browserneustarts.

**Quelllage `develop` `a313b080`:** `GameDo()` führt `WalkerMoveAll(...PlateList,ChestList,...)` und `SonecCollidePlate(...PlateList,ChestList,...)` getrennt aus. `WalkerMove()` begrenzt Bewegung an Plattformkanten und prüft `WalkerChestDistanceAhead()`, nicht aber Sonec; keine aktive Walker↔Sonec-Körperkontaktbehandlung in der Hauptschleife gesehen. Vor Implementierung gewünschte Stoppdistanz, Fortsetzung nach Verlassen der Zone und Interaktion mit FireState klären; IK und vorhandene Bewegungs-/Turmmechanik nicht refaktorieren.

**HUD:** `gui.agc:GuiEnergyDraw()` nutzt `ceil(Health.State*150/StateMax)` Segmente, Schild `ceil(EnergyShield.State*25/StateMax)`, gewöhnliche Energie `ceil(EnergyLoad*20/Energy.StateMax)` und Overload `ceil(EnergyOverload*10/Energy.StateMax)`. HP/Schild und Energie benutzen unterschiedliche Sprites und vertikale Abstände. Die Anforderung ist proportional **optisch**, keine beabsichtigte Änderung von `Energy.StateMax`, Energieverbrauch, Schildkapazität oder Lebenspunkten. Ein Overload-Maximum für Anzeige ist noch gemeinsam zu spezifizieren.

**Schildbefund:** `shield.agc:ShieldAbsorbDamage()` existiert und wird bei `ExplosionCollideSonec(...Shield,Now)` angewandt. Der aktive `bullet.agc:BulletCollide(BulletList,Sonec)` behandelt `TYPEENEMY` und reduziert unmittelbar `Sonec.Health.State` um `Bullet.BulletData.Damage`, **ohne** `ShieldAbsorbDamage()`. Daher bietet die bestehende Implementierung keinen Kugelschutz; ein A/B-Schadensvergleich im Spiel wurde noch nicht gemeldet. Möglicher kleinster Fix später: signatur- und aufrufseitig Schild/`Now` weiterreichen und den vorhandenen Absorptionswert abziehen. Keine neuen Schutzparameter erfinden.

**Status:** ausschließlich Code gelesen und Befunde dokumentiert, **keinerlei Spielcodeänderung**. Für Release zuerst einzeln priorisieren und nach jeder Änderung unter AGK/HTML5 nachtesten, statt mehrere Änderungen zu bündeln.

### HTML5-Game-over und Neustart: praktischer Entwicklertest bestanden (16.11.2026)

Entwickler bestätigt mehrfachen Tod **innerhalb derselben HTML5-Browsersitzung** durch Minen und Walker-Beschuss und danach mehrfaches Wiederauferstehen durch Neustart. Die Sitzung läuft weiterhin; Pause funktioniert. Der geforderte grundlegende Tod-/Mindestens-zwei-Neustarts-Smoke-Test ist damit **positiv**. Nicht nachgewiesen sind alle Randfälle, Speicherlecks bei langen Sitzungen, andere Browser und der exakte exportierte Code-SHA. Keine eigenen Browser-Laufzeittests des Assistenten.

**Spätere Informationsavatar-Umsetzung:** Schon als `PROJECT.md`-Idee vorgesehen. Neuer Vorschlag des Entwicklers: zuerst ein roter Warntext in Versalien am oberen Bildschirmrand, Beispiel „MINEFIELD DETECTED“ bei gruppenweise eintreffenden Minen; eventuell Grafik, später Sprachausgabe. Kein aktueller Implementierungsauftrag. Für Warntrigger Spawn-Ereignisse und Duplikatunterdrückung prüfen. `GameDo()` hat eine `random(0,10000) < 5`-Prüfung pro Update und anschließend `for i = 0 to random(0,15)` zum Hinzufügen mehrerer Minen, solange `MineCountAll < 15`; dies stützt die Rudel-Beobachtung und die Hypothese möglicher FPS-Abhängigkeit, ersetzt aber noch keine Messung. Nicht ungeprüft verändern.

**Weitere priorisierte Punkte:** Feindkugeln umgehen `ShieldAbsorbDamage()`, daher zuerst enge Schadenspfadkorrektur mit A/B-Test erwägen; danach Walker-Sonec-Überlappung und optische HUD-Höhenskalierung getrennt. Noch keine Spielcodeänderung. itch.io-Draft/Secret-URL-Test weiterhin offen, öffentliche Veröffentlichung nicht freigegeben.

### Schildabsorption für feindliche Kugeln – isolierter Fix (16.11.2026; anschließend lokal bestanden)

**Implementierung:** `bullet.agc:BulletCollide(BulletList,Sonec,Shield,Now)` nutzt beim tatsächlichen Treffer eines feindlichen Projektils (`CollisionType = TYPEENEMY`) dieselbe Formel wie `ExplosionCollideSonec`: `Health -= (BulletData.Damage - ShieldAbsorbDamage(Shield,Sonec,BulletData.Damage,Now))`. Der `GameDo()`-Aufruf in `game.agc` reicht jetzt `Game.Shield,Now` durch. Die Absorption findet nur statt, wenn der bestehende `ShieldAbsorbDamage()`-Pfad einen aktiven, nicht im Abbau befindlichen und geladenen Schild erkennt. Er reduziert Schildladung, aktualisiert Frame/Größe und Schadensspur. Keine Änderungen an `shield.agc`, Kugel-Eigenschaften, `SHIELD_MAX_PROTECTION_PERCENT`, Auf- und Abbau oder Explosionstreffern.

**Nachweisgrenze:** Nur statischer GitHub-Vergleich; Entwickler hat alte Browsersitzung geschlossen und muss den aktuellen Code neu kompilieren/exportieren. Nächster Nachtest: Windows/HTML5, HP-Verlust ohne Schild, geringerer Verlust mit aktivem geladenem Schild, Schildladungsverbrauch und rote Spur, leer/deaktiviert normaler Kugelschaden, Explosionsabsorption nicht regressiert. Keine Behauptung eines bestandenen Builds vor Rückmeldung.

### Schild-Feindkugel-Patch: Entwicklertest abgeschlossen; Kettenreaktion beobachtet

**Testmeldung vom 16.11.2026:** Walker verursacht HP-Schaden ohne Schild. Mit Schild wird die Ladung sichtbar reduziert und die **rote Schadensspur oberhalb der Schildanzeige** zeigt die absorbierte Wirkung; dies setzt sich bis zur erschöpften Ladung fort. Entwickler erklärt ausdrücklich **alle zuvor vereinbarten Tests als bestanden**, inklusive der besprochenen Rest-/Regressionsprüfungen. Die vorherige Markierung „Test offen“ ist historischer Stand; **aktuelle Bewertung: lokal akzeptiert**. Keine eigenständigen AGK-Laufzeittests und keine quantitativen Messungen des Assistenten.

**Emergente Kettenreaktion laut Spieler:** Walker hat auf eine Mine geschossen und wurde durch die resultierende Explosion selbst zerstört. Die bestehenden neutralen Explosions- und Fraktionsmechanismen erlauben solche Wechselwirkungen. Beobachtung, kein bestätigter Defekt, nicht aus dem Code heraus umdeuten oder ohne Spieltest abschalten.

**Nächster Einzelpunkt:** Walker kann momentan durch Sonec hindurchlaufen; die gewünschte Stop-/Feuerreaktion ist von Kistenstopp und bestehender Feuerzustandslogik abzugrenzen. Erst eng untersuchen, anschließend minimal implementieren und testen. Energie-HUD danach getrennt.

### Walker/Sonec: eng begrenzter Bewegungsstopp und Radiusprüfung (16.11.2026; anschließend lokal positiv)

**Radiusprüfung auf ausdrücklichen Hinweis des Entwicklers:** `SonecInit()` weist `Sonec.ObjectData.Size.Width = GetSpriteWidth(ProtoSonec.AnimRight.Stand.Sprite.ID)`, `Sonec.ObjectData.Radius = Sonec.ObjectData.Size.Width * 0.5`, `Sonec.SpriteData.Scale = 1` zu. Kein zweites Multiplizieren mit `SpriteData.Scale` in `sonec.agc` gefunden. Daher im erkennbaren Initialisierungspfad **keine doppelte Scale-Schrumpfung**, tatsächliche optische Sprite-/Hitbox-Passung im Spiel kontrollieren. Radius- oder Spritewerte wurden nicht geändert.

**Neuer Walker-Movement-Pfad:** `WalkerSonecDistanceAhead(Walker,Sonec)` in `walker.agc` ermittelt in Weltkoordinaten die freie Distanz vor der bestehenden Walker-Hülle (`WALKER_HULL_HALF_WIDTH=50`, `WALKER_HULL_HORIZONTAL_CLEARANCE=5`, `WALKER_HULL_TOP=50`, `WALKER_HULL_BOTTOM=35`) und Sonecs Kreis-/AABB-Hilfsregion (`Sonec.ObjectData.Position ± Sonec.ObjectData.Radius`). Nur bei vertikaler Überlappung blockiert der Spieler, beim Ausweichen nach oben nicht. `WalkerMove()` fordert `Sonec ref as TSonec`, begrenzt `StepX` innerhalb des bisherigen `if StepX>0`-Zweigs nach `WalkerChestDistanceAhead()`, und setzt bei erreichten/überlappenden Hindernisabständen `Walker.PauseUntilMs=Now+1200`. Anders als eine Kiste löst Sonec **keine Umdrehung** aus, sondern die unveränderte `WalkerFireAll()`-Logik darf in der normalen Pause feuern. `WalkerMoveAll()` und der Aufruf in `game.agc` sind entsprechend angepasst.

**Nachweisstatus:** GitHub-Signatur-/Aufrufprüfung bestanden; **kein eigener AGK-Compiler-/Laufzeittest**. Entwickler testet Windows/HTML5, Stop vor Sonec aus beiden Richtungen, reguläres Zielen/Schießen, Weiterlaufen bei freiem Weg, Flug über Walker hinweg und unveränderte Kisten-, Kanten-, Stand-/IK- und Turmregeln. Bei schlechter Distanz bitte erst Screenshot/Beobachtung, dann gezieltes Feintuning; keinen allgemeinen Collider-Umbau. HUD erst nach Testabschluss angehen.

### Walker-Sonec-Stopp: Developertest positiv, Sprungkontakt und Sound getrennt (16.11.2026)

**Bild-/Spielbefund:** Zwei Screenshots und Entwicklerbericht bestätigen den passenden horizontalen Abstand bei beidseitiger Annäherung. Walker bleibt stehen, zielt/feuert und kann Sonec Schaden zufügen. Sonec kann wegfliegen und über den Walker hinwegfliegen; Walker verhält sich danach wie erwartet. Damit ist die eng gefasste Walker-Bewegungsbremse **lokal bestanden**. Kein unabhängiger AGK-Lauf durch Assistenten, keine ausdrücklichen Einzelangaben zum Kisten-/Kantenregressionstest.

**Separater Kontaktfall:** Sonec kann springend in die Walkergeometrie eindringen. `WalkerSonecDistanceAhead()` begrenzt nur die Walker-Laufbewegung vor Sonec; es greift nicht in Sonecs Flug-/Sprungphysik ein und ist keine komplette wechselseitige Collider-Implementierung. Als späteren Beobachtungs-/Prüfpunkt notieren, nicht den bestandenen Schritt wegen anderer Kollisionsrichtung wieder öffnen.

**Sound-Architekturidee:** Auslösung gemeinsamer Ereignis-/Schuss-Sounds soll in den jeweils zuständigen Funktionen liegen und auch für andere Akteure als Sonec gelten. Die Implementierung ist noch nicht untersucht oder freigegeben. Vorher Bestandsaufnahme der tatsächlichen Sound-Trigger; Mehrfachabspielen vermeiden.

**Nächster Schritt:** ausschließlich optische Skalierung des grünen Energiebalkens und roten Overload-Bereichs auf ungefähr die Gesamthöhe von HP+Schild; kein Energie-/HP-/Schild-Balancing und kein Walker-/Sound-Code gleichzeitig.

### HUD: proportionaler Energie-/Overload-Dreisatz (16.11.2026; Test offen)

**Quellenbasis:** `source/sonec/media/gfx/gui/bar_horizontal_small.png` ist 16×2 px und `bar_horizontal.png` 32×5 px (PNG-IHDR der GitHub-Assets). HP/Schild in `GuiEnergyDraw()`: `150` plus `25` kleine Balken mit 2 px vertikaler Schrittweite, zusammen **350 px**. Energie-Segmente nutzen 5 px plus 2 px Abstand, also **7 px** je Segment. Gerundeter Dreisatz: `150*2/7 ≈ 43` grüne und `25*2/7 ≈ 7` rote Segmente, zusammen **350 px**. Der Code berechnet beide Maxima aus `GetSpriteHeight()` und dem bisherigen festen Abstand `+2`.

**Geänderter Code ausschließlich in `gui.agc`:** `EnergyBarsMax`/`OverloadBarsMax` sind lokale Integer, `max = ceil(EnergyLoad*EnergyBarsMax/Energy.StateMax)`, `maxOverload = ceil(EnergyOverload*OverloadBarsMax/Energy.StateMax)` (Float-Rechnung durch `*1.0`); maximaler roter Overload-Bereich auf `OverloadBarsMax` gedeckelt. Keine Änderung an tatsächlicher Energie, maximaler Energie, Verbrauch, Aufnahme, Überladung, Schild, HP, Ammo, Sprite-Positionen oder anderen Draw-Pfaden. Rote Slots werden nur bei Overload größer null gezeichnet, nicht als immer gefüllte Reserve.

**Nachweisgrenze:** GitHub-Code geprüft; kein AGK-Compile/Browser-Test durch Assistenten. Entwickler soll neue Windows-/HTML5-Fassung und Screenshot prüfen: Vollenergie nahe HP-Balken, Überladung nahe Schildbereich, Gesamt maximal ca. 350 px; normale Verbrauchs-/Regenerationsanimation und Neustart ohne Überlauf. Erst nach positivem Ergebnis abschließen.

### HUD-Testwerte konkretisiert: Normal 4000, Overload 500 (16.11.2026)

Entwickler akzeptiert den proportionalen HUD-Screenshot als funktional und bittet um eindeutigen Test mit **4000 normaler Energie plus 500 Overload, insgesamt 4500**. In `sonec.agc:SonecInit()` `Energy.StateMax` von 5250 auf **4000**, Startwert von vorher 5250 (keine Überladung) auf **4500** gesetzt. Die erste Version des neuen HUDs skalierte rote Segmente noch relativ zu `Energy.StateMax`, sodass +500 nur `ceil(500*7/4000)=1` rotes Segment gezeigt hätte; daher skaliert `gui.agc` die Überladung jetzt gegen **500**, damit +500 **7 rote** Segmente füllt. Das rote Maximum bleibt auf sieben Slots begrenzt. Grüner Balken weiter `ceil(EnergyLoad*43/4000)`; zusammen ca. 350 Pixel.

**Keine anderen Gameplayänderungen:** Energiekosten, Regeneration, Schwellen bei Energieobjekten und Overload-Health-Schaden sind unverändert. Gerade `SonecHealthRegenerate()` zieht bei Überladung weiter Gesundheit ab; 4500 ist daher als **bewusster temporärer Sichttestwert** zu behandeln, nicht als endgültiges Release-Balancing. Kein eigener AGK-/HTML5-Test des Assistenten; Entwickler soll direkt nach Start/Neustart die volle grüne/rote Anzeige und anschließend den erwarteten Verbrauch prüfen.

### HUD-Skala 1500 / Alpha 170 für alle Balken (16.11.2026; Test offen)

**Entwicklerfeedback:** Bei +500 Overload auf sieben roten Segmenten entfernte kurzer Flug rund drei Segmente; Skala zu empfindlich. Übernahme des Vorschlags **1500 Overload als 7-Segment-Anzeigebereich**, keine Erhöhung tatsächlicher Startenergie oder Kapazität. Änderung nur in `gui.agc`: `maxOverload = ceil(EnergyOverload*OverloadBarsMax*1.0/1500.0)`, unveränderte Obergrenze sieben. Bei `Energy.State=4500`, `Energy.StateMax=4000` ergibt das `ceil(500*7/1500)=3` rote Segmente. Die roten Slots repräsentieren einen theoretischen Darstellungsbereich bis +1500; darüber begrenzt das HUD auf sieben Slots. Bestehende Risiken/Kosten der Überladung bleiben unverändert.

**Zweiter visual-only Test:** Sämtliche 10 expliziten `ColorSet(Data.Color,R,G,B,255)`-Aufrufe innerhalb `GuiEnergyDraw()` auf `...170` umgestellt. Betroffen: HP in grün/rot, Schild blau, rote Schildschadensspur, Energie in grün, Overload in rot, MG- und Granatenanzeigen in grün/rot. Die Proto-/Spriteassets selbst, Welt-Sprites und sonstige Farbzuweisungen sind nicht geändert. Alpha kann Darstellung je nach Hintergrund anders wirken; unter Windows/HTML5 visuell kontrollieren.

**Status:** GitHub-Quellprüfung, kein eigener AGK-Compile. Nutzer soll frischen Build und Screenshot liefern; Test erst danach als bestanden markieren. Keine Balancing-/Spielphysikänderung.

### Zentralisierte HUD-Balken-Deckkraft: HUD_BAR_ALPHA=100 (16.11.2026; Test offen)

Nach dem visuellen Test von `Alpha=170` mit zwei Entwickler-Screenshots wurde der HUD-Anteil des Bildes als noch zu dominant bewertet. Die freigegebene isolierte Änderung steht in `gui.agc`: `#constant HUD_BAR_ALPHA 100` vor `GuiEnergyDraw()`, sämtliche **zehn** bisherigen `ColorSet(Data.Color,R,G,B,170)` dieser Funktion sind nun `ColorSet(...,HUD_BAR_ALPHA)`. HP-Warnfarben, blaue Schildladung, rote Schild-Schadensspur, Energie-Grün, Overload-Rot und beide Munitionsanzeigen behalten ihre jeweiligen RGB-Werte; nur die Deckkraft ändert sich. Kein Eingriff in Bilddateien, Renderer, Farbwahl oder HUD-Geometrie.

Der vorherige Anzeigemaßstab +1500 für sieben rote Segmente sowie Energie `StateMax=4000` / `State=4500` bleiben unverändert. **Nachweisstatus:** Codekontrolle auf GitHub, neuer AGK-/HTML5-Lauf offen. Lesbarkeit über hellem Sternenhintergrund und dunkleren Spielabschnitten prüfen; bei Bedarf später die zentrale Konstante feinjustieren.

### HTML5-Draft-Deployment und itch.io-Embed-Smoke-Test (16.11.2026; Entwicklerbericht)

**Testumgebung:** AGK Studio Compile/Export HTML5 durch Entwickler, Apache/XAMPP als lokaler Nachtest, anschließend ZIP-Upload in die bestehende itch.io-Seite im **Draft-Modus**. `index.html` generiert, Beschreibung eingetragen, Promo-Cover-/Banner auf der Seite; Screenshot zeigt den eingebetteten Spiel-Intro-Screen und FPS-Wert 60. Entwickler meldet **kein sichtbares Tearing** im Apache-Test; keine eigene Bildraten- oder Browsermessung, keine Aussage zur Performance fremder Geräte. `main.agc` fordert HTML5-`SetVSync(1)` an; das ist keine technische Garantie für jedes Browser-Display. Der exakte SHA des hochgeladenen Binär-Builds ist nicht separat protokolliert; Code- und Dokumentations-HEAD nicht mit Export-SHA gleichsetzen.

**Im eingebetteten itch.io-Spiel laut Entwickler positiv getestet:** Gamepad wird erkannt; Lauf- und Bewegungsfunktionen, alle vier Waffen (MG/Granate/Flamme/Plasma-Blitz), Schild, Energieanziehung und Pause funktionieren; Sonec kann durch Energieverlust/Absturz sterben. ESC/QUIT sind im HTML5-Pfad erwartungsgemäß deaktiviert. **Nicht als Embedded-Test belegt:** Neustart nach diesem Tod (mehrfache Neustarts waren zuvor nur im lokalen HTML5-Browser bestätigt), andere Browser-/Gamepadmodelle, lange Browserläufe. Der Assistent hat weder AGK kompiliert noch itch.io selbst interaktiv gespielt.

**Veröffentlichung/Branch:** Die Seite ist über Secret URL im Draft erreichbar und wird von Besitzer an ausgewählte Community-Tester geteilt; **nicht Published**. `develop` bleibt aktiv; ein späterer Merge nach `main` ist **nicht ausgeführt** und vorab gesondert zu beschließen. Der Entwickler ergänzt einen `develop`-GitHub-Link selbst auf itch.io. Die URL mit Secret-Token nicht in öffentliche Dokumente aufnehmen. KI-generierte Werbegrafik ist als Promo-Interpretation zu kennzeichnen; AI-Disclosure-Text zu Graphics, Text/Dialog und Code wurde vorbereitet.

### Letzter itch.io-Nachtrag: Neustart + GitHub-Links (16.11.2026)

**Zusätzlicher Entwicklertest:** Nach dem erfolgreichen Funktions-Smoke-Test im itch.io-HTML5-Embed wurde auch der **Neustart** als „soweit ok“ bestätigt. Damit ist der einfache Neustart im Embed positiv gemeldet; mehrere lokale HTML5-Neustarts waren bereits zuvor bestanden. Keine vollständige Langzeit-/Browserübergreifende Regression oder eigener Browserlauf des Assistenten. Auf der itch.io-Draft-Seite sind laut Entwickler nun **zwei separate GitHub-Links** zu `develop` und `main` gesetzt. Die Seite verbleibt ausdrücklich im **Draft mit Secret URL**; der Link wird an Community-Tester weitergegeben. Der spätere Merge `develop`→`main` ist **noch nicht ausgeführt**. Keine Spielcodeänderung.

## 8. Übergabe und Historie

[HANDOFF.md](HANDOFF.md) enthält den kurzen aktuellen Übergang mit Evidenz und genau einem nächsten Schritt. Technische Referenzparameter bleiben hier; Releaseumfang und Gates stehen in [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md), nächste Aufgaben in [TODO.md](TODO.md). Tatsächlichen `develop`-HEAD neu abfragen, alte Anhänge nicht voraussetzen.

Das gesamte ältere Untersuchungs-/Testprotokoll bleibt [hier im Git-Stand vor Konsolidierung](https://github.com/ChristianEngel19820128/SonecBot/blob/18f92a965810763b552bd96649607c112f966238/TECHNICAL.md), die frühere ausführliche Aufgabenliste [hier](https://github.com/ChristianEngel19820128/SonecBot/blob/18f92a965810763b552bd96649607c112f966238/TODO.md). Diese historischen Quellen nicht als aktuelle Reihenfolge ausführen. Die aktuelle Arbeitsreihenfolge wird ausschließlich in HANDOFF/TODO gepflegt.

Knowledge-Base-Kandidaten stehen in [BACKLOG.md](BACKLOG.md); Beiträge separat vereinbaren und Quellen-/Evidenzstatus erhalten. Arbeitsregeln in [AGENTS.md](AGENTS.md).


### Drohnen-Verhaltenslogik – Scan vor Laser (lokaler Test offen)

`DroneMove` in `source/sonec/drone.agc`: Nur ein abgeschlossener Scan mit Sonec vor der Drohne und in der horizontalen Laserbahn autorisiert das Aufladen. Vor Abschuss werden Richtung und vertikale Zielnähe erneut geprüft; sonst kein Projektil. Bei Richtungswechsel wird die Zielerfassung gelöscht und nach Abschluss der 400-ms-Wende ein neuer Scan fällig. Zufällige Wendewahrscheinlichkeit nach Scan leicht erhöht: 5→10 %, in 220 px Nähe 25→30 %. Scan-/Ladeanimation, Projektil, Schaden und Schild ansonsten unverändert. **AGK-Compile und Verhaltenstest durch Entwickler ausstehend.**

**Drohnen-Scan/Schuss-Feinschliff (lokaler Test offen):** Nach abgeschlossenem Scan gilt für Sonec vor der Drohne eine linear mit der horizontalen Entfernung fallende Erfassungschance: maximal 50 % bei 0 px, 0 % ab 500 px. Die Zufallswendung nach Scan bleibt 10 % bzw. 30 % bei höchstens 220 px Abstand. Nach erfolgreicher Erfassung wird der Schuss bei weiterhin passender X-Richtung nur abgebrochen, wenn Sonec mehr als 120 px über/unter der Drohne ist; der Laser bleibt horizontal und verfolgt Sonec nicht. Die Treffergeometrie selbst bleibt unverändert. AGK-Compile und Gameplaytest ausstehend.

**Drohnen-Schussfrequenz-Korrektur (Entwickler lokal 8/8 bestanden, 22.11.2026):** Ein erfolgreicher Scan setzt `DroneNextChargeMs` auf das Ende der vorhandenen 1200-ms-Aktionspause und unterdrückt die zufällige Wende dieses Scans. Nur nach erfolglosem Scan wird wie bisher mit 10 % bzw. 30 % Nähe gewendet. Die Scan-Erfassung bleibt linear 50 %→0 % (0–500 px); vor dem Schuss gelten Richtung und 120-px-Y-Toleranz. Kein Schaden-/Laser-/Jetstream-Umbau. AGK-Compile/Start, Schussfrequenz, unmittelbares Aufladen nach Scan, Zufallswenden nach Fehlscan, Entfernungschance, 120-px-Höhentoleranz, Abbruch und Laser-/Schild-/Jetstream-Regression vom Entwickler bestätigt. Für die Alpha keine weiteren Verhaltensänderungen vorgesehen.

**Drohnen-Jetstream-Ausrichtung (lokaler Sichttest offen, 22.11.2026):** In `DroneJetfireDo` liegen die äußeren Partikelquellen jetzt bei X ±15 px (zuvor ±10 px) und Y +13 px; die mittlere bei X 0 und Y +16 px (zuvor +13 px), passend zum längeren mittleren Auspuff des 46×30-Sprites. Partikelbreite/-Skalierung 0,65, Emissionsintervall 30 ms und Lebenszyklus unverändert. Positionen anhand Screenshots angenähert, visuelle Entwicklerabnahme steht aus.

**Jetstream-Nachkorrektur (lokaler Sichttest offen):** Entwickler-Screenshot zeigte die vorherigen Quellen ±15/+13 außen und 0/+16 mittig zu weit außen und unten. Neuer Versuch: äußere X ±7 / Y +8, Mitte X 0 / Y +10 (mittlerer Auspuff bleibt länger). Partikelbreite/-skalierung unverändert. AGK-Compile und optischer Test ausstehend.

**Drohnen-Jetstream final (Entwickler bestätigt, 22.11.2026):** Entwickler hat die Partikelquellen selbst pixelgenau ausgerichtet und auf `develop` eingecheckt: links/rechts X ±8 px, Y +8 px; Mitte X 0, Y +10 px. `DRONE_JET_PARTICLE_SCALE` auf 0.6 reduziert. Entwickler bestätigt, dass Optik nun passt. Frühere ±9-/±10-Offsets und Skalierung 0.65 sind überholte Testwerte; keine weiteren Änderungen nötig.

**Drohnen-Scanbonus durch Energieansaugung (AGK-Test offen, 22.11.2026):** `DroneMove` erhält `Game.Inenergie` aus `game.agc` und prüft `Inenergie.Enabled` beim Abschluss des Scans. Die Grundchance fällt linear von 50 % bei 0 px auf 0 % ab 500 px; bei aktiver Ansaugung addiert sich ein ebenfalls linear abfallender Bonus von maximal 25 Prozentpunkten (75 % nahe 0 px, 0 % bei 500 px). Nur in Flugrichtung; Schussfreigabe und übriges Verhalten unverändert. Keine eigene AGK-Kompilierung, Entwickler-Test ausstehend.

**Drohnen-Scanbalancing (temporärer Entwicklertest, 22.11.2026):** `DRONE_SCAN_MAX_SUCCESS_PERCENT` von 50 auf 62.5 erhöht (+25 % relativ), `ScanChance` als Float; bei aktiver Energieansaugung weiterhin bis +25 Prozentpunkte, also maximal 87.5 % nahe 0 px, linear auf 0 % bei 500 px. `DRONE_DEBUG_FORCE_ACQUIRE` wieder 0, gelbe Scan-Diagnose bleibt aktiv. Vorheriger Erzwingungstest bestätigte Laser-Schusskette, nicht die natürliche Erkennung. Lokaler AGK-/Spieltest ausstehend; nach Test Debugcode entfernen.

**Aktueller Scan-Balancingtest (22.11.2026, AGK-Test offen):** Auf Wunsch wieder `DRONE_SCAN_MAX_SUCCESS_PERCENT=50`, bei aktiver Energieansaugung linearer Bonus bis +25 Prozentpunkte (Maximum 75 %). Diagnose mit `random(1,10000)` und Vergleich `ScanChance*100` bleibt vorübergehend; keine erzwungene Erkennung. Schusshäufigkeit vom Entwickler noch zu bewerten.


## Geschossindex und Flak-Explosivmunition

- `BulletAdd` liefert den tatsächlich angelegten oder wiederverwendeten Array-Index zurück. Bestehende Standardmunition-Aufrufer können den Rückgabewert ignorieren.
- `FlarakFireBullet` übergibt den zurückgegebenen Index ausdrücklich an `BulletSetModification` und verwendet ihn für die Flak-Diagnose. Die frühere indirekte Herleitung über `FirstFree-1` entfällt.
- Quellprüfung: Die frühere unmittelbare Aufrufreihenfolge zeigte keinen bewiesenen Fehlindex; die Änderung verhindert eine fragile implizite Zuordnung. Explosionsdauer 175–200 ms, Schadenslogik und andere Waffen unverändert.
- AGK-Abnahme durch Entwickler: **bestanden** (alle fünf Prüfungen). Projekt kompiliert und startet; vier Flak-Geschosse pro Salve; sichtbare unabhängige Explosionen; stabile Geschosse nach vielen Salven; Sonec- und Walker-Standardmunition unverändert. Keine Auffälligkeiten gemeldet.


## Flarak/Flak Trefferzonen – vereinbartes Modell und visueller Ersttest

- Geschlossene Silos und sämtliche bereits in Frame 1 sichtbaren unteren Siloteile sind grundsätzlich unverwundbar.
- Der ausfahrende Sockel erhält eine vertikale rechteckige Trefferzone, deren sichtbare Höhe mit den Animationsframes 2–5 wächst bzw. beim Einfahren schrumpft.
- Bei ausgefahrenem Raketenwerfer: rechteckige obere Trefferzone; bei Flak: kreisförmige obere Trefferzone. Die obere Zone folgt der jeweiligen Ausrichtung und bei Flak dem zusätzlichen Ausfahrversatz.
- Erste Implementierung ausschließlich als farbige Umrissdiagnose: Taste 9 ein-/ausblenden (Toggle); Taste 0 bleibt frei; keine Treffer, Health, Rewards oder Zerstörung implementiert. Sockel cyan, Oberteil gelb. Die Maße sind **vorläufige Schätzwerte** und müssen gegen die tatsächlichen Sprites/Frames lokal geprüft und gegebenenfalls korrigiert werden.
- Testauftrag: AGK-Compile; geschlossene Stellung ohne Trefferzone; Frames 2–5, Ein-/Ausfahren, beide Varianten, links/rechts Schwenk und Flak-Hub; Frame-1-Siloteile stets ausgespart. Erst nach Entwicklerabnahme die Kollisionsberechnung anbinden.

- Debug-Sichtbarkeit: Entwickler meldet, dass die Anzeige auch bei `GAME_DEBUG_ENABLED=1` nicht sichtbar war. Der anfängliche Hauptschalterbefund war daher nicht ausreichend. Die Umrisse verwenden jetzt wie die funktionierende Sonec-Kreisdiagnose ein 2-px-Liniensprite statt `DrawLine` (`7f863f3`); AGK-Nachtest offen, Ursache noch nicht abschließend bewiesen.

- Debug-Feinabstimmung (Entwicklervorgabe, noch AGK-Test ausstehend): Flak-Kreis Radius **15 px** statt 13 px und Mittelpunkt **15 px Bildschirm-Y tiefer**, bei unverändertem X und unveränderter Winkelberechnung. Sockelrechteck beider Varianten **14 px Höhe bei Frame 5** (linear über Frames 2–5), Unterkante **14 px tiefer** als bisher; X und Breite unverändert. Flarak-Oberteilrechteck unverändert. **Nächster separater Schritt nach Sichtprüfung:** Flarak-Oberteilrechteck zusätzlich auf Flak übertragen; noch nicht implementiert.

- Visuelle Feinabstimmung nach Screenshots: Flarak-Oberteilrechteck um **2 px Gesamtlänge** gekürzt (Halbbreite 18→17). Flak-Kreis behält **Radius 15 px**; sein Mittelpunkt liegt bei Nullwinkel **6 px tiefer** als zuvor. Der Kreis dreht nun um einen Punkt **3,75 px (¼ Radius) unterhalb seines Zentrums**, mit rotiertem Mittelpunktversatz; die Sprite-Position bleibt als Bezug erhalten. AGK-Prüfung für geschwenkte Stellungen steht aus. Das zusätzliche Flarak-Rechteck für Flak ist weiterhin erst als Folgeschritt vorgesehen.

- Flak-Kreis-Rotationsdiagnose (`afe0bb4`, AGK-Test offen): Die künstliche Pivot-Verschiebung wurde entfernt. Kreiszentrum wird als lokaler Versatz `(0,+11)` relativ zum tatsächlichen `FlakSprite`-Drehpunkt berechnet und mit dem sichtbaren Flak-Winkel rotiert; Radius 15 px. Magentafarbenes Kreuz zeigt Sprite-Pivot, weißes Kreuz den Kreismittelpunkt; weiße Verbindungslinie zeigt den Versatz. X bei Nullwinkel und übrige bereits abgenommene Formen unverändert. Zunächst Winkelbewegung per Screenshots prüfen, erst danach zusätzliche Flak-Rechteckzone einbauen.

- Entwicklerabnahme Flak-Kreisrotation: Kreis mit Radius 15 px und tatsächlichem Sprite-Pivot in allen getesteten Stellungen korrekt ausgerichtet (Screenshot und Rückmeldung). Daraufhin das bereits bestätigte 34×14-px-Oberteilrechteck der Flarak auch in die **Flak-Debug-Anzeige** übernommen (`ac09b36`), mit Pivot von `LauncherSprite`; der Flak-Kreis bleibt zusätzlich sichtbar. Drei sichtbare Zonen bei Flak: Sockelrechteck, Werferrechteck und Kreis. AGK-Sichtprüfung dieser Kombination noch offen; weiterhin keine aktive Treffer-/Schadenslogik.

- **Visuelle Entwicklerabnahme erfolgreich** (zwei weitere Screenshots): kombinierte Flak-Trefferzonen aus Sockelrechteck, gemeinsamem Werferrechteck und Geschützkreis sitzen auch bei unterschiedlichen Winkeln korrekt. Die Debug-Geometrie gilt damit als optisch bestätigt. Nächster Schritt erst nach separater Abstimmung: reale Treffererkennung, Lebenspunkte und Zerstörung; bis dahin keine Schadenswirkung.

### Verbindliche Schadensspezifikation Flarak/Flak (23.11.2026; Implementierung offen)

- Jede Flarak- und Flak-Stellung erhält initial **150 HP**. Eingefahren (Frame 1) sowie sämtliche unteren, schon in Frame 1 sichtbaren Siloteile sind unverwundbar.
- Freigegebene visuelle Kollisionsgeometrie beibehalten: ausfahrender Sockel (animiertes vertikales Rechteck), oberes Launcher-Rechteck für beide Varianten, zusätzlich Flak-Geschützkreis mit Radius 15 px. **Nur die obere Bildschirmhälfte des Flak-Kreises** zählt für Schaden; der untere Halbkreis bleibt als Debug-Umriss zunächst sichtbar. Andere Trefferzonen bleiben vollständig wirksam.
- **Alle Sonec-Waffen und Explosionen** sollen Schaden verursachen: Maschinengewehr, Flammenwerfer, direkter Granatenaufprall, Plasma-Blitz und bestehende Explosionen. Bestehende Schadenswerte und Zeitintervalle unverändert übernehmen, keine neuen Multiplikatoren/Panzerung. Die bestehenden Kollisionsaufrufe und die Regeln zur Einmal-/Mehrfachwirkung pro Waffe vor Integration prüfen; insbesondere direkter Granatenaufprall plus nachfolgende Explosion nicht unbeabsichtigt doppelt behandeln.
- Dies ist eine **Designfreigabe**, noch keine implementierte Treffer-, HP- oder Zerstörungslogik. Explosions-/Belohnungs-/Entfernungsdarstellung bei 0 HP noch separat festzulegen. AGK-Test nach Implementierung erforderlich.

### Zerstörungsdarstellung Flarak/Flak – Alpha-Vorgabe

- Bei 0 HP: Waffenfunktion endet, oberer Werfer-/Flak-Aufbau verschwindet; das untere Siloelement **Frame 1** bleibt als dunkel eingefärbtes, rein dekoratives Wrack zurück. Kein zusätzlicher Trefferbereich für das Wrack.
- Vorhandene `shiphit`-Animation ist in `source/sonec/explosion.agc` als **Explosionstyp 4** geladen (`/media/gfx/explosions/shiphit`, Frames `shiphit00...`). Als visuelle Zerstörungsexplosion vorgesehen. Vor Einbau prüfen, ob ein normaler `ExplosionAdd(...,4,...)` auch Flächenschaden auslöst und ob dieser bei einer reinen Zerstörungsdarstellung erwünscht ist; keine unbeabsichtigte Schaden-Kettenreaktion.
- Ein eigener Wrack-Spriteframe ist **optionale spätere Verbesserung**, ausdrücklich **kein Alpha-Muss**. Aktuell noch keine Codeimplementierung oder AGK-Abnahme dieser Zerstörung.

### ShipHit-Zerstörung, Kettenreaktion und Energiebelohnung (23.11.2026)

- Entwickler bestätigt: **ShipHit-Typ 4 soll regulären Explosionsschaden verursachen**; Kettenreaktionen sind ausdrücklich erwünscht. `EXPLOSION_DAMAGE_TYPE_MAX = 4` ist bereits korrekt. `ExplosionNew` verwendet pro Explosion den ersten Frame zur Radiusbasis (`max(width,height)/2`), zufällige Skalierung 0,85–1,15 und `ExplosionAnimateAll` eine dreieckige Wachstums-/Schrumpfkurve. Vor endgültiger Radiusentscheidung tatsächliche `shiphit`-Spriteabmessungen visuell prüfen; derzeit noch **keine Bildstichprobe** der PNGs ausgewertet. Bestehender Schaden: 30 pro 100 ms.
- Typ 4 hat in `ExplosionNew` aktuell **keinen eigenen `PlaySound`-Fall** (nur Typen 0–2). Soundüberlagerung bei vielen Explosionen ist spätere separate Untersuchung, kein Blocker der ersten Alpha-Implementierung.
- Zerstörte Stellung hinterlässt dunkles Frame-1-Silowrack und eine **einmalige Energiebelohnung**. `source/sonec/energie.agc` stellt `EnergieAdd` bereit; `source/sonec/reward.agc` ist der bestehende zentrale `RewardDrop`-Dispatcher und benötigt einen neuen Objekt-Typ für Flarak/Flak. Anzahl und Typverteilung noch abzustimmen (Vorschlag: 5–10 Items, Standardverteilung der größeren Gegner); nicht als bestätigter Balancewert behandeln.
- Vor Implementierung: Schaden über alle Sonec-Waffen integrieren, einmalige Zerstörungs-/Drop-Auslösung sichern und Explosionsketten testen. Kein Gameplay-Code in diesem Dokumentationsschritt verändert.

- Belohnungsentscheidung (Entwickler): Flarak/Flak zunächst **an bereits existierenden Gegnerdrops orientieren**, keine eigenständige finale Balance festlegen. Bestehende Beispiele aus `reward.agc`: Kiste 3–6, Drohne 4–8, Walker/Orb 1–13, Bomber 8–15; alle nutzen vorhandene `EnergieAdd`-Logik. Ein konkreter vorläufiger Referenzgegner/Dropbereich wird beim Implementierungsschritt ausgewählt und anschließend getestet. **Endgültiges Balancing** hängt zusätzlich von Wellenlogik und Levelsystem ab und wird in separaten Folgechats behandelt. **Soundmanagement** einschließlich Überlagerungen gehört in einen eigenen späteren Polishing-Chat; nicht in diesen Implementierungsschritt ziehen.

### Implementierungsstand Zerstörbarkeit – Schritt 1 (23.11.2026)

- `flarak.agc`: `TFlarak.Health` initial 150, `Destroyed` als einmaliger Zustandswechsel; `FlarakApplyDamage`/`FlarakDestroy` bilden den zentralen zukünftigen Schadenseinstieg. Bei 0 HP: `ExplosionAdd` mit Typ 4 (`shiphit`, regulär schädlich), `RewardDrop(REWARD_OBJECT_FLARAK)` genau einmal, Frame-1-Silo dunkelgrau (RGB 65), oberer Waffenaufbau nicht mehr gezeichnet, keine weiteren Schüsse. Bereits aktive Raketen werden weiterhin simuliert; noch angehängte werden gelöst. Die zerstörte Basis bleibt als nicht recycelter dekorativer Eintrag, solange die Plattform existiert.
- `reward.agc`: eigener Objekttyp 8, **vorläufig exakt dieselben 4–8 Drops und dieselbe Typverteilung wie Drohne**. Finales Balancing in eigenem Level-/Wellen-Chat.
- **Noch nicht angeschlossen:** tatsächliche Kollisionen mit den fünf Spielerwaffen und Explosionen, inklusive oberer Flak-Kreishälfte. Daher kann die neue 150-HP-/Zerstörungslogik im normalen Spiel **noch nicht ausgelöst oder abgenommen** werden. Nächster zusammenhängender Schritt ist Geometrie plus Anbindung der Waffen-/Explosionspfade; anschließend lokaler AGK-Test. Kein AGK-Compile durch den Assistenten.

- **Schritt 2 begonnen (Commit `dc9ae1b`):** `FlarakPointHits` und `FlarakPointInRotatedRect` als Weltkoordinaten-Punktprüfung ergänzt: ausfahrender 12-px-Stamm, 34×14-px gedrehtes Launcher-Rechteck und bei Flak nur obere Hälfte des Radius-15-Kreises. Frame 1 und Wracks ausgeschlossen. Aktuelle Pivot-Positionen stammen wie bei der Debug-Anzeige aus den Sprites; **die Synchronisierung dieser Positionen vor den Kollisionsprüfungen ist noch zu prüfen**, da die Spritepositionen bisher in `FlarakDraw` gesetzt werden. Punktprüfung ist noch nicht in Waffenpfade eingebunden, kein AGK-Compile/Test; vor Abnahme unbedingt Bewegung/Sprite-Pivot-Update und Sweep/Flächenüberlappung korrekt integrieren.

- **Schritt 2 Zwischenstand (23.11.2026):** `FlarakPointHits` leitet Launcher-/Flak-Pivots nun direkt aus aktueller Weltposition, Winkel und Flak-Ausfahr-Offset ab statt aus der letzten `DrawSprite`-Pose (`00e68c6`). `BulletFlarakSweepEntry` prüft die Geschossbahn mit max. 2px Abtastabstand; `BulletCollidePlayerTargets` berücksichtigt Flarak/Flak als siebten Zieltyp in derselben nächsten-Treffer-Auswahl (`4f6900d`, `83a1757`). Maschinengewehrtreffer lösen über `FlarakApplyDamage` den 150-HP-Zerstörungsablauf aus. **Noch unvollständig und nicht AGK-kompiliert:** Flammen, Granaten, Plasma-Blitz, Explosionen, Radius-/Sweep-Randfälle, Kettenreaktionen. Insbesondere die Punktabtastung berücksichtigt bisher nicht den Geschossradius und benötigt einen gezielten Abnahmetest. Keine lokale AGK-Testfreigabe als Gesamtfeature behaupten.

### Flarak/Flak – erste vollständige Waffenanbindung (23.11.2026, AGK-Test offen)

- Maschinengewehr: `BulletCollidePlayerTargets` integriert Flarak/Flak in die bestehende nächste-Treffer-Priorität; Bahnsampling <=2px (`4f6900d`, `83a1757`). Achtung: der Geschossradius ist noch nicht in die Flarak-Sweep-Geometrie eingerechnet; Randtreffer prüfen.
- Flammenwerfer, Granatendirekttreffer und Plasma-Blitz: eigene Kollisionseinstiege verwenden `FlarakAreaHits` und jeweils den **vorhandenen** Waffenschaden (`763b57f`, `a675ab3`, `a8dbc80`, `81abc1b`). Plasma-Abklingzeit wird wie zuvor erst nach allen Zielprüfungen zurückgesetzt. Granaten erzeugen ihre normale Explosion zusätzlich zum Direktschaden.
- Explosionen: `TExplosion.LastFlarakHitMs` pro Explosion und Ziel; Typ 4 ist über `EXPLOSION_DAMAGE_TYPE_MAX=4` schädlich, gleiche 100-ms-/30-Schaden-Regel wie andere Ziele. Prüfung nach `FlarakDoAll` und `ExplosionFollowPlates`; zerstörte Flaraks erzeugen selbst wieder ShipHit-Explosionen und ermöglichen Kettenreaktionen (`a96adf5`, `de03545`, `b0c834b`). `FlarakAreaHits` prüft den Ziel-Footprint mit 2px-Abstand statt einer bei großen Explosionen zu groben Quellabtastung (`ef4aaff`).
- **Status: Code integriert, kein lokaler AGK-Compile und kein Entwickler-Laufzeittest.** Vor weiteren Balance-/Polishing-Schritten zuerst AGK kompilieren und gezielt prüfen: alle fünf Waffen, geschlossene Silos/Wracks immun, 150 HP, einmaliger 4–8-Drop, Kettenreaktionen, Flak-Halbkreis, schnell bewegte Randtreffer, Plattformbewegung, keine Regression anderer Ziele. Stichprobe ShipHit-PNG und genaue Kollisionsradius-/Visuallogik bleiben gesondert zu prüfen. Bei Compilerfehlern exakte Fehlermeldung/Zeile zurückmelden.
