# SonecBot – Real Alpha Roadmap

**Stand:** 19. November 2026 (Real-Alpha-Planung und Release-Gates)  
**Status:** gemeinsam vereinbarte Entwicklungsrichtung; **Planung, keine Freigabe zur Implementierung einzelner Gameplay-Funktionen**  
**Branch:** `develop`  
**Verwandte Dokumente:** [HANDOFF.md](HANDOFF.md) · [TODO.md](TODO.md) · [PROJECT.md](PROJECT.md) · [TECHNICAL.md](TECHNICAL.md)  
**Wichtig:** Die öffentlich sichtbare itch.io-Seite bleibt bis zu einer gesonderten Entscheidung im **Draft/Secret-URL-Modus**. Kein `main`-Merge oder Publish aufgrund dieses Dokuments.

## Verbindliche technische Alpha-Release-Gates (Entscheidung 19.11.2026)

### M1 – Einheitliches Bewegungsmodell

Die Bewegung kontinuierlich bewegter Objekte soll vor der Real Alpha auf einer einheitlichen, **pausierbaren zeitbasierten Berechnung** beruhen. Kandidat **Modus B (Delta-Time pro aktivem Update)** wird bevorzugt; Modus A (10-ms-Timer mit `CalcRange`) bleibt für reproduzierbare Vergleiche erhalten, bis die Migration getestet ist. Im aktuellen Quellcode unterscheiden sich Hochhausbewegung (B), Plattformen/Walker (A) und Drohne (B). `F5` vergleicht Hochhäuser, `F6` Plattformen mit Walker-Regression; `F4` testet davon unabhängig Render-Pixel-Snap. VSync/FPS-Limiter ebenfalls separat. Nicht blind den Walker umstellen: IK, Fußkontakte, Kollision und Schusszeitpunkte regressionsprüfen. Eine **Optionsmenü-Umschaltung ist noch nicht beschlossen**; nur bei belegbarem Nutzen, grafische Glättung/Snap separat bewerten. Beobachtung: Drohne bei 55–60 FPS im HTML5-Browser leicht ruckelig, Ursache offen.

### K1 – Zuverlässige Gewehrprojektil-Treffer (hohe Priorität vor weiterer Drohnenbewaffnung)

**K1a-Entwicklertest (19.11.2026):** **10/12 erfolgreich bestätigt**, inklusive AGK-Compile, Treffer auf beide Minenarten, Randtreffer/knappe Fehlschüsse, zwei Schussrichtungen, bestehende Waffen/Walker/Orbs/Kisten, Pause/Neustart und lokales HTML5. Die beiden übrigen Prüfpunkte (zwei Minen exakt hintereinander / gemischte Minen hintereinander, nur vordere getroffen) waren unter den vorhandenen Spawn-/Formationsbedingungen kaum testbar und bleiben **offen, nicht fehlgeschlagen**. Später mit isoliertem Testaufbau prüfen. Der Entwickler beobachtete zudem häufig die Explosion eines ganzen Minenfelds nach Zerstörung einer Mine; siehe E1 unten. K1a-Gewehrtreffer spürbar verbessert, allgemeines K1-Gate weiterhin offen.

**K1a umgesetzt (19.11.2026), ursprünglicher Status vor Entwicklerprüfung:** Erste schmale Korrektur für Spieler-Gewehrkugeln gegen intelligente und einfache Minen. Start- und Endposition jedes Bewegungsschritts werden für einen Segment-Kreistest mit unverändertem kombiniertem Radius verwendet. Bei mehreren Minen wird der früheste Treffer **über beide Listen gemeinsam** gewählt; eine Kugel verursacht nur einen Minentreffer. Feindgeschosse behalten ihre bisherige Endpunktprüfung. Keine Veränderung von Geschwindigkeit, Schaden, übrigen Zielen, Waffen oder Zeitmodell. **Noch kein eigener AGK-/HTML5-Test; nicht als K1-Gesamtabnahme verstehen.** Andere Zieltypen (Orb/Walker/Chest), bewegte Mine relativ zum Projektil und Trefferpriorität über unterschiedliche Gegnerklassen bleiben Folgeaufgaben.



Entwickler beobachtet, dass Maschinengewehrkugeln vor allem kleine einfache Minen kaum treffen; zusätzlich passt älteres Spielerfeedback zu durchfliegenden Bullets. **Wahrgenommenes Problem bestätigt, konkrete Ursache noch zu isolieren.** Aus `bullet.agc`: Geschossgeschwindigkeit ca. 3 px/ms; `BulletMove()` bewegt pro fälligem Timer anhand der Zeitspanne; `BulletCollideMine()` testet anschließend **nur aktuelle Kugelposition** gegen Mine. Bei ca. 55–60 FPS sind etwa 50–55 px pro Frame rechnerisch möglich, gegenüber nur 11×11 px einfacher Mine. Plausible **Tunneling-Hypothese**, nicht als einziger Defekt bewiesen. Andere Bullet-Kollisionen nutzen momentane AABBs und benötigen ebenfalls Prüfung.

**K1-Teststrategie:** Ein begrenzter erster Patch für von Spieler gefeuerten Bullet gegen **intelligente und einfache Minen** mittels *Swept Collision* (vorherige bis aktuelle Position + Dicke); frühesten gültigen Treffer identifizieren, keine unbeabsichtigten Mehrfachtreffer. Kein bloßes Vergrößern der Hitboxen, kein ungezielter Umbau sämtlicher Waffen. Mit AGK/Windows und lokalem HTML5 testen (55–60 FPS, zentrale und knappe Randtreffer, offensichtliche Fehlschüsse, zwei Minen hintereinander, beide Flugrichtungen) und danach Trefferpfade für Walker, Orb, Kiste und feindliche Bullets separat ausweiten. M1/K1 sind **verbindliche Release-Gates**, aber noch keine Freigabe für einen konkreten Quellcode-Patch; jede Umsetzung in kleinen getrennten Schritten.

