# SonecBot – TODO und Meilensteine

**Dokumentstatus:** Version 0.4  
**Stand:** 14. November 2026  
**Branch:** `develop`  
**Ziel:** Kleine, überprüfbare Schritte zur spielbaren HTML5-Alpha

---

## Legende und Arbeitsweise

- `[x]` – Im Code umgesetzt oder als lokaler Meilenstein bestätigt; der tatsächliche Testumfang steht jeweils dabei.
- `[ ]` – Offen, geplant oder noch nicht ausreichend geprüft.
- Die Aufgabenliste ist **keine pauschale Änderungsfreigabe**. Für Codeänderungen gilt weiterhin `AGENTS.md`; die Prüfung erfolgt bevorzugt in kleinen Commits auf `develop`.
- Neue technische Befunde gehören in `TECHNICAL.md`, grundlegende Projektentscheidungen in `PROJECT.md`.

## 1. Walker – aktueller Schwerpunkt

### Abgeschlossener IK-Meilenstein (13. November 2026)

- [x] Die frühere direkte Beinwinkelanimation durch eine 2-Knochen-IK mit gemeinsamer Winkelumrechnung ersetzen.
- [x] Unterschiedliche Beinlängen anhand von `Proto.Offset → Proto.Anchor` berechnen, statt für beide Glieder 31 px anzunehmen.
- [x] Bilddrehpunkte und Anschlusspositionen mit weißem Skelett, roten Offset- und türkisen Anchor-Markierungen untersuchen.
- [x] Weiße Debug-Linien (2 px) und Gelenkmarkierungen (5 × 5 px) korrekt nach Offset positionieren.
- [x] Corpus-Anchor an die unveränderte IK-Hüfte und den Turm-Offset an den Corpus-Offset anbinden (Referenz-Commit `deb8b74`).
- [x] Stabile Standpose mit 30 px Hüfthöhe und zwei Fußzielen bei ±10 px im lokalen Screenshot des Entwicklers grundsätzlich bestätigen. **Das bestätigt nicht automatisch die fertige Laufanimation.**
- [x] Historische ±45°-Proto-Rotationen für Thigh und Shank als Altwerte identifizieren; aktuelle Testwerte bleiben 0°.

### Abgeschlossener Laufanimations-Meilenstein (14. November 2026)

- [x] Standpose-Diagnosemodus deaktivieren: `WALKER_STAND_POSE_TEST = 0`.
- [x] Getrennte Fußziele von −10/+10 px auch während der Schritte beibehalten.
- [x] Standbein auf der Plattform fixieren und Schwungbein mit an die Reichweite angepasstem Schrittziel bewegen (180° pro 15 px Weg).
- [x] Füße beim Anhalten sanft zur Grundhaltung zurückführen.
- [x] An Plattformkanten über `TurnPending` erst zur Standpose zurückkehren, dann die Blick- und Laufrichtung wechseln.
- [x] Einheitliches, langsameres Lauftempo `0.05` für vergleichbare Tests setzen.
- [x] Fußgelenke 8 px über der Plattformoberkante platzieren; die tatsächlichen Fußsohlen liegen im lokalen Screenshot optisch passend auf.
- [x] Weißes Debug-Skelett, Proto-Markierungen und Winkelanzeige standardmäßig deaktivieren; Diagnoseroutinen erhalten.
- [x] Gangbild, Pausen, Richtungswechsel und Animation ohne Debug in lokalen Screenshots/Videos grundsätzlich prüfen. **Bewertung des Entwicklers: Laufanimation alpha-tauglich.** Das ersetzt keinen umfassenden HTML5-/Randfalltest.

### Walker-Bewaffnung – nächster Schwerpunkt

