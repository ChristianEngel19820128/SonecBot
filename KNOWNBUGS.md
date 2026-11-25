# SonecBot – Offene Fehler und Fehlerverdachte

Stand: 25.11.2026 · develop. Regeln: [AGENTS.md](AGENTS.md).
Vor automatisierten Prüfungen auf Dubletten prüfen. Keine automatische Codefreigabe. Behobene oder widerlegte Einträge nach Nachweis entfernen; Historie in Git. IDs erst nach geprüfter Zuordnung vergeben.

## Gelegentlich fehlende Direkttreffer
- ID: Noch nicht vergeben · Priorität: Offen · Status: Vermutet.
- Beobachtung: gelegentlich fehlende Granatwerfer/Flarak/Flak-Direkttreffer. Soll: gültige Direkttreffer zuverlässig erkennen; Explosionstreffer getrennt bewerten.
- Reproduktion: betroffene Waffe, Ziel, Flugweg und Trefferart erfassen; Dateien/Ursache/Korrektur offen.
- Quelle: TODO vor Konsolidierung, Revision 0ba2ee8c665325f25a9e7da38a86c9ca49cb7e5a.

## Flammenwerfer: falsche Bewegungsübernahme
- ID: Noch nicht vergeben · Priorität: Offen · Status: B2.1 Korrektur implementiert, lokaler AGK-Test offen; ursprüngliche Laufzeitursache noch nicht isoliert.
- J4-Test am 25.11.2026 nach Compile-Korrektur e17440a (Testformular d35a6e8): Flammen bewegen sich laut Entwickler nicht mehr korrekt nach rechts, horizontale Bewegung wirkt zu stark; bei Sonecs Auf-/Abbewegung fliegen Partikel sehr weit nach oben/unten statt der erwarteten Mitbewegung.
- Quellbefund e17440a: `FlameNew` addiert `ObjectData.AutoSpeed.x/y` unmittelbar zur eigenen Schussgeschwindigkeit. `SonecCarrierVelocity` berechnet AutoSpeed seit der Bewegungsumstellung als Träger-Schrittwert (Plattengeschwindigkeit mal CalcRange). `FlameMove` multipliziert die so gebildete Geschwindigkeit erneut mit seinem CalcRange. Das spricht für eine Einheiten-/Referenzrahmen-Verwechslung, besonders auf bewegten Plattformen; außerdem wird Sonecs eigene MoveSpeed in FlameNew nicht übernommen. Der genaue erwartete Anteil eigener Bewegung und die Ursache im freien Flug sind noch zu klären.
- `flame.agc`, `sonec.agc`, `timer.agc` und `sprite.agc` sind gegenüber dem Stand vor J4 (ebd0d8e) unverändert; daher kein belegter direkter J4-Codefehler. Zeitpunkt des erstmaligen Auftretens offen.
- Ergänzung Entwickler am 25.11.2026 (nach Feinjustierung ba4be02): Flammenwerfer insgesamt nicht wirklich funktionsfähig; vollständige Prüfung in separatem Bug-Chat vereinbart. Keine weitere Ursachenfeststellung und keine Codekorrektur in A5.
- B2.1 Entwicklervorgabe: zusammenhängender Flammenstrahl, beim Abschuss einmalige Übernahme der Sonec-Weltgeschwindigkeit, danach freier Flug mit Luftwiderstand; leichte Krümmung relativ zur Mündung bei Aufstieg/Fall erwünscht, keine Schwerkraft.
- Umsetzung: SonecFlameGunInput normiert MoveSpeed plus AutoSpeed nur bei Bodenkontakt durch den letzten Sonec-MoveTimer.CalcRange (Fallback Range); identische Zeitbasis beider MoveTimer (10 ms / Range 10). FlameNew addiert den normierten Wert zur unveränderten Schussgeschwindigkeit 1. FlameMove skaliert die bestehende achsenweise Bremsung 0.01 pro Referenzschritt mit 60 Hz und integriert bis zum Stillstand ohne Überschwingen. Keine Änderungen an Sonec-Resolver, Feuerrate, Lebensdauer, Grafik, Energie, Schaden oder Kollisionsregeln. 
- Prüfung separat: Schuss nach links/rechts im Stand, auf horizontal/vertikal bewegter Plattform, bei freiem Aufstieg/Fall und horizontaler Eigenbewegung; Strahlzusammenhang, unabhängiger Flug älterer Partikel, erwartete leichte Krümmung, keine falsche Richtungsumkehr. Bewegungsmodell nutzt den letzten Timerschritt (keine neue globale Zeitphysik); Sichtprüfung und ggf. Feinjustierung erforderlich. Nicht mit den bekannten Kollision-/Deckungsfragen verwechseln.

## Flammenwerfer: Kollision und Deckung
- ID: Noch nicht vergeben · Priorität: Offen · Status: Vermutet.
- Beobachtung: Flammenkollision bei Flak/Flarak im Silomodus ohne Wirkung. Siloschutz ist beabsichtigt; Löschung und Kistendeckung sind noch abzustimmende Designfragen, keine bestätigten Fehler.
- Prüfung: Silozustand, Übergangsframes und andere Kollisionsziele getrennt prüfen; `FlameCollideFlaraks`, `FlarakAreaHits`, `FlameCollideChest`. Ursache und Korrektur offen.
- Quelle: TODO und Bewegungsspezifikation vor Konsolidierung, Revision 0ba2ee8c665325f25a9e7da38a86c9ca49cb7e5a.

## Wiederverwendung von Plattform- und Flarak-Listenplätzen
- ID: Noch nicht vergeben · Priorität: Offen · Status: Vermutet (Quellbefund add9fe7).
- `GameDo`: FlarakDoAll vor PlateCheckAll, PlateAdd im nächsten Frame vor FlarakDoAll. Ein deaktivierter Plattformslot kann wiederverwendet werden, bevor die alte Stellung ihre Bindung verliert. Soll: keine Übertragung alter Stellung/Wrack auf neue Plattform. Gezielt Trägerabgang mit unmittelbar folgender Slot-Wiederverwendung prüfen.
- `ExplosionCollideFlaraks`: LastFlarakHitMs pro Listenindex; bei Slot-Recycling während einer laufenden Explosion kann ein alter Cooldown übernommen werden. Soll: neuer Gegner übernimmt keinen alten Trefferzeitpunkt. Prüfen, ob zeitliche und räumliche Überlappung tatsächlich erreichbar ist.
- Keine Korrektur dieser Verdachtsfälle in B1.1; keine Indexverschiebung bei Proto-Umstellung. Dubletten: eigener Laufzeit-Lebenszyklus, nicht Neustart.