**K1b-Entwicklerabnahme (19.11.2026): 12/12 bestanden.** AGK Studio, Orbs, Walker-Turm (nicht Beine/Korpus), Kisten, beide Minenarten, Randtreffer/Fehlschüsse, Orb-vor-Mine **und** Mine-vor-Orb, E1b/Kettenreaktion, Gegnergeschosse/andere Waffen, Pause/Neustart, lokales HTML5 bestätigt. Trefferbild laut Entwickler deutlich fairer. K1b abgeschlossen.

**K1c umgesetzt (19.11.2026), Entwicklertest offen:** Gegner-Bullets werden nun per Segment-zu-Kreis-Test von `PreviousPosition` zur aktuellen Position gegen Sonecs **unveränderten** Radius geprüft, um das bisherige Endpunkt-Tunneling zu vermeiden. Schild-/Health-Formel unverändert; keine Änderung am Spieler-Bullet-Sweep oder an Trefferflächen. Windows/HTML5 und schnelle/knappe Treffer sowie Schildwirkung noch durch Entwickler testen. **Danach getrennte Untersuchung:** Shape Collision für Sonecs Körper bei kreisförmigem Schild und ggf. verbesserte Walker-Bein-/Umgebungskollision; der Walker-Turm bleibt bislang einzige Gewehr-Schadenszone. Trefferblinken und Drohnen-Jet-Sprite bleiben vorgemerkt.

**K1c – ursprüngliche Untersuchung (historisch):** Gegnerbullets nutzen bei Sonec derzeit nur Endpunkt-Kreisprüfung; vorhandenes `PreviousPosition` erlaubt Sweep gegen den bisherigen Radius. Entwickler erwägt **Shape Collision für Sonecs Körper**, während das Schild ein **Kreis** ist. Vor einer Änderung entscheiden, wie präzise Körperkollision und tunneling-sicherer Segmenttest zusammenpassen; Schildabsorption unverändert halten. **Noch kein K1c-Code.** Sonec-Grafiken derzeit grün; rotes Trefferblinken und giftgrüne Grunddarstellung sowie separates Schild-Einschlagfeedback als spätere Vorschläge (Schildgrafik schwarz/weiß). Spätere Drohnenidee: Jet-Sprite bei vertikaler Bewegung wie bei Sonec verwenden. Keine Assets, Farben oder Drohne geändert.

**K1b implementiert (historisch, vor Entwicklerabnahme):** `BulletCollidePlayerTargets` bestimmt über **Orb, Walker-Turm, intelligente/einfache Mine und Kiste** den frühesten Treffer einer Spieler-Bullet anhand ihrer letzten Bewegungsstrecke. Für Orb, Walker-Turm und Kiste nutzt `BulletBoxSweepEntry` die bestehende AABB erweitert um den Kugelradius; Minen behalten K1a-Kreis-Sweep. Bei gleicher Trefferzeit stabile Reihenfolge Orb, Walker-Turm, intelligente Mine, einfache Mine, Kiste. Ein Bullet beschädigt höchstens ein Ziel. Gegner-Bullet-Kollisionen mit Minen/Kisten, Explosionen, andere Waffen, Schaden und Bewegung bleiben unverändert. **AGK-/Windows-/HTML5-Tests sowie kontrollierte Überlagerungsszenen offen; kein eigener Laufzeittest.** K1-Release-Gate erst nach Entwicklerabnahme weiter bewerten.

### E1 – Explosionsradius und Minenkettenreaktion prüfen (Alpha-Qualität)

**Ermittlung vom 19.11.2026 (Code und Originalbild geprüft):** `RedExplode/redexplode0004.png` (erstes Bild des Minenexplosionstyps 1) misst **175×175 px**. Daraus berechnet `ExplosionNew` den **Basisradius 87,5 px** und mit 75–125 % Zufallsskalierung einen **fixen Schadensradius zwischen 65,625 und 109,375 px** pro Explosion. Die Bildgröße/Radiusberechnung ändert sich während der Animationsframes nicht. Bei 32×48 px Versatz einer Dreierformation liegen benachbarte Minenmittelpunkte **57,69 px** auseinander und sind daher **bei jeder Skalierung direkt in Reichweite**; die äußeren Minen (115,38 px auseinander) sind **nicht direkt** im Maximalradius, können aber über die mittlere Mine kaskadieren. Zusammen mit 30 Schaden je 100-ms-Trefferintervall und 25 HP erklärt das den beobachteten vollständigen Feldzerfall **ohne Nachweis eines Radiusfehlers**. **E1 als Geometriefrage geklärt**, keine unmittelbare Änderung an Explosion oder Formation; weitere Formationsabstände später bewusst für unterschiedliche Kettenreaktionswahrscheinlichkeiten wählen.

**E1b vollständig abgenommen (19.11.2026): 9/9 Entwicklertests bestanden.** AGK-Compile, normale Dreier-Kettenexplosion, unveränderter Radius, Explosionsschaden an beide Minenarten – auch unabhängig **innerhalb derselben Explosion** –, andere Explosionsziele (Sonec/Orbs/Kisten/Walker), Pause/Neustart und lokales HTML5 bestätigt. Keine nicht durchgeführten Tests; Anmerkung „hatte alles dank kettenreaktionen funktioniert“. **E1b abgeschlossen.** Die ursprüngliche Implementierungsnotiz mit ausstehendem Test weiter unten ist historisch. 100-ms-Takt und Kreisprüfung bleiben gewollt und unverändert. Kein eigener AGK-/Browserlauf des Assistenten; Audio-Polishing von mehrfach gleichzeitig klingenden Explosionen bleibt gesonderte Alpha-Arbeit.

