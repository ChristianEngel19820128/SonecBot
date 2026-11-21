# SonecBot – Ideen für vielleicht später

**Stand:** 21. November 2026  
**Status:** Unverbindliche Sammlung; ohne feste Reihenfolge, Termin oder Implementierungsfreigabe.

Die beschlossenen Real-Alpha-Grundversionen stehen in [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md), nächste Schritte in [TODO.md](TODO.md).
Bomber, Flarak, hilfreicher Jumppod, Gefahren-/Erfahrungsgrundsystem, kleine Ziele und die Munitions-/Panzerungsbasis sind dorthin übernommen.

## Varianten und Unterstützung

- **Quadrokopter:** eigenständiges, noch offenes Konzept. Möglich sind zeitweilige verbündete Unterstützung, etwa als Belohnung nach zerstörten Flaraks, ein auf Abstand angreifender Verfolger oder Aufklärung. Keine Rolle endgültig gewählt; keine weitere Kamikaze-Kopie der intelligenten Mine als Vorgabe.
- **Jumppod-Falle:** sehr seltene explodierende Attrappe. Nur erwägen, wenn ein kleiner erkennbarer Unterschied bzw. eine rechtzeitige Aktivierungsbewegung faire Gegenwehr erlaubt. Idee: bei Annäherung etwa einen Pixel ausfahren, Kontakt löst Explosion aus. Nicht auf alle vorhandenen Minentypen übertragen.
- **Flarak-Massenwerfer:** ungenaue Raketensalve ohne Zielsuchraketen als spätere Modifikation.
- **Drohnen-Schildfunktion:** Später ein eigenes Schildkonzept für Drohnen entwerfen (Aktivierung, Schutzwirkung, Trefferfeedback und Gegenmaßnahmen); keine aktuelle Implementierung oder Balancevorgabe.
- **Drohnen-Dauerlaser:** seltener, zeitlich begrenzter, über den Boden schwenkender Strahl; sichtbares Aufladen vor dem Angriff. Alpha-Basis sind kurze Laserprojektile.
- **Flammenfalle:** stationäre Modifikation mit berechenbarem Feuerraum. Flammenwerfer müssen nicht exklusiv Sonec gehören.
- **Luftunterstützung als Aufgabe/Belohnung:** Flaraks zerstören, um Unterstützung zu ermöglichen; mögliche Hilfe gegen ein oder zwei Bomber. Konkrete Aufgabe und Unterstützungsfunktion offen, kein Pflichtumfang der ersten kleinen Ziele.
- **Walker-Erweiterungen:** zusätzliche Trefferzonen/Beinschaden als Beispiel für taktische Wirkung; gegebenenfalls stationäre Variante im Fallenkonzept. Kein neuer Auftrag am abgeschlossenen Alpha-Walker und keine Umdeutung seiner aktuellen Turm-Schadenszone.
- **Weitere Bots/Bosse:** nur bei eigener spielerischer Rolle konkretisieren; keine Mindestzahl an Varianten.

## Fortschritt, Wertung und Bedienung

- **Punkte und Online-Ranglisten:** später getrennt vom Erfahrungswert entwickeln; Erfahrung steuert Gefahr, die Wertung ist noch nicht festgelegt. Mögliche Anknüpfung an Crystals.
- **Schwierigkeitsauswahl:** im Zusammenhang mit späteren Punkten/Ranglisten prüfen. Getrennte Tabellen je Schwierigkeit und eine gemeinsame Alpha-Ausgangseinstellung sind Vorschläge aus der Besprechung, noch keine endgültigen Regeln.
- **Umfassende Rüstungs-/Schadensmatrix:** einfache testbare Basis gehört zur Alpha; weitere Gegenwerte, Typen und Feinausgleich später, besonders vor 1.0. Fraktionen Player/Enemy/Neutral getrennt von Schadensarten behandeln.
- **Zusätzliche Upgrades, Ressourcenanzeigen und Achievements:** bei erkennbarem spielerischem Nutzen konkretisieren.
- **Gamepad-Rebinding, Maus und weitere Bedienoptionen:** später; Entwickler ist mit der vorhandenen Gamepad-Steuerung zufrieden. Keyboard-Umbelegung, Speicherung und Reset sind umgesetzt.
- **Spieloptionen zurücksetzen:** Umfang getrennt vom fertigen Keyboard-Reset klären.
- **Energieanziehung als Halten/Umschalten:** mögliche spätere Einstellung; heutiges Verhalten nicht automatisch ändern.
- **Umfangreichere Missionen, Informationsavatar oder Sprache:** über die kleinen Alpha-Ziele und vorhandenen Warn-/Hilfetexte hinausgehender Ausbau.
- **Optionale Draufsicht und Multiplayer:** langfristig, ohne zugesagten Release.

