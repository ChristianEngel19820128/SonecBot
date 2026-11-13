# SonecBot – TODO und Meilensteine

**Dokumentstatus:** Erste Fassung 0.1  
**Stand:** 13. November 2026  
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

### Nächste isolierte Tests – hohe Priorität

- [ ] `WALKER_STAND_POSE_TEST` kontrolliert von `1` auf `0` stellen und die normale Schrittsteuerung wieder aktivieren.
- [ ] Im Video beide Laufrichtungen, Schritte, Bodenkontakt, Pausen, Loslaufen und Richtungswechsel mit der neuen Körperanbindung prüfen.
- [ ] Stand- und Schwungbein besser unterscheiden; Standfuß soll nicht sichtbar über die Plattform gleiten.
- [ ] Übergang zwischen Bewegung und stabiler Standpose ohne abrupte Fußsprünge abstimmen.
- [ ] Vorläufige richtungsabhängige Fußwinkel (`-90°` links, `+90°` rechts) anhand der Originalbilder überprüfen und endgültige Endglied-Referenz festlegen; keine verdeckten individuellen Beinwinkelkorrekturen einführen.
- [ ] Nach erfolgreichem Bewegungstest Debug-Anzeigen standardmäßig deaktivieren, die Diagnosefunktionen und Schalter aber für spätere Gegner erhalten.

### Walker – anschließende Arbeiten

- [ ] Kollisions- und Bewegungsverhalten an Kisten sowie schmalen Plattformen überprüfen; Plattformkanten begrenzen die Bewegung bereits.
- [ ] Eigene Walker-Projektile über das bestehende Bullet-System integrieren und auf korrekt positionierte Mündungen prüfen.
- [ ] Kleine, kontrollierte Torso-/Turm-Neigung beim Zielen evaluieren; stabile Fuß- und Hüftanschlüsse dabei erhalten.
- [ ] Größeninitialisierung in `WalkerNew` und die daraus abgeleiteten Begrenzungs-/Kollisionswerte prüfen.
- [ ] Explosionstreffer für Walker ergänzen, wenn die allgemeine neutrale Explosionskollision erweitert wird.
- [ ] Später entscheiden, ob eine Torso-Trefferzone das Spielgefühl verbessert.
- [ ] Spriter oder ein vergleichbares Keyframe-Werkzeug optional für Spezialanimationen (Knien, Aufstehen, Zerstörung) evaluieren; das prozedurale IK-System bleibt die Grundlage.

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
- [ ] Grafik-, Sound- und UI-Feinschliff nach stabiler Kernmechanik priorisieren.

## 5. Dokumentation und Nachvollziehbarkeit

- [x] `PROJECT.md` auf Version 0.5 mit dem Walker-Meilenstein aktualisieren.
- [x] `TECHNICAL.md` auf Version 0.4 mit IK-Mathematik, Proto-Verbindungen, Debug-Verfahren und Fehlergeschichte aktualisieren.
- [x] `TODO.md` als priorisierte Aufgabenübersicht anlegen.
- [ ] Nach erfolgreichem Walker-Lauftest dessen Ergebnis sowie mögliche neue Restfehler nachtragen.
- [ ] Vor der HTML5-Alpha offene Anforderungen und tatsächlichen Teststatus der Kernsysteme erneut abgleichen.

**Referenz des Walker-Meilensteins:** `deb8b74` auf `develop`. Bestätigt wurde die Standpose anhand lokaler Tests und Screenshots des Entwicklers; kein eigener AGK-Build durch den Assistenten.