**E1b implementiert (historisch, 19.11.2026; damaliger Teststatus offen):** Ein eigenes `LastSimpleMineHitMs`-Array trennt nun die Trefferzeitpunkte der einfachen Minen von `LastMineHitMs` für intelligente Minen. `ExplosionCollideMine` erhält einen Pooltyp-Parameter, den die zwei Aufrufe in `GameDo` passend setzen. Gleiche Indizes blockieren dadurch nicht mehr gegenseitig den Schaden derselben Explosion. **100-ms-Intervall, 30 Schaden pro gültigem Treffer, Kreisprüfung pro aktivem Spielupdate und Explosionsradius bleiben unverändert.** Gemischten Überlappungsfall und Regressionen unter Windows/HTML5 noch prüfen; kein allgemeines Explosion-Rebalancing.

**E1b – ursprünglicher Befund vor Korrektur (historisch):** `TExplosion.LastMineHitMs[k]` ist derzeit ein gemeinsam benutztes Zeitstempelarray für die beiden getrennten `MineList`-Aufrufe in `GameDo`. Haben intelligente und einfache Mine denselben Listenindex, kann die eine die 100-ms-Sperre der anderen beeinflussen. Ein echter möglicher Mehrziel-Timerfehler, **noch kein Laufzeittest**; bei Gelegenheit gezielt reproduzieren und getrennt korrigieren. Erwünschte kreisförmige Kollisionsprüfung pro Spielupdate und der 100-ms-Schadentakt bleiben bestehen.



**Entwicklerpräzisierung (19.11.2026):** Kreisförmige Explosionskollision und wiederholte Schadensprüfung während der gesamten Explosion sind **absichtlich**. Im aktuellen Code erfolgen die Kollisionsabfragen pro aktivem `GameDo`-Update und die Schadensintervalle mindestens 100 ms auseinander, nicht ausschließlich einmal je neuem Animationsframe. Vor jeglicher Änderung zuerst Explosionsbildradius, zufällige Skalierung und Formationsabstände überprüfen; keine vorschnelle Fehlerannahme. Später **Formationsmuster mit bewusst unterschiedlichen Abständen** planen: Kettenreaktionen dürfen vorkommen, sollen aber **nicht zwangsläufig bei jedem Minenfeld** die gesamte Formation zerstören. Spielerische Abwägung/Fairness erst nach Radiusanalyse.



Der Entwickler berichtet, dass nach Zerstören einer Mine häufig die **ganze einfache Dreierformation** explodiert. Aktuelle Formationsabstände sind **32 px horizontal** und **48 px vertikal**, also ca. **57,7 px zwischen Nachbarn** und **115,4 px von erster zu dritter Mine**. `MineDestroy()` erstellt eine Explosion vom Typ 1; ihr Radius hängt vom Bilddurchmesser und zufälliger Skalierung **75–125 %** ab. `ExplosionCollideMine()` prüft Entfernung des Minenmittelpunktes gegen den Explosionsradius; bei aktiviertem Zeitmodus sind **30 Schaden** pro Treffer und mindestens **100 ms** zwischen Treffern vorgesehen, gegenüber **25 HP** einer Mine. Das legt Kettenreaktionen nahe, beweist aber ohne tatsächliche Bildmaße und gezielten Laufzeittest keinen exakten Reichweitenwert. Für E1: Bildradius messen, Reichweitenvarianz und Formation vergleichen, Kaskade/Schadentakt testen, spielerische Fairness beurteilen. Kettenreaktion kann erwünschtes Gameplay sein; **noch keine Balanceentscheidung oder Codefreigabe**.

### Alpha-Balancing – Minenfeldhäufigkeit und Warnungsdichte

Der Entwickler empfindet `MINEFIELD DETECTED` bei längerer Spielzeit als zu häufig. Aktueller Zufallsabstand zwischen Minenfeld-Spawnversuchen: **18–30 Sekunden aktiver Spielzeit**. Beim späteren Alpha-Balancing **höhere Zufallsintervallwerte** erproben, um Felder/Warnungen tendenziell seltener erscheinen zu lassen. Neue Werte erst nach Beobachtung im Zusammenspiel mit weiteren Feinden und einem möglichen Gefahrenbudget festlegen. Warn-Trigger selbst und heutige Spawnwerte bleiben unverändert.

### K1-Folgetest – Orb vor Mine / Mine vor Orb

Der Entwickler beobachtete, dass eine Spielerkugel bei einem Orb direkt vor einer intelligenten Mine **nur den Orb** traf. Das passt zur aktuellen Prüf- und Löschreihenfolge in `GameDo`: Orb → Walker → Minen → Kisten. **Dies beweist noch keine korrekte räumliche Reihenfolge**, denn Orbs/Walker/Kisten nutzen momentane Endpunkt-AABBs, während Minen K1a-Segmenttests benutzen. Für die spätere K1-Erweiterung **beide Reihenfolgen** (Orb vor Mine und Mine vor Orb) mit reproduzierbarer Aufstellung testen und ggf. einheitliche früheste Trefferwahl über Zielklassen konzipieren. Noch keine Codefreigabe oder Änderung.

### Positive Meldungen und Sound-Feedback – vorgemerkte Alpha-Verbesserung

**Positivnachrichten-Symbol:** Das im bisherigen schematischen Beispiel verwendete **Stern-im-Kreis-Motiv** als Ausgangsidee für ein eigenes positives Hinweis-/Erfolgssymbol vormerken, deutlich von rotem Warn-Dreieck getrennt. Der genaue Stil, das endgültige Sprite und Anwendungsfälle werden später gemeinsam entschieden.

**Konkreter Testfall:** Bei der beabsichtigten Dreier-Kettenreaktion können **drei Explosionssounds fast gleichzeitig** abgespielt werden. Für das spätere Audio-Polishing Spitzenlautstärke, Übersteuerung/Kratzen und Browser-Verhalten bei gleichzeitig laufenden Soundinstanzen prüfen und ggf. mit Mischpegeln/Instanzmanagement korrigieren; Sound- oder Explosionslogik jetzt nicht ändern.

