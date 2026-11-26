# SonecBot – Offene Fehler und Fehlerverdachte

Stand: 26.11.2026 · develop. Regeln: [AGENTS.md](AGENTS.md).
Vor automatisierten Prüfungen auf Dubletten prüfen. Keine automatische Codefreigabe. Behobene oder widerlegte Einträge nach Nachweis entfernen; Historie in Git. IDs erst nach geprüfter Zuordnung vergeben.

## Gelegentlich fehlende Direkttreffer
- ID: Noch nicht vergeben · Priorität: Offen · Status: Vermutet.
- Beobachtung: gelegentlich fehlende Granatwerfer/Flarak/Flak-Direkttreffer. Granaten-Basissweep sowie Flak-/Flarak-Kontakt-Explosionsposition und Flak-Zünder abgenommen; übrige Befunde noch offen. Soll: gültige Direkttreffer zuverlässig erkennen; Explosionstreffer getrennt bewerten.
- B3.1 Granaten-Kollision im geprüften Umfang behoben und abgenommen (14/14, 7831960 mit Compile-Korrektur 7c3d73a); Nachweis in TECHNICAL.md. Relative Bewegung im vereinbarten Umfang B3.3 abgenommen, Flugphysik B3.4 offen.
- B3.2 Flak-/Flarak-Kontakt-Explosionsposition und Flak-Zeitzünder im geprüften Umfang behoben und lokal abgenommen (11/11, 4a954f8); Nachweis in TECHNICAL.md. Weltgrenzenlöschung und relative Bewegung im vereinbarten Umfang B3.3 abgenommen.
- B3.3a Relative Sweeps gegen Sonec für Gegnerbullets, Drohnenlaser und Flarak-Raketen im geprüften Umfang behoben und lokal abgenommen (14/14, 0c0a111, 26.11.2026); Nachweis in TECHNICAL.md. Bewegungsregression und subjektiver Performance-Check bestanden. Explosionsschadensprüfung weiterhin an aktueller Pose; Bomberbomben in B3.3b, Abfangziele/Weltgrenzen in B3.3c abgenommen.
- B3.3b gemeinsame früheste Bombenkollision mit Sonec, bewegten Kisten und Plattformen lokal abgenommen (15/15, bf39985, 26.11.2026). B3.3c relative Abfangkollisionen und nachgelagerte Weltgrenzenlöschung lokal abgenommen (15/15, 66ddfe5, 26.11.2026). B3.3 im vereinbarten Umfang abgeschlossen, Nachweise und Grenzen in TECHNICAL.md; B3.4 bleibt offen.
- B3.4: zeitabhängige ballistische Physik in physics.agc implementiert; lokale AGK-Abnahme offen. GrenadeMove nutzt konstante Gravitation und analytische Integration statt Quadrieren je Update; optionaler linearer Luftwiderstand im allgemeinen Integrator, für Granatwerfer deaktiviert. Horizontaler Abschuss 3 px/ms, 675 px Referenzreichweite ab Mündung auf ebener Plattform. Gravitation aus stehender Referenzabschusshöhe minus bestehender vertikaler Granaten-Halbausdehnung berechnet; gleiche Gravitation beim Ducken/im Flug. Vorhandene 10-ms-Gates, lineare Sweeps, Trefferreaktionen, Munition, Rückstoß und Eingabe erhalten. Wurfgranaten und kombinierte Eingabe später separat.
- Reproduktion: betroffene Waffe, Ziel, Flugweg, Trefferart und gegebenenfalls Kontakt-/Explosionsposition erfassen. Bestehende Bullet-Sweeps bleiben in B3.1 unverändert.
- Quelle: TODO vor Konsolidierung, Revision 0ba2ee8c665325f25a9e7da38a86c9ca49cb7e5a.

## Wiederverwendung von Plattform- und Flarak-Listenplätzen
- ID: Noch nicht vergeben · Priorität: Offen · Status: Vermutet (Quellbefund add9fe7).
- `GameDo`: FlarakDoAll vor PlateCheckAll, PlateAdd im nächsten Frame vor FlarakDoAll. Ein deaktivierter Plattformslot kann wiederverwendet werden, bevor die alte Stellung ihre Bindung verliert. Soll: keine Übertragung alter Stellung/Wrack auf neue Plattform. Gezielt Trägerabgang mit unmittelbar folgender Slot-Wiederverwendung prüfen.
- `ExplosionCollideFlaraks`: LastFlarakHitMs pro Listenindex; bei Slot-Recycling während einer laufenden Explosion kann ein alter Cooldown übernommen werden. Soll: neuer Gegner übernimmt keinen alten Trefferzeitpunkt. Prüfen, ob zeitliche und räumliche Überlappung tatsächlich erreichbar ist.
- Keine Korrektur dieser Verdachtsfälle in B1.1; keine Indexverschiebung bei Proto-Umstellung. Dubletten: eigener Laufzeit-Lebenszyklus, nicht Neustart.