## Grafik und Präsentation

- **Trefferfarben nach Schadenshöhe:** Optional später ein einheitliches Farbspektrum für die Höhe eines erlittenen Treffers entwerfen. Derzeit bleibt Standardrot RGB (255,0,0) für alle Gegner bestehen; keine Umsetzung im aktuellen Drohnenschritt.

- **Weitere Paintball-Flecken:** zusätzliche Grafiken bei Gelegenheit; optionaler Alpha-Mini-Schritt ist bereits auf ein Pixel breite Laufnasen ohne Fleckenrotation begrenzt. Aufwendige organische Tropfen sind kein aktueller Auftrag.
- **Drohnen-/Quadrokopter-Art-Pass:** an den Spielstil angleichen, separat vom Funktionsausbau. Fehlende Endgrafik ist kein Entwicklungsblocker; beim Quadrokopter zunächst die Rolle klären.
- **Strukturierte externe Hilfetexte, etwa JSON:** mögliche spätere Ausbaustufe, kein aktueller Architekturauftrag.
- **Öffentliche Hinweise:** englische itch.io-Bereiche `COMING SOON` und `TIPS & TRICKS` bei passendem Deployment-Schritt; Pläne und verfügbare Funktionen unterscheiden.

## Technik und wiederverwendbare Erkenntnisse

- **Sound-Trigger ordnen:** Ereignisse und Sonec-spezifische Aufrufe inventarisieren, Doppeltrigger vermeiden. Konkretes Audio-Kratzen bleibt Qualitätsfrage der Alpha-Roadmap.
- **Aufnahmeverfahren:** lange GifCam-Aufnahmen/RAM-Verhalten bei Bedarf untersuchen; bisherige Ursache nur Hypothese.
- **AGK-Knowledge-Base-Kandidaten:** Gamepad-Initialisierung, Browser-ESC/QUIT, XAMPP-Cache, zeitabhängige Spawns, Sprite-/Zahlenrechnung, Random-Grenzen, verschachtelte Konstanten und Turmprojektion.
- **Soundloops:** Entwicklererfahrung zu MIDI-Ereignissen am Loop-Anfang und einer Pause am Ende; Werkzeuge, Export und Reproduzierbarkeit vor einer allgemeinen Empfehlung prüfen.
- Knowledge-Base-Beiträge separat vereinbaren; Quellen/Revision, Bedingungen und Evidenzgrad erhalten.

## Pflege

- Kurze Einträge, vorhandenen Themen zuordnen; keine Chatprotokolle anhängen.
- Ausgewähltes in die betreffende Roadmap verschieben; erledigte oder verworfene Ideen entfernen, Dubletten zusammenfassen.
- Konkrete Fehler und zugesagte Releasearbeit nicht als unverbindliche Ideen wegparken.
- Crystals/Crystal Columns hat eine [eigene TODO](https://github.com/ChristianEngel19820128/Crystals/blob/main/TODO.md).

Historische Ausgangsstände bleiben im [Archiv](docs/archive/README.md); kein Pflichtlesestoff beim Chatstart.