**Sound-/Ereignisfeedback:** Zusätzliche Sounds sowie Optimierung der vorhandenen Klänge für Treffer, Schaden, drohende Gefahr, Todesursachen, Belohnungen und Explosionen als eigenständigen Alpha-Polishing-Punkt führen. Verständlichkeit, Lautstärke, Timing und Mehrfachsounds untersuchen, Feedback von Pre-Alpha-Testerinnen und -Testern berücksichtigen; nicht automatisch neue Dateien oder Audiooptionen einführen. Kein unmittelbarer Codeauftrag.

## 1. Zielbild und bewusst begrenzter Umfang

SonecBot soll von einer spielbaren HTML5-Pre-Alpha zu einer **verständlich spielbaren Real Alpha** wachsen. Die drei gemeinsam **priorisierten und überschaubar gehaltenen Kernfeatures** sind:

1. **Minenvarianten:** intelligente/verfolgende Minen bleiben einzeln; einfache Minen verfolgen Sonec **nicht** und reagieren **nicht** auf seine Energieanziehung (gemeinsam entschiedene Variante B). Sie sollen später in **Feldern/Rudeln** auftreten.
2. **Drohnen:** neue, zunächst einfache Gegner, die **von links nach rechts schweben**.
3. **Warn-/Avatar-Hilfesystem:** kurze, kontextbezogene Hinweise **oben im laufenden Spiel**, als Ausbau des bereits angedachten `MINEFIELD DETECTED`-Ansatzes.

**Nicht gleichzeitig anfangen.** Die drei Features einzeln konkretisieren, schmal implementieren, lokal mit AGK Studio / HTML5 testen und ausdrücklich abnehmen. Entscheidend sind Lesbarkeit, Fairness, kontrollierbarer Schwierigkeitsanstieg und ein übersichtlicher Entwicklungsumfang – nicht möglichst viele neue Gegner.

### Grundgedanke aus dem ersten Community-Feedback

Erstes externes Feedback (17.11.2026): Grundidee und Animationen gefallen; Spieler meldet gelegentliches Durchfallen durch Plattformen, als sehr stark empfundene Beschleunigung, unklare linke Anzeigen, unverständliche plötzliche Todesfälle und scheinbar wirkungslose Rifle. **Dies sind Spielerbeobachtungen, keine automatisch bestätigten Bugs.**

Gemeinsame Einordnung des Entwicklers:
- **Schnelles Durchfallen** ist grundsätzlich als Spielmechanik geplant: „it's not a bug, it's a feature“. Dennoch **Fairness und erkennbare Ursache** prüfen; nicht ohne Abstimmung die Mechanik abschaffen.
- **Beschleunigung:** physikalisches Verhalten und tatsächlichen Bewegungs-/Bremsweg prüfen, bei Bedarf später anhand messbarer Vergleichstests anpassen.
- **HUD:** Erklärung der linken Anzeigen; vertikal gesetzter Text wäre bei Platzmangel möglich, rotierende/kontextuelle Hilfe ebenfalls.
- **Tod/Schaden:** vor allem fehlendes akustisches Feedback bei Bullet-Treffern; Avatar soll helfen. Vorhandene Idee für eine **Top-Warnmeldung** im Spiel eignet sich als Einstieg. Ursache und Anzeige von Minen, Überladung, Schild, Schaden unterscheiden.
- **Rifle:** rotes Treffer-Aufleuchten existiert bereits, kann aber zu wenig sein; Projektile und Kollisionsflächen prüfen. **Walker ist derzeit vor allem am Turm empfindlich**, Erweiterung der verwundbaren Zonen für später erwünscht; keine voreilige Behauptung, dass alle Projektile durchfliegen.
- Diese Themen gehören überwiegend zur **Real Alpha**, nicht zum aktuell klein gehaltenen Keyboard-/Pre-Alpha-Patch.

## 2. Pre-Alpha-/Keyboard-Patch abgeschlossen (Stand 18. November 2026)

**Die frühere Vorbedingung ist erfüllt; die vorherigen offenen Keyboard-Aufträge in dieser Roadmap sind historisch und nicht erneut auszuführen.**

- **Alpha-Walker** ist vom Entwickler abgenommen; keine weitere Walker-Politur ohne gesonderten Auftrag oder bestätigten Blocker.
- **Keyboard-Patch Schritte 1–4** auf `develop` abgeschlossen: `CONTROLS > KEYBOARD` mit MOVEMENT/ACTIONS, Tastenerfassung, Persistenz, roter Doppelbelegungsanzeige und `RESTORE DEFAULTS` (RESET/CANCEL). Gamepad-Rebinding gehört ausdrücklich nicht zum abgeschlossenen Patch.
- **Windows/AGK und lokales HTML5/Apache:** die vereinbarten Tests wurden laut Entwickler erfolgreich durchgeführt. Nach dem letzten optischen OPTIONS-Mini-Fix ist ein separater Windows-Nachtest nicht dokumentiert; der anschließende HTML5-/Apache-Test war **13/13 bestanden**.
- **Aktualisierter itch.io-Draft-Embed:** Entwickler meldete am 18.11.2026 **12/12 Smoke-Testpunkte bestanden**, einschließlich Rebinding/Reset, persistierter Tastenbelegung nach Reload, Gamepad, Walker und Tod/Neustart. Dies ist ein **Entwicklerbericht**, kein unabhängiger Assistenten-Laufzeittest.
- Neues Keyboard-Promobild, aktualisierte englische itch.io-Beschreibung und README wurden laut Übergabe bereits übernommen. **itch.io bleibt Draft / Secret URL**, nicht Published.
- **Nächster Release-Gate:** Dokumentation auf `develop` abgleichen, danach die Pre-Alpha-Übernahme nach `main` anhand aktueller Branch-Differenzen prüfen und **nur mit gesonderter Merge-Freigabe** durchführen. Die Roadmap allein gibt weder Merge noch Publish frei.

**Danach:** Real Alpha schrittweise beginnen. Kernfeature 1 sind die Minenvarianten; zunächst vorhandene intelligente Einzelminen schützen und die einfache Mine eindeutig spezifizieren. Entscheidungen zu Gruppenspawn, Anzahl, Abständen und Warnsystem folgen separat.