- [x] Erste horizontale Walker-Testschüsse in Blickrichtung mit einem Timer von 1800 ms über `BulletAdd(...,TYPEENEMY,...)` eingebunden; Mündungsposition wirkt im lokalen Test plausibel. Schüsse treffen Sonec und verursachen Schaden.
- [x] Walker-Turmtreffer auf Spielerprojektile (`TYPEPLAYERONE`) begrenzt, damit Walker-Geschosse nicht ihre eigenen Artgenossen beschädigen.
- [x] **Zwei-Schuss-Salve im Code implementiert:** Walker startet nur während einer normalen Standpause mit ruhig stehenden Füßen eine Salve aus zwei Geschossen (150 ms Abstand). Während `FireState` aktiv ist, darf weder die Laufbewegung noch eine Wendung beginnen; nach dem zweiten Schuss bleiben 200 ms Erholungszeit für einen späteren Rückstoß/eine Animation. Bestehender Schussabstand zwischen Salven 1800 ms. **Lokaler Laufzeittest noch offen.**
- [ ] **Nächster Test:** Im Spiel prüfen, ob der Walker die Bewegung für beide Schüsse und bis zum Ende des Feuerzustands festhält, erst anschließend weiterläuft, nicht während des Wendens schießt und der Feuertimer bei längeren Standphasen sinnvoll bleibt.
- [ ] Testen, ob die Geschosse mit Float-Weltkoordinaten tatsächlich mittig aus dem **2 px hohen Rohr** austreten; Bullet-Grafik ist laut Entwickler 6 px hoch. Den Grafikbestand nicht vorschnell umbauen. Gemessene Mündung (Proto-Anschluss) und sichtbare Spriteposition vergleichen; `Floor()` in `SpriteDraw()` keinesfalls ohne projektweiten Test entfernen.
- [ ] Bestehendes Mündungsfeuer (`FlashAdd`) für Walker wiederverwenden, **ohne Sonecs Maschinengewehrcode zu verändern**. Ggf. gemeinsame kleine Aufruffunktion oder geeignete Parameter ergänzen; Position, Richtung, Effektlebensdauer und Scale prüfen.
- [ ] Eine vorübergehende zuschaltbare Debug-Anzeige für Walker-Waffen entwickeln: Mündungs-Pivot, tatsächlicher Bullet-Startpunkt, Blickrichtung, Salvenzustand, Schuss-Timer sowie Bullet-Typ/Geschwindigkeit; optional Zeitlupe/Marker für einzelne Geschosse.
- [x] **Fairness-Regel Orbs:** Orbs sind keine neutralen Ziele für Geschosse: Nur `TYPEPLAYERONE` darf sie per `BulletCollideOrbs()` treffen; Walker-/Feind-Bullets werden ignoriert. Statisch eingecheckt, lokaler Test offen. Weitere Schadensquellen (Explosionen usw.) separat betrachten.
- [ ] **Trefferregel-Matrix festlegen:** Welche Geschosse (Spieler, Walker/Feind) dürfen Sonec, Schild, Walker, Minen, Orbs, Kisten oder andere Objekte treffen? Kistenschaden durch Walker ist aktuell möglich und eventuell akzeptabel, Entscheidung offen. Bei allen Gegnerfähigkeiten auf **faire Computergegner** achten: erkennbare Angriffsmuster, realistische Reaktionszeiten und keine unbeabsichtigte Zerstörung spielerrelevanter Ressourcen.
- [ ] Sehr schnelle Bullets (derzeit ungefähr 300 virtuelle px/s) auf **Tunneling** zwischen Kollisionsprüfungen testen; ggf. Strecke zwischen alter und neuer Position statt nur Endposition prüfen. Der gelegentliche Eindruck minimal verfehlter Treffer bei Sonec ist noch kein bestätigter Fehler.
- [ ] Prüfen, wie feindliche Geschosse mit Sonecs Schild interagieren; `BulletCollide()` zieht derzeit unmittelbar Gesundheit ab.
- [ ] Diagonal schießende Bullets, inklusive Projektilgrafik und korrekt rotierter Trefferbox, erst **nach** dem horizontalen Waffen-Grundtest entwickeln.
- [ ] Danach Zielwahl/Erkennungsbedingungen und optional eine begrenzte Turm-/Torso-Neigung separat planen, ohne die funktionierende Bein-IK zu verändern.

### Walker – spätere Arbeiten und Polishing

