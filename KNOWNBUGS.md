# SonecBot – Offene Fehler und Fehlerverdachte

Stand: 25.11.2026 · develop. Regeln: [AGENTS.md](AGENTS.md).
Vor automatisierten Prüfungen auf Dubletten prüfen. Keine automatische Codefreigabe. Behobene oder widerlegte Einträge nach Nachweis entfernen; Historie in Git. IDs erst nach geprüfter Zuordnung vergeben.

## Gelegentlich fehlende Direkttreffer
- ID: Noch nicht vergeben · Priorität: Offen · Status: Vermutet.
- Beobachtung: gelegentlich fehlende Granatwerfer/Flarak/Flak-Direkttreffer. Granaten-Basissweep sowie Flak-/Flarak-Kontakt-Explosionsposition und Flak-Zünder abgenommen; übrige Befunde noch offen. Soll: gültige Direkttreffer zuverlässig erkennen; Explosionstreffer getrennt bewerten.
- B3.1 Granaten-Kollision im geprüften Umfang behoben und abgenommen (14/14, 7831960 mit Compile-Korrektur 7c3d73a); Nachweis in TECHNICAL.md. Relative Bewegung der Kollisionspartner bleibt B3.3, Flugphysik B3.4.
- B3.2 Flak-/Flarak-Kontakt-Explosionsposition und Flak-Zeitzünder im geprüften Umfang behoben und lokal abgenommen (11/11, 4a954f8); Nachweis in TECHNICAL.md. Noch offene Randfälle: Weltgrenzenlöschung vor Trefferprüfung bei Bullets/Raketen, relative Bewegung und Update-Reihenfolge separat B3.3 prüfen; keine Laufzeitfehler hierfür bestätigt.
- Weitere konkrete Quellbefunde (getrennt prüfen): B3.3 Laser und Bomberbomben: Sonec-Abfrage vor endgültiger Kontaktauflösung, getrennte Bombenzielprüfungen, bewegte Abfangziele bisher nur aktuelle Pose; tatsächliche Laufzeitwirkung offen. B3.4 GrenadeMove quadriert vertikale Beschleunigung je Update, Flugbahn zeitabhängig von Updatezahl; ballistische Flugphysik und spätere Wurfgranaten separat abstimmen (physics.agc), Reichweite nicht ungefragt verändern.
- Reproduktion: betroffene Waffe, Ziel, Flugweg, Trefferart und gegebenenfalls Kontakt-/Explosionsposition erfassen. Bestehende Bullet-Sweeps bleiben in B3.1 unverändert.
- Quelle: TODO vor Konsolidierung, Revision 0ba2ee8c665325f25a9e7da38a86c9ca49cb7e5a.

## Wiederverwendung von Plattform- und Flarak-Listenplätzen
- ID: Noch nicht vergeben · Priorität: Offen · Status: Vermutet (Quellbefund add9fe7).
- `GameDo`: FlarakDoAll vor PlateCheckAll, PlateAdd im nächsten Frame vor FlarakDoAll. Ein deaktivierter Plattformslot kann wiederverwendet werden, bevor die alte Stellung ihre Bindung verliert. Soll: keine Übertragung alter Stellung/Wrack auf neue Plattform. Gezielt Trägerabgang mit unmittelbar folgender Slot-Wiederverwendung prüfen.
- `ExplosionCollideFlaraks`: LastFlarakHitMs pro Listenindex; bei Slot-Recycling während einer laufenden Explosion kann ein alter Cooldown übernommen werden. Soll: neuer Gegner übernimmt keinen alten Trefferzeitpunkt. Prüfen, ob zeitliche und räumliche Überlappung tatsächlich erreichbar ist.
- Keine Korrektur dieser Verdachtsfälle in B1.1; keine Indexverschiebung bei Proto-Umstellung. Dubletten: eigener Laufzeit-Lebenszyklus, nicht Neustart.