## 3. Real Alpha – Kernfeature 1: Minefields und intelligente Minen

### Real-Alpha-Minen: S3 abgenommen und nächster Schritt offen (18.11.2026)

**S1 9/9, S2 10/10, S3 12/12** laut Entwickler unter AGK Studio/Windows und lokalem HTML5 bestanden. S3-Stand `2ba518bd4a5f55dd12f0b4fd8df9ff39355661b5`: regelmäßige vollständige 3er-Diagonalformationen, 18–30 s pro Spawnversuch aktiver Spielzeit, maximal 6 aktive einfache Minen, variable sichere Spawnhöhe und keine Nachholspawns. Die bestehende Intelligenz-Mine und Trefferpfade wurden laut Test nicht beeinträchtigt. **Dunkelgrün RGB 32/125/55, Alpha 255 wird beibehalten.** Beobachtete Durchflugzeit ca. 10–12 s; erster praktischer Balancing-Hinweis, keine bestätigte Notwendigkeit zur Intervalländerung.

**Gestaltungsentscheidungen:** Bewährte diagonale Dreierformation dauerhaft behalten. Später wenige weitere Muster (Keil, vertikale Staffelung, unregelmäßiges Rudel A) ermöglichen; 5er-/7er-Versionen nur wo spielerisch fair. Steigende Schwierigkeit bevorzugt durch Formationswahl, Dichte, Häufigkeit und Kombinationen, **nicht durch pauschalen Schadensanstieg**. Langfristiges **Gefahrenbudget** als gemeinsame Richtgröße für intelligente/einfache Minen, Walker, Drohnen und spätere Feinde: Spawnhäufigkeit, Gefahrendauer und -dichte berücksichtigen; noch keine globale Steuerung oder verbindliche Zahlen.

**Nächste Designentscheidung:** zusätzliche Grundformation oder kleines `MINEFIELD DETECTED`-Topwarnsystem. Beides **nicht implementiert und nicht zur Implementierung freigegeben**. Der bereits laufende Spawn darf bei einer Warnung nicht ohne Vorlauf als sicher angekündigt gelten; Timing und Fairness vor Umsetzung klären.



**S3 implementiert, Entwicklertest offen (18.11.2026):** Spawnversuche im zufälligen Abstand von **18–30 Sekunden aktiver Spielzeit**, maximal **6 aktive einfache Minen**. Jede vollständige Formation hat 3 Minen; bei weniger als 3 freien Plätzen wird der Versuch ohne Nachholen übersprungen. Variierende sichere Bildschirmhöhe, rechts außerhalb des sichtbaren Bildes, Initialisierung bei Neustart, Pause über bestehende virtuelle Uhr. **S2 vom Entwickler 10/10 unter AGK/Windows und lokalem HTML5 abgenommen;** Dunkelgrün beibehalten. Globale Gefahrenbudget-Planung für spätere Gegner: Schwierigkeit durch Dichte, Muster und Kombinationen statt pauschaler Schadenssteigerung; **nicht Teil von S3**. 

**S1 abgenommen (18.11.2026):** einfache gezackte 11×11-Mine mit separater Liste/Proto und Linksdrift; keine Verfolgung, keine Energieanziehungsreaktion. **Entwickler meldet AGK/Windows und lokales HTML5 9/9 bestanden**, ohne offene Punkte; kein eigener Assistenten-Laufzeittest. **S2 implementiert, Test offen:** eine diagonale **Dreierformation** pro `GameInit`, Positionen durch Anzahl und Abstände berechnet (initial 32 px horizontal, 48 px vertikal), einheitliche Linksdriftgeschwindigkeit; Weißgrafik wird per Code dunkelgrün (RGB 32/125/55, Alpha 255). **Diagonale bleibt Grundformation**, Keil und Vertikalstaffelung sowie 5/7 Minen mögliche spätere Muster; unregelmäßiges **Rudel A später als Anordnungsvariation** desselben einfachen Minentyps. Keine zufälligen Felder, Warnungen oder Balancing in S2.


### Spielidee

Bisherige intelligente Minen weiterhin **einzeln** und mit vorhandener Bewegung/Annäherung an Sonec. Zusätzlich ein **einfacher Minentyp** für erkennbare **Minenfelder bzw. Rudel**. **Entschieden (Variante B):** Einfache Minen verfolgen Sonec nicht und reagieren auch nicht auf aktive Energieanziehung. Als erster Bewegungsentwurf driften sie unabhängig von Sonec nach links; genaue Bewegung und Gruppenregeln werden vor Implementierung separat freigegeben. So entstehen zwei deutlich unterscheidbare Gefahren: gezielte Bedrohung versus Raumkontrolle.

### Entwurfsfragen vor Code

- Eindeutige visuelle Unterscheidung der Minentypen (Form, Farbe, Bewegung).
- Regel für Gruppengröße, Abstand, Spawnregion, Lebensdauer, maximale gleichzeitige Minenzahl und Performance.
- Festgelegt: keine Sonec-Verfolgung und **keine Reaktion auf Energieanziehung** bei einfachen Minen. Vorgeschlagene Linksdrift und genaue Geschwindigkeit/Bewegung noch vor Code abstimmen; intelligente Minen behalten ihr jetziges Verhalten.
- Spawn-Fairness: niemals unangekündigt direkt in Sonec oder an Stellen, aus denen man nicht ausweichen kann; Mindestabstände und Sichtbarkeit.
- Zusammenhang mit der Warnung `MINEFIELD DETECTED`: Warnung früh genug, aber keine ständigen Spams.
- Bestehende Minen/Explosions-Kettenreaktionen und Energieanziehung beachten; diese zieht bereits Minen an.
- Bestehende frameabhängige Zufalls-Spawns sind **als Beobachtung dokumentiert**, nicht pauschal umzubauen; auf tatsächliche Dichte und Frame-Rate prüfen.