- [ ] Verhalten an Kisten und auf besonders schmalen Plattformen überprüfen; Plattformkanten sind bereits berücksichtigt.
- [ ] Größeninitialisierung in `WalkerNew` und die daraus abgeleiteten Begrenzungs-/Kollisionswerte prüfen.
- [ ] Explosionstreffer für Walker ergänzen, wenn die allgemeine neutrale Explosionskollision erweitert wird.
- [ ] Später entscheiden, ob eine zusätzliche Corpus-Trefferzone sinnvoll ist.
- [ ] **Grafisches Polishing (nicht alpha-blockierend):** Beinsegmente bei Bedarf etwas schlanker zeichnen und Knie-/Gelenkdetails, Konturlinien oder kleine Highlights ergänzen. Dabei Sprite-Offsets und Anchors nur bei wirklicher Änderung der Bildgeometrie nachmessen.
- [ ] Die vorhandene richtungsabhängige ±90°-Fußwinkelzuweisung für ein künftiges verallgemeinertes Skelett-/Endglied-Konzept dokumentiert lassen; nur bei konkretem Fehler anfassen.
- [ ] Allgemeine, beobachtete 1-px-Darstellungsabweichung bei Plattformen/Kisten/Sonec gesondert untersuchen; Ursache durch `Floor()` ist noch nicht bestätigt.
- [ ] Langfristig IK-Grundfunktionen und Debug-Skelett vereinheitlichen und bei Bedarf für weitere Gegnertypen auslagern; aktuelle Walker-Implementierung nicht vor der Alpha destabilisieren.
- [ ] Spriter oder ein vergleichbares Keyframe-Werkzeug optional für Spezialanimationen evaluieren.

## 2. HTML5-Alpha – hohe Priorität

- [ ] Aktuellen HTML5-Build in einer Browserumgebung praktisch testen; Ziel für die erste Veröffentlichung ist itch.io.
- [ ] Gamepad-Eingaben mit dem bestehenden HTML5-Index-1-Workaround verifizieren; bei Problemen mit dem Referenzprojekt Crystals vergleichen.
- [ ] **Alpha:** Tastatur als zuverlässig spielbare Alternative zum Gamepad prüfen und vollständige Standardbelegung für Bewegung, Jetpack, Waffen, Schild und Pause festlegen und testen.
- [ ] **Alpha-Optionen (Minimalumfang):** Entscheiden, ob ein kleines Optionsmenü vor der Veröffentlichung nötig ist (zumindest Steuerung anzeigen, Audio/Anzeige falls relevant); alternativ Standardbelegung im Spiel/Hilfetext dokumentieren. Kein komplexes Menü als automatische Alpha-Voraussetzung.
- [ ] **Beta:** Frei belegbare Tastatursteuerung (Key-Rebinding) mit Konfliktprüfung, Standardwerte wiederherstellen und dauerhafter Speicherung als eigene Aufgabe vorsehen.
- [ ] **Beta:** Optionsmenü um Eingabe-/Audio-/Grafikeinstellungen entsprechend tatsächlichem Bedarf erweitern.
- [ ] Freien Fall, Sprung, Jetpack, Landungen, Waffen und Plattformen bei unterschiedlichen Bildraten testen.
- [ ] Offene bildratenabhängige Bewegungsberechnungen (insbesondere Sonec) bewerten; nicht allein wegen aktiviertem VSync als gelöst einstufen.
- [ ] Spielrunde, Pause, Tod, Neustart und minimale Alpha-Abschlussbedingungen festlegen.
- [ ] **Einfaches Punktesystem für die Alpha prüfen:** Vorhandene Punkte-/Score-Anzeige und Punktvergabe im aktuellen SonecBot-Code inventarisieren; minimale Regeln für Treffer, zerstörte Ziele, Ressourcen und Spielende festlegen und testen.
- [ ] **Online-Highscore-Tabelle prüfen:** Bestehende Lösung aus Crystals und ihre technische Anbindung/Datenschutz/Fehlerfälle prüfen; entscheiden, ob eine einfache Online-Tabelle bereits mit der Alpha sinnvoll und zuverlässig ist oder erst mit der Beta veröffentlicht wird.
- [ ] **Schwierigkeitsgrade für die Veröffentlichung vormerken:** mindestens das gewünschte Standard-Spielgefühl und mögliche Varianten prüfen; Spawnrate, Gegnerpräzision, Feuerpausen, Ressourcenverfügbarkeit und Fairness berücksichtigen. Kein sofortiger Umbau der Balance.
- [ ] Alpha-Umfang bewusst klein halten: ein zuverlässig spielbarer Walker ist Pflicht, zusätzliche Gegner nicht automatisch.

## 3. Kampf, Energie und Kollisionen – mittlere Priorität

