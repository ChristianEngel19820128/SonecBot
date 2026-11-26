# SonecBot – Ideen für vielleicht später

**Stand:** 25. November 2026  
**Status:** Unverbindliche Sammlung; ohne feste Reihenfolge, Termin oder Implementierungsfreigabe.

Die beschlossenen Real-Alpha-Grundversionen stehen in [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md), nächste Schritte in [TODO.md](TODO.md).
Bomber, Flarak, Jumppod einschließlich Landminen-Attrappe, Gefahren-/Erfahrungsgrundsystem, kleine Ziele und die Munitions-/Panzerungsbasis sind dorthin übernommen. Am 25.11.2026 zusätzlich dunkle Hintergrundkisten und Nacharbeit an der Minen-Rudelformation in A6 übernommen, umgesetzt und abgenommen; siehe Roadmap.

## Varianten und Unterstützung




- **Quadrokopter:** eigenständiges, noch offenes Konzept. Möglich sind zeitweilige verbündete Unterstützung, etwa als Belohnung nach zerstörten Flaraks, ein auf Abstand angreifender Verfolger oder Aufklärung. Keine Rolle endgültig gewählt; keine weitere Kamikaze-Kopie der intelligenten Mine als Vorgabe.
- **Flarak-Massenwerfer:** ungenaue Raketensalve ohne Zielsuchraketen als spätere Modifikation.
- **Drohnen-Schildfunktion:** Später ein eigenes Schildkonzept für Drohnen entwerfen (Aktivierung, Schutzwirkung, Trefferfeedback und Gegenmaßnahmen); keine aktuelle Implementierung oder Balancevorgabe.
- **Gameplay-Balancing nach Bewegungsumstellung (25.11.2026):** G2c-Entwicklertest bestanden, aber durch normale Sprünge mehr Energie übrig und häufige Overload-Tode; Gegner insgesamt sehr gefährlich, Drohne vergleichsweise harmlos. Energiefluss, Startwert (derzeit 4500 bei Normalmaximum 4000 als früherer HUD-Testwert), Overload-Schadenspfade, Pickup-Verteilung und Gegnergefährlichkeit gemeinsam im vorgesehenen Balancing-Chat bewerten; keine automatische Änderung von Gegnerverhalten oder Overload-Mechanik. Bewegungsparameter getrennt in G2d.
- **Drohne später gefährlicher gestalten:** Nach lokal 8/8 bestandenem Scan-/Schussfrequenz-Feinschliff (22.11.2026) wirkt das Verhalten deutlich intelligenter; für die Alpha keine weiteren Verhaltensänderungen. Spätere zusätzliche Gefährlichkeit erst separat spielerisch konzipieren, keine aktuelle Balancevorgabe.
- **Drohnen-Dauerlaser:** seltener, zeitlich begrenzter, über den Boden schwenkender Strahl; sichtbares Aufladen vor dem Angriff. Alpha-Basis sind kurze Laserprojektile.
- **Plattform-Flammenfalle / Flammenaustritte (konsolidiert, 25.11.2026):** Stationäre Flammenaustritte auf Plattformen mit berechenbarem Feuerraum; Flammenwerfer müssen nicht exklusiv Sonec gehören. Als mögliche Ausführung den vorhandenen gemeinsamen Sockel von Jumppod, Landmine und Flak/Flarak wiederverwenden (Plattformbindung, Platzierungsreserve, mechanische Basis und Darstellung); separate Flammendüsen-/Aktivierungsmechanik erst entwerfen. Austrittsrichtung, Takt, Schadenszone, Zerstörbarkeit und Balance offen. Keine zweite redundante Flammenfallen-Idee, keine Implementierungs- oder Releasefreigabe.
- **Luftunterstützung als Aufgabe/Belohnung:** Flaraks zerstören, um Unterstützung zu ermöglichen; mögliche Hilfe gegen ein oder zwei Bomber. Konkrete Aufgabe und Unterstützungsfunktion offen, kein Pflichtumfang der ersten kleinen Ziele.
- **Walker-Erweiterungen:** zusätzliche Trefferzonen/Beinschaden als Beispiel für taktische Wirkung; gegebenenfalls stationäre Variante im Fallenkonzept. Kein neuer Auftrag am abgeschlossenen Alpha-Walker und keine Umdeutung seiner aktuellen Turm-Schadenszone.
- **Weitere Bots/Bosse:** nur bei eigener spielerischer Rolle konkretisieren; keine Mindestzahl an Varianten.