### Akzeptanzkriterien (Entwurf)

Intelligente Einzelminen verhalten sich wie bisher; einfache Minen verfolgen Sonec nicht und reagieren nicht auf Energieanziehung; Minenfelder sind sichtbar unterscheidbar, beherrschbar, nicht unfair bei Spawn/Bewegung und verursachen keine ungewollten Performance-/Kollisionseffekte. Gamepad, Waffen, Explosionsreaktionen und HTML5 bleiben funktional.

## 4. Real Alpha – Kernfeature 2: Schwebende Drohnen

### Drohnen-Art-Pass – Alpha-Planung, noch nicht implementiert (19.11.2026)

Die aktuelle farbige D1-Drohne hat sich als **funktionaler Prototyp** bewährt, passt aus Sicht des Entwicklers aber **noch nicht ausreichend zum gemeinsamen visuellen Stil** der übrigen SonecBot-Grafiken. Die drei bestehenden Drohnenansichten bleiben **Basis für die spätere Überarbeitung**, nicht Abfall. Der **Sensor soll ein eigenständiges Bild/Sprite** erhalten, unabhängig vom Körper steuerbar, damit Leuchten, Farbwechsel, Blinken, Warn-/Treffereffekte und ggf. weitere Richtungsanimationen möglich werden. Keine sofortige Grafik- oder Codeänderung, eigener späterer Design- und Testschritt.

**Offener Umfang der Real Alpha:** Anzahl und Auswahl zusätzlicher Gegnertypen werden **im Entwicklungsverlauf** festgelegt, auch unter Berücksichtigung der noch laufenden **Pre-Alpha-Feedbackauswertung**. Keine Mindestzahl, keine feste Deadline oder voreilige Zusage weiterer Gegner; K1 und M1 haben als technische Release-Gates Vorrang. Feedbackauswertung wird weiterhin in eigenem Arbeitsstrang behandelt.


**D1-Abnahme und kleiner Animationsfeinschliff (19.11.2026):** Der Entwickler meldet **11/11 bestandene Tests** in AGK/Windows und lokalem HTML5 für den unbewaffneten Patrouillenprototyp mit drei 46×30-px-Ansichten. Die Mittelansicht war in 200 ms kaum wahrnehmbar. Deshalb wurde **nur die Wendedauer auf 400 ms** erhöht (getesteter Ausgangsstand `86e3520`; dieser Feinschliff noch ungetestet). Später können vertikale Wanderung pro Wende, richtungsabhängige Waffe und Gefahrenbudget gesondert freigegeben werden.


### D1 – erste unbewaffnete Patrouillendrohne (Implementierung, Entwicklertest offen)

Drei vom Entwickler gezeichnete farbige 46×30-px-Ansichten: links, Mitte und rechts. Ein neues `drone.agc` lädt diese Sprites. Genau **eine** unbewaffnete Drohne pro `GameInit`, zunächst dauerhaft und ohne Kollision/Schaden. Start im sichtbaren Y-Bereich, feste Welt-Y-Höhe mit 80-px-Abstand zur oberen/unteren Weltgrenze. Horizontal zwischen X=60 und X=Bildschirmbreite–60, Testgeschwindigkeit ca. 0,10 px/ms. Je Umkehr 200 ms Stillstand und Mittelansicht, dann entgegengesetzte Flugansicht. Pause nutzt vorhandene virtuelle Uhr, Neustart setzt den Zustand zurück. **Spätere optionale Variante:** kleiner vertikaler Schritt pro Richtungswechsel; noch nicht umgesetzt. Bewaffnung in Flugrichtung erst nach D1-Abnahme, keine weiteren Drohnen, kein automatischer Spawn, kein Gefahrenbudget.



### Spielidee

Ein neuer, zunächst **einfacher fliegender Gegner**, der sich **von links nach rechts** durchs Bild beziehungsweise den sichtbaren Weltbereich bewegt. Nicht von Anfang an komplexe KI oder Angriffssysteme voraussetzen. Drohnen schaffen eine eigene vertikale Gefahr und nachvollziehbare Ziele für Waffen.

### Entwurfsfragen vor Code

- Höhe, Geschwindigkeit, Eintritt/Austritt, Sichtbarkeit, Maximalzahl, Spawnabstand und Rücksicht auf Kamera/Plattformen.
- Kollisionshülle, Gesundheit, Trefferbereiche, Projektilreaktionen, Explosion und Sound.
- Muss die erste Drohne angreifen oder reicht vorerst Überflug/Kontaktgefahr? **Noch offen**.
- Trefferklarheit und Feedback: besonders MG/Rifle und Plasma; sichtbare Trefferwirkungen bestätigen.
- Basisgrafik vorhanden? **Für Drohnen noch nicht bestätigt**, vor Artwork-Bau prüfen.

### Akzeptanzkriterien (Entwurf)

Drohnen schweben verlässlich auf der festgelegten Route, sind sichtbar und fair, Treffer/Schaden sind erkennbar, keine Kollisionseffekte auf Walker/Plattformen, stabile Windows-/HTML5-Läufe.

### Korrektur nach S4-Entwicklertest: Spawn-Y in Weltkoordinaten (18.11.2026)

S4-Warnmeldung nach `Message`-Compilerfix auf Windows/AGK und lokalem HTML5 laut Entwickler sichtbar/funktional. Zusätzlicher S3-Befund: Minenfeld-Y wurde mit `Game.Screen.Height` (Viewport) statt `Game.World.Size.Height` (Hintergrund/Welt) ausgelost. Enger Korrekturpatch verwendet die gesamte Welthöhe mit **50 px Mindestabstand der äußeren Formationsminen zu den Weltgrenzen**, inklusive halber Spritehöhe; **AGK-/HTML5-Nachtest offen**. Warnung, 18–30-s-Intervall, Sechs-Minen-Limit und übriges Gameplay unverändert.

