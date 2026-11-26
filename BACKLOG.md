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
- **Walker-Erweiterungen:** zusätzliche direkte Körperteil-Trefferzonen am 26.11.2026 als höher priorisierte Real-Alpha-Aufgabe in REAL_ALPHA_ROADMAP.md übernommen; konkrete Schadenswirkung dort abstimmen. Stationäre Variante im Fallenkonzept bleibt unverbindliche Idee.
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
- **Umfangreichere Missionen, Informationsavatar oder Sprache:** über die kleinen Alpha-Ziele und vorhandenen Warn-/Hilfetexte hinausgehender Ausbau. Polishing-Idee 26.11.: gezielte englische Sprachmeldungen zu Spielereignissen, z. B. „Touchdown imminent“ (Formulierungsvorschlag für bevorstehende Landung); Entwickler möchte die englischen Ansagen selbst einsprechen und nachbearbeiten, keine KI-Stimme. Auswahl, Trigger, Audio und Prioritäten später konkretisieren.
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

- **Menü-Paintball als freiwillige Entspannungs-/Abwechslungsaufgabe (26.11.2026):** Entwickler beobachtet sich regelmäßig wiederholende Fleckenfarbtypen; vielfältigere Farbrandomisierung, ausdrücklich auch Schwarz möglich. Erster freigegebener Minischritt (26.11.2026): Kugelgröße 6–20 statt 12–18, native 20×20-Grafik mit absoluter SetSpriteScaleByOffset-Skalierung und anschließendem Mittelpunkt; gemeinsames Sprite, Positions- und Trefferlogik unverändert. Entwickler bestätigt kleinere Kugeln als Herausforderung und zeigt erfolgreichen lokalen Menü-Sichttest (26.11.2026); eigene Grafikverbesserung auf Stand fbacf33 eingecheckt. Anschließend Mindestgröße auf 5 reduziert und Kreis-Trefferradius ohne bisherige 2px-Toleranz umgesetzt; Entwickler bestätigt im lokalen Kurztest Treffer auch kleiner Kugeln (26.11.2026). Kugelfarben mit gleichfarbigem Trefferfleck und Laufnasen implementiert: RGB-Zufall beim Spawn, je 5 % explizit Schwarz/Weiß, Farbe pro Kugel gespeichert; lokaler Farbtest bestanden (Entwickler bestätigt passende Flecken und Laufnasen, zufällige Sichtbarkeit als erwünschte Schwierigkeit). Fleckengröße jetzt Kugeldurchmesser ×4 (20–80), 500 Flecken als Datenarray, vier gemeinsame Sprites einschließlich Kugel, UV- und Laufnasenoptik beibehalten; lokaler Sichttest erfolgreich, große Flecken jedoch kantig. Entwickler liefert 900×900-Atlas mit 100 belegten 90×90-Zellen (teils dupliziert); UV-Raster und Frameanzahl aus Bildmaßen, Fleckengröße ×4,5 (22,5–90), Tropfen-UV angepasst. Lokaler Atlas-Sichttest erfolgreich; Tropfenenden kaum sichtbar. Tropfenenden verwenden jetzt die runde Energiegrafik mit pro Laufnase gespeicherter Zufallsbreite 2–4 und Höhe 2–5 virtuelle Pixel; Farbe und Wachstum unverändert, Lokaler Tropfen-Sichttest erfolgreich; Breite anschließend auf 2–3 reduziert, Höhe unverändert, erneuter Kurztest offen. Virtuelle Menüauflösung bewusst als separates späteres Thema zurückgestellt. Cursor und weitere Spawnvariation getrennt. Optional eigene Graffiti im Titel-Hintergrundbild durch Entwickler. Bestehende abgenommene UV-Ausrichtung und ein Pixel breite Laufnasen erhalten; Farbalgorithmus und Größen separat abstimmen. Zusätzliche Fleckengrafiken bei Gelegenheit, kein Releaseblocker.
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

## Bewegungs-Ergänzungen (26. November 2026)

- **Normale horizontale Sprungkorrektur leicht erhöhen:** Entwickler wünscht etwas mehr Einfluss im regulären Sprung; bestehende schwache Korrektur (0.001 Beschleunigung, 1.5 Richtungsgrenze laut docs/SONEC_MOVEMENT_SPEC.md) als Referenz, konkrete Parameter noch offen. Keine Änderung an Jetpack, vertikalem Sprungimpuls oder Trägermomentum ohne Entscheidung.
- **Allgemeines Treppensystem:** vorhandene Sockel-/Stufenmechanik so auslagern und parametrisieren, dass Höhen übergeben werden können und z. B. kleinste Vordergrundkisten als Stufe nutzbar sind. Bestehende Kollisions-/Mini-Hop-Regeln erhalten; zulässige Höhen und Geometrie separat abstimmen.
- **Absichtliches Fallenlassen auf tiefere Ebene:** mögliche Eingabekombination Ducken + Rückwärtsbewegung (im Ducken kein aktives Laufen). Gezielte Freigabe nur der verlassenen Oberfläche, tiefere gültige Landung und Vermeidung versehentlicher Auslösung vor Umsetzung entwerfen. Separat vom unerwarteten Durchfall-Bug in KNOWNBUGS.md.

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


- **Experimentelle Menü-Musik (26.11.2026):** Entwickler eigener WAV-Loop `media/mfx/mystery_loop_2026-11-11.wav`, testweise als wiederholter Sound mit Lautstärke 35 im Menü inklusive Optionen; Stopp beim Spielstart/Programmende, Neustart bei Rückkehr. HTML5-Start nach Eingabe vorgesehen; lokaler Audio-/Plattformtest offen. Keine neuen Audiooptionen.

- **Menü-Fadenkreuz:** `media/gfx/gui/cross.png` (18×18), gemeinsames Software-Sprite am Pointer-Mittelpunkt, zuletzt gezeichnet; Systemcursor innerhalb der Menüfläche ausgeblendet, bei Spielstart/Ende wieder sichtbar. Trefferfarbe mit RGB-Untergrenze 80 für Sichtbarkeit; lokaler Desktop-/HTML5-Test offen. Musik unverändert.
