# SonecBot – Offene Fehler und Fehlerverdachte

Stand: 26.11.2026 · develop. Regeln: [AGENTS.md](AGENTS.md).
Vor automatisierten Prüfungen auf Dubletten prüfen. Keine automatische Codefreigabe. Behobene oder widerlegte Einträge nach Nachweis entfernen; Historie in Git. IDs erst nach geprüfter Zuordnung vergeben.

## Wiederverwendung von Plattform- und Flarak-Listenplätzen
- ID: Noch nicht vergeben · Priorität: Offen · Status: Vermutet (Quellbefund add9fe7).
- `GameDo`: FlarakDoAll vor PlateCheckAll, PlateAdd im nächsten Frame vor FlarakDoAll. Ein deaktivierter Plattformslot kann wiederverwendet werden, bevor die alte Stellung ihre Bindung verliert. Soll: keine Übertragung alter Stellung/Wrack auf neue Plattform. Gezielt Trägerabgang mit unmittelbar folgender Slot-Wiederverwendung prüfen.
- `ExplosionCollideFlaraks`: LastFlarakHitMs pro Listenindex; bei Slot-Recycling während einer laufenden Explosion kann ein alter Cooldown übernommen werden. Soll: neuer Gegner übernimmt keinen alten Trefferzeitpunkt. Prüfen, ob zeitliche und räumliche Überlappung tatsächlich erreichbar ist.
- Erneute Quellprüfung 5bfba31 am 26.11.2026: GameDo Reihenfolge weiterhin PlateAdd (345), FlarakDoAll (429), PlateCheckAll (444); PlateAdd überschreibt freie Slots, FlarakDoAll (flarak.agc 933 ff.) prüft nur Index/Enabled, nicht Trägeridentität. ExplosionCollideFlaraks (explosion.agc 527 ff.) nutzt weiterhin LastFlarakHitMs[k]. Beide Laufzeitfälle nicht reproduziert, Priorität offen; erster Fall potenziell sichtbarer und spielrelevanter als zeitlich/räumlich bedingter Cooldown. Recycling selbst ist beabsichtigt; nur falsche Zustandsübernahme wäre ein Bug. Keine Korrektur in B1.1 oder späteren abgenommenen Paketen. Als offene Verdachtsfälle in nächsten Chat übernehmen, kein nachgewiesener Releaseblocker; vor Release gezielt bewerten. Dubletten: eigener Laufzeit-Lebenszyklus, nicht Neustart.