## Fortschritt, Wertung und Bedienung



- **Hauptmenü-Minispiel: unsichtbarer Countdown und Punkte:** Nur während der Spieler aktiv im Hauptmenü spielt, intern Zeit und Punkte erfassen; genaue Spielregeln, Anzeige und Start-/Endbedingungen noch offen. Menüarbeiten als gelegentliche Abwechslung, nicht als aktueller Schwerpunkt.
- **Menü-Highscore und optionaler Online-Score:** Punktestand im Menü anzeigen; Highscore-Eintrag ausschließlich, wenn der Spieler beim aktiven Menüspiel den bisherigen Rekord übertrifft. Online-Rangliste später separat hinsichtlich Speicherung und Datenschutz entscheiden.
- **Initialien-Eingabe:** Virtuelle Tastatur oder vergleichbare Eingabe für neue Highscores; Initialien optional auch im Spiel oder Menü wiederverwenden. Eingabemethode und Gültigkeitsregeln später festlegen.


- **Punkte und Online-Ranglisten:** später getrennt vom Erfahrungswert entwickeln; Erfahrung steuert Gefahr, die Wertung ist noch nicht festgelegt. Mögliche Anknüpfung an Crystals.
- **Schwierigkeitsauswahl:** im Zusammenhang mit späteren Punkten/Ranglisten prüfen. Getrennte Tabellen je Schwierigkeit und eine gemeinsame Alpha-Ausgangseinstellung sind Vorschläge aus der Besprechung, noch keine endgültigen Regeln.
- **Umfassende Rüstungs-/Schadensmatrix:** einfache testbare Basis gehört zur Alpha; weitere Gegenwerte, Typen und Feinausgleich später, besonders vor 1.0. Fraktionen Player/Enemy/Neutral getrennt von Schadensarten behandeln.
- **Zusätzliche Upgrades, Ressourcenanzeigen und Achievements:** bei erkennbarem spielerischem Nutzen konkretisieren.
- **Gamepad-Rebinding, Maus und weitere Bedienoptionen:** später; Entwickler ist mit der vorhandenen Gamepad-Steuerung zufrieden. Keyboard-Umbelegung, Speicherung und Reset sind umgesetzt.
- **Spieloptionen zurücksetzen:** Umfang getrennt vom fertigen Keyboard-Reset klären.
- **Energieanziehung als Halten/Umschalten:** mögliche spätere Einstellung; heutiges Verhalten nicht automatisch ändern.
- **Umfangreichere Missionen, Informationsavatar oder Sprache:** über die kleinen Alpha-Ziele und vorhandenen Warn-/Hilfetexte hinausgehender Ausbau.
- **Optionale Draufsicht und Multiplayer:** langfristig, ohne zugesagten Release.

## Belohnungs-Balancing: Grenzfälle und Ersatznutzen

- **Keine nutzlosen Pickups (Vorschlag, noch nicht implementiert):** Wenn ein Upgrade oder eine Ressource am Limit ist, soll der Pickup einen sinnvollen Ersatznutzen geben, mindestens eine Energie-Gutschrift. Beispiele: volle Gesundheit -> Energie; Burst am Maximum -> zunächst bestehender Feuerraten-Fallback, danach Energie, sobald auch beide Feuerraten-Limits erreicht sind; volle Munition oder maximale Regeneration -> Energie. Bei voller Energie gesondert festlegen, wie Überlauf und bestehender Energie-Überladungsschaden behandelt werden, damit der Ersatznutzen nicht unbeabsichtigt schadet.
- **Quellbefund 21.11.2026:** `energie.agc`/`EnergieCollect` Fälle 1–7 enthalten derzeit teils stille Grenzfälle: maximale Regeneration, volle Gesundheit, maximale Feuerraten/Burst, volle MG-/Granatenmunition. Die Nachrichten sind nicht in allen Fällen zentralisiert. Im Balancing alle acht Pickup-Typen, Grenzwerte, Fallback-Reihenfolge und Meldungen als Matrix definieren und gemeinsam testen; bis dahin keine Codeänderung.

