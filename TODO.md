# SonecBot – TODO und Meilensteine

**Dokumentstatus:** Version 0.2  
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

- [ ] Vorhandene `BulletAdd`-/`BulletNew`-Schnittstellen sowie Kollisions- und Projektilbesitzerlogik untersuchen, bevor ein Gegner schießt.
- [ ] Zielwahl und einfache Erkennungsbedingungen für Sonec festlegen; keine unbegrenzte Treffergenauigkeit oder Dauerfeuer.
- [ ] Mündungsposition aus dem aktuellen Turm-Sprite und seinen Proto-Daten ableiten und im Debugtest prüfen.
- [ ] Kontrollierte Walker-Schüsse mit Abklingzeit und sauberer Freund-/Feind-Unterscheidung auf Basis des bestehenden Bullet-Systems implementieren.
- [ ] Kollision und Schaden feindlicher Geschosse gegen Sonec sowie Interaktion mit dem Schild lokal testen.
- [ ] Optionale, begrenzte Turm-/Torso-Neigung beim Zielen separat evaluieren; die funktionierende Bein-IK nicht verändern.

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
- [ ] Eingabealternativen und Benutzbarkeit von Tastatursteuerung prüfen.
- [ ] Freien Fall, Sprung, Jetpack, Landungen, Waffen und Plattformen bei unterschiedlichen Bildraten testen.
- [ ] Offene bildratenabhängige Bewegungsberechnungen (insbesondere Sonec) bewerten; nicht allein wegen aktiviertem VSync als gelöst einstufen.
- [ ] Spielrunde, Pause, Tod, Neustart und minimale Alpha-Abschlussbedingungen festlegen.
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
- [ ] Vorhandene Online-Highscore-Lösung für eine spätere Beta prüfen.
- [ ] Weiteren Grafik-, Sound- und UI-Feinschliff nach stabiler Kernmechanik priorisieren; Walker-Beindetails sind bewusst auf später verschoben.

## 5. Dokumentation und Nachvollziehbarkeit

- [x] `PROJECT.md` auf Version 0.6 mit dem alpha-tauglichen Walker-Gangbild aktualisieren.
- [x] `TECHNICAL.md` auf Version 0.5 mit IK-Mathematik, Laufsteuerung, Fußhöhe, Debug-Verfahren und Testgrenzen aktualisieren.
- [x] `TODO.md` angelegt und auf Version 0.2 mit priorisierten Walker-Bewaffnungsaufgaben erweitert.
- [x] Ergebnis der lokalen Walker-Lauftests nachtragen; mögliche Randfälle und graphisches Polishing ausdrücklich später behandeln.
- [ ] Vor der HTML5-Alpha offene Anforderungen und tatsächlichen Teststatus der Kernsysteme erneut abgleichen.

**Walker-Referenzstände:** Corpus-/Turmanbindung `deb8b74`; getrennte Fußziele `760c8c3`; angepasste Gangphase `20eced3`; Wendeverhalten `810d342`; einheitliche Geschwindigkeit `20b2d7d`; Fußhöhe 8 px `328c5e0`; Debug-Anzeigen aus `c6d47e6` (jeweils auf `develop`). Der Entwickler hat das lokale Gangbild als alpha-tauglich bewertet; ein eigener AGK-Build des Assistenten und ein HTML5-Praxistest stehen aus.
