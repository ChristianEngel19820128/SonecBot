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
| physics.agc / collision.agc | Gemeinsame ballistische Zeitintegration und geometrische Sweep-Verfahren; getrennt von Waffenreaktionen |
| weaponcollision.agc | Gemeinsame quellen- und ebenenbezogene Freigabe direkter Waffentreffer |
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

### Sonec-Bewegung: abgeschlossene Architektur (25.11.2026)

- Verbindliche Regeln, Parameterzuständigkeit und Abnahme: [Bewegungsspezifikation](docs/SONEC_MOVEMENT_SPEC.md). Mechanische Kollisionsgeometrie von Schadensgeometrie getrennt.
- `SonecCollidePlate` koordiniert den gemeinsamen relativen Sweep/Resolver; `SonecResolveContact` behandelt frühesten Kontakt und verbleibenden Weg. `SonecPrepareSupportPath` nutzt tatsächliche Trägertranslation; `SonecReleaseSupportMotion` und `SonecSetGroundContact` übernehmen bzw. transformieren Geschwindigkeit einmalig.
- `LinkedPlateIndex` ist Tiefenebene, nicht Support; horizontales Verlassen löst Zuordnung, Landung übernimmt neue Ebene. Lokale dynamische Durchflugfreigabe statt globaler höchster Kiste.
- Direkte Seitenfront und Luft-Eckkreise, Fußlandung, Kisten-Support-Exit und Mini-Hop gemeinsam auflösen. Bewegungsparameter zentral in sonec.agc; aktuelle Werte dort prüfen.
- Temporäre CSV-Diagnose nur unter Debug-Schaltern; Messmethode vor Schlussfolgerungen prüfen. Historische technische Details im [vorherigen Stand](https://github.com/ChristianEngel19820128/SonecBot/blob/0ba2ee8c665325f25a9e7da38a86c9ca49cb7e5a/TECHNICAL.md).

## Flak/Flarak – Proto-Ressourcen und Rundenreset (B1.1, 25.11.2026)

- `TProtoFlarak` hält fünf gemeinsame Sprite-Ressourcen (Basis, Launcher, Flak, Rakete, Warnanzeige), geladen in `GameCreate` über `FlarakProtoLoad`. Instanzen speichern Zustand statt Sprite-IDs. Draw setzt instanzbezogene Position, Winkel, Frame und Farben; Debug-Pivots werden aus Instanzpose berechnet. Kein Create/Delete pro Spawn; Debug-Ressourcen weiterhin separat.
- `FlarakFirstFree` und wiederverwertbare Slots: kein Remove/Umsortieren während einer Runde; Wiederverwendung nur bei deaktivierter Stellung und zwei inaktiven Raketen. `FlarakInit` leert Liste und setzt FirstFree auf 0 in GameInit; Prototypen bleiben geladen. Sockel-Slotzuordnung, Treffergeometrie und freie Raketen bleiben erhalten.
- **Lokaler AGK-Compile und Entwicklertest bestanden (11/11, a2ea2a8, 25.11.2026):** beide Varianten, Animation/Ausrichtung/Schüsse, mehrere Stellungen, isolierte Treffer-/Wrackfarben, Sockel/Plattformbindung/Zeichenreihenfolge, Raketen/Jetstreams, freie Raketen nach Trägerabgang, Debug-Hitboxen, Neustart mit aktiven Raketen und wiederholte Neustarts ohne alte Explosionen oder sonstige Effekte. Keine offenen Einzelpunkte. Der ursprüngliche Flarak-Neustartfehler gilt im geprüften Umfang als behoben; die frühere genaue Quelle kleiner Explosionen wurde nicht separat isoliert.
- Entwickler wünscht weitere Langzeitbeobachtung bei laufenden Spieltests. Keine gesonderte Langzeitmessung, Ressourcenmessung oder HTML5-Abnahme behauptet. Die beiden Index-Recycling-Verdachtsfälle wurden anschließend präventiv korrigiert und lokal abgenommen (siehe unten).

## Vollständiger Rundenreset – Abschluss B1.2–B1.4 (25.11.2026)

- `SonecInit` initialisiert `MGun.FireBurst` und `PlasmaBlitzGun.Upload` mit 0. `GameInit` verwirft `DroneDeathEffectPending` und setzt `DroneDeathPosition` auf (0,0). Normale Waffen-, Drohnen-Zerstörungs- und Belohnungspfade unverändert.
- **Lokaler AGK-Compile und Entwicklertest bestanden (8/8, 7b9bb48, 25.11.2026):** MG einschließlich aufgewerteter Mehrfachsalve, keine ausstehende Salve nach Neustart, Plasmablitz lädt/feuert korrekt, keine Übernahme einer Teilaufladung, Drohnenverhalten, Explosion und Belohnung bei Zerstörung, keine alten Drohneneffekte/Belohnungen nach Neustart. Keine offenen Einzelpunkte, keine Auffälligkeiten gemeldet. Die präventive Drohnen-Reset-Lücke war zuvor nicht als Laufzeitfehler nachgewiesen; kein gezielt erzwungenes Pending-Ereignis behauptet.
- B1 insgesamt im geprüften Umfang abgeschlossen (19/19 gemeldete Testpunkte über beide Pakete). Entwickler wünscht Langzeitbeobachtung beider Pakete in regulären Spieltests. Keine gesonderte Langzeit-/HTML5-Abnahme oder vollständige Randfallabdeckung behauptet. Offene unabhängige Verdachtsfälle siehe KNOWNBUGS.md.

## Flammenwerfer – Partikelbewegung B2.1 (25.11.2026)

- Beim Abschuss normiert SonecFlameGunInput die Eigenbewegung und nur bei Bodenkontakt die zusätzliche Trägerbewegung auf die gemeinsame Timer-Zeitbasis (10 ms / Range 10); letzter Sonec-MoveTimer.CalcRange, Fallback Range. FlameNew übernimmt die resultierende Weltgeschwindigkeit einmalig zusätzlich zur unveränderten Schussgeschwindigkeit 1. Bereits erzeugte Partikel bleiben unabhängig.
- FlameMove bremst beide Achsen zeitabhängig mit bisheriger Bremsstärke 0.01 je 60-Hz-Referenzschritt, integriert den Weg bis zum Stillstand ohne Richtungsumkehr. Keine zusätzliche Schwerkraft. Feuerrate, Lebensdauer, Partikelgröße, Grafik, Energieverbrauch, Schaden, Kollision und Sonec-Bewegungsresolver unverändert.
- **Lokaler AGK-Compile und Entwicklertest bestanden (12/12, 1bed93b, 25.11.2026):** horizontal links/rechts im Stand, Vorwärts-/Rückwärtslaufen, horizontal/vertikal bewegte Plattformen, zusammenhängender leicht gekrümmter Strahl bei Aufstieg/Fall, horizontaler Flug, unabhängige ältere Partikel bei Richtungswechsel, keine auffälligen Lücken oder ungewollt starken diagonalen Bahnen. Keine offenen Einzelpunkte. Entwickler bewertet die Bewegung als berechenbar und fair und wünscht keine weiteren Bewegungsänderungen. Screenshot anschließend im Chat vorgelegt: gekrümmte Flammenbahn nachvollziehbar; Entwickler betont, dass die Bewegung im Spiel besser wirkt als das Standbild.
- Bewegungsfehler damit im geprüften Umfang behoben. Keine separate Framerate-/HTML5-/Langzeitmessung behauptet. Kollision und Deckung anschließend separat in B2.2/B2.3 bearbeitet und abgenommen (siehe unten).

## Flammenwerfer – Durchdringung und zeitabhängige Treffer B2.2/B2.3 (25.11.2026)

- Entwicklerentscheidung: Flammen durchdringen Objekte; keine Beschneidung oder Partikellöschung bei aktiven Treffern. Lebensdauer/Weltgrenzen und abgenommene Partikelbewegung bestimmen den Flug. Bestehende Treffergeometrien und Unverwundbarkeit geschlossener Flak/Flarak-Silos bleiben erhalten.
- Schaden 5 je Partikel und Ziel bei Erstkontakt, danach frühestens nach FLAME_DAMAGE_INTERVAL_MS = 100 ms virtueller Spielzeit bei weiterer Überlappung; keine Nachholtreffer. Individuelle FlameTargetId bei Zielerzeugung trennt neue Instanzen auch bei wiederverwendeten Slots und beide Minenlisten. HitList wird bei jeder Partikelerzeugung geleert; Flammenliste und Zielserial werden bei Rundenreset zurückgesetzt. Raketen und Bomben weiterhin sofort abfangbar, ohne Partikelverbrauch. Nicht aufgerufener Selbstschadenspfad FlameCollide und bestehende Explosions-Cooldowns unverändert.
- **Lokaler AGK-Compile und Entwicklertest bestanden (13/13, 7c44b93, 25.11.2026):** Bewegung/Strahlform unverändert, Kisten durchdrungen, mehrere Ziele hintereinander beschädigt, Orbs und beide fliegenden Minenarten, Walker-Turm, Drohne, Bomber, ausgefahrene Flak/Flarak, Jumppods und Plattform-Landminen beschädigbar; geschlossene Silos geschützt; Raketen/Bomben abgefangen; länger anhaltender Schaden plausibel; Neustart ohne Altpartikel oder Trefferzustände. Keine offenen Einzelpunkte. Zeitintervall und Instanztrennung zusätzlich im separaten Rechenmodell geprüft, keine instrumentierte Laufzeitmessung behauptet.
- Entwickler bewertet Schaden als relativ ähnlich zu älteren SonecBot-Versionen; starke Waffe mit Energieverbrauch, zunächst alles in Ordnung. Endgültiges Balancing später; keine zusätzliche Balanceänderung. B2 im geprüften Umfang abgeschlossen (25/25 gemeldete Testpunkte über beide Pakete). Keine gesonderte Langzeit-/HTML5-Abnahme behauptet.

## Granaten – früheste Kollision auf dem Flugsegment B3.1

- `collision.agc`: waffenunabhängige Rechteck- und Kreis-Sweep-Funktionen liefern Eintrittsanteil 0..1 oder -1. `TGrenade.PreviousPosition` bei Erzeugung und jedem Bewegungsschritt gesetzt. `GrenadeCollideAll` ermittelt den frühesten Treffer aller bisherigen Ziele einschließlich Bomber, Raketen und Bomben; bisherige Zieltyp-Reihenfolge nur bei Gleichstand. Bestehende Geometrie (Flak/Flarak mit 2px-Zielabtastung) und Siloschutz erhalten.
- Direktschaden an erstem Ziel, reguläre Granatendetonation am Eintrittspunkt; Abfangtreffer behalten die bisherige einzelne Zielexplosion. `GrenadeDestroy` gegen Mehrfachaufruf abgesichert; Weltgrenzenlöschung nach Kollisionsprüfung. Flugphysik und Bullet-Pfade unverändert. Bewegte Ziele zunächst an aktueller Pose, relative Bewegung bleibt B3.3. Ballistische Physik in B3.4 separat implementiert und abgenommen (siehe unten).
- **Lokaler AGK-Compile und Entwicklertest bestanden (14/14):** Implementierung 7831960, notwendige AGK-Syntaxkorrektur 7c3d73a (Sweep-Ergebnis zuerst einer lokalen Float-Variable zuweisen). Entwickler verwendete ursprüngliches Testformular mit Referenz 7831960 nach Compile-Korrektur erneut. Bestätigt: unveränderte Flugbahn/Reichweite, Kisten/Plattformen, Orbs und beide fliegenden Minenarten, Walker-Turm, Drohnen/Bomber, ausgefahrene Flak/Flarak, geschlossene Silos geschützt, Jumppods/Plattform-Landminen, Abfangen von Raketen/Bomben, nachvollziehbarer Auftreffpunkt, keine auffälligen Mehrfachexplosionen, erster Kontakt gewinnt, Weltgrenzen. Keine offenen Einzelpunkte; präzise explodierende Granaten laut Entwickler.
- Separate Rechenmodellprüfung der Sweep-Verfahren 12/12; keine instrumentierte Laufzeitmessung oder Langzeit-/HTML5-Abnahme behauptet. B3.1 abgeschlossen, übrige B3-Befunde bleiben offen.

## Flak/Flarak – früheste Kontakt-Explosionsposition und Flak-Zeitzünder B3.2

- `BulletSonecImpactEntry` nutzt die bestehende Treffersemantik (aktive Zwei-Kreis-Geometrie, bisheriger strikter Bullet-Hittest und Debug-Schalter, kein zusätzlicher Projektilradius); `CollisionCircleSweepEntry` bestimmt den frühesten Eintritt. Explosive Flak-Bullets erzeugen dort die bisherige Explosion Typ 3, keinen zusätzlichen Direktschaden. Bei fälligem Zeitzünder begrenzt `BulletMove` den Flugweg auf die Frist (auch letzter Teil-Tick); `BulletCollide` vor `BulletExplosiveFuses`. Zündzeitraum 175–200 ms unverändert.
- `FlarakRocketHitsSonec` verwendet das bisherige Segment zwischen alter und neuer rotierter Raketenspitze und beide zentralen Sonec-Kreise; Explosion Typ 3 am frühesten Eintritt. Flug, Homing, Abfangen, Lebensdauer und Weltgrenzenregeln unverändert. Standard-Bullet-Treffer und bestehende Schadens-/Schildlogik erhalten. Weltgrenzenlöschung vor Trefferprüfung sowie relative Bewegung der Kollisionspartner bleiben Randfälle für B3.3.
- **Lokaler AGK-Compile und Entwicklertest bestanden (11/11, 4a954f8):** Flak feuert in beide Richtungen, Zeit- und Kontaktzündung plausibel, Flarak-Start/Homing unverändert, Einschlag an der Raketenspitze, Stehen/Ducken, Schild und Lebenspunkte plausibel, keine auffälligen Mehrfachexplosionen, Raketen abfangbar, normale MG-Geschosse unverändert. Keine offenen Einzelpunkte. Entwickler berichtet, dass Flak gefährlicher wirkt und Treffer meist an den Beinen beim Überfliegen entstehen. Explosionsgröße und endgültiges Balancing ausdrücklich nachgelagert.
- Separate Rechenmodellprüfung 11/11, keine instrumentierte Laufzeitmessung oder Langzeit-/HTML5-Abnahme behauptet. B3.2 im geprüften Umfang abgeschlossen.

## Relative Projektil-Sweeps gegen Sonec B3.3a

- `CollisionRelativeSweepEntry` in collision.agc: relative Kreis- bzw. horizontale Kapsel-Sweeps; strikte Tangentenregel für Gegnerbullets, inklusive Randtreffer für Laser/Raketen. Keine Vergrößerung der bestehenden Treffergeometrie.
- sonec.agc: passive, begrenzte Historie der mechanisch aufgelösten Teilstrecken mit Zeitintervallen und Körperkreis-Offsets/-Radien; `SonecDamageSweepEntry` prüft nur überlappende Zeitabschnitte und liefert den Eintrittsanteil des ursprünglichen Projektilsegments. Neue Schüsse prüfen frühestens ab ihrer Erzeugung; offene Bewegungsgates werden beim folgenden simulierten Schritt berücksichtigt. Mechanische Resolver-Entscheidungen unverändert.
- `BulletSonecCircleEntry` ersetzt die bisherigen statischen Gegnerbullet-Tests einschließlich Debug-Vergleich und Kontaktanteil; Flak-Zündfrist bleibt begrenzend. Laser und Flarak-Raketen lösen ihre Treffer nach SonecCollidePlate und vor Spielerwaffen aus. Laser weiterhin 30px horizontal; Raketenspitzen-Sweep einschließlich Trägertranslation. Schadenswerte, Schild, Flugsteuerung und Explosionsschadensregeln unverändert. Bomberbomben in B3.3b gemeinsam behandelt und abgenommen (siehe unten); B3.3c Abfangziele und Weltgrenzen abgenommen (siehe unten).
- **Lokaler AGK-Compile und Entwicklertest bestanden (14/14, 0c0a111, 26.11.2026):** Lauf/Sprung/Flug, Landungen/Kistenkontakte/Mini-Hop, bewegte Plattformen, Gegnerbullets, Flak-Treffer/Explosionsposition, Raketen-Homing/Treffer, Raketenstart/Jetstream/Abfangen, Laser in beide Richtungen, Laser-Ausweichen, Stehen/Ducken, Schild/HP, Neustart und keine spürbaren Performance-Einbußen. Keine offenen Einzelpunkte, keine zusätzlichen Beobachtungen.
- Separate Rechenmodellprüfung 17/17; keine instrumentierte Performance-Messung, Langzeit- oder HTML5-Abnahme behauptet. B3.3a im geprüften Umfang abgeschlossen.

## Relative Bomberbomben-Kollision B3.3b

- `BomberBombCollideAll` ersetzt die getrennten Sonec-, Kisten- und Plattformabfragen nach SonecCollidePlate. Frühester Kontakt pro Bombe; exakte Gleichstände in bisheriger Zieltyp-/Slotreihenfolge, mehrere Bomben weiterhin in Listenreihenfolge. `SweepStartMs` und PreviousPosition je Update, kein erneuter Sweep bei Nullzeit. SonecDamageSweepEntry mit unverändertem Bombenradius; relative Kisten-AABB und bewegte Plattformoberkante mit bisheriger +5px-Spitze. Neuschüsse und neu entstandene Träger werden zeitlich eingegrenzt.
- Plattformgebundene Explosion wird vom Kontaktpunkt um die restliche Trägertranslation zur aktuellen Plattformpose mitgeführt; ExplosionAddAboveY, Abschirmung, Verbundgrafik und Reward bei zerstörter Kiste bleiben erhalten. Bei zerstörter eigener Vordergrund-Stützkiste mechanischen Slot deaktivieren und SonecCollideReset verwenden; keine rückwirkende Neuberechnung des mechanischen Weges. Flugphysik, Schadenswerte und Abfangpfade unverändert. B3.3c relative Abfangkollisionen und Weltgrenzen abgenommen (siehe unten).
- **Lokaler AGK-Compile und Entwicklertest bestanden (15/15, bf39985, 26.11.2026):** Bomberflug/Abwurf, Bombenfall, Direkttreffer auf bewegten Sonec, Schildwirkung, Kistenzerstörung/Reward, horizontale und vertikale Plattformbewegung, mitgeführte Explosion, Schutz direkt unter Plattform, Schaden außerhalb der Kanten, frühester Kontakt, Fallen nach Stützkistenzerstörung, Abfangbarkeit, keine auffälligen Mehrfachexplosionen oder spürbaren Performance-Einbußen. Keine offenen Einzelpunkte und keine zusätzlichen Beobachtungen.
- Separate Rechenmodellprüfung 18/18; keine instrumentierte Performance-Messung, Langzeit- oder HTML5-Abnahme behauptet. B3.3b im geprüften Umfang abgeschlossen.

## Relative Abfangkollisionen und Weltgrenzen B3.3c

- `CollisionTimedCircleEntry` in collision.agc prüft überlappende Zeitintervalle von MG, Granaten und Flammen mit den Zentren bewegter Flarak-Raketen und Bomberbomben. Bei geschlossenem Bewegungsgate stationäre aktuelle Pose ab letzter Framegrenze bzw. Erzeugung. `CollisionTimedAreaEntry` prüft den Zielweg gegen die aktuelle Plasma-Rechteckpose, frühestens ab Plasma-Erzeugung. MG wählt innerhalb der jeweiligen Abfang-Zielfamilie den frühesten Kontakt; Granaten behalten die gemeinsame Trefferauswahl.
- Vorhandene Radius-/Flächengrößen, Projektilverbrauch (MG/Granate verbraucht, Flamme/Plasma bleiben aktiv), Explosionsarten und Abfang-Explosionsposition am Zielendpunkt erhalten. Keine Flugphysik- oder Schadensparameteränderung. Bullets, Raketen und Bomben prüfen das letzte vollständige Flugsegment vor der Weltgrenzenlöschung. Flammen werden nach Abfangprüfung wie bisher vor übrigen Flammenschäden gelöscht. Flak-Zeitzündung außerhalb der Welt ohne Kontakt weiterhin unterdrückt, Raketenlebensdauer unverändert.
- Grenzen: keine globale Ereignissortierung zwischen Waffen-/Zielfamilien, keine exakte Begrenzung auf Grenzübertrittszeit, keine zusätzliche frameübergreifende Zielhistorie; Plasma-Pose und wachsender Flammenradius am aktuellen Update abgetastet. B3.3 im vereinbarten Umfang abgeschlossen; B3.4 Flugphysik separat abgenommen (siehe unten).
- **Lokaler AGK-Compile und Entwicklertest bestanden (15/15, 66ddfe5, 26.11.2026):** Raketen und Bomben mit allen vier Waffen abfangbar, Flammen und Plasma bleiben aktiv, Abfangexplosionen/Verbrauch plausibel, Weltgrenzenlöschung und normale Flak-Zeit-/Kontaktzündung unverändert, keine auffälligen Mehrfachexplosionen oder spürbaren Performance-Einbußen. Keine offenen Einzelpunkte und keine zusätzlichen Beobachtungen.
- Separate Rechenmodellprüfung 16/16; keine instrumentierte Performance-Messung, Langzeit- oder HTML5-Abnahme behauptet.

## Gemeinsame ballistische Flugphysik B3.4

- physics.agc: PhysicsLaunchVelocity, PhysicsHorizontalRangeGravity und PhysicsBallisticStep; Einheiten px, ms, px/ms, px/ms², positives Y nach unten. Analytische konstante Gravitation und optionaler linearer Luftwiderstand (Werfer: 0); keine Abhängigkeit von Sprite, Kollision oder Waffenlogik. Ersetzt das Quadrieren der vertikalen Beschleunigung pro GrenadeMove-Update. Bestehender Bewegungstakt und lineare Sweeps bleiben erhalten; gekrümmte Flugbahn innerhalb eines einzelnen Kollisionssegments weiterhin linear angenähert.
- Granatwerfer 3 px/ms horizontal, 675 px Referenzreichweite ab Mündung bei stehender Referenzhöhe minus vertikaler Granaten-Halbausdehnung, ca. 225 ms rechnerische Flugzeit. Konstante Gravitation beim Ducken und im Flug, entsprechend andere Reichweite; unveränderte Eingabe, Feuerrate, Munition, Rückstoß, Schadens- und Abfangreaktionen. Spätere Wurfgranaten und kombinierte Eingabe getrennt.
- **Lokaler AGK-Compile und Entwicklertest bestanden (12/12, 1c32657, 26.11.2026):** horizontale Schüsse beidseitig, flache gleichmäßig gekrümmte Flugbahn, ca. 3/4 Bildschirmbreite im Stehen, kürzer im Ducken/länger aus höherer Position, Treffer und Abfangen, Explosionsposition, Feuerrate/Munition/Rückstoß, übrige Waffen/Sonec-Bewegung und Weltgrenzen bestätigt. Entwickler bewertet Granatwerfer gegenüber früherer unpräziser Version als verbessert. Neuer separater Tiefenüberdeckungsbefund in KNOWNBUGS.md, kein offener B3.4-Einzeltest.
- Separate Rechenmodellprüfung 15/15; keine instrumentierte Framezeitmessung, Langzeit-/HTML5-Abnahme oder tatsächliche Nutzung des optionalen Luftwiderstands im Spiel behauptet. B3.1–B3.4 im vereinbarten Umfang abgeschlossen.

## Waffen-Tiefenfreigabe (26.11.2026)

- TWeaponDepth / WeaponDepthAllows: gesperrte Plattformidentitäten und getrennte Hintergrund-Unterebenen. MG, Granatwerfer, Flammenpartikel und Walker-MG übernehmen beim Abschuss eine unveränderliche Momentaufnahme; aktives Plasma übernimmt aktuelle Pose und Freigabe vor der Schadensprüfung, abgelöster Resteffekt behält den letzten Zustand. Sonec nutzt SONEC_DEPTH_PASSAGE und gültigen mechanischen PassThroughChestIndex sowie tatsächliche Hintergrundkisten-Überdeckung. Walker nutzt vorhandene Bewegungshülle und Trägergeometrie. Eindeutige Plattform-ID pro Erzeugung schützt Projektil-Snapshots vor Slot-Recycling; dieselbe ID wird in der späteren präventiven Flarak-Recycling-Korrektur verwendet (siehe unten).
- Direkte bestehende Trefferpfade einschließlich zusätzlicher Bullet-Kistenprüfung gefiltert; freie Gegner/Abfangziele, Flak, Bomberbomben, indirekte Explosionen, Bewegungsmechanik unverändert. Neu erzeugte Plattformen nicht in alten Snapshots; Walker-Überdeckung angenähert, keine neuen Körperteil-Trefferzonen.
- **Lokaler AGK-Compile und Entwicklertest bestanden (18/18, 8d3c8a1, 26.11.2026):** alle vier Waffen gegen Hintergrundkisten und bei Durchflug, freie Hintergrund-/Vordergrundziele, plattformgebundene Ziele, andere Ebenen, gespeicherte Projektilfreigabe, Live-Plasma, freie Gegner/Abfangen, Walker-MG, Flak/Bomber, Explosionen/Deckung, Bewegung/Animation, Neustart und subjektive Performance bestätigt. Keine offenen Einzelpunkte. Entwickler: großer Testaufwand, zufriedenstellend. Separater Rechenmodelltest 22/22; keine instrumentierte Langzeit- oder HTML5-Abnahme.
- Separater mechanischer Befund: unerwarteter Durchfall durch tiefer liegende Plattform mit Todesfolge; Zusatzkorrektur lokal abgenommen (siehe unten). Keine nachgewiesene Regression durch weaponcollision.agc.

## Landefreigabe tieferer Plattformen (26.11.2026)

- Quell-/Rechenmodell reproduzierte gültige relative Fußkreuzung, die wegen bestehender PASSAGE und naher höherer Kiste verworfen wurde. Exakter ursprünglicher Todesablauf ohne Trace nicht nachgewiesen. SonecLowerLandingAllowed ergänzt nur die Top-Kandidatenauswahl für aktive tiefere Träger und deren mechanische Kisten/Sockel. Vergleich interpolierter Trägeroberkanten am Kontaktzeitpunkt; SonecRememberLandingReference speichert bei Landung/Entkopplung und am erreichten Frame-Ende die letzte gültige Trägerhöhe. Kein Zusatzfilter vor erster Landung; nach Trägerverlust letzte bekannte Höhe. Bestehende Top-Geometrie, frühester Kontakt, Seiten-/Unterseitenregel, Aufwärtsdurchflug, Waffenfreigabe und Bewegungsphysik unverändert.
- **Lokaler AGK-Compile und Entwicklertest bestanden (6/6, 5bfba31, 26.11.2026):** Landung auf tieferen Plattformen nach Entkopplung, Kisten/Sockeln und bewegten tieferen Plattformen, Aufwärtsdurchflug höherer Plattformen, reguläre Bewegung/Seitenkontakte/Waffenfreigabe plausibel. Keine offenen Einzelpunkte. Rechenmodell 20/20, keine instrumentierte Langzeit-/HTML5-Abnahme. Im vereinbarten Umfang abgeschlossen.

## Präventive Plattform-/Flarak-Recycling-Korrektur (26.11.2026)

- TFlarak.CarrierPlateId übernimmt vorhandene TPlate.WeaponDepthId bei Spawn. FlarakDetachRecycledPlate deaktiviert alte Stellungen/Wracks vor Neubelegung des Trägerslots in PlateAdd; löst aktive Raketen ohne zusätzliche Bewegungsintegration, Flarak-Slot bleibt bis Ende beider Raketen belegt. FlarakCarrierMatches prüft Trägeridentität in Update, Zeichnung, Rauch, Sockelplatzierung/-mechanik und Walker-Tiefenerfassung. Keine neuen ID-Zähler oder Änderungen an Spawnwahrscheinlichkeit, Raketenphysik und Rauchgestaltung.
- Explosion.LastFlarakTargetId nutzt vorhandene eindeutige FlameTargetId neben LastFlarakHitMs; beim Wechsel der Zielinstanz nur zugehörigen Cooldown zurücksetzen. ExplosionNew leert beide Listen. Gleiches Ziel behält bisherigen Schadensrhythmus; Pools und IDs beim Rundenneustart zurückgesetzt.
- **Lokaler AGK-Compile und Entwicklertest bestanden (6/6, 985bde4, 26.11.2026):** Flak/Flarak normal, Wracks/Rauch, Raketen bei Trägerverlust, Explosionsschaden, Neustart und längerer Spielbetrieb ohne auffällige Recyclingfehler. Keine offenen Einzelpunkte. Getrennte Modellprüfung 19/19; exakte seltene Recycling-Sequenzen nicht separat lokal reproduziert, keine instrumentierte Langzeit-/HTML5-Messung oder allgemeine Prüfung aller Objekttypen. Beide registrierten Verdachtsfälle im vereinbarten Umfang präventiv bearbeitet.
- Bug-Chat abgeschlossen: 155/155 lokale Testpunkte in 13 Implementierungspaketen, eine Compile-Korrektur, keine funktionale Nachkorrektur. Kein Beleg vollständiger Fehlerfreiheit.

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

Der Entwickler berichtet von Performance-Einbußen nach längerem Testen, die sich durch einen Browserneustart wieder besserten. Erneute Beobachtung am 26.11.2026 nach der Waffen-Tiefenfreigabe: auch Chat-Texteingabe träge, Browserneustart beabsichtigt. Kein isolierter Nachweis der Ursache, kein belegter Zusammenhang mit Spiellaufzeit oder neuer Waffenlogik, keine neue Messung.

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

## Phase B – B01: zentrale Schadensgrundlage

**Status: abgeschlossen im vereinbarten Umfang (28.11.2026).**

- `damage.agc`: gemeinsame Schadens-/Verursachertypen, zentrale HP-Verarbeitung aller aktiven Kampfpfade, getrennte Schildabsorption über die unveränderte Schildfunktion. Roh-HP bleiben vorzeichenbehaftet; effektiver Verlust = max(0, max(0, HP vorher) - max(0, HP danach)). Keine vorgezogenen Änderungen von Schwellen, Geometrie, Intervallen, Reaktionen oder Drops.
- Wert-Snapshots mit ursprünglicher Partei/Instanz und unmittelbarer Quellenart/-ID; IDs unabhängig von Array-Slots, Quellenzähler und Ereignis-Snapshots in GameInit zurückgesetzt. Verzögerte Zerstörung behält Herkunft des Schwellenübertritts; Erholung auf nichtnegative HP verwirft sie. Kettenexplosionen übernehmen ursprüngliche Partei/Instanz, Abfangexplosionen den Abfangenden; Kontaktminen sich selbst. Normale Zerstörungsereignisse enthalten keinen nochmals anrechenbaren HP-Verlust; direkte Entfernung ohne HP-Abzug erfasst verbleibende positive HP separat.
- `DamagePublishHit` / `DamagePublishDestruction` sind synchrone Erweiterungspunkte für spätere Pakete; begrenzte letzte Ereignis-Snapshots, keine Queue, keine XP-/Entlastungsberechnung. Überladung und übermäßige Energieaufnahme bleiben außerhalb der Kampfverarbeitung.
- Vier nicht referenzierte Altpfade entfernt (BulletCollideOrbs, BulletCollideWalkers, FlameCollide, PlasmaBlitzCollide). Sonstige Bereinigung bleibt B13.
- Debug-Taste 0 schaltet `sonec_damage_diagnostics.csv` im app-lokalen AGK-Schreibverzeichnis ein/aus. Trace standardmäßig und nach Neustart aus, keine Datei-I/O im normalen Betrieb; erneute Aktivierung schreibt mit neuer Rundennummer weiter. Datei-I/O bei Diagnose kann Performance beeinflussen. CSV enthält Runde, Sequenz, Ereignisart, ursprünglichen Eigentümer, unmittelbare Quelle, Ziel, angeforderten Schaden, Schildabsorption, Roh-HP und effektiven Verlust.

B01 abgeschlossen im vereinbarten Umfang: lokale Abnahmen d1 13/13 (a13893e), d2 14/14 (6d80fc9), d3 17/17 (2852d91), e 10/10 (a46bea6), CSV-Ergänzung 5/5 (zusammen 59/59 bestätigte Prüfpunkte). Drei Schadens-CSV-Aufzeichnungen: 471 Ereignisse, 402 Treffer, 69 Zerstörungen; alle 402 Roh-HP- und Effektivverlustberechnungen korrekt, keine doppelten Zerstörungen innerhalb einer Aufzeichnung/Runde, keine Sequenzlücken. Trefferbilanz: 7898 angefordert, 7311 effektive HP, 156 Schildabsorption, 431 Überschuss. Plasmablitz im dritten Trace 19 Treffer (190 angefordert, 175 effektiv), zwei Zerstörungen; Quellentyp 23, Sonec als Eigentümer. Mehrere Runden, Kettenreaktionen, Drohnenlaser und direkte Bombentreffer nachgewiesen. Abfangen aller vier Spielerwaffen funktional bestätigt und Herkunftsweitergabe in Bomber-, Flarak-, Granaten- und Explosionscode statisch überprüft; CSV unterscheidet Abfangexplosionen nicht eindeutig von anderen Spielerexplosionen, daher kein isolierter CSV-Nachweis behauptet. Keine neuen Bugbefunde. Keine Langzeit-/HTML5- oder vollständige kombinatorische Randfallabnahme.

## Phase B – B02ab: Vorbereitung

Schadensarten und AP werden beim Start jeder Quelle als Wert-Snapshot gesetzt. Neue Explosionen übernehmen weiterhin nur OwnerKind/OwnerId. Zielprofile werden für bestehende Objekttypen zentral über DamageTargetArmor bestimmt; Sonec besitzt vier individuelle Werte, die in SonecInit auf 0 gesetzt werden. damagearmor.json enthält die fünf Profile; DamageArmorLoad lädt einmal bei GameCreate, prüft Version/Werte und nutzt bei erkannter ungültiger oder fehlender Datei die Konzeptmatrix. AGK-Verhalten bei fehlerhaftem JSON/fehlenden Feldern lokal noch prüfen. DamageReducedHP bereitet proportionale AP-Berechnung mit Immunität und Mindestschaden vor, wird in B02ab noch nicht zur HP-Verarbeitung aufgerufen. CSV enthält zusätzlich Typ, Profil, Basis-/effektive Resistenz, AP, verhinderte HP, HP-Schaden und Konfigurationsladestatus; Resistenzverhinderung bleibt bis B02c null. Kontakt ohne HP-Treffer hat Typ 0. Lokaler AGK-Compile und Funktionstest B02ab 10/10 bestanden (0ebecb5, Entwickler, 28.11.2026). Erste CSV mit fehlender lokaler JSON-Datei nutzte die Standardmatrix; Entwickler hat die fehlende Datei im Compile-Verzeichnis ergänzt und erneuten Test geliefert. Kein Pfadcode geändert.

## Phase B – B02c: Aktivierung

DamageApplyHP verarbeitet jetzt einmalig die Resistenz nach bestehender Schildabsorption. Direkte und verzögerte HP-Pfade nutzen dieselbe Funktion; verzögerte Attribution nutzt Result.HPDamage vor Zustandszuweisung. Individuelle Sonec-Resistenzen werden bei Verwendung auf 0–75 begrenzt. Unmittelbare Zerstörungen unverändert. Bei Einschalten der Debug-CSV (Taste 0) läuft ein isolierter 31-Punkte-Selbsttest mit lokalen Wertkopien ohne Spielereignisse: 20 Matrixberechnungen, acht AP-/Immunitäts-/Rundungs-/Schildfälle, unabhängige Profilwerte und zwei Zerstörungsschwellenfälle. Anzeige selftest x/31 und JSON 0/1. Die Matrixprüfung verwendet die geladenen Werte als Rechenbasis; die tatsächliche externe Änderung ist separat lokal zu prüfen. AGK-Compile und B02c-Spieltest offen.
