# SonecBot – Offene Fehler und Fehlerverdachte

Stand: 26.11.2026 · develop. Regeln: [AGENTS.md](AGENTS.md).
Vor automatisierten Prüfungen auf Dubletten prüfen. Keine automatische Codefreigabe. Behobene oder widerlegte Einträge nach Nachweis entfernen; Historie in Git. IDs erst nach geprüfter Zuordnung vergeben.

## Unerwarteter Durchfall durch tiefer liegende Plattform
- ID: Noch nicht vergeben · Priorität: Hoch (Vorschlag, Todesfolge) · Status: Bestätigt als Entwicklerbeobachtung, Ursache offen. Test 8d3c8a1 am 26.11.2026.
- Ist: Sonec fällt durch eine tiefer liegende Plattform, die nach Erwartung betretbar sein sollte; Entwickler berichtet Tod als Folge. Exakte Anordnung, Flugrichtung davor, Plattformbewegung und Tiefenzustand nicht protokolliert.
- Soll: Eine von oben gültig erreichbare tiefere Plattform soll eine Landung ermöglichen; die bewusste Durchflugfreigabe von unten und bestehende Trägerbindung müssen dabei erhalten bleiben. Kein pauschales Solidsetzen aller Plattformen. Absichtliches Fallenlassen ist eine separate Feature-Idee im BACKLOG.
- Quellbefund: sonec.agc SonecDepthRefresh setzt/behält SONEC_DEPTH_PASSAGE abhängig von Fußhöhe, horizontaler Überdeckung und lokaler höchster Oberkante. SonecFindContact schließt PASSAGE und den Träger von PassThroughChestIndex als Plattform-Landekandidaten aus; SonecChestRelevant und SonecDepthClearTime ebenfalls prüfen. Möglicher zu lange gültiger Passagezustand oder nicht passende Freigabehöhe; konkrete Ursache nicht nachgewiesen. Waffenfreigabe übernimmt diese mechanischen Zustände nur, kein Beleg, dass die neue weaponcollision.agc den Durchfall verursacht hat.
- Prüfung: gezielt von höherer Plattform auf tiefere wechseln bzw. fallen, mit/ohne Kisten/Sockel, horizontaler/vertikaler Trägerbewegung, vorherigem Durchflug, bestehender und gelöster Trägerbindung. Relative Fußhöhe, Passagezustand, Freigabezeit und ausgewählten Landekandidaten im bestehenden Trace erfassen. Kleinsten notwendigen Eingriff in die Tiefen-/Landefreigabe erst nach Ursachenanalyse abstimmen; akzeptierte Bewegungsphysik und Waffen-Snapshots schützen.
- Dubletten: neuer konkreter Randfall zur abgenommenen Bewegungsumstellung, nicht Wiederöffnung aller Bewegungs- oder Waffenpakete. Waffen-Tiefenfreigabe lokal 18/18 abgenommen (8d3c8a1), Nachweis in TECHNICAL.md.

## Wiederverwendung von Plattform- und Flarak-Listenplätzen
- ID: Noch nicht vergeben · Priorität: Offen · Status: Vermutet (Quellbefund add9fe7).
- `GameDo`: FlarakDoAll vor PlateCheckAll, PlateAdd im nächsten Frame vor FlarakDoAll. Ein deaktivierter Plattformslot kann wiederverwendet werden, bevor die alte Stellung ihre Bindung verliert. Soll: keine Übertragung alter Stellung/Wrack auf neue Plattform. Gezielt Trägerabgang mit unmittelbar folgender Slot-Wiederverwendung prüfen.
- `ExplosionCollideFlaraks`: LastFlarakHitMs pro Listenindex; bei Slot-Recycling während einer laufenden Explosion kann ein alter Cooldown übernommen werden. Soll: neuer Gegner übernimmt keinen alten Trefferzeitpunkt. Prüfen, ob zeitliche und räumliche Überlappung tatsächlich erreichbar ist.
- Keine Korrektur dieser Verdachtsfälle in B1.1; keine Indexverschiebung bei Proto-Umstellung. Dubletten: eigener Laufzeit-Lebenszyklus, nicht Neustart.