## 5. Real Alpha – Kernfeature 3: Top-Warnungen / Avatar-Unterstützung

### S4 – Warnsystem implementiert, Entwicklertest offen (18.11.2026)

Zentraler Warnzustand `TWarning`, neue `warning.agc`, 440×58-px halbtransparenter Balken (Alpha 180), eingebundenes weißes Entwickler-Warnsymbol `warning.png` aus `/media/gfx/effects` per Code rot gefärbt, roter fetter Text (Größe 23). Overlay-Zeichnung in `GameDraw()` **vor `Swap()`**. Bei erfolgreichem Minenfeldspawn `MINEFIELD DETECTED` für **3000 ms**; kein Trigger bei voller Kapazität, kein Vorwarn-Timer. Ablauf und Neustart basieren auf vorhandener virtueller Spieluhr. Prioritäten und andere Texte sind vorbereitete Schnittstellen; weitere Ereignisse, Sounds und Avatar bewusst noch nicht umgesetzt. **Windows-/AGK- und HTML5-Laufzeittests ausstehend.**



### Spielidee

Die angedachte Meldung **`MINEFIELD DETECTED` oben im laufenden Spiel** wird zu einem **kleinen wiederverwendbaren Hinweis-/Warnsystem** ausgebaut. Langfristig hilft der Avatar; sein tatsächlicher Darstellungs-/Audioanteil ist erst zu entwerfen. Keine Annahme, dass es bereits ein fertiges Hilfesystem gibt.

### Vorschläge für Warnfälle (noch nicht endgültig)

- `MINEFIELD DETECTED` – räumliche Gefahr, abgestimmt auf Minenfeldspawn.
- `ENERGY OVERLOAD` – erklärt, dass Überladung gesundheitsschädlich sein kann.
- `SHIELD DOWN` / `LOW ENERGY` – Schutz-/Energiereserven.
- `CRITICAL DAMAGE` – gefährlicher Gesundheitsschaden.
- Spätere Gegner: `BOMBER APPROACHING`, `MISSILE LOCK` erst, **wenn** diese Mechaniken existieren.

### Gestaltung und Architektur

- Kurzer Text **oben**, damit HUD links und Action-Fokus erhalten bleiben.
- Priorität bei konkurrierenden Meldungen, Cooldown, Mindest-/Maximaldauer, keine Textüberflutung.
- Unterschied zwischen Warnung, kurzer Anleitung und Todesursache. Nicht jeden Spielzustand als Alarm ausgeben.
- Farbigkeit/Transparenz im bestehenden Cyan-/HUD-Stil testen, gute Lesbarkeit auf HTML5 und kleinen Screens.
- Warnungen können später mit einfachen Sounds/Avatar kombiniert werden, aber **Sound und Instanzlogik** separat testen.
- Gegebenenfalls Hilfetext-Definitionen später strukturiert/extern, z. B. JSON; aktuell nur Zukunftsidee und kein automatischer Umbau.

### Akzeptanzkriterien (Entwurf)

Warnungen erscheinen im richtigen Moment, bleiben ausreichend lang, stören weder Gameplay noch Menüsteuerung, erscheinen nicht ständig wiederholt und erklären mindestens eine zuvor unverständliche Gefahr; lokaler AGK-/HTML5-Test mit Entwicklerabnahme.

## 6. Weitere Real-Alpha-Kandidaten – bewusst nachrangig

Diese Ideen sind **nicht Bestandteil der drei vorrangigen Kernfeatures**. Nur später gezielt priorisieren:

| Kandidat | Aktueller Stand | Besonderheit |
|---|---|---|
| **Bomber** | Vorversion der Grafiken laut Entwickler vorhanden | Hoher Überflug, mehrere Bomben in Salven; Warnzeit, Fallbahn, faire Ausweichmöglichkeit, Kamera |
| **Flarakstellung** | Vorversion der Grafiken laut Entwickler vorhanden | Fährt aus dem Boden, feuert mehrere zielgesteuerte Raketen; komplexere Zustands-/Ziel-/Projektil-Logik |
| **MG/Rifle-Trefferfeedback und Hitboxen** | Rotes Aufleuchten existiert, frühere Trefferchecks erfolgreich; neuer Spieler unsicher | Walker ist aktuell vor allem am **Turm** verletzbar; weitere empfindliche Bereiche prüfen, keine Trefferprobleme unbelegt behaupten |
| **Bewegungsphysik und Fall-Fairness** | Community-Spieler meldet „Raketenbeschleunigung“ und Plattformdurchfall | Schnelles Durchfallen ist **bewusst vorgesehen**, aber auf Fairness/physikalische Plausibilität testen |
| **Schaden-/Tod-Erklärung** | Spieler versteht Ursachen teilweise nicht | Bullet-Soundfeedback fehlt laut Entwickler, mögliche Warn-/Avatar-Anbindung, Overload und Tod durch Weltgrenze beachten |
| **HUD-Beschriftung/Tutorial** | Linke Balken unverständlich für Erstspieler | Gesundheit/Schild, Energie/Overload, MG-/Granatenmunition; vertikaler Text möglich, kontextbezogene Hilfe bevorzugt ausprobieren |
| **Kleines Missions-/Überlebensziel** | Reiner Vorschlag, nicht beschlossen | Orientierung geben ohne großes Missionssystem |
| **Phasen-/Wellensteuerung** | Reiner Vorschlag, nicht beschlossen | Erst nach vorhandenen Gegnern; aktuelle Spawnlogik nicht beiläufig ersetzen |
| **HTML5-Sound-Überlagerung** | Entwickler beobachtet Kratzen bei überlappenden SFX | Separater **Knowledge-Base-Kandidat**; Soundinstanzen, Summenpegel/Clipping und Absenkung laufender Instanzen **erst reproduzieren**, kein bestätigter Fix |

### Reihenfolge innerhalb der Real Alpha