- **Upgrade-Wege getrennt halten (Balancing-Vorschlag 21.11.):** Burst-Pickup verbessert zuerst die Burst-Anzahl bis zum Limit, danach ausschließlich die Burst-Feuerrate bis zu deren Limit, erst danach Ersatzenergie. Feuerraten-Pickup verbessert ausschließlich die allgemeine Feuerrate, danach Ersatzenergie. Bisherige gekoppelte Steigerungen in `EnergieCollect` (Fälle 4/5) bei späterer Umsetzung bewusst trennen; dazu passende, effektbezogene Meldungen vorsehen. Weitere Pickup-Typen sind geplant: die Fallback-Matrix erweiterbar halten, nicht vorschnell alle künftigen Typen festlegen.
- **Overload-Schutz bei Ersatzenergie:** Keine zusätzliche oder beschleunigte Gesundheitsschädigung durch Fallback-Gutschriften. Der aktuelle Typ-0-Code prüft `Energy.State > 1.5 * Energy.StateMax`, zieht Gesundheit ab und setzt den Energiewert zurück; das ist eine Schwelle mit Rücksetzung, nicht der Nachweis eines unbegrenzten Overload-Speichers. Bestehende Overload-Mechanik und etwaige weitere Schadenspfade beim Balancing vollständig prüfen. Sicherer Ersatznutzen bei voller Energie ist noch offen; keine unbeabsichtigte Todesfalle und keine Erhöhung der bisherigen Schadensrate/-höhe.

## Grafik und Präsentation

- **Fadenkreuz im Hauptmenü:** Statt des System-Mauszeigers ein eigenes Fadenkreuz anzeigen; vorhandenes Paintball-Easter-Egg bei der Gestaltung berücksichtigen. Nur Idee, noch keine Implementierung.
- **Halbtransparente Einschusslöcher:** Bei Treffern auf den Hintergrund dezente Spuren zeigen; später Sichtbarkeit, Lebensdauer und Begrenzung der Anzahl festlegen. Nur Idee, noch keine Implementierung.


- **Trefferfarben nach Schadenshöhe:** Optional später ein einheitliches Farbspektrum für die Höhe eines erlittenen Treffers entwerfen. Derzeit bleibt Standardrot RGB (255,0,0) für alle Gegner bestehen; keine Umsetzung im aktuellen Drohnenschritt.

- **Weitere Paintball-Flecken:** zusätzliche Grafiken bei Gelegenheit; optionaler Alpha-Mini-Schritt ist bereits auf ein Pixel breite Laufnasen ohne Fleckenrotation begrenzt. Aufwendige organische Tropfen sind kein aktueller Auftrag.
- **Drohnen-/Quadrokopter-Art-Pass:** an den Spielstil angleichen, separat vom Funktionsausbau. Fehlende Endgrafik ist kein Entwicklungsblocker; beim Quadrokopter zunächst die Rolle klären.
- **Strukturierte externe Hilfetexte, etwa JSON:** mögliche spätere Ausbaustufe, kein aktueller Architekturauftrag.
- **Öffentliche Hinweise:** englische itch.io-Bereiche `COMING SOON` und `TIPS & TRICKS` bei passendem Deployment-Schritt; Pläne und verfügbare Funktionen unterscheiden.

## Technik und wiederverwendbare Erkenntnisse

- **Gemeinsame streckenabhängige Jetstream-Erzeugung (Idee, 25.11.2026):** Bei Bedarf die separaten Emissionspfade von Sonec, Drohne, Bomber und Flarak-Rakete über eine wiederverwendbare visuelle Funktion zusammenführen. Individuelle Düsenpositionen, Partikelabstände/-grenzen, Größe, Ausrichtung, Takt und je Düse eigener Verlauf bleiben einstellbar; Sonecs Energieverbrauch und Gegnerverhalten unverändert. Sonec-Verdichtung `4cba3e3` 7/7 bestanden, Bomber besitzt bereits eigene Streckeninterpolation. Kein aktueller Fehlernachweis bei Gegner-Jets, keine Releasezusage oder Codefreigabe.

