# SonecBot – Technische Dokumentation

**Dokumentstatus:** Konsolidierter Abschlussstand 3.22  
**Stand:** 16. November 2026  
**Branch:** `develop`  
**Historische lokal akzeptierte Walker-Code-Referenz:** [`18f92a965810763b552bd96649607c112f966238`](https://github.com/ChristianEngel19820128/SonecBot/commit/18f92a965810763b552bd96649607c112f966238)  
**Status:** **Alpha-Walker abgeschlossen. Nächster Auftrag: HTML5-Pre-Alpha-Deployment.**

> [HANDOFF.md](HANDOFF.md) ist der direkte Chat-Einstieg. Dieses Dokument konsolidiert den aktuellen Stand; die vollständige datierte Entwicklungshistorie ist [im vorherigen TECHNICAL-Stand](https://github.com/ChristianEngel19820128/SonecBot/blob/18f92a965810763b552bd96649607c112f966238/TECHNICAL.md) und in Git erhalten. Historische „Test offen“-Abschnitte beschreiben frühere Stände, nicht automatisch neue Entwicklungsaufträge.

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

Virtuelle Auflösung aktuell **900×450**, Windows-Fenster 1350×675. main.agc führt eine pausierbare virtuelle Zeit CurrentNow getrennt von der realen Millisekundenzeit. Während aktiver Pause werden Spielupdate/-eingabe ausgesetzt, Darstellung bleibt erhalten. GameInit setzt Pause/Lost zurück und initialisiert die Spielobjektpools. Echter Tod-/Neustartfluss im Browser noch zu prüfen.

Objektverwaltung und Kollisionen bestehen weitgehend aus eigenen Strukturen/Pools und Kreis-/AABB-Hilfen. Keine pauschale Umstellung auf native Sprite-Physik beschlossen. Einzelne Sonec-Bewegungs-/Ereignispfade können noch bildratenabhängig sein; keine globale Zeit-/Physikänderung vor Veröffentlichung ohne konkreten Befund.

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

Hochhausbewegung standardmäßig positiver dt-Pfad (B); Plattformbewegung im Normalbetrieb weiter bisheriger Timerpfad (A). F1 Walker/IK und F2 Plattformdiagnose sind Windowsfunktionen; F4 Pixel-Snap, F5 Hochhaus-A/B und F6 Plattform-A/B nur Diagnose. Nicht im Release ungeprüft umstellen. Alte Ruckelhypothesen nicht als neue bestätigte Blocker darstellen.

**F1-Einschränkung:** Die Textzeile Flash ist noch vereinfacht aus Barrel0 gebildet; sie misst nicht den tatsächlichen neutralisierten Pool-Flash. Echte Markerbewegung wurde vom Entwickler bestätigt; Animation insgesamt akzeptiert. Debugtext später pflegen.

## 5. Weitere Mechaniken und bekannte Grenzen

- Sonec-Energie: Maximum und Start 5250 als ausdrückliche Testhilfe, kein endgültiges Alpha-Balancing.
- Schild: lokal bestätigte proportional ladungsabhängige Explosionsabsorption bis 80 %, 500-ms-Regenerationspause nach Schaden, dynamische Größe und rote HUD-Schadensspur. Standardgrößenfaktor 0.8 akzeptiert; nicht weiter verkleinern. Stärkere Upgrades nicht umgesetzt.
- Shield-Shape-/Radiusvergleich ist Diagnose, echte Schadenslogik nicht auf Shape umgestellt. Ladung/Animationsframe langfristig trennen.
- Explosionen: zeitbasierter Modus 30 Schaden je 100 ms; neutraler Schaden/Kettenreaktionen beabsichtigt. Walker-Explosionstreffer noch nicht vollständig ergänzt.
- BulletCollide zieht bei Feindtreffer direkt Gesundheit ab. Vollständiger Schildschutz gegen feindliche Bullets nicht behaupten.
- Walker-Bullets sollen eigene Walker/Orbs nicht treffen; Kisten/Minen vorläufig schon. Weitere Matrix/Tunneling/OBB-Fragen offen.
- Rotierte Bullet-Trefferhülle ist AABB, keine pixelgenaue OBB.
- Doppelskalierung bei Kisten-/Flammenkollision korrigiert; wachsende Flammenkreise gegen Kisten lokal positiv. Spätere Orbs-/Minen-Radiusregression und reine Seiteneffekte getrennt prüfen. Spielerflammen-Sonec-Aufruf ist nicht automatisch aktiver Schadenspfad.
- Sonecs eigener Bullet-Radius 25 px / Flash-Radius 33 px ist vom Walker getrennt.
- Upgrade-/Dropbalance, Energieaufnahme-Kosten, Transparenz und Schusssound-Entkopplung sind spätere Aufgaben.
- Crystals ist Vergleichsquelle für HTML5-Controller/Highscore-/Speicherfragen, kein Auftrag zu Änderungen in dessen Repository.

## 6. HTML5 und nächster Auftrag

1. Nutzer erstellt/bereitstellt aktuellen AGK-HTML5-Export; bisher kein ZIP/Browserbuild im Chat.
2. Browserstart mit Assets, Intro/Start und Audio prüfen.
3. **Grundsätzliche HTML5-Gamepad-Funktion vom Entwickler bestätigt** (Xbox- oder kompatibler Controller). Festen Index 1 im HTML5-Workaround beibehalten: Erst nach einer initialen Eingabe wird Controller 1 verfügbar, möglicherweise mit 2–3 s Verzögerung; Windows-Erkennungsverfahren funktioniert im HTML5-Pfad nicht. IntroDo und Pause verwenden Gamepad; Tastatur ist unvollständig, KEY_2 doppelt belegt. **Alle Tasten im Windows-Compile getestet, nicht alle HTML5-Aktionen**. Gamepad-only-Hinweis und vollständigen Browser-Aktionstest vor Draft-Freigabe vorsehen.
4. Spielrunde, Kampf, Pause/Fortsetzen, Tod und mindestens zwei Neustarts testen.
5. Nur konkrete Releaseblocker minimal korrigieren; keine weitere Walkerentwicklung.
6. README/itch.io mit tatsächlichen Controls, Known Limits und Pre-Alpha-Status finalisieren.
7. Auf itch.io hochladen und den eingebetteten Build erneut testen. Projekt-URL/Zugang und Exportartefakt im neuen Chat klären.

Zieltermin des Nutzers: **16. November 2026**. Keine Veröffentlichung, erfolgreiche Browserprüfung oder verfügbaren Zugriff erfinden. Der Assistent hat bisher keinen AGK-/HTML5-Build ausgeführt.

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

## 7. Übergabe und Historie

[HANDOFF.md](HANDOFF.md) enthält getesteten Referenzcommit, exakte Parameter, Release-Gates, offene Entscheidungen und einen direkten Starttext. Tatsächlichen develop-HEAD neu abfragen, lokale Nutzerdateien/alte Anhänge nicht voraussetzen.

Das gesamte ältere Untersuchungs-/Testprotokoll bleibt [hier im Git-Stand vor Konsolidierung](https://github.com/ChristianEngel19820128/SonecBot/blob/18f92a965810763b552bd96649607c112f966238/TECHNICAL.md), die frühere ausführliche Aufgabenliste [hier](https://github.com/ChristianEngel19820128/SonecBot/blob/18f92a965810763b552bd96649607c112f966238/TODO.md). Diese historischen Quellen nicht als aktuelle Reihenfolge ausführen. Aktuelle Priorität: **abgeschlossener Alpha-Walker → HTML5-Pre-Alpha-Deployment**.

Knowledge-Base-Kandidaten/kurzes Register nach dem dringenden Deployment prüfen; Quellen-/Evidenzstatus erhalten. Arbeitsregeln in AGENTS.md.