- **Kernentwicklung:** (1) Minenvarianten, (2) Drohnen, (3) Warnsystem – Warnsystem darf konzeptionell parallel geplant werden, nicht ungeprüft in fremde Features eingreifen.
- **Qualität/Verständlichkeit:** Kollisions-/Physik-Fairness, Treffer-/Todesfeedback, HUD/Anleitung passend zu Testerbefunden in kleinen Einzelprüfungen.
- **Optional danach:** Bomber, Flarakstellung, einfache Ziele, Wellenlogik – nur wenn Umfang und Testaufwand vertretbar sind.

Keine feste Deadline oder Release-Versprechen.

## 7. itch.io-Plan für beide Spiele – Inhalt zunächst vorbereiten

Die folgende **gemeinsame Inhaltsidee gilt für SonecBot und Columns**, aber Änderungen an beiden itch.io-Seiten bleiben manuell und nur nach Freigabe:

- **COMING SOON** – kurze, realistische Vorschau auf tatsächlich geplante Features; klar von verfügbaren Features unterscheiden. Bei SonecBot ggf. drei Kernfeatures und später Bomber/Flarak **als Pläne**, nicht als bereits spielbar ausgeben.
- **TIPS & TRICKS** – verständliche Bedienungs- und Spielhinweise, möglichst aus Nutzerfragen/Feedback: Schild/Energie/Overload, Gefahr durch Minen, Bewegung, Waffen/Verwundbarkeit; für Columns später entsprechend eigenständig ausarbeiten.
- Englisches Markdown für itch.io vorbereiten, keine neuen Termine, keine unbestätigten technischen Behauptungen, keine automatische Umstellung auf Published.
- **Pre-Alpha-Abschluss-Promobild mit Keyboard** für SonecBot erst **am Ende** des Keyboard-Patches, als eigener freigegebener Gestaltungsauftrag.

## 8. Columns – nur projektübergreifende Übergabe, keine Änderungen im anderen Repo

Der Entwickler hat folgende Arbeiten für **Columns** genannt:

- **Columns 1.1 hat vorerst keine Priorität.**
- **Eigenes TODO-Dokument** im Columns-Repository erstellen, **nur sofern dort noch keines existiert**; vorhandene TODO nicht überschreiben und zuerst die aktuelle Projektlage/Branch-Regeln prüfen.
- `AGENTS.md` für Columns ist eine **Baustelle** und soll später gesondert überarbeitet werden.
- **Zwei Theme-Tracks** für Columns sollen später entstehen (Kompositions-/Lizenz-/Format- und Looppunkte vorher besprechen).
- itch.io-Seite später mit **COMING SOON** und **TIPS & TRICKS** verbessern, im gleichen Arbeitsgang wie SonecBot oder besser im separaten Columns-Chat. Inhalte/Releaseplan für Columns nicht aus SonecBot ableiten.

**Repository nun verifiziert (17.11.2026):** Das Projekt heißt **Crystal Columns**, das GitHub-Repository ist **[`ChristianEngel19820128/Crystals`](https://github.com/ChristianEngel19820128/Crystals)** (nicht `/Columns`). Vorhandene `AGENTS.md` geprüft, `TODO.md` fehlte und wurde nach ausdrücklicher Zustimmung des Entwicklers auf `Crystals/main` **neu angelegt**: [`Crystals/TODO.md`](https://github.com/ChristianEngel19820128/Crystals/blob/main/TODO.md), Commit `935fde8`. Enthält die zurückgestellten Themen **1.1 ohne Priorität**, `AGENTS.md` verbessern, zwei Theme-Tracks und itch.io **COMING SOON/TIPS & TRICKS**. Keine Änderungen an Crystals-Quellcode, bestehenden Agent-Regeln oder itch.io. Die frühere Zugriffslücke betraf allein die Suche nach dem falschen Repositorynamen.

## 9. Zusammenarbeit und Abnahme

- In allen Folgeschritten zunächst `AGENTS.md` beachten: **read-only als Standard**, nur **eng vom Besitzer freigegebene** Änderungen.
- `develop` ist der Arbeitsbranch; `main`, `source/legacy`, itch.io und das unabhängige AGK-Knowledge-Base-Repo bleiben ohne separate Freigabe unberührt.
- Jede einzelne Änderung: GitHub-HEAD prüfen → genaue Quelllage verstehen → gewünschtes Verhalten vereinbaren → minimal ändern → statisch kontrollieren → Entwickler kompiliert/prüft Windows und HTML5 → Bericht auswerten → dokumentieren → erst dann nächster Schritt.
- Prüfberichte präzise auseinanderhalten: **Spielerfeedback**, **Hypothese**, **Quellprüfung**, **lokaler AGK-Test** und **Browser-/itch.io-Test**.
- Keine generelle automatische „Fehlerbereinigung“ und keine Balanceänderung nur aufgrund eines Kommentars.
- Bei Chatwechsel: dieses Dokument und die frisch ergänzte Top-Sektion in `HANDOFF.md` sind die **aktuelle Richtung**. Ältere anderslautende offene Einträge sind Projektgeschichte.

## 10. Aktueller Wiedereinstieg

> **SonecBot auf `develop`: Alpha-Walker, Keyboard-Rebinding einschließlich Restore Defaults und der aktualisierte itch.io-Draft-Embed-Test (12/12 laut Entwickler am 18.11.2026) sind abgeschlossen. Jetzt zuerst die Dokumentation angleichen und die geprüfte Pre-Alpha-Übernahme nach `main` separat freigeben. Anschließend Real Alpha mit genau drei Kernfeatures: (1) intelligente Einzelminen plus einfache Minenfelder – einfache Minen verfolgen Sonec nicht und reagieren nicht auf Energieanziehung (Variante B), (2) von links nach rechts schwebende Drohnen, (3) Top-Warnungen und spätere Avatar-Unterstützung. Keine Codeänderung ohne eng umrissene Zustimmung; AGK-/HTML5-Laufzeittests durch den Entwickler. itch.io bleibt Draft / Secret URL, kein Publish ohne gesonderte Freigabe.**