- **Sound-Trigger ordnen:** Ereignisse und Sonec-spezifische Aufrufe inventarisieren, Doppeltrigger vermeiden. Konkretes Audio-Kratzen bleibt Qualitätsfrage der Alpha-Roadmap.
- **Aufnahmeverfahren:** lange GifCam-Aufnahmen/RAM-Verhalten bei Bedarf untersuchen; bisherige Ursache nur Hypothese.
- **AGK-Knowledge-Base-Kandidaten:** Gamepad-Initialisierung, Browser-ESC/QUIT, XAMPP-Cache, zeitabhängige Spawns, Sprite-/Zahlenrechnung, Random-Grenzen, verschachtelte Konstanten und Turmprojektion.
- **Soundloops:** Entwicklererfahrung zu MIDI-Ereignissen am Loop-Anfang und einer Pause am Ende; Werkzeuge, Export und Reproduzierbarkeit vor einer allgemeinen Empfehlung prüfen.
- Knowledge-Base-Beiträge separat vereinbaren; Quellen/Revision, Bedingungen und Evidenzgrad erhalten.


- **Jumppod-Sprungstärke (Balancing):** J1-Entwickler empfindet den Pod möglicherweise als zu stark; Ursache kann auch der normale Sprung sein. Beide getrennt im Spieltest bewerten. Aktuell Faktor 2.0; keine bestätigte Änderung.

## Spätere Eingabe- und Waffensteuerung (24. November 2026)

- **Schadenswirksame Aufladeanimationen (25.11.2026):** Bereits während der sichtbaren Aufladung des Drohnenlasers und des Plasmablitzes soll eine Berührung der jeweiligen Aufladezone Schaden an gültigen Zielen verursachen können. Kontakt/Schaden unterbrechen weder die Aufladeanimation noch den regulären anschließenden Angriffs-/Schussprozess. Treffergeometrie, Fraktions-/Zielregeln, Schaden, Trefferintervall und Schild-/Panzerungswirkung später separat festlegen; gegen Sonec bestehende zentrale Zwei-Kreis-Treffergeometrie verwenden. Keine Änderung am bisherigen Angriff allein aufgrund dieses Backlog-Eintrags.

- **Granatwerfer/Wurfgranaten – spätere kombinierte Eingabe:** kurz drücken = Granatwerfer, halten und loslassen = ballistischer Wurf mit haltedauerabhängiger Wurfweite. Design in PROJECT.md festgehalten; B3.4 bereitet die gemeinsame Physik vor. Halteschwelle, Ladegrenzen, Rückstoß und Munition vor Eingabeimplementierung abstimmen; noch nicht implementiert.

## HUD, Warnungen und Trefferpartikel (24. November 2026)

- **HUD kompakter gestalten:** Balken und prozentuale Anzeigen mit angepassten Prozentwerten/Größen verkleinern; gesamte HUD-Höhe reduzieren. Kleine, vertikal unter den Balken ausgerichtete Beschriftungen pro Anzeige ergänzen. Bestehende HUD-Transparenz auch auf Texte anwenden. Lesbarkeit und konkrete Maße vor Umsetzung abstimmen.
- **Punktzahl und Spielzeit:** Im HUD beziehungsweise Bildschirmaufbau geeignete, dauerhaft reservierte Bereiche für Punktzahl und Spielzeit vorsehen; genaue Position ist ausdrücklich noch zu bewerten.
- **Warnungsanzeige:** Neue Warnungen verdrängen bisherige Warnungen zu schnell; Anzeigepriorität, Mindestlesedauer und gegebenenfalls Warteschlange vor Umsetzung klären.
- **ShipHit-Explosionspartikel:** Partikeleffekt nachbearbeiten und grün einfärben; optional einzelne Partikel vergrößern. Größen und Optik später im Spiel prüfen.

## Pflege

- Kurze Einträge, vorhandenen Themen zuordnen; keine Chatprotokolle anhängen.
- Ausgewähltes in die betreffende Roadmap verschieben; erledigte oder verworfene Ideen entfernen, Dubletten zusammenfassen.
- Konkrete Fehler und zugesagte Releasearbeit nicht als unverbindliche Ideen wegparken.
- Crystals/Crystal Columns hat eine [eigene TODO](https://github.com/ChristianEngel19820128/Crystals/blob/main/TODO.md).

Historische Ausgangsstände bleiben im [Archiv](docs/archive/README.md); kein Pflichtlesestoff beim Chatstart.

