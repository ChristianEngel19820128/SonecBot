# SonecBot – Jumppod, Landmine, Sockel und Rauch (A5)

**Stand:** 25. November 2026 · **Branch:** develop
**Status:** Fachlich abgestimmt; Implementierung und lokale Abnahme offen.
**Codebasis der Voranalyse:** [37682ba9](https://github.com/ChristianEngel19820128/SonecBot/commit/37682ba92c148a637b657beb9fb5e9fc1d98ec1c).
Bewegungsgrundlage: [SONEC_MOVEMENT_SPEC.md](SONEC_MOVEMENT_SPEC.md). Parameter sind zunächst plausible zentral einstellbare Testwerte, keine endgültige Balance.

## 1. Gemeinsame Sockelregeln (J1–J3)

- Identische plattformgebundene zweistufige Sockelgeometrie für Jumppod, Landmine und Flak/Flarak: exakt zwei Rechtecke, oberes Rechteck ist zugleich der aktive Bereich von Pod bzw. Mine. Keine dritte Triggerform, kein automatisches Treppensteigen.
- Sonec kann auf beide Oberseiten springen und darauf landen; Seitenkontakt blockiert entsprechend den bestehenden mechanischen Bewegungsregeln. Nur gültiger Kontakt von oben am oberen Rechteck kann eine Funktion auslösen.
- Beide Rechtecke bleiben nach Zerstörung mechanisch erhalten; der Sockel bleibt sichtbar, wird wie zerstörte Flak/Flarak umgefärbt und hat keine aktive Pod-/Minenfunktion mehr. Sonecs Waffen kollidieren weiterhin mit beiden Rechtecken von Pod/Mine, aber der zerstörte Sockel nimmt keinen weiteren Schaden.
- Plattformentranslation, Tiefenregeln, frühester gültiger Kontakt, Restweg und einmalige Trägerübernahme bleiben erhalten. Schadensgeometrie von Sonec bleibt getrennt.
- Walker dürfen neben Pods/Minen erscheinen und laufen an ihnen auch nach Zerstörung vorbei; keine Walker-Kollisions-/IK-Änderung und keine Walker-Auslösung. Gegnerische Geschosse ignorieren Pods/Minen und deren Wracks vollständig (kein Treffer, keine Blockade); allgemeine Explosionen aller Ursprünge dürfen intakte Objekte beschädigen und Kettenreaktionen auslösen.
- Flak/Flarak erhalten in J3 die gemeinsame mechanische Sockelgeometrie für Sonec. Ihre bestehende Bewaffnung, KI, Silofunktion und Schadenszonen/Siloschutz bleiben unverändert. Kein Pod-/Minentrigger und keine Änderung der bestehenden Gegnerwaffenregeln für Flak/Flarak.
- Zerstörung löst genau einmal die vorgesehene Explosion, Umfärbung und später Rauch (J4) aus; Wracks bleiben bis zur Entfernung am Weltende erhalten.

## 2. J1 – Jumppod

- Grafik: `media/gfx/plate/jumppod.png`, zwei Frames: 1 = bereit, 2 = ausgelöst. Der obere Teil ist der Pod selbst.
- Gültiger Kontakt von oben mit dem oberen Rechteck bei Frame 1 löst automatisch, ohne Tastendruck, einen Sprungimpuls aus; Faktor 2.0 des normalen vertikalen Sprungimpulses (aktuell 8, also zunächst 16), keine Energiekosten.
- Frame 2 sofort anzeigen; Dauer als kurzer Millisekundenparameter. Währenddessen keine erneute Auslösung; mit Rückkehr zu Frame 1 wieder nutzbar. Kein zusätzlicher Animationsablauf.
- Der Impuls ist der doppelte normale Absprungimpuls, nicht das Doppelte der Sprunghöhe. Horizontales Momentum, Trägerübernahme und anschließende Schwerkraft/Kollisionen wie bei normalem Sprung; kein Jetpack-Zwang.
- Lebenspunkte; durch alle vier Spielerwaffen und allgemeine Explosionen zerstörbar. Kleine, tatsächlich schadensverursachende Zerstörungsexplosion.
- Nach Zerstörung Frame 1 bzw. Sockeldarstellung in Wrackfarbe; keine Auslösung mehr.

## 3. J2 – Landmine als Attrappe

- Grafik: `media/gfx/enemies/landmine.png`. Dieselbe Grundsilhouette und dieselben beiden Rechtecke wie der Jumppod, kein zweiter Auslöseframe.
- Von weitem nicht eindeutig unterscheidbar; aus der Nähe zentrales blinkendes 2×2-Pixel-Quadrat als Erkennungsmerkmal. Blinkintervall, Farbe und Sichtbarkeitsdistanz sind Testparameter.
- Nur gültiger direkter Kontakt von oben am oberen Rechteck löst aus: sofortige Explosion und Zerstörung ohne Wartezeit, Umfärbung und in J4 Rauch. Keine Auslösung beim Seitenkontakt.
- Lebenspunkte und Fernzerstörung durch alle Spielerwaffen; auch allgemeine Explosionen können zerstören. Eigene schadensverursachende Explosion deutlich heftiger als die des Jumppods.
- Nicht mit intelligenten oder einfachen fliegenden Minen vermischen. Keine Änderungen an deren Verhalten.

## 4. Platzierung / Testbetrieb

- Regelmäßige zeitbasierte Testerzeugung auf geeigneten Plattformen (Spielzeit, Pause respektieren); 75 % Jumppod, 25 % Landmine nach Integration von J2. J1 zunächst mit Pods allein testbar.
- Keine Überlappung mit Kisten, Flak/Flarak, anderen Pods/Minen oder deren verbleibenden Sockeln; auch vorhandene Flak/Flarak-Wracks berücksichtigen. Walker sind ausdrücklich ausgenommen.
- Plattformgebundene Objekte müssen vollständig auf einen geeigneten freien Abschnitt passen. Technischer Vorschlag: kein freier Platz → Versuch ohne Verschieben bestehender Objekte auslassen.
- Spawnintervall, Lebenspunkte, Explosionsstärke/-radius, Blinkparameter, Frame-2-Zeit und exakte Rechteckmaße zunächst sinnvoll auslegen und zentral parametrieren. Feinabstimmung erst im sichtbaren Spieltest; keine globale Balanceänderung.

## 5. J4 – Wiederverwendbare Rauch-Unit

- Eigene `source/sonec/smoke.agc` mit Grundfunktionen `ProtoSmokeLoad()`, `SmokeInit()`, `SmokeAdd()`, `SmokeDoAll()`, `SmokeDrawAll()`, `SmokeDeleteAll()`; gemeinsame Parameterliste, keine objektspezifischen Partikelimplementierungen.
- Grafiken `media/gfx/effects/smoke/smoke_1.png` bis `smoke_5.png`. Individuelle Partikel mit Bildvariation und Rotation (zufällige Start-/Rotationswerte als Testansatz).
- Kontinuierlicher Emitter am Zerstörungspunkt; folgt dem zerstörten Objekt/der Plattform, solange dieses existiert. Rauchmenge steigt allmählich bis zur vorgesehenen Dichte. Wenn das Objekt am Weltende entfernt wird, endet die Emission. Bereits emittierte Partikel leben unabhängig bis zum Ausfaden; Neustart räumt alles auf.
- Partikel bewegen sich in Weltkoordinaten, steigen auf und driften mit zufälliger relativer Geschwindigkeit nach rechts (Energiepartikel als Orientierung), rotieren, faden bis zur Auflösung aus und werden dabei nur minimal kleiner.
- Reiner visueller Effekt. Gleiche Rauchfunktion für Pod, Mine, Flak/Flarak und künftige Nutzer; Unterschiede in der Dichte nur durch mehr/weniger Partikel.
- Parameter: Emissionsintervall und Zufallsstreuung, Anlaufdauer, Partikelanzahl, Lebensdauerbereich, X-/Y-Geschwindigkeitsbereiche, Rotationsbereich, Startalpha, Start-/Endgröße (Endgröße nur leicht kleiner). Plausible Werte bei Implementierung; Feinjustierung nach Sichttest.

## 6. Technische Voranalyse und Paketgrenzen

Quellbasis 37682ba9; folgende Integrationspunkte sind geprüft, der Entwurf ist noch kein implementierter Code:

- J1: `sonec.agc` – `SonecFindContact`, `SonecResolveContact`, `SonecCollidePlate`, `SonecPrepareSupportPath`, `SonecSupportExitTime` und Tiefenfreigabe sind auf PlateList/ChestList zugeschnitten. Neue Rechtecke als mechanische Kandidaten desselben Resolvers einbeziehen, nicht nachträglich die Position überschreiben. Keine gewöhnlichen Kisten in die gemeinsame ChestList einschleusen: sie würde auch Walker, Spawn, Waffen, Rewards und Lebenszyklus beeinflussen. Gemeinsame Rechteckdaten/Abfragen für Sockel und Kisten gezielt prüfen; stabiler Objekt-/Rechteckbezug auch bei Wrack und Slot-Wiederverwendung.
- `SonecStartNormalJump`, `SonecReleaseSupportMotion`, `SonecMoveVerticalSpeed`: normalen Impuls und Trägerübernahme wiederverwenden; Pod-Impuls nur einmal am akzeptierten Oberkontakt anwenden, Restweg entsprechend prüfen, keine zweite Landung/Auslösung im selben Kontakt. Normalsprung und Jetpack-Eingaberegeln erhalten.
- `game.agc`: `GameProtoLoad`, `GameInit`, `GameDo`, `GameDraw`; plattformgebundene Start-/Endpositionen nach dem Plattformtick, vor Kontaktresolver aktualisieren. `PlateCheckAll` entfernt Plattformen am linken Rand; Sockel und Referenzen vor Slot-Wiederverwendung bereinigen. Zeitsteuerung auf virtuellem Spiel-Now, nicht auf Framezahl. Vorhandene Grafikänderungen außerhalb A5 nicht nebenbei integrieren.
- J1/J2: MG in `BulletCollidePlayerTargets` in denselben frühesten Spieler-Treffersweep integrieren. Flamme, Granate, Plasma und allgemeine Explosion über ihre bestehenden Kollisionspfade in `flame.agc`, `grenade.agc`, `plasmablitz.agc`, `explosion.agc`. Treffer/Blockade von Schadensannahme unterscheiden; gegnerische direkte Trefferpfade unverändert lassen. `ExplosionNew` verwendet gemeinsamen Schaden; gewünschte stärkere Minenexplosion gezielt parametrisieren, ohne andere Typen umzubalancieren. Bestehende Explosion-Sonec-Geometrie/Schutz und per-Ziel-Timing beachten, Kettenreaktionen ohne doppelte Zerstörung.
- J3: `FlarakFindFreeOffsetX`, `FlarakSpawn`, `FlarakDoAll`, `FlarakDestroy` als Referenz für Platzierung, Anbindung und Wrackfarbe; dort bereits eigenes lebendes/zerstörtes Objekt. Keine Veränderung der geschützten Silo-Trefferzonen. Kollision mit Sonec über dieselbe mechanische Basis wie J1.
- J4: `energie.agc` als Referenz für Weltposition/Drift und `jetfire.agc` für vorhandene Effekt-Listen/Protos. Rauchdaten in die vorhandene Initialisierung, Update-, Draw- und Reset-Reihenfolge einbinden. Keine Rauch-Kollisionsprüfung oder Gameplay-Abhängigkeit.

## 7. Abnahme

- J1: Grafik/Position, beide Rechtecke von beiden Seiten, Landung und korrekter einmaliger doppelter Absprung; Energie unverändert durch Pod; Framewechsel, erneute Nutzung, Plattformmitnahme, Tiefenregeln, Waffen/Explosionen, zerstörter begehbarer und durch Spielerwaffen treffbarer Sockel; Neustart.
- J2: 25-%-Auswahlregel, Blinkmerkmal in Nähe, keine seitliche Auslösung, sofortige stärkere schadensverursachende Explosion auch bei Fernbeschuss; Kettenreaktion, Walker läuft vorbei, gegnerische Geschosse durchdringen auch Wracks, keine Überschneidung stationärer Objekte.
- J3: Sockel vor/nach Zerstörung mechanisch nutzbar, Plattformbindung, Flak/Flarak-Gegnerfunktionen/Siloschutz unverändert.
- J4: alle fünf Grafiken, Rotation, kontinuierlicher Aufstieg und Rechtsdrift, Ausfaden/minimal kleiner, ansteigende und verschiedene Dichte über Partikelanzahl, Emitter folgt Wrack und endet bei dessen Entfernung, keine Reste nach Neustart.
- Tests an sinnvollen Paketgrenzen bündeln. Lokale AGK-Abnahmen durch Entwickler; übergreifender HTML5-Test getrennt. Kein Test als bestanden behaupten, bevor Rückmeldung vorliegt.
