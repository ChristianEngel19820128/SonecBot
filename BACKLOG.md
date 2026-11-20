# SonecBot – Ideen für vielleicht später

**Stand:** 20. November 2026  
**Status:** Unverbindliche Sammlung; ohne feste Reihenfolge, Termin oder Implementierungsfreigabe.

Ein Eintrag hier ist keine Zusage für einen Release. Bei bewusster Auswahl wird er in dessen Roadmap übernommen.
Bereits eingeplante Arbeit und konkrete Qualitätsfragen stehen in [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md).
Die nächsten tatsächlich vereinbarten Schritte stehen in [TODO.md](TODO.md).

## Optionale Kandidaten aus der bisherigen Alpha-Planung

Ihre Release-Zuordnung bleibt bei der erneuten Real-Alpha-Besprechung ausdrücklich offen:

- **Bomber:** hoher Überflug und Bombensalven; frühe Grafiken laut Entwickler vorhanden. Warnzeit und Ausweichraum zuerst entwerfen.
- **Flarakstellung:** ausfahrende Stellung mit gelenkten Raketen; frühe Grafiken laut Entwickler vorhanden. Größerer Entwurfs-/Testumfang.
- **Kleines Rundenziel:** Orientierung oder Überlebensziel ohne großes Missionssystem.
- **Phasen/Wellen oder Gefahrenbudget:** Gegnerdichte und Kombinationen gemeinsam steuern; keine bestehende Spawnlogik beiläufig ersetzen.
- **Weitere Walker-Trefferzonen:** von der konkreten offenen Sonec→Walker-Kontaktfrage in der Roadmap unterscheiden; Turm-Fokus und akzeptierte IK bewahren.

## Weitere Spiel- und Präsentationsideen

- **Hauptmenü-Paintball:** echte runde Tropfenenden und organischere Laufnasen; Release-Zuordnung offen. Das Easter Egg selbst ist bereits umgesetzt und getestet gemeldet.
- **Fraktionen/Schadensarten:** Player, Enemy, Neutral; Plasmaexplosion/-flamme, kinetisch und Plasma-Blitz mit passenden Panzerungen. Noch keine Widerstandswerte oder Multiplikatoren.
- **Zusätzliche Upgrades und Ressourcenanzeigen:** nur bei erkennbarem spielerischem Nutzen konkretisieren.
- **Score/Achievements, Online-Hochscores:** mögliche Anknüpfung an Crystals; „Waffenschein für alle“ war ein Scherz, keine feste Anforderung.
- **Optionale Draufsicht und Multiplayer:** langfristige Ideen ohne zugesagten Release.
- **Gamepad-Rebinding, Maus und weitere Bedienoptionen:** bestehende Tastaturbelegung, Speicherung und Keyboard-Reset sind bereits vorhanden.
- **Spieloptionen zurücksetzen:** Umfang und Bestätigungsdialog getrennt vom bereits fertigen Keyboard-Reset klären.
- **Energieanziehung als Halten/Umschalten:** mögliche Einstellung erst bei konkretem Bedarf besprechen; heutiges Verhalten nicht automatisch ändern.
- **Strukturierte externe Hilfetexte, etwa JSON:** mögliche spätere Ausbaustufe, kein aktueller Architekturauftrag.
- **Öffentliche Hinweise:** englische itch.io-Bereiche `COMING SOON` und `TIPS & TRICKS` bei passendem Deployment-Schritt; Pläne und verfügbare Funktionen sauber unterscheiden.

## Technik und wiederverwendbare Erkenntnisse

- **Sound-Trigger ordnen:** Ereignisfunktionen und Sonec-spezifische Aufrufe inventarisieren, Doppeltrigger vermeiden. Konkretes Audio-Kratzen bleibt Qualitätsfrage der Alpha-Roadmap.
- **Aufnahmeverfahren:** lange GifCam-Aufnahmen/RAM-Verhalten bei Bedarf untersuchen; bisherige Ursache nur Hypothese.
- **AGK-Knowledge-Base-Kandidaten:** Gamepad-Initialisierung, Browser-ESC/QUIT, XAMPP-Cache, zeitabhängige Spawns, Sprite-/Zahlenrechnung, Random-Grenzen, verschachtelte Konstanten und Turmprojektion.
- **Soundloops:** Entwicklererfahrung zu MIDI-Ereignissen am Loop-Anfang und einer Pause am Ende; Werkzeuge, Export und Reproduzierbarkeit vor einer allgemeinen Empfehlung prüfen.
- Vor einem Knowledge-Base-Beitrag Quelle/Revision, Bedingungen, Gegenprobe und Evidenzgrad prüfen; Bearbeitung des anderen Repositories gesondert vereinbaren.

## Pflege

- Neue Ideen kurz halten und vorhandenen Themen zuordnen; keine Chatprotokolle oder Umsetzungshistorie anhängen.
- Ausgewählte Punkte in die zuständige Release-Roadmap verschieben; erledigte oder verworfene Ideen aus dieser aktiven Liste entfernen.
- Wenn die Sammlung unübersichtlich wird, gemeinsam zusammenfassen und aussortieren. Nicht automatisch weitere Pflicht-Lesedokumente erzeugen.
- Crystals/Crystal Columns hat eine [eigene TODO](https://github.com/ChristianEngel19820128/Crystals/blob/main/TODO.md); dessen Themen bleiben im eigenen Projekt.

Historischer Ausgangsstand: [TODO-Archiv](docs/archive/TODO_BIS_2026-11-20.md) und [Real-Alpha-Archiv](docs/archive/REAL_ALPHA_ROADMAP_BIS_2026-11-20.md).
