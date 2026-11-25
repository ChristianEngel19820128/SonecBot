# SonecBot – Offene Fehler und Fehlerverdachte

Stand: 25.11.2026 · develop. Regeln: [AGENTS.md](AGENTS.md).
Vor automatisierten Prüfungen auf Dubletten prüfen. Keine automatische Codefreigabe. Behobene oder widerlegte Einträge nach Nachweis entfernen; Historie in Git. IDs erst nach geprüfter Zuordnung vergeben.

## Spielobjekte/Effekte bleiben nach Neustart erhalten (Flarak-Rakete, kleine Explosionen)
- ID: Noch nicht vergeben · Priorität: Offen · Status: Bestätigt.
- Entwicklerbefund: J1-Test am 25.11.2026, Revision bb16236: bisher mysteriöses Sprite als Flarak-Rakete identifiziert; möglicherweise bleiben auch Launcher erhalten. Soll: alle Spielobjektinstanzen beim Neustart entfernen, Prototypressourcen behalten.
- Quellbefund bb16236: `GameCreate` ruft `FlarakVisualTestCreate` auf, `GameInit` leert die FlarakList nicht. `FlarakDoAll` und `FlarakDrawAll` verarbeiten auch Raketen deaktivierter Launcher. Die fehlende Reset-Anbindung erklärt den Befund; sichtbare weitere Altobjekte sind noch nicht bestätigt.
- Ergänzung A5c-Test f77a8c3, 25.11.2026: kleine Explosionen werden nach Neustart gezeichnet; Entwickler vermutet Flak. Quellbeleg: GameInit ruft ExplosionInit und BulletInit auf, beide leeren ihre Listen; FlarakList fehlt weiterhin. FlarakRocketDo kann bei Treffer/Ablauf neue kleine Explosionen vom Typ 3 erzeugen, Flak nutzt explosive Bullets. Ein fortlebendes Altobjekt könnte also nach dem Reset neue Explosionen erzeugen; konkrete Quelle nicht isoliert, kein Nachweis einer ungeleerten Explosionsliste.
- Entwicklerauftrag für separaten Bug-Chat: sämtliche Spielobjekt-/Effekt-Initialisierungen auf vollständige Löschung/Deaktivierung prüfen, einschließlich globaler Einzelinstanzen, Listen, per Instanz erzeugter Sprites, Projektile, Timer, Folgespawns und Referenzen; Prototypen erhalten. Erst Befunde sichern, dann Korrekturpakete abstimmen.
- Vorschlag: separate Flarak-Resetfunktion, sämtliche instanzbezogenen Sprites (Basis, Launcher, Flak, beide Raketen, Warnung) löschen, Liste leeren, bei GameInit aufrufen; übrige Objekt-Resetpfade gezielt auf Vollständigkeit prüfen.
- Reproduktion/Abnahme: bei aktiver Rakete bzw. vorhandenen intakten/zerstörten Flak/Flarak neu starten, keine alten Sprites, Raketen, KI oder Treffer; mehrfach wiederholen. Korrektur noch nicht implementiert.
- Dublette: ersetzt „Sporadisches Sprite nach Neustart“, ursprünglich aus TODO, Revision 0ba2ee8c665325f25a9e7da38a86c9ca49cb7e5a.

## Gelegentlich fehlende Direkttreffer
- ID: Noch nicht vergeben · Priorität: Offen · Status: Vermutet.
- Beobachtung: gelegentlich fehlende Granatwerfer/Flarak/Flak-Direkttreffer. Soll: gültige Direkttreffer zuverlässig erkennen; Explosionstreffer getrennt bewerten.
- Reproduktion: betroffene Waffe, Ziel, Flugweg und Trefferart erfassen; Dateien/Ursache/Korrektur offen.
- Quelle: TODO vor Konsolidierung, Revision 0ba2ee8c665325f25a9e7da38a86c9ca49cb7e5a.

## Flammenwerfer: falsche Bewegungsübernahme
- ID: Noch nicht vergeben · Priorität: Offen · Status: Entwicklerbefund bestätigt, Ursache noch nicht durch Laufzeittest isoliert.
- J4-Test am 25.11.2026 nach Compile-Korrektur e17440a (Testformular d35a6e8): Flammen bewegen sich laut Entwickler nicht mehr korrekt nach rechts, horizontale Bewegung wirkt zu stark; bei Sonecs Auf-/Abbewegung fliegen Partikel sehr weit nach oben/unten statt der erwarteten Mitbewegung.
- Quellbefund e17440a: `FlameNew` addiert `ObjectData.AutoSpeed.x/y` unmittelbar zur eigenen Schussgeschwindigkeit. `SonecCarrierVelocity` berechnet AutoSpeed seit der Bewegungsumstellung als Träger-Schrittwert (Plattengeschwindigkeit mal CalcRange). `FlameMove` multipliziert die so gebildete Geschwindigkeit erneut mit seinem CalcRange. Das spricht für eine Einheiten-/Referenzrahmen-Verwechslung, besonders auf bewegten Plattformen; außerdem wird Sonecs eigene MoveSpeed in FlameNew nicht übernommen. Der genaue erwartete Anteil eigener Bewegung und die Ursache im freien Flug sind noch zu klären.
- `flame.agc`, `sonec.agc`, `timer.agc` und `sprite.agc` sind gegenüber dem Stand vor J4 (ebd0d8e) unverändert; daher kein belegter direkter J4-Codefehler. Zeitpunkt des erstmaligen Auftretens offen.
- Ergänzung Entwickler am 25.11.2026 (nach Feinjustierung ba4be02): Flammenwerfer insgesamt nicht wirklich funktionsfähig; vollständige Prüfung in separatem Bug-Chat vereinbart. Keine weitere Ursachenfeststellung und keine Codekorrektur in A5.
- Prüfung separat: Schuss nach links/rechts im Stand, auf horizontal/vertikal bewegter Plattform, bei freiem Aufstieg/Fall und horizontaler Eigenbewegung; Ausgangsgeschwindigkeit, AutoSpeed, MoveSpeed, CalcRange und tatsächliche Partikelbahn erfassen. Vorschlag: Bewegungskomponenten vor Addition in einheitliche Geschwindigkeitsbasis umrechnen; keine Änderung an Sonec-Resolver, Waffenwerten oder Kollisionsregeln ohne Freigabe. Nicht mit den bekannten Kollision-/Deckungsfragen verwechseln.

## Flammenwerfer: Kollision und Deckung
- ID: Noch nicht vergeben · Priorität: Offen · Status: Vermutet.
- Beobachtung: Flammenkollision bei Flak/Flarak im Silomodus ohne Wirkung. Siloschutz ist beabsichtigt; Löschung und Kistendeckung sind noch abzustimmende Designfragen, keine bestätigten Fehler.
- Prüfung: Silozustand, Übergangsframes und andere Kollisionsziele getrennt prüfen; `FlameCollideFlaraks`, `FlarakAreaHits`, `FlameCollideChest`. Ursache und Korrektur offen.
- Quelle: TODO und Bewegungsspezifikation vor Konsolidierung, Revision 0ba2ee8c665325f25a9e7da38a86c9ca49cb7e5a.
