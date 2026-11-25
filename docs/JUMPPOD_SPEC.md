# SonecBot – Jumppod, Landmine, Sockel und Rauch (A5)

**Stand:** 25. November 2026 · **Branch:** develop
**Status:** J1 lokal abgenommen (10/10, bb16236, 25.11.2026); J1a Treppenfunktion lokal abgenommen (9/9, ddc24e8, 25.11.2026); J2 Landmine lokal abgenommen (12/12, 517763f, 25.11.2026); J3 Flak/Flarak-Sockel implementiert, lokaler Compile/Test offen; J4 fachlich abgestimmt, Umsetzung offen.
**Codebasis der Voranalyse:** [37682ba9](https://github.com/ChristianEngel19820128/SonecBot/commit/37682ba92c148a637b657beb9fb5e9fc1d98ec1c).
Bewegungsgrundlage: [SONEC_MOVEMENT_SPEC.md](SONEC_MOVEMENT_SPEC.md). Parameter sind zunächst plausible zentral einstellbare Testwerte, keine endgültige Balance.

## 1. Gemeinsame Sockelregeln (J1–J3)

- Identische plattformgebundene zweistufige Sockelgeometrie für Jumppod, Landmine und Flak/Flarak: exakt zwei Rechtecke, oberes Rechteck ist zugleich der aktive Bereich von Pod bzw. Mine. Keine dritte Triggerform. J1a: automatisch hinauflaufen bei Bodenbindung auf derselben Plattform; abwärts vorhandener Mini-Hop.
- Sonec kann auf beide Oberseiten springen und darauf landen oder sie über die Treppenfunktion betreten. Seitenkontakt im Flug blockiert entsprechend den bestehenden mechanischen Bewegungsregeln. Nur gültiger Kontakt von oben oder ein gültiger Aufwärts-Stufenwechsel auf das obere Rechteck kann eine Funktion auslösen.
- Beide Rechtecke bleiben nach Zerstörung mechanisch erhalten; der Sockel bleibt sichtbar, wird wie zerstörte Flak/Flarak umgefärbt und hat keine aktive Pod-/Minenfunktion mehr. Sonecs Waffen kollidieren weiterhin mit beiden Rechtecken von Pod/Mine, aber der zerstörte Sockel nimmt keinen weiteren Schaden.
- Plattformentranslation, Tiefenregeln, frühester gültiger Kontakt, Restweg und einmalige Trägerübernahme bleiben erhalten. Schadensgeometrie von Sonec bleibt getrennt.
- Walker dürfen neben Pods/Minen erscheinen und laufen an ihnen auch nach Zerstörung vorbei; keine Walker-Kollisions-/IK-Änderung und keine Walker-Auslösung. Gegnerische Geschosse ignorieren Pods/Minen und deren Wracks vollständig (kein Treffer, keine Blockade); allgemeine Explosionen aller Ursprünge dürfen intakte Objekte beschädigen und Kettenreaktionen auslösen.
- Flak/Flarak erhalten in J3 die gemeinsame mechanische Sockelgeometrie für Sonec. Ihre bestehende Bewaffnung, KI, Silofunktion und Schadenszonen/Siloschutz bleiben unverändert. Kein Pod-/Minentrigger und keine Änderung der bestehenden Gegnerwaffenregeln für Flak/Flarak.
- Zerstörung löst genau einmal die vorgesehene Explosion, Umfärbung und später Rauch (J4) aus; Wracks bleiben bis zur Entfernung am Weltende erhalten.

## 2. J1 – Jumppod

- Grafik: `media/gfx/plate/jumppod.png`, zwei Frames: 1 = bereit, 2 = ausgelöst. Der obere Teil ist der Pod selbst.
- Gültiger Kontakt von oben mit dem oberen Rechteck oder Hinauflaufen auf die obere Stufe bei Frame 1 löst automatisch, ohne Tastendruck, einen Sprungimpuls aus; Faktor 2.0 des normalen vertikalen Sprungimpulses (aktuell 8, also zunächst 16), keine Energiekosten.
- Frame 2 sofort anzeigen; Dauer als kurzer Millisekundenparameter. Währenddessen keine erneute Auslösung; mit Rückkehr zu Frame 1 wieder nutzbar. Kein zusätzlicher Animationsablauf.
- Der Impuls ist der doppelte normale Absprungimpuls, nicht das Doppelte der Sprunghöhe. Horizontales Momentum, Trägerübernahme und anschließende Schwerkraft/Kollisionen wie bei normalem Sprung; kein Jetpack-Zwang.
- Lebenspunkte; durch alle vier Spielerwaffen und allgemeine Explosionen zerstörbar. Kleine, tatsächlich schadensverursachende Zerstörungsexplosion.
- Nach Zerstörung Frame 1 bzw. Sockeldarstellung in Wrackfarbe; keine Auslösung mehr.

## 3. J2 – Landmine als Attrappe

- Grafik: `media/gfx/enemies/landmine.png`. Dieselbe Grundsilhouette und dieselben beiden Rechtecke wie der Jumppod, kein zweiter Auslöseframe.
- Von weitem nicht eindeutig unterscheidbar; aus der Nähe zentrales blinkendes 2×2-Pixel-Quadrat als Erkennungsmerkmal. Blinkintervall, Farbe und Sichtbarkeitsdistanz sind Testparameter.
- Nur gültiger direkter Kontakt von oben am oberen Rechteck oder Hinauflaufen auf die obere Stufe löst aus: sofortige Explosion und Zerstörung ohne Wartezeit, Umfärbung und in J4 Rauch. Keine Auslösung beim Seitenkontakt.
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

## 7. Implementierungsstand J1

- `jumppod.agc`: gemeinsamer Sprite, 80×21-Pixel-Zellen; feste Unterseite 58×5, Oberseite 34×8 (aus Frame 1). Die visuelle Ausfahrbewegung in Frame 2 ändert die mechanische Geometrie nicht.
- Testparameter: 150 ms Auslöseframe, 80 HP, 2,500 ms Mindestabstand erfolgreicher Spawns auf frisch erzeugten Plattformen mit freiem Platz; Blast Typ 3, Skalierung 0.85, Schaden 12 pro gültigem Schadensintervall; Faktor 2.0. J1 erzeugt nur Pods. Werte sind provisorisch.
- Resolver-eigene Rechteckliste aus Kisten und zwei Sockelrechtecken je Pod, stabile Zuordnung 3*i / 3*i+1 / 3*i+2. Bestehende ChestList bleibt für Walker, Waffen, Rewards etc. unverändert. Diagnose-Supportindizes beziehen sich jetzt auf diese mechanische Liste. Pod-Auslösung nur am akzeptierten oberen Landekontakt, sofortiger einmaliger Impuls plus verbleibender Weg; danach normale Resolverprüfung.
- MG im gemeinsamen frühesten Spielertreffersweep, Flamme wird am Sockel beendet, Granate explodiert beim Treffer, Plasma verwendet bestehende flächige Timer-Trefferlogik (keine neue Strahlabschneidung). Allgemeine Explosionen treffen beide Rechtecke mit einem gemeinsamen Ziel-Cooldown. Wracks bleiben geometrisch erhalten; Gegnergeschosse erhalten keinen Pod-Kollisionspfad.
- Keine Landmine, keine Flak/Flarak-Mechanik und kein Rauch in J1. Keine Änderungen an Waffenwerten anderer Objekte oder Walker-Logik. Statische Struktur-/Aufrufprüfung durch Assistent; lokaler AGK-Compile und Entwicklertest anschließend bestanden.

## 8. J1a – Gemeinsame Treppenfunktion (lokal abgenommen)

- Freigegeben: bei bestehender Bodenbindung auf eigener Plattformebene automatisch über 5 px (Plattform → Unterstufe) und 8 px (Unterstufe → Oberstufe) aufsteigen. Betreten der oberen Stufe löst intakten Pod bzw. in J2 Mine genauso wie Landung aus. Seitlicher Flugkontakt löst nicht aus. Wracks haben dieselbe Geometrie, aber keine aktive Funktion.
- `TChest.MechanicalStepLevel` markiert nur die beiden Sockelrechtecke (1/2), gewöhnliche Kisten bleiben 0. Unter-/Oberstufe liegen in benachbarten Resolver-Slots; diese Zuordnung muss J3 ebenfalls wahren.
- `SonecSockelStepMode` / `SonecSockelStepTime`: nur direkter Aufwärtswechsel vom zugehörigen Träger bzw. von dessen eigener Unterstufe; am Fußreferenzpunkt wird die Kante relativ zum Träger zeitlich erreicht. Maximalhöhe 8 px und Auflagetoleranz 0,05 px. Bei der oberen Stufe wird die normale 25-px-Frontlinie auch beim zulässigen Anlauf auf die untere Stufe ausgenommen, damit sie den 12-px-Vorsprung nicht vorzeitig blockiert. Seitliche Bodenkorrektur ist in diesen Fällen ebenfalls ausgenommen. Andere Kisten-/Flug-/Tiefenkontakte bleiben normal.
- Kontaktart `SONEC_CONTACT_STEP_UP` (7) konkurriert im bestehenden frühesten Sweep vor Support-Exit, nach anderen gültigen Wandkontakten. Gewählter Kontakt wechselt auf die höhere Auflage, erhält den relativen horizontalen Restweg, nutzt vorhandene Trägerübernahme und dieselbe Auslösefunktion wie die Landung. Kein Kanten-Balanceimpuls oder Mini-Hop beim Aufwärtswechsel. Abwärts bestehender Support-Exit und Mini-Hop bleiben unverändert, keine neue Abstiegsmechanik.
- Nicht geändert: normaler Sprung, Jetpack, Kisten, Waffen, Walker und Flarak-Reset. J2/J3/J4 noch nicht umgesetzt. Statische Strukturprüfung und übersetzte Geometrieprüfung; lokaler AGK-Compile und Entwicklertest anschließend bestanden.

## 9. J2 – Landmine (lokal abgenommen)

- `jumppod.agc` nutzt eine gemeinsame Liste mit `ObjectKind` für Pod/Mine. Keine zusätzliche Rechteck-, Waffen- oder Walker-Kollisionslogik, keine Änderung der J1a-Treppenregeln. Die beiden benachbarten Resolver-Slots, Plattformbindung und Wrackregeln bleiben gleich. Landminengrafik 80×13 px: beide Rechtecke entsprechen dem vorhandenen Pod-Frame 1 (58×5 / 34×8). Gleicher Farbton und Wrackfarbe, kein zweiter Frame.
- Gemeinsamer Testspawntakt unverändert (2.500 ms Mindestabstand erfolgreicher Spawns auf geeigneten neuen Plattformen); nach freier Platzwahl genau eine Zufallsauswahl 1–100, Werte 1–25 Mine, 26–100 Pod. 25 % Wahrscheinlichkeit, keine feste Reihenfolge oder exakte Quote bei kurzen Stichproben.
- Testparameter Mine: 80 HP, Warnquadrat 2×2 px orange (255/155/45), 160 px Weltabstand zum Spieler, 140 ms an / 140 ms aus, Position mittig auf der oberen Stufe. Keine Warnung in der Ferne oder nach Zerstörung. Mine ist jederzeit kontaktaktiv, der Blinkzustand ist nur optisch.
- `JumppodHandleUpperContact` unterscheidet beim ausgewählten oberen Landungs-/Aufwärtskontakt Pod-Impuls und Minen-Detonationsanforderung. `JumppodResolveContactTriggers` verbraucht diese im selben Spieltick direkt nach dem Resolver, ohne Zündverzögerung. Kein Sprungimpuls bei Mine. Seitenkontakt und untere Stufe lösen nicht aus. Zerstörung genau einmal über denselben Schadenspfad wie bei Fernbeschuss; verbleibende Sockelkollision unverändert.
- Minenblast Typ 3 (vorhandene Grafik), Skala 1,8 statt 0,85 und 36 statt 12 Schaden pro gültigem Schadensintervall; vorhandener größerer Explosionssound. Radius entwickelt sich wie bei den bestehenden Explosionen; Sonec-Schaden über zentrale Zwei-Kreis-/Shield-Regeln, keine zusätzliche Sofortschadensroutine. Alle Spielerwaffen und allgemeinen Explosionen nutzen die gemeinsame Geometrie und Ziel-Cooldowns; gegnerische Geschosse weiterhin ohne Pod-/Minenkontakt. Rauch erst J4.
- Statische Struktur-/Integrationsprüfung; lokaler AGK-Compile und Entwicklertest anschließend bestanden. Keine Änderungen an fliegenden Minen, Kisten, Walker, Flak/Flarak, J1a-Bewegungsregeln oder Fremdbugs.

## 10. J3 – Flak/Flarak-Sockel (implementiert, Test offen)

- Pixelprüfung der vorhandenen `flarak.png` (560×64, sieben 80×64-Frames): geschlossener Frame 1 hat dieselbe untere (x 11–68, y 59–63) und obere (x 23–56, y 51–58) Rechtecksilhouette wie der gemeinsame Sockel 58×5 / 34×8. Die mechanische Geometrie bleibt über alle ausgefahrenen Frames und nach Zerstörung konstant; Launcher/Raketen selbst sind keine neuen mechanischen Hindernisse.
- `SockelUpdateRects` in `jumppod.agc` ist die gemeinsame Geometriefunktion aller vier Objekttypen. Die Resolverliste nutzt nun stabile Fünfergruppen: Kiste 5*i, Pod/Mine 5*i+1/+2, Flak/Flarak 5*i+3/+4. Beide Sockelstufen bleiben benachbart (J1a); nur Pod-/Minen-Oberseiten lösen eine Funktion aus. Diagnoseindizes beziehen sich auf die aktuelle Resolverliste.
- Flak/Flarak-Basis wird nur für aktiv geführte Instanzen mit gültiger, eingeschalteter Plattformbindung erzeugt, unabhängig von Destroyed oder Ausfahrframe. Beide Rechtecke folgen den originalen Plattform-Start-/Endpositionen und dem bestehenden PlateOffsetX; der Sprite-Pivot liegt höher und ist nicht die Fußauflage. Keine Basis für deaktivierte, nur noch Raketen führende Instanzen. Plattformprüfung erfolgt nach PlateCheckAll. Wracks bleiben bis zur Plattformentfernung mechanisch erhalten.
- `flarak.agc`, Waffen, KI, Siloschutz, Sprites, Schadenszonen, Explosionen, Rewards und Walker bleiben unverändert. Vorhandene Spawnbedingungen (Flak/Flarak vor Pod/Mine, bestehende 80-px-Stationsreserve und Kistenprüfung) bleiben bestehen. Der bekannte Flarak-Neustartfehler bleibt ausdrücklich zurückgestellt; eine ggf. fortbestehende alte Station kann dadurch auch eine Basis behalten, solange sie im alten System weiterhin als gültig geführt wird. Keine neue Reset-Korrektur.
- Statische Struktur-/Integrationsprüfung sowie übersetzte Slot-/Geometrieprüfung; AGK-Compile und Spieltest offen. Keine Änderung an J1a-Resolver, J2-Trigger, Pod-/Minenwerten oder Rauch.

## 11. Abnahme

- J1 **bestanden**, Entwickler, lokaler AGK-Compile und Test am 25.11.2026, bb16236, 10/10 bestätigt: Grafik/Farbe/Plattformposition, regelmäßige überschneidungsfreie Spawns, Seitenkontakt ohne Auslösung, automatischer doppelter Sprung, Framewechsel/Wiederverwendung/kein Energieverbrauch, alle vier Spielerwaffen, Schadensexplosion/Umfärbung/verbleibende Kollision, Walker/Gegnergeschosse ignorieren Pods, bestehende Bewegung und Neustart. Separater bestätigter Flarak-Raketen-Resetfehler in [KNOWNBUGS.md](../KNOWNBUGS.md); keine Aussage über dessen Behebung. Pod wirkt möglicherweise zu stark (normalen Sprung getrennt beurteilen); Treppenfunktion danach als J1a freigegeben, implementiert und separat lokal abgenommen. Vermutete unterschiedliche Sockelgröße vom Entwickler als optische Täuschung korrigiert. Keine HTML5-/Langzeitabnahme behauptet.
- J1a **bestanden**, Entwickler, lokaler AGK-Compile und Test am 25.11.2026, ddc24e8, 9/9 bestätigt: Aufstieg von links und rechts, Pod-Auslösung an der oberen Stufe, zerstörter Sockel vollständig begehbar, Mini-Hop beim Abstieg, keine Auslösung bei seitlichem Flugkontakt, keine unerwünschten Effekte auf bewegten Plattformen, Kistenmechanik und normale Bewegung unverändert. Keine offenen Testpunkte oder zusätzlichen Beobachtungen; keine gesonderte HTML5-/Langzeitabnahme.
- J2 **bestanden**, Entwickler, lokaler AGK-Compile und Test am 25.11.2026, 517763f, 12/12 bestätigt: Spawns neben Jumppods ohne Objektüberlappung, Blinkquadrat nur in Nähe, Auslösung bei Landung auf Oberstufe und Hinauflaufen, keine Auslösung an Unterstufe oder seitlich im Flug, Zerstörung durch alle vier Spielerwaffen und allgemeine Explosionen, stärkere schadenswirksame Explosion, umgefärbtes begehbares Wrack, Walker und Gegnergeschosse ignorieren Landminen, Jumppod-Funktion unverändert. Keine offenen Testpunkte oder zusätzlichen Beobachtungen. Die 25-%-Auswahlregel wurde statisch geprüft; keine gemessene Spawnquote, gesonderte Kettenreaktionsmessung oder HTML5-/Langzeitabnahme behauptet.
- J3 (Test offen): beide Sockelstufen für Flak und Flarak vor/nach Zerstörung begehbar, Aufstieg beidseitig, Mini-Hop, Flugseitenkontakt, Plattformbindung, kein Pod-/Minen-Trigger, keine Überlappung, Flak/Flarak-Gegnerfunktionen/Siloschutz unverändert; Pod/Mine und Kisten unverändert.
- J4: alle fünf Grafiken, Rotation, kontinuierlicher Aufstieg und Rechtsdrift, Ausfaden/minimal kleiner, ansteigende und verschiedene Dichte über Partikelanzahl, Emitter folgt Wrack und endet bei dessen Entfernung, keine Reste nach Neustart.
- Tests an sinnvollen Paketgrenzen bündeln. Lokale AGK-Abnahmen durch Entwickler; übergreifender HTML5-Test getrennt. Kein Test als bestanden behaupten, bevor Rückmeldung vorliegt.
