# SonecBot – Technische Dokumentation

**Dokumentstatus:** Konsolidierter Abschlussstand 3.22  
**Stand:** 16. November 2026  
**Branch:** `develop`  
**Letzter lokal getesteter Code:** [`18f92a965810763b552bd96649607c112f966238`](https://github.com/ChristianEngel19820128/SonecBot/commit/18f92a965810763b552bd96649607c112f966238)  
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
3. Gamepad-Index 1 praktisch nachweisen. IntroDo und Pause verwenden Gamepad; Tastatur ist unvollständig, KEY_2 doppelt belegt. Minimalvorschlag Gamepad-only mit klarer Beschreibung; noch nicht abschließend beschlossen/getestet.
4. Spielrunde, Kampf, Pause/Fortsetzen, Tod und mindestens zwei Neustarts testen.
5. Nur konkrete Releaseblocker minimal korrigieren; keine weitere Walkerentwicklung.
6. README/itch.io mit tatsächlichen Controls, Known Limits und Pre-Alpha-Status finalisieren.
7. Auf itch.io hochladen und den eingebetteten Build erneut testen. Projekt-URL/Zugang und Exportartefakt im neuen Chat klären.

Zieltermin des Nutzers: **16. November 2026**. Keine Veröffentlichung, erfolgreiche Browserprüfung oder verfügbaren Zugriff erfinden. Der Assistent hat bisher keinen AGK-/HTML5-Build ausgeführt.

## 7. Übergabe und Historie

[HANDOFF.md](HANDOFF.md) enthält getesteten Referenzcommit, exakte Parameter, Release-Gates, offene Entscheidungen und einen direkten Starttext. Tatsächlichen develop-HEAD neu abfragen, lokale Nutzerdateien/alte Anhänge nicht voraussetzen.

Das gesamte ältere Untersuchungs-/Testprotokoll bleibt [hier im Git-Stand vor Konsolidierung](https://github.com/ChristianEngel19820128/SonecBot/blob/18f92a965810763b552bd96649607c112f966238/TECHNICAL.md), die frühere ausführliche Aufgabenliste [hier](https://github.com/ChristianEngel19820128/SonecBot/blob/18f92a965810763b552bd96649607c112f966238/TODO.md). Diese historischen Quellen nicht als aktuelle Reihenfolge ausführen. Aktuelle Priorität: **abgeschlossener Alpha-Walker → HTML5-Pre-Alpha-Deployment**.

Knowledge-Base-Kandidaten/kurzes Register nach dem dringenden Deployment prüfen; Quellen-/Evidenzstatus erhalten. Arbeitsregeln in AGENTS.md.