- [ ] Explosionen gegen Walker und weitere zerstörbare Objekte auf neutrale Schadenswirkung sowie gewünschte Kettenreaktionen ausbauen.
- [ ] Schildkollisionen mit AGK-Shape-Diagnose weiter bewerten; bisherige Radius-/Schadenslogik nicht ungeprüft ersetzen.
- [ ] Schildladung langfristig von Animationsframes entkoppeln; Schadensarten kinetisch, Explosion, Plasma und Flamme fachlich trennen.
- [ ] Gewünschte höhere Energie- und Schildkapazitäten inklusive späterer Upgrades und HUD-Balkenproportionen konkret festlegen.
- [ ] Transparenz für HUD, Inenergie-Animation und abhängig vom Energiewert dargestellte Sammelobjekte einführen.
- [ ] Energieverbrauch bei Energieaufnahme als mögliche ältere Designentscheidung überprüfen.
- [ ] Belohnungen durch zerstörte Kisten und Orb-/Upgrade-Verhalten anhand des aktuellen Codes und Spieltests verifizieren.

## 4. Spätere Erweiterungen – niedrige Priorität

- [ ] Weitere Gegnertypen und besondere Bewegungs-/Angriffssysteme erst nach stabiler Alpha-Basis planen.
- [ ] Informationsavatar sowie mögliche Aufgaben/Missionen konkretisieren.
- [ ] Vorhandene Online-Highscore-Lösung als Option für Alpha/Beta prüfen (erste Prüfung und mögliche frühere Alpha-Integration im Abschnitt HTML5-Alpha).
- [ ] Weiteren Grafik-, Sound- und UI-Feinschliff nach stabiler Kernmechanik priorisieren; Walker-Beindetails sind bewusst auf später verschoben.

## 5. Dokumentation und Nachvollziehbarkeit

- [x] `PROJECT.md` auf Version 0.6 mit dem alpha-tauglichen Walker-Gangbild aktualisieren.
- [x] `TECHNICAL.md` auf Version 0.5 mit IK-Mathematik, Laufsteuerung, Fußhöhe, Debug-Verfahren und Testgrenzen aktualisieren.
- [x] `TODO.md` angelegt und auf Version 0.2 mit priorisierten Walker-Bewaffnungsaufgaben erweitert.
- [x] Ergebnis der lokalen Walker-Lauftests nachtragen; mögliche Randfälle und graphisches Polishing ausdrücklich später behandeln.
- [ ] **README.md für die Alpha aktualisieren:** Bestehende Kurzbeschreibung und veraltete Aussage „only with Joypad“ anhand des tatsächlich getesteten Steuerungsstands korrigieren; Spielkonzept, Controls, bekannte Grenzen, HTML5-Start, Lizenz/Projektstatus und itch.io-Link verständlich darstellen.
- [ ] **itch.io-Alpha-Seite vorbereiten:** Aussagekräftigen Titel, Kurz- und Langbeschreibung, Kategorie, Tags, Steuerung, Browserhinweise, Alpha-Stand und ehrliche bekannte Einschränkungen formulieren; README und Seite konsistent halten.
- [ ] **Alpha-Screenshots erstellen und auswählen:** 3–5 aussagekräftige Spielszenen, sinnvolles Cover/Banner; für eingebettete HTML5-Seiten ggf. Bilder zusätzlich in der Beschreibung platzieren.
- [ ] **Kurzen Gameplay-Trailer prüfen:** Video/MP4 bei Bedarf erstellen; itch.io unterstützt laut offizieller Dokumentation als Trailer derzeit Links zu extern gehosteten Videos (u. a. YouTube/Vimeo), keine direkte MP4-Einbettung als dokumentierte Trailer-Option. Veröffentlichung und Darstellung auf der HTML5-Seite testen.
- [ ] Vor der HTML5-Alpha offene Anforderungen und tatsächlichen Teststatus der Kernsysteme erneut abgleichen.
- [ ] Vor dem Alpha-Abnahmetest bzw. beim Wechsel in einen neuen Chat ein **Übergabeprotokoll** erstellen: Branch und Commits, getesteter Build, erledigte Funktionen, offene Fehler/Entscheidungen, aktuelle Prioritäten, relevante Dateien und bekannte AGK-Besonderheiten.

**Walker-Referenzstände:** Corpus-/Turmanbindung `deb8b74`; getrennte Fußziele `760c8c3`; angepasste Gangphase `20eced3`; Wendeverhalten `810d342`; einheitliche Geschwindigkeit `20b2d7d`; Fußhöhe 8 px `328c5e0`; Debug-Anzeigen aus `c6d47e6` (jeweils auf `develop`). Der Entwickler hat das lokale Gangbild als alpha-tauglich bewertet; ein eigener AGK-Build des Assistenten und ein HTML5-Praxistest stehen aus.
