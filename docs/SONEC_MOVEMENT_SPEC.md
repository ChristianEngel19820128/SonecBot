# SonecBot – Spezifikation der Bewegungs- und Kollisionsphysik

**Stand:** 24. November 2026  
**Status:** Fachlich freigegebenes Ziel für die erste Implementierung (Phasen A–G); Umsetzung schrittweise auf `develop`, mit lokalem Entwicklertest nach jedem Schritt  
**Zweig:** `develop`  
**Geltungsbereich:** Sonec, Plattformen, Kisten, Weltgrenzen, Sprung und Jetpack

## 1. Leitprinzipien

1. Der **erste gültige Kontakt entlang des Bewegungswegs** entscheidet, nicht die zufällige Reihenfolge von Kollisionsabfragen.
2. Kontakte werden anhand der **relativen Bewegung** von Sonec und Hindernis ermittelt; auch schnelle Bewegungen dürfen nicht tunneln.
3. Ein Kontakt begrenzt **nur die betroffene Bewegungskomponente**: Seitentreffer horizontal, Landung vertikal.
4. Physikalische Eigenschaften, Eingaben/Aktionen und Kollisionsergebnisse werden auseinandergehalten. Ein Seitenkontakt darf `Stand` nicht künstlich setzen.
5. Möglichst wenige allgemeine Regeln; explizite Ausnahmen nur, wo das Spiel sie erfordert. Bereits bestehende Kontakte dürfen nicht automatisch als neue blockierende Kollision gelten.

## 2. Tiefenebenen und Plattformbindung

Die 2D-Darstellung bildet verschiedene räumliche Tiefenebenen ab.

- `LinkedPlateIndex` bezeichnet die zugeordnete Tiefenebene, nicht zwingend die aktuell tragende Oberfläche.
- Die Zuordnung bleibt beim Springen, Fallen und Fliegen bestehen; sie wird nicht allein aufgrund einer Höhe gelöscht.
- Sie ändert sich **erst bei einer gültigen Landung** auf einer anderen Plattform oder einer zugehörigen Kiste.
- Beim Durchflug einer **fremden Plattform von unten** sind deren Boden **und sämtliche ihrer Kisten**, auch seitlich, vorübergehend durchlässig. Sonecs bisherige Ebene bleibt dabei bestehen.
- **Einfache Erstregel:** Diese Durchflugausnahme endet, sobald Sonecs Füße oberhalb der höchsten Kistenoberkante dieser Plattform liegen.
- **Späterer Spielgefühl-Test:** Statt der pauschalen Höhenregel eventuell die tatsächlichen Überlappungen einzelner relevanter Elemente prüfen. Das ist ausdrücklich keine Anforderung der ersten Version.

## 3. Landungen und gleichzeitige Kontakte

- Eine Landung ist nur bei einem gültigen **Kontakt von oben** möglich: Die Füße müssen die Oberfläche von oben erreichen und beim Abwärtsweg kreuzen. Dass nur der Kopf eine Höhe erreicht, genügt nicht.
- Plattformoberflächen und Oberseiten aktiver Kisten sind mögliche Landeflächen.
- Beim gültigen Landekontakt wird die Plattformzuordnung übernommen.
- Bei mehreren Kandidaten gewinnt der **früheste gültige Kontakt entlang des Wegs**. Bei gleicher Höhe gilt „first in“: die in Bewegungsrichtung zuerst erreichte gültige Fläche; exakte Gleichstände sind deterministisch aufzulösen.
- Hohe Fallgeschwindigkeit darf keine gültige Landung überspringen.
- Bereits vorhandener Bodenkontakt blockiert keine zulässige horizontale Bewegung.

## 4. Mechanische Kollisionsgeometrie

**Mit tatsächlichem Bodenkontakt:** Seitliche Kistenkollision durch eine **vertikale Linie an Sonecs Vorderseite** über seine **physikalische Körperhöhe**, nicht die Spritehöhe. Ihre horizontale Lage wird am gewünschten Gewehrlaufabschluss ausgerichtet und für die Kontaktseite gespiegelt.

**Ohne Bodenkontakt (Sprung, Fall, Flug):** Die bestehenden **zwei Körperkreise** bleiben für die mechanische Kistenkollision erhalten; sie sind fairer als ein Rechteck.

- Der Wechsel der Geometrie darf keine Positionssprünge, Teleports oder künstliches Herausschieben erzeugen.
- Die vorhandenen Zwei-Kreis-Prüfungen für **Schaden durch Geschosse, Explosionen und andere Gefahren** bleiben unangetastet.
- Ducken erhält vorerst keine verkleinerte physikalische Höhe: Röhren und Decken sind nicht implementiert.

## 5. Seitenkollisionen

- Beim Anlaufen gegen eine Kiste stoppt Sonec vor dem Hindernis. Bewegung und Geschwindigkeit **in das Hindernis hinein** werden relativ zu dessen Bewegung begrenzt.
- Weiter gedrückte Richtung darf keine unsichtbar anwachsende Geschwindigkeit gegen die Wand erzeugen.
- Beim Gegenlenken kann Sonec sofort in die freie Richtung beschleunigen.
- Ein Seitenkontakt setzt **nicht** `Stand = TRUE` und unterbricht nicht die vertikale Bewegung.
- Auch im Weitsprung gilt: Ein seitlicher Kistentreffer begrenzt nur die horizontale Komponente; Steigen/Fallen geht weiter.
- Bewegte Kisten werden über ihre eigene Geschwindigkeit berücksichtigt. Kein pauschales Nullsetzen der Weltgeschwindigkeit bei bewegten Hindernissen.

## 6. Bewegte Plattformen und Weltgrenze

Alle derzeitigen Plattformen bewegen sich **nach links**.

- Sonec wird von seiner tragenden Plattform mitgenommen.
- Durch aktives Gegenlaufen kann er die Mitnahme zunehmend ausgleichen und schließlich überwinden; seine bisherige maximale Laufgeschwindigkeit bleibt zunächst unverändert.
- **Technischer Testvorschlag, noch nicht abschließend entschieden:** Eigene Geschwindigkeit und Plattformmitnahme intern trennen, beim Abspringen die resultierende Weltgeschwindigkeit ohne Sprung oder doppelte Addition übernehmen. Das endgültige Modell entscheidet das Spielgefühl.
- **Einzige ausdrücklich vereinbarte Kisten-Durchdringung am Weltrand:** Wenn eine weiter nach links fahrende Kiste Sonec am linken Weltrand erreicht und er nicht weiter ausweichen kann, darf die Kiste ihn durchdringen. Kein Verschieben aus der Welt und kein Teleport.
- Plattform-Richtungswechsel sind derzeit nicht vorgesehen; mögliche Bossmechaniken werden später separat entworfen.

## 7. Springen und Schwerkraft

- Der normale Sprung ist wie ein **Weitsprung**: ein einmaliger vertikaler Impuls; der horizontale Anlauf bestimmt den Schwung.
- Während des normalen Sprungs kann der horizontale Richtungsimpuls **nicht aktiv umgelenkt** werden.
- Die Schwerkraft wirkt weiter und hebt den anfänglichen vertikalen Impuls allmählich auf.
- Seitenkontakte beenden den Sprung nicht und setzen keine Bodenhaltung.

## 8. Mini-Hop beim Verlassen einer Kistenkante

- Beim Verlassen einer Kistenkante soll grundsätzlich ein **einmaliger Mini-Hop** ausgelöst werden, unabhängig von der anfänglichen horizontalen Geschwindigkeit.
- Ein kleiner **vertikaler Impuls** unterstützt den Übergang.
- Ist die horizontale Geschwindigkeit für ein korrektes Verlassen der Kante zu gering, kommt ein **zusätzlicher horizontaler Impuls in Bewegungsrichtung** hinzu.
- Wiederholte Impulse für denselben Kantenübergang sind ausgeschlossen.
- Die exakten Werte und die sichere Erkennung des Kantenübergangs sind per lokalem Spieltest abzustimmen. Die bisherige Versuchsimplementierung war bei sehr geringer Geschwindigkeit unzuverlässig.

## 9. Jetpack, Energie und Eingaben

- Jetpack-Schub muss die Schwerkraft überwinden; `Fly` allein darf Sonec nicht nach oben teleportieren.
- Verfügbare Energie bestimmt, ob der Schub eingesetzt werden kann.
- **Bestehendes Verhalten erhalten:** Kreuz nach oben wird mit `ButtonDown` kontinuierlich geprüft. Sammelt Sonec während eines Sprungs Energie, während die Taste gedrückt bleibt, kann das Jetpack **sofort wieder einsetzen**.
- Beim Übergang soll vorhandene Bewegung nicht ohne Grund zurückgesetzt werden.
- **Separates Backlog, nicht Bestandteil dieser Umsetzung:** Zweiter Druck auf Kreuz nach oben im Sprung als gezielte Jetpack-Aktivierung; genaue Steuerung und Verhältnis zu `ButtonDown` später festlegen.

## 10. Zustandsmodell

Bisher können mehrere Bool-Werte gleichzeitig wahr sein; verschachtelte `if`-Abfragen entscheiden stellenweise über ihre Priorität.

Künftig klar unterscheiden:
- **Eingaben/Aktionen:** Laufwunsch, Sprungimpuls, Jetpack-Schub.
- **Physikalische Eigenschaften:** tatsächlicher Bodenkontakt, Geschwindigkeiten, Tiefenebene.
- **Kontaktergebnisse:** Landung, seitliche Blockade, tragende Oberfläche.

Bestehende Begriffe und Beziehungen:
- `Stand` und `Duck`: unterschiedliche, gegenseitig ausgeschlossene Haltungen.
- `Fall` und `Fly`: unterschiedliche, gegenseitig ausgeschlossene Bewegungszustände.
- `Jump`: einmaliger Impuls, kein dauerhafter Schub.
- `Back` und `Forward`: Richtungen relativ zur Ausrichtung.

Die Bool-Werte müssen nicht pauschal entfernt werden. Entscheidend ist, dass versteckte Prioritäten nicht zu widersprüchlichen physikalischen Ergebnissen führen. Die **tatsächliche Bodenberührung**, nicht bloß ein priorisierter Bool-Wert, bestimmt die mechanische Kollisionsgeometrie.

## 11. Technischer Entwurf (schrittweise umzusetzen)

1. Eingaben, Kräfte und einmalige Impulse auswerten.
2. Geplante Sonec-, Plattform- und Kistenbewegungen für den Frame bestimmen.
3. Anhand der Tiefenebene und aktiver Durchflugphase gültige Kollisionskandidaten wählen.
4. Frühesten Kontakt entlang der **relativen Bewegungswege** bestimmen (Swept Collision).
5. Nur die betroffene Bewegungskomponente begrenzen; verbleibende Bewegung gegebenenfalls erneut prüfen.
6. Position, Bodenkontakt, Trägeroberfläche, Tiefenebene und übrige Zustände konsistent aktualisieren.

Vermeiden: mehrere unabhängige Routinen, die nacheinander dieselbe Position korrigieren und sich gegenseitig überschreiben. Der genaue Ablauf muss mit dem AGK-Updatezyklus abgestimmt werden.

## 12. Vorgeschlagene kleine Umsetzungsschritte

| Phase | Schwerpunkt | Prüfung |
| --- | --- | --- |
| A | Zustände, Geschwindigkeiten und Kollisionsdaten entflechten | Bestehende Bewegung bleibt nachvollziehbar |
| B | Erster Kontakt / Swept Collision | Kein Tunneln bei hoher Geschwindigkeit |
| C | Linie am Boden, zwei Kreise in der Luft; Seitenkontakt | Gewehr stoppt vor Kiste, Gegenlenken funktioniert |
| D | Plattformmitnahme und relative Kistenbewegung | Stehen, Gegenlaufen, Abspringen |
| E | Tiefenebenen, Durchflug, Landungen | Gültige Ebenenwechsel, keine Fremdkisten-Blockade |
| F | Mini-Hop an Kistenkanten | Funktioniert auch bei sehr geringer Geschwindigkeit |
| G | Integration und Balancing | Regressionstests und Spielgefühl |

Die Reihenfolge ist vorläufig; tatsächliche technische Abhängigkeiten können eine andere Aufteilung erfordern.

## 13. Offene Detailfragen für technische Durchsicht und Tests

- Exakte horizontale Lage der Boden-Kollisionslinie und Übergang zu den Kreisen.
- Gleichzeitige Kontakte und bestehende Überlappungen ohne Positionssprünge.
- Exakte Mini-Hop-Impulse und Erkennung der Kantenereignisse.
- Feinabstimmung der Geschwindigkeitsübernahme beim Abspringen/Landen.
- Eventuelle spätere elementweise Durchflugprüfung statt pauschaler Höhenregel.

## 14. Abnahmefälle

- Kisten von beiden Seiten langsam/schnell anlaufen; sofortiges Gegenlenken.
- Seitlicher Kistenkontakt im Weitsprung ohne vertikalen Stopp.
- Landung auf kleinen/großen Kisten, schnelles Fallen ohne Durchtunneln.
- Durchflug einer fremden Plattform von unten, anschließend gültige Landung und Ebenenwechsel.
- Mehrere gleichzeitige Plattformkandidaten.
- Mitnahme auf nach links fahrender Plattform, Gegenlaufen und Absprung ohne ungewollten Geschwindigkeitssprung.
- Mini-Hop an Kistenkante auch bei sehr niedriger Geschwindigkeit.
- Verhalten am linken Weltrand.
- Jetpack nach Energieaufnahme bei gehaltenem Kreuz nach oben.
- Unveränderte Schadens-Hitboxen, Waffenfunktionen und bestehende Steuerung.

**AGK-Kompilierung und Laufzeittests erfolgen lokal durch den Entwickler. Die fachliche Freigabe für die schrittweise Erstimplementierung A–G liegt vor; jede spätere Regeländerung wird vor der betreffenden Umsetzung hier nachgeführt.**

## 15. Start Phase A – Quellbefund und Abgrenzung (24.11.2026)

- Die Zustandsflags `Fly`, `Fall`, `Stand`, `Duck`, `Move`, `Jump` und Ausrichtungen liegen in `TObjectState` (`source/sonec/def_game.agc`); die Bewegungsgeschwindigkeiten `MoveSpeed` und die Plattformmitnahme `AutoSpeed` in `TObjectData`.
- `TSonec` hält daneben `LinkedPlateIndex` (Tiefenebene), `CollisionData` (aktuelle Kontaktoberfläche), `CollisionMoveStart/End` (Bewegungsweg) sowie `BlockedChest*` und `PassThroughChestIndex` (derzeitige Kontakt-/Durchflug-Ausnahmen). Diese Daten haben unterschiedliche Aufgaben und dürfen nicht als austauschbare Zustände behandelt werden.
- `SonecInput` setzt Zustandsflags, `SonecMoveVerticalSpeed` konsumiert `Jump` und verändert die Vertikalgeschwindigkeit, `SonecMoveHorizontalSpeed` verändert die Horizontalgeschwindigkeit, `SonecCollidePlate` und `SonecCollideChestHorizontal` setzen Bodenkontakt und Plattformzuordnung. Die bisherige Kollisionsauflösung ist noch auf mehrere Routinen verteilt.
- **A1-Ziel:** Zunächst diese Zuständigkeiten und ihre Übergänge im Code eindeutig kennzeichnen bzw. kleinräumig entflechten, **ohne** die bestehende Bewegungs- oder Kollisionswirkung zu verändern. Erst nach lokalem AGK-Compile folgt der nächste Eingriff. Keine vorzeitige Einführung der Phasen B–F.


## 16. Implementierungsnachweis Phase A1 (24.11.2026)

- **Revision:** `de0115a34b6c3cf623ef15bd6e4d75cb40c02948` auf `develop`.
- **Änderung:** Sechs Funktionskommentare in `source/sonec/sonec.agc` klären Verantwortlichkeiten; keine Ausführungslogik geändert.
- **Entwicklertest:** AGK-Studio-Kompilierung vom Entwickler ausdrücklich als **bestanden** gemeldet; keine weiteren Beobachtungen. Ein Gameplay-Test wurde für diesen reinen Kommentarschritt nicht verlangt oder behauptet.
- **Nächster Schritt A2:** Zustandsübergänge kleinräumig entflechten, ohne beabsichtigte Änderung des bestehenden Verhaltens. Änderungen an Spielregeln bleiben dokumentationspflichtig.

## 17. Phase A2 – Vertikale Eingabezustände entflechten (24.11.2026)

- **Revision:** `7471d83d8929e078c54ec2773966472b31e88767` auf `develop`.
- **Änderung:** Die vorhandenen Entscheidungen zu gehaltenem Kreuz nach oben, Jetpack-Aktivierung, Sprunganforderung und Übergang zu `Fall` wurden aus `SonecInput` unverändert in `SonecInputVerticalState` ausgelagert. `SonecInput` ermittelt den bisherigen Up-Tastenstatus und übergibt ihn an den Helfer.
- **Bewusst unverändert:** Reihenfolge der Bedingungen, Energiekosten/-schwellen, Zustandszuweisungen, Animation und Jetfire-Auslösung; noch keine neue Physik oder neue Tiefenebenenregel.
- **Prüfung:** Quellseitige Überprüfung der Extraktion; **AGK-Kompilierung und Laufzeitwirkung noch nicht vom Entwickler geprüft**. Nächster Kontrollpunkt: AGK-Compile, danach erst weitere Entflechtung.
- **Regel 1:** Keine neue fachliche Entscheidung getroffen; bei späteren Abweichungen wird die Spezifikation vor dem betreffenden Code angepasst.

## 18. Entwicklertest Phase A2 (24.11.2026)

- **Getesteter Code-Commit:** `7471d83d8929e078c54ec2773966472b31e88767` auf `develop`.
- **Gesamtergebnis:** **Bestanden, 5/5 bestätigt**, vom Entwickler lokal in AGK Studio gemeldet.
- **Bestätigt:** AGK-Kompilierung erfolgreich; normaler Sprung funktioniert; Fallen funktioniert; Jetpack funktioniert; Energieaufnahme bei gehaltenem Kreuz nach oben funktioniert.
- **Offen:** Keine. **Beobachtungen:** Keine Angaben.
- **Einordnung:** Die Extraktion der vertikalen Eingabezustände hat in diesen Prüfungen keine erkennbare Regression verursacht. Das ist keine Abnahme der späteren neuen Kollisionsphysik.
- **Nächster Schritt:** Phase A3 – weitere Zuständigkeiten von Bewegung und Bodenkontakt kleinräumig trennen, ohne fachliche Regeln stillschweigend zu ändern.

## 19. Phase A3 – Bodenkontakt-Zuweisung zentralisiert (24.11.2026)

- **Code-Revision:** `a330ff71031e76c46879b8fbc030f6902a26039e` auf `develop`.
- **Änderung:** `SonecSetGroundContact` bündelt die bisher identischen Zuweisungen von `Fall`, `Stand`, `CollisionData.ListType/Index`, `LinkedPlateIndex` und vertikaler Geschwindigkeit bei gültiger Landung auf Plattform oder Kiste. Beide bisherigen Landestellen rufen diesen Helfer auf.
- **Bewusst unverändert:** Kontaktprüfung, Kollisionsreihenfolge, Positionsberechnung, Kisten-Ausgleichsschritt und alle fachlichen Regeln. Die bestehende separate Bereinigung ungültiger `LinkedPlateIndex`-Werte ist noch nicht neu gestaltet.
- **Prüfung:** Quellseitige Prüfung der Ersetzung; AGK-Kompilierung und Laufzeitverhalten durch den Entwickler noch offen. Nächster Schritt erst nach Rückmeldung.

## 20. Entwicklertest Phase A3 (24.11.2026)

- **Getesteter Code-Commit:** `a330ff71031e76c46879b8fbc030f6902a26039e` auf `develop`.
- **Gesamtergebnis:** **Bestanden, 5/5 bestätigt**, vom Entwickler lokal in AGK Studio gemeldet.
- **Bestätigt:** AGK-Kompilierung erfolgreich; Landung auf Plattform funktioniert; Landung auf Kiste funktioniert; Absprung und erneute Landung funktionieren; Kistenrand und Ausgleichsschritt weiterhin unauffällig.
- **Offen:** Keine. **Beobachtungen:** Keine Angaben.
- **Einordnung:** Die Zentralisierung der Bodenkontakt-Zuweisungen zeigt in diesen Prüfungen keine erkennbare Regression. Die neue Kollisionsphysik ist damit noch nicht implementiert oder abgenommen.
- **Nächster Schritt:** Phase A fortsetzen, jeweils kleinräumig und mit Entwicklertest; fachliche Änderungen zuerst in der Spezifikation festhalten.

## 21. Phase A4 – Plattformbindungs-Validierung isoliert (24.11.2026)

- **Code-Revision:** `8895d100f5d212b63cce2b32fefcfed00614c3a5` auf `develop`.
- **Änderung:** Die bisherige Prüfung des `LinkedPlateIndex` auf ungültigen Index bzw. deaktivierte Plattform wurde aus `SonecCollidePlate` unverändert in `SonecValidateLinkedPlate` ausgelagert. Die Prüfung wird an derselben Stelle aufgerufen.
- **Bewusst unverändert:** Alle bisherigen Bedingungen und Zuweisungen, Landung, Durchflug, Kistenkontakt, Sprung und Jetpack. Es wurde keine neue Tiefenebenenregel umgesetzt. Insbesondere ist die spätere fachliche Vorgabe zur persistenten Bindung noch gesondert umzusetzen; die alte Validierung löscht weiterhin ungültige/deaktivierte Verweise.
- **Prüfung:** AGK-Kompilierung und Laufzeittest durch den Entwickler stehen noch aus.

## 22. Entwicklertest Phase A4 und Abschluss Phase A (24.11.2026)

- **Getesteter Code-Commit:** `8895d100f5d212b63cce2b32fefcfed00614c3a5` auf `develop`.
- **Gesamtergebnis:** **Bestanden, 5/5 bestätigt**, vom Entwickler lokal in AGK Studio gemeldet.
- **Bestätigt:** Jetpack und Plattformwechsel unauffällig; Kistenlandungen funktionieren; Plattformlandungen funktionieren; AGK-Kompilierung erfolgreich; Springen und Fallen funktionieren.
- **Offen:** Keine. **Beobachtungen:** Keine Angaben.
- **Einordnung:** Phase A1–A4 (Zuständigkeiten und kleine Extraktionen ohne beabsichtigte Gameplay-Änderung) ist damit vom Entwickler erfolgreich geprüft und als vorbereitende Phase abgeschlossen. Die neue Bewegungs- und Kollisionsphysik der Phasen B–G ist noch nicht umgesetzt oder abgenommen.
- **Nächster Schritt:** Vor dem ersten fachlichen Eingriff in Phase B den konkreten Geltungsbereich und alle dafür nötigen Details anhand dieser Spezifikation prüfen; jede zusätzliche Entscheidung zuerst hier festhalten.

## 23. Phase B – Quellbefund und erster Eingriff (24.11.2026)

- **Korrektur der Phasenbezeichnung:** Phase B ist gemäß Abschnitt 12 die zeitlich korrekte Kontaktfindung entlang des Bewegungswegs (Swept Collision). Die vollständige Tiefenebenen-/Durchfluglogik folgt in Phase E; die vorherige mündliche Bezeichnung von B als Tiefenebenenphase war ungenau.
- **Ist-Befund:** `SonecMove` speichert `CollisionMoveStart` und `CollisionMoveEnd`. In `SonecCollidePlate` prüft die bestehende Plattformlandung jedoch primär die aktuelle Fußhöhe und eine geschwindigkeitsbasierte Nachbedingung. Die Kistenkontakte werden separat verarbeitet. Damit ist die übergreifende Auswahl des frühesten gültigen Kontakts noch nicht implementiert.
- **B1-Ziel:** Als erster isolierter Schritt die Abwärtskreuzung einer Plattformoberfläche anhand der gespeicherten Fußpositionen vor und nach der Bewegung prüfen, ohne dabei bereits Kistenkontakte, Tiefenebenen, Jetpack oder seitliche Kollisionen umzubauen. Die Landung erfolgt nur bei Abwärtsbewegung und einem von oben gekreuzten Boden; der erste Kontakt entlang des Wegs muss bei mehreren Kandidaten Vorrang erhalten.
- **Technische Abhängigkeit:** Die Bewegungen von Plattformen/Kisten erfolgen nach `SonecMove`; für die später vollständige relative Swept Collision sind Anfangs- und Endpositionen der Hindernisse bzw. eine entsprechende Bewegungsdifferenz erforderlich. B1 allein erfüllt daher noch nicht alle Abnahmefälle aus Abschnitt 14.
- **Prüfung:** Vor einem B1-Code-Commit sind der genaue Ablauf der Kollisionsfunktionen und die bisherige Boden-Kontaktbehandlung zu kontrollieren. Nach der kleinsten Codeänderung folgt ein lokaler AGK-Test.

## 24. Phase B1 – Erste gesweepte Plattformlandung (24.11.2026)

- **Code-Revision:** `6a6c85bfb3061d469db4494c6864aa6404330c23` (`ab0ba2d` mit nachfolgender Deklarationskorrektur) auf `develop`.
- **Änderung:** Plattformlandung prüft die Fußposition in `CollisionMoveStart` und `CollisionMoveEnd`: nur bei Abwärtsbewegung und Kreuzung der Plattformoberkante von oben. Bei mehreren gekreuzten aktiven Plattformen gewinnt die oberste (= entlang des Abwärtswegs zuerst erreichte); bei exakter Gleichhöhe gewinnt die zuerst durchlaufene Plattform im Array. Die bestehende horizontale Bereichsprüfung bleibt zunächst erhalten.
- **Unverändert:** Kistenkontakt- und Kistenlandelogik laufen vorher; Jetpack, Seitenkollision, Durchflug-Ausnahme und Geschwindigkeitsmodell wurden nicht umgestellt.
- **Noch offen:** Plattform-/Kistenbewegung relativ zum Sweep, zeitgenauer horizontaler Kontakt und gemeinsame Priorisierung von Kisten- und Plattformkontakten; B1 ist kein vollständiger Swept-Resolver.
- **Entwicklerprüfung ausstehend:** AGK-Kompilierung, normale Plattformlandung, Landung nach Sprung/Jetpack, schneller Fall auf Plattform und Plattformen auf unterschiedlichen Höhen. Keine Testergebnisse vorweggenommen.

## 25. Entwicklertest Phase B1 (24.11.2026)

- **Getesteter Code-Commit:** `6a6c85bfb3061d469db4494c6864aa6404330c23` auf `develop`.
- **Gesamtergebnis:** **Bestanden, 6/6 bestätigt**, vom Entwickler lokal in AGK Studio gemeldet.
- **Bestätigt:** AGK-Kompilierung erfolgreich; normale Plattformlandung funktioniert; Landung nach Sprung funktioniert; Landung nach Jetpack funktioniert; schneller Fall auf Plattform funktioniert; mehrere Plattformhöhen unauffällig.
- **Offen:** Keine. **Beobachtungen:** Keine Angaben.
- **Einordnung:** B1 ist für diese sechs Fälle erfolgreich geprüft. Die noch ausstehenden Aspekte der vollständigen Swept Collision (relative Hindernisbewegung, horizontaler Kontaktzeitpunkt und gemeinsame Kontaktpriorisierung) sind damit nicht automatisch abgenommen.
- **Nächster Schritt:** B2 als kleinsten weiteren, separat testbaren Schritt vorbereiten; jede neue Bewegungsentscheidung zuerst in dieser Spezifikation dokumentieren.

## 26. Phase B2 – Beschlossene relative Plattformoberflächen-Kreuzung (24.11.2026)

- **Regel vor Codeänderung:** Für die Prüfung der Landung auf bewegten Plattformen zählt die relative vertikale Bewegung von Sonecs Füßen gegenüber der Plattformoberkante. Die Oberkante wird am Anfang und Ende desselben Bewegungsupdates betrachtet. Eine gültige Kreuzung erfordert, dass die Füße zu Beginn auf oder oberhalb der damaligen Oberkante liegen, am Ende die neue Oberkante erreichen/überschreiten und sich relativ zur Plattform nach unten bewegen.
- **Technik:** Jede Plattform erhält eine für die Kollisionsphysik gespeicherte Anfangsposition des aktuellen Bewegungsschritts. Diese wird auch bei Updates ohne Plattformbewegung erneuert. Die neue Prüfung betrifft zunächst ausschließlich die Plattformlandung, nicht Kisten oder Seitenkontakte.
- **Kandidatenauswahl:** Bei mehreren gekreuzten Plattformen wird die kleinste relative Kontaktzeit innerhalb des Updates gewählt, statt allein die Höhe am Ende zu vergleichen. Exakte Gleichstände bleiben stabil in Plattform-Array-Reihenfolge.
- **Grenzen B2:** Horizontale Kontaktprüfung bleibt zunächst die bestehende Endpositionsprüfung; Kisten-/Plattformkontakte werden noch nicht gemeinsam priorisiert. Pass-through-Ausnahme und Zustandslogik bleiben unverändert.
- **Entwicklertest:** AGK-Kompilierung; ruhende und bewegte Plattformlandungen; Sprung/Jetpack; schneller Fall; Plattformen unterschiedlicher Höhen. Noch keine Testbestätigung.

## 27. Phase B2 – Implementierungsstand (24.11.2026)

- **Code-Commits auf `develop`:** `2a168c4` (Plattformtyp), `b8a633d` (Startposition vor Bewegung), `cfa5e35` (relative Kreuzungsprüfung).
- **Umsetzung:** `TPlate.CollisionMoveStart` speichert die Position vor `PlateMove` (auch bei ausgelassenem Timer-Schritt); die Plattformlandung in `SonecCollidePlate` vergleicht Anfangs- und Endabstand der Füße zur bewegten Oberkante und wählt die kleinste gültige Kontaktzeit. Exakte Zeitgleichheit bleibt durch strikten `<`-Vergleich beim ersten Array-Eintrag.
- **Bewusst nicht umgesetzt:** horizontale Swept-Prüfung, gemeinsame Kisten-/Plattform-Priorisierung, vollständige Durchfluglogik und restliche Bewegungsphysik.
- **Status:** AGK-Kompilierung und Funktionstests durch den Entwickler stehen aus. Kein lokaler AGK-Compiler verfügbar.

## 28. Entwicklertest B2 – Regression bei Kistenlandung (24.11.2026)

- **Getesteter Code-Commit:** `cfa5e35dcf8a6efe5b8ad9ef79fcc014ac6aed56` auf `develop`.
- **Gesamtergebnis:** **Auffälligkeiten / Fehler; B2 nicht abgenommen.** AGK-Kompilierung erfolgreich; Landung auf normaler und vertikal bewegter Plattform, Sprung mit erneuter Landung, Jetpack mit anschließender Landung sowie schneller Fall und unterschiedliche Plattformhöhen unauffällig (6/7 Prüfpunkte). **Offen/fehlgeschlagen:** Kistenlandungen nicht durchgehend zuverlässig.
- **Entwicklerbeobachtung (wörtlich):** „teilweise fallen durch kisten möglich. scheinbar in der mitte der kistenoberfläche.“ Keine weitergehenden reproduzierbaren Randbedingungen gemeldet.
- **Quellbefund:** `SonecCollideChestHorizontal` verwendet für Kistenlandungen noch aktuelle Fußhöhe plus `MoveSpeed.y` als engen Nachbereich, nicht die relative Start-/Endbewegung. Die Kisten-Seitenkontaktklassifikation läuft vorher und kann einen Kandidaten ausschließen. B2 änderte dagegen ausschließlich die Plattformlandung und ergänzte Plattform-Startpositionen. Ein ursächlicher Zusammenhang ist damit noch **nicht bewiesen**; die Kistenlandelogik war bereits vor B2 potenziell empfindlich gegen schnelle Schritte.
- **Entscheidung zum Vorgehen:** B3 aussetzen. Erst Reproduktion und Diagnose der Kistenlandung, insbesondere Fälle mitten auf der Kistenoberfläche; keinen unbestätigten Kausalzusammenhang behaupten. Eine konkrete Regel-/Codekorrektur zuerst in der Spezifikation beschließen, danach klein ändern und lokal erneut testen.

## 29. B2 – Eingrenzung des Kisten-Durchfallens (24.11.2026)

- **Neue Entwicklerbeobachtung:** Die Häufigkeit des Durchfallens steigt scheinbar mit der **horizontalen Geschwindigkeit**; bisher ausschließlich bei **großen Kisten** beobachtet. Der vorherige Bericht beschreibt Fälle scheinbar mitten auf der Kistenoberfläche. „Scheinbar“ kennzeichnet die noch nicht kontrolliert reproduzierten Bedingungen.
- **Quellbefund:** `SonecCollideChestSideContacts` bestimmt einen `SideHitIndex` anhand gesweepter Körperkreise und horizontaler Bewegung. `SonecCollideChestHorizontal` überspringt danach **jede** Landungsprüfung für genau diese Kiste (`SideHitIndex <> i`), auch wenn Sonecs Füße ihre Oberkante im selben Schritt von oben kreuzen könnten. Außerdem nutzt die Kistenlandung weiterhin die alte vertikale Endpositionsprüfung. Das ist ein konkreter möglicher Mechanismus, aber noch kein bewiesener Auslöser der Beobachtung.
- **Vorgesehene kleinste Korrektur (noch nicht implementiert):** Eine gültige Fußkreuzung von oben darf nicht allein durch einen im selben Frame ermittelten Seitenkontakt-Index verworfen werden. Vor der Änderung muss die zeitliche Reihenfolge von Seiten- und Oberseitenkontakt anhand der relativen Bewegung geklärt und im Code umgesetzt werden; Seitenkontakt bleibt wirksam, wenn er tatsächlich zuerst erfolgt. Kein pauschales Entfernen der Seitenkollision und keine neue Kisten-Durchlässigkeit.
- **Status:** B2 weiterhin nicht abgenommen; B3 ausgesetzt. Gezielte Regressionstests: große Kiste mit niedriger/hoher horizontaler Geschwindigkeit, mittiger/naher Rand-Landung, kleine Kiste, echte Seitenkollision und Durchflug von unten.

## 30. Phase B – Nächster Architekturbaustein: relative Kistenoberseiten (24.11.2026)

- **Entwicklerentscheidung:** Kein Sonderfix der alten Kistenkollision. Die bereits geplante Swept-Collision-Architektur wird schrittweise auf Kisten ausgedehnt; falls ein Fehler erst mit gemeinsamer Kontaktpriorisierung lösbar ist, bleibt er bis dahin offen.
- **Dieser isolierte Schritt (B-K1):** Bei der Landung auf einer Kiste die bisherige vertikale Endpositions-/Geschwindigkeitsbedingung durch eine Kreuzung der Füße relativ zur **bewegten Kistenoberkante** ersetzen. Die vorhandenen `Sonec.CollisionMoveStart/End` und `Chest.CollisionMoveStart` werden genutzt; Kontakt nur bei relativ abwärts gerichteter Bewegung, Start oberhalb/auf der Oberfläche und Ende auf/unter der Oberfläche. Bei mehreren gültigen Kistenoberseiten entscheidet die früheste relative Kontaktzeit; Gleichstand stabil in Array-Reihenfolge.
- **Bewusst unverändert:** Die vorherige Seitenkontakt-Erkennung und deren `SideHitIndex`-Ausschluss, horizontale Endpositionsprüfung, Balanceschritt, Durchflugregeln und Reihenfolge Kiste vor Plattform. B-K1 allein muss den beobachteten Fehler bei großen Kisten und hoher Horizontalgeschwindigkeit **nicht** beheben; die gemeinsame zeitliche Priorisierung von Seite/Oberseite folgt separat.
- **Prüfung:** AGK-Kompilierung, Kistenlandung bei niedriger und hoher Horizontalgeschwindigkeit, große und kleine Kisten, echte Seitenkollision, Jetpack/Durchflug und Plattformlandung. Bis zum Test keine Abnahme.

## 31. Phase B-K1 – Implementierung und offener Test (24.11.2026)

- **Code-Commit:** `9b8834cfd2be75c003755b242df042230981edaf` auf `develop`.
- **Umsetzung:** Die Landungsentscheidung auf Kistenoberseiten verwendet die relative Fußkreuzung von `Sonec.CollisionMoveStart/End` gegen `Chest.CollisionMoveStart` und die aktuelle Kistenoberkante. Bei mehreren Kandidaten gewinnt die früheste relative Kontaktzeit. Bestehende Landungsfolgen inklusive Balanceschritt bleiben erhalten.
- **Nicht behoben/noch offen:** Der vorherige `SideHitIndex`-Ausschluss kann weiterhin Kistenlandungen verhindern; eine gemeinsame zeitliche Kontaktpriorisierung ist der nächste Architekturbaustein, kein Legacy-Sonderfix. B2 bleibt nicht abgenommen.
- **Entwicklertest ausstehend:** AGK-Kompilierung; Landung auf großen/kleinen Kisten mit langsamer/schneller Horizontalbewegung; echte Seitenkollision; Plattformlandung; Jetpack/Durchflug. Keine Testergebnisse vorweggenommen.

## 32. Entwicklertest B-K1 und weiterhin offener Kisten-Durchfall (24.11.2026)

- **Getesteter Code-Commit:** `9b8834cfd2be75c003755b242df042230981edaf`.
- **Formularergebnis des Entwicklers:** „Bestanden“, **7/7 Prüfpunkte bestätigt**, keine offenen Formularpunkte: AGK-Kompilierung, Landung auf kleinen Kisten, auf großen Kisten bei geringer und hoher horizontaler Geschwindigkeit, echte Seitenkollision, Plattformlandung, Jetpack und Durchflug von unten.
- **Wichtige Einschränkung aus den Freitext-Beobachtungen:** „teilweise kann man scheinbar doch durch alle kistengrößen fallen. eher unklar warum. geringer und langsamer sprung und landen auf kiste funktioniert zumindest regulär. seitliche kollision funktioniert wie in der vorgängeränderung.“ Damit ist der Fehler **nicht behoben** und die Gesamtkollision nicht abgenommen; die sieben bestätigten Einzelprüfungen gelten nur für die jeweils erfolgreich ausgeführten Fälle.
- **Folgerung:** Keine Sonderreparatur der alten Landelogik. Als nächster Architekturbaustein zeitliche Priorisierung von Kisten-Seiten- und Oberseitenkontakten entlang der relativen Bewegung; anschließend gezielt auch intermittierendes Durchfallen auf allen Kistengrößen prüfen. Ursache derzeit nicht bewiesen.
- **Backlog-Idee separat:** Landen auf einem Silowrack ohne horizontale Seitenkollision; zwei Höhen wie eine Treppe, zunächst nur bei Landekontakten. Keine aktuelle Verhaltensänderung beschlossen.

## 33. Phase B-K2 – Kontaktzeit statt pauschalem Seitenvorrang (24.11.2026)

- **Vor Codeänderung beschlossen:** Für eine Kiste mit gültiger relativer Fußkreuzung von oben wird deren Kontaktzeit mit der Zeit des bereits gesweepten Körperkreis-Seitenkontakts verglichen. Ein **früherer oder zeitgleicher gültiger Oberseitenkontakt** hat Vorrang; ein tatsächlich früherer Seitenkontakt bleibt blockierend. Bei Gleichstand gewinnt die Oberseite, damit eine Eckberührung beim Landen nicht allein als Seitenwand interpretiert wird.
- **Kleiner isolierter Schritt B-K2:** Die vorhandene Funktion `SonecCollideChestSideContacts` ermittelt zusätzlich den frühesten zulässigen Kisten-Oberseitenkontakt aus dem bereits in B-K1 verwendeten relativen Fuß-Sweep und dem bestehenden horizontalen Endpositions-/Kistenfilter. Ist dieser zeitlich vor oder gleich dem erkannten Seitenkontakt **derselben Kiste**, wird dieser Seitenkontakt nicht angewendet; die bestehende B-K1-Landungsprüfung kann danach landen. Eine früher berührte andere Seitenwand bleibt wirksam. Die bestehende Unterseiten-Pass-through-Regel bleibt unberührt.
- **Bewusst nicht Bestandteil:** Vollständiger gemeinsamer Resolver über Kisten und Plattformen, horizontale Kontaktposition entlang des Sweeps, Restbewegungsauflösung und Tiefenebenen-Redesign. Diese sind weitere geplante Schritte; die Intermittenz kann auch andere Ursachen haben.
- **Testziel:** AGK-Compile, kleine/große Kisten mit langsamem/schnellem Sprung, diagonale Landung nahe Kistenkante, echte Seitenkollision, Durchflug von unten, Plattformlandung. B2 bleibt bis zur Gesamtabnahme offen.

## 34. Phase B-K2 – Code umgesetzt, AGK-Test offen (24.11.2026)

- **Code-Commit:** `b6849d6a10f3c3f248f4493e7bc431c6fa9200d6` auf `develop`.
- **Umsetzung:** Bevor `SonecCollideChestSideContacts` den ausgewählten Seitenkontakt anwendet, prüft es für dieselbe Kiste eine gültige relative Fußkreuzung von oben. Wenn die Oberseite zuerst oder zeitgleich getroffen wird, entfällt nur dieser Seitenblock; die anschließende B-K1-Landungsroutine entscheidet weiterhin über tatsächlichen Bodenkontakt. Ein früherer Seitenkontakt bleibt erhalten.
- **Grenze:** Keine vollständige globale Priorisierung von Kisten und Plattformen und noch kein horizontaler Sweep für die Kistenlandung. Der sporadische Durchfallfehler bleibt offen, bis der Entwickler nachgetestet hat.
- **AGK-Kompilierung und Laufzeittests:** durch den Assistenten nicht ausführbar, ausdrücklich ausstehend.

## 35. Entwicklertest B-K2 – Einzelprüfungen bestanden, Gesamtfehler offen (24.11.2026)

- **Getesteter Code-Commit:** `b6849d6a10f3c3f248f4493e7bc431c6fa9200d6`.
- **Entwickler bestätigt 7/7 Prüfpunkte, Gesamtergebnis „Bestanden“:** AGK-Kompilierung; kleine und große Kistenlandungen; schnelle diagonale Landung nahe Kistenkante; echte Seitenkollision; Plattformlandung; Jetpack und Durchflug von unten.
- **Gleichzeitig beobachtete, weiterhin offene Fehler:** Sonec fällt **gelegentlich** durch Kisten, Landungen wirken bei geringer Geschwindigkeit zuverlässiger. Gelegentliches **seitliches Tunneln** durch Kisten besteht fort; ein Zusammenhang mit fehlgeschlagenen Landungen ist möglich, aber nicht bewiesen. Beim Stoppen vor einer Kiste steckt das **Gewehr weiterhin in der Kiste**.
- **Bewertung:** B-K2-Einzeltests bestanden; die Gesamt-Kistenkollision ist **nicht abgenommen**. Keine neuen Legacy-Sonderfixes. In den geplanten nächsten Architekturbausteinen horizontale Swept-Kontakte, gemeinsame Kontaktreihenfolge und bodengebundene Front-/Gewehr-Kollisionslinie berücksichtigen. Die Gewehrfront ist Teil der vereinbarten Bodenkollisionsgeometrie, während die zwei Kreise für Luft-Seitenkontakte gelten. Keine Behauptung einer bereits behobenen Ursache.

## 36. Phase B-K3 – Horizontaler Sweep beim Bodenkontakt (vor Code, 24.11.2026)

- **Geplanter isolierter Schritt:** Bei `State.Stand = TRUE` wird für Kisten-Seitenkontakte statt der beiden Luft-Körperkreise eine vertikale Körperfront-Linie über die physische Sonec-Höhe gegen die relativ bewegte Kisten-Seitenfläche gesweept. Die Front liegt zunächst bei ± halber physischer Körperbreite; der genaue Gewehrlauf-Vorsprung ist noch nicht aus den Bewegungsdaten abgeleitet und wird nicht behauptet. Die endgültige Gewehrlauf-Front ist ein späterer Geometrieschritt.
- **Kontaktprüfung:** Relativer X-Weg des Sonec-Mittelpunkts zur Kiste, Kreuzung der passenden Seitenebene von außen nach innen, und vertikale Überlappung **zum Kontaktzeitpunkt**. Ein gültiger Kontakt setzt X auf die aktuelle Kistenkante minus/plus halbe Körperbreite, stoppt die horizontale Eigenbewegung und speichert die Blockierung wie bisher. Bei mehreren Kisten gewinnt die früheste Kontaktzeit, Gleichstand Array-Reihenfolge. Die vorhandene Weltrand-Ausnahme bleibt bestehen.
- **Unverändert:** Luftkollision mit zwei Kreisen, Unterseiten-Durchflug, B-K2-Landungspriorität, Tiefenebenenfilter, Plattformlandung und Kisten-Balanceschritt. Die später geplante globale Kontaktauflösung ist damit noch nicht abgeschlossen.
- **Test:** AGK-Compile, Anlaufen von beiden Seiten im Stand, schnell/langsam, Gewehrposition als Beobachtung (nicht als bereits gelöst markieren), Kisten auf bewegten Plattformen, Jetpack-Seitenkontakt, Sprunglandung, Durchflug von unten. Durchfallen/Tunneln bleibt bis zum Test offen.

## 37. Phase B-K3 – Code umgesetzt, Entwicklertest offen (24.11.2026)

- **Code-Commit:** `f7c1061649fea92a162b37dd28ce59ede2cc9333` auf `develop`.
- **Umsetzung:** `SonecCollideChestSideContacts` prüft im Stand relative horizontale Kreuzungen der Kisten-Seitenflächen mit einer vertikalen Frontlinie in ± halber physischer Sonec-Breite und prüft die volle Körperhöhe zum Kontaktzeitpunkt. Frühester gültiger Seitenkontakt gewinnt; die bisherige X-Blockierung und Weltrand-Ausnahme werden weiterverwendet. Im Nicht-Stand bleiben die beiden gesweepten Körperkreise unverändert.
- **Einschränkung:** Die endgültige Gewehrlauf-Frontgeometrie ist noch nicht umgesetzt; die Linie liegt vorläufig am physischen Körperrand. B-K2-Oberseitenpriorität, Durchflug und Tiefenebenenfilter unverändert. Seitliches Tunneln, gelegentliches Durchfallen und Gewehrüberlappung bleiben bis zum Entwicklertest bzw. Folgeschritt offen.
- **AGK-Compile/Laufzeit:** Nicht durch den Assistenten durchgeführt. Nächster Schritt: gezielter Entwicklertest, erst danach weitere Kollisionsänderungen.

## 38. Entwicklertest B-K3 – 7/7 Einzelprüfungen, verbleibende Regressionen (24.11.2026)

- **Getesteter Code-Commit:** `f7c1061649fea92a162b37dd28ce59ede2cc9333`.
- **Entwicklerergebnis:** „Bestanden“ im Sinn erfolgreich ausgeführter Einzelprüfungen, **7/7 bestätigt**: AGK-Kompilierung; langsames und schnelles Anlaufen von beiden Seiten; Springen/Landen auf kleinen und großen Kisten; Seitenkontakt im Flug/Jetpack; Durchflug von unten und Plattformlandung; Kiste auf bewegter Plattform. Keine offenen Formularpunkte.
- **Neue Beobachtung – Plattform:** Sonec fällt vereinzelt **durch Plattformen, sogar nachdem er bereits darauf stand**. Vermutung des Entwicklers: Float-/Integer-Ungenauigkeit; ausdrücklich **nicht bewiesen**, Positionen normalerweise Float. Vor Korrektur insbesondere Standkontakt-Erhaltung, Zustandswechsel und gesweepte Fußkreuzung prüfen; keinen Rundungsfix auf Verdacht.
- **Weiterhin offen – Kisten:** Gelegentliches Durchfallen durch Kisten. Die Seitenkollision wird beim **Beginn des Fliegens** teilweise ignoriert. Reproduktionshinweis: **links neben Kiste stehen, nach rechts drücken, Granatwerfer mit Rückstoß verwenden** – danach kann Sonec durch die Kiste laufen. Mögliche Ursachen (noch nicht belegt): Wechsel Boden-/Luft-Kollisionsgeometrie und Rückstoßbewegung außerhalb der geprüften Kontakttrajektorie.
- **Bewertung:** B-K3-Einzelprüfungen bestätigt, Gesamt-Kollision weiterhin **nicht abgenommen**. Nächster geplanter Schritt: Ursachenpfade der genannten Fälle prüfen und danach die gemeinsame Kontaktauflösung weiterentwickeln, statt alte Kollision durch Sonderfixes zu reparieren. AGK-Laufzeitbefunde stammen vom Entwickler, nicht aus einer lokalen Ausführung des Assistenten.

## 39. Nächster Architekturbaustein – physischer Bodenkontakt getrennt vom Animationszustand (24.11.2026, vor Code)

- **Ziel:** Ein gültiger bestehender Plattform-/Kistenkontakt wird nicht allein durch einen Waffenrückstoß oder einen Wechsel von `Stand`/Laufanimation gelöscht. Physische Kontaktbindung ist separat zu führen. Sprung und Jetpack heben den Kontakt ausdrücklich auf; Verlassen einer Oberfläche und Deaktivierung der Trägergeometrie ebenso.
- **Isolierter Schritt:** `GroundContactActive` in `TSonec` führt die physische Stützung. `SonecSetGroundContact` setzt es, `SonecCollideReset` löscht es; der Eingabepfad für echten Sprung/Jetpack löscht es ausdrücklich. Plattform-/Kisten-Standfortsetzung und bodengebundene Seitengeometrie fragen diese Kontaktbindung ab, statt ausschließlich `State.Stand` zu vertrauen. Nach gültiger Fortsetzung darf `State.Stand` wieder TRUE sein. Rückstoß behält seine horizontale Wirkung, ist aber keine eigene Abhebeaktion.
- **Numerik:** Welt-, Bildschirm-, Bewegungs- und Kontaktpositionen bleiben Float. Bei Quotienten mit benötigtem Bruchteil steht ein Float-Operand vor/in der Division, z. B. `mx / 2.0`, nicht bloß eine Float-Zielvariable oder `(mx / 2) * 1.0`. Keine pauschalen Rundungs-/Epsilon-Korrekturen.
- **Nicht Teil:** Globale Kontaktzeit-Priorisierung, endgültige Gewehrfront, Änderung des Jetpackverhaltens oder Reparatur weiterer Legacy-Sonderfälle. Plattformverlust ohne Waffenrückstoß bleibt gesondert zu prüfen.
- **Test:** AGK-Compile; Granatwerfer-Rückstoß im Stand links/rechts an Kiste; Plattformstand bei Rückstoß; Springen/Jetpack vom Boden; Kisten- und Plattformkanten verlassen; Landungen und Durchflug. Keine Vorab-Abnahme.

## 40. Bodenkontaktbindung – Implementierung und offener AGK-Test (24.11.2026)

- **Code:** `ca4cf36aebfc7bea4208c743d21069291e87ec37` (`TSonec.GroundContactActive`), `71ed85e0f592a7d5fb2b259517db03891f539b7f` (Kontaktverwaltung in `sonec.agc`).
- **Implementiert:** Landung setzt die physische Bindung, Kollisionsreset löscht sie; Sprung/Jetpack lösen sie ausdrücklich. Vor der Kollision wird ein durch nicht-abhebende Aktionen verlorenes `Stand` bei bestehender Bindung wiederhergestellt; Boden-Seitengeometrie verwendet die Bindung statt nur das Animationsflag. Granatwerfer-Rückstoß und seine Geschwindigkeit bleiben unverändert. Welt-/Bildschirmpositionen bleiben Float; keine Division oder Rundung verändert.
- **Grenze:** Noch kein globaler Resolver; Plattformverlust ohne Rückstoß, Kistendurchfall und Gewehrfront weiterhin offen. Keine AGK-Kompilierung durch den Assistenten. Bei unerwarteten Stand-/Flugzuständen die konkrete Eingabe und Plattformbindung prüfen.
- **Knowledge Base (read-only geprüft):** `agk-knowledge-base/topics/timing-and-frame-rates.md` erklärt `1000.0 / Span` und die Gefahr von Integer-Division, aber nicht ausdrücklich, dass eine Float-Zielvariable allein ungenügend ist. Ergänzung dort braucht gesonderte Schreibfreigabe. Für korrekte Bruchteile Float-Operand **vor bzw. innerhalb** der Division verwenden, z. B. `mx / 2.0`; `(mx / 2) * 1.0` ist nicht zuverlässig, weil der Bruchteil bereits abgeschnitten sein kann.
- **Nächster Schritt:** Entwickler testet AGK-Compile, Rückstoß links/rechts an Kiste und auf Plattform, normalen Sprung/Jetpack, Abgang von Plattform-/Kistenkante, Seitenkontakte, Durchflug und Landungen.

## 41. Entwicklertest Bodenkontaktbindung und Präzisierung AGK-Division (24.11.2026)

- **Getesteter Code-Commit:** `71ed85e0f592a7d5fb2b259517db03891f539b7f`. Entwickler bestätigt **8/8**: AGK-Kompilierung, Granatwerfer-Rückstoß beidseitig an Kisten und auf Plattform, normaler Sprung, Jetpack, Kantenabgang, Seitenkontakt, Landungen/Durchflug. „Bestanden“ bezieht sich auf diese Prüfpunkte, **nicht auf die Fehlerfreiheit der Kollisionslogik**.
- **Unverändert beobachtet:** Mit Granatwerfer-Rückstoß kann Sonec **von links** weiterhin durch Kisten tunneln; gelegentliches Durchfallen durch Plattformen; insgesamt **keine merkliche Verhaltensänderung**. Ursachenzuordnung zur Bodenkontaktbindung nicht bestätigt. Kein weiterer Code-Fix auf Verdacht.
- **AGK-Division:** Entwickler weist darauf hin, dass AGK BASIC auf C/C++ basiert und die Auswertung von `(mx / 2) * 1.0` nicht isoliert verifiziert ist. Frühere definitive Einstufung als falsch wird **zurückgenommen**. Für kritische Berechnungen weiterhin gut lesbare explizite Float-Operanden wie `mx / 2.0` bevorzugen; dies ist eine vorsorgliche Schreibkonvention, kein Beweis über alle anderen Ausdrücke. Unterschiedliche Ausdrucksformen und tatsächliche Laufzeitergebnisse sind separat zu testen.
- **AGK Knowledge Base:** Mit ausdrücklichem Nutzerwunsch wurde **nur der Backlog** `agk-knowledge-base/TODO.md` präzisiert (Commit `e360c685d503de95a3f03a734c8fd5f9ac7f1685`); publizierter Timing-Artikel unverändert.
- **Nächster Fokus:** Reproduktionspfad linksseitiger Granatwerfer-Rückstoß und Verlust bereits bestehender Plattformstützung auf konkrete Bewegungs-/Kontaktzeitpunkte zurückführen; danach geplante gemeinsame Kontaktauflösung, keine Legacy-Sonderpatches.

## 42. Quellcode-Untersuchung: Kontaktfortsetzung nach Rückstoß und Plattformstützung (24.11.2026)

- **Basis:** `develop` bei `bbb65177cf8c39798f8335a5b6b0d3afdded3326`; statische Codeprüfung, **kein AGK-Laufzeittest** und keine neue Fehlerursache als bewiesen markiert.
- **Linksseitiger Granatwerfer-Rückstoß:** `SonecGrenadeLauncherInput` ändert `MoveSpeed.x` und ggf. `Alignment`, bei `Move = FALSE` auch `Stand = FALSE`. Die neue physische `GroundContactActive`-Bindung wird nicht gelöscht; `SonecCollidePlate` stellt `Stand` bei gültiger Bindung vor der Seitenprüfung wieder her. `SonecCollideChestSideContacts` verwendet für diesen Bodenkontakt eine vertikale Frontlinie, während `SonecMoveLimitChestWall` die persistierte Seitenblockierung im folgenden Bewegungsschritt weiterhin nur über die zwei Kreise validiert. Diese **Geometrie-Inkonsistenz** kann eine Blockierung vorzeitig löschen; konkrete Reproduktion/Verursachung noch offen. Zudem verlangen Seiten-Sweeps Richtungskombinationen aus Eigenbewegung und Relativbewegung; die linksseitige Rückstoßkonstellation gezielt testen.
- **Plattformkontakt:** `SonecCollidePlate` setzt bei bestehendem `Stand` und `TYPEPLATE` die Fußhöhe auf die aktuelle Plattformoberkante und setzt Kontakt bei deaktivierter Plattform oder horizontalem Verlassen zurück. Nach `SonecCollideReset` gibt es keine generelle ruhende Kontaktwiederaufnahme: Die B2-Landung verlangt `RelativeEndY > RelativeStartY`, `RelativeStartY <= 0`, `RelativeEndY >= 0` und horizontale Endposition innerhalb der Plattform. Ein einmal verlorener Kontakt kann damit bei waagerechter Bewegung oder bereits unterhalb der Oberkante nicht neu entstehen. **Ursache des sporadischen Kontaktverlusts noch nicht bestimmt**; Float-Ungenauigkeit nicht belegt.
- **Nächster Architekturbaustein (Vorschlag, noch nicht implementiert):** Einheitliche persistierte Seitenkontaktgeometrie für Bodenkontakt und Frontlinie (inkl. Rückstoß-Richtungswechsel) sowie explizite Validierung/Fortsetzung bestehender Plattformstützung vor der neuen Sweep-Landung. Kein Epsilon- oder Rundungsfix auf Verdacht und keine isolierte Legacy-Reparatur. Vor Code konkrete Kontaktregeln und Tests im nächsten Spezifikationsabschnitt festlegen.

## 43. Geplanter kleiner Implementierungsschritt: persistierte Seitenkontaktgeometrie (vor Code, 24.11.2026)

- **Umfang:** Nur die Validierung einer bereits gespeicherten Kisten-Seitenblockierung in `SonecMoveLimitChestWall`. Beim physisch gestützten Sonec (`GroundContactActive = TRUE`) dieselbe volle Körperhöhe wie beim B-K3-Frontlinien-Sweep prüfen: `centerY + height/2 > chestTop` und `centerY - height/2 < chestBottom`. Ohne physische Stützung bleibt die bisherige Zwei-Kreis-Prüfung. Die horizontale Kontaktposition, die Weltrand-Ausnahme, `BlockedChestSide`, `BlockedChestOffsetX` und das Abbremsen in die Wand bleiben erhalten.
- **Architekturabsicht:** Entstehung und Fortsetzung eines Seitenkontakts verwenden bei Bodenkontakt dieselbe vertikale Ausdehnung, statt einen B-K3-Kontakt mit einer anderen Form zu verwerfen. Kein Sonderfall für Granatwerfer, keine neue Float-Rundung oder Epsilon-Regel.
- **Nicht Teil:** Änderung der Seitensweep-Richtung bei Rückstoß, Plattformkontakt-Fortsetzung, globaler Kollisionsresolver, tatsächliche Waffenmündungsgeometrie. Der bekannte linksseitige Rückstoß-Tunnelfehler **kann** unverändert bleiben; aus dieser Änderung wird keine gesicherte Verbesserung abgeleitet.
- **Test:** AGK-Compile; im Stand von links/rechts gegen Kisten drücken und Kontakt halten; Granatwerfer-Rückstoß von links/rechts; Kiste auf bewegter Plattform; Flug-/Jetpack-Seitenkontakt; Kantenabgang, Sprung, Landung und Durchflug. Der Entwickler führt Laufzeittests aus.

## 44. Implementierung der persistierten Seitenkontaktgeometrie (24.11.2026)

- **Code-Commit:** `ec7da9340a302dd2a9440fea6606fd05ad2cf14f`, ausschließlich `source/sonec/sonec.agc`, `SonecMoveLimitChestWall`.
- **Code-reviewed:** Bei `GroundContactActive = TRUE` prüft die Kontaktfortsetzung die gesamte Körperhöhe gegen die Kistenhöhe, wie B-K3 beim Entstehen des Seitenkontakts. Bei `GroundContactActive = FALSE` bleibt die bisherige Zwei-Kreis-Prüfung. Die horizontale Blockierung und Bewegungsregeln sind unverändert; keine Koordinatenkonvertierung oder neue Rundung.
- **AGK-Compile/Runtime:** Offen, ausschließlich durch Entwickler testbar. Die bekannten sporadischen Plattform-/Kistendurchfälle sowie das linksseitige Granatwerfer-Tunneln sind **nicht als behoben markiert**. Nächster Schritt nach Testergebnis: Rückstoß-Richtungskombination und Plattformstützung getrennt untersuchen.

## 45. Entwicklertest persistierter Seitenkontakt und neue Reproduktionen (24.11.2026)

- **Getesteter Code:** `ec7da9340a302dd2a9440fea6606fd05ad2cf14f`. Entwickler meldet **8/8 Einzelprüfungen bestanden**, inklusive AGK-Kompilierung, beidseitigem Anlaufen/Halten an Kisten, beidseitigem Granatwerfer-Rückstoß, bewegter Plattform, Jetpack-/Flugseitenkontakt, Sprung/Kanten/Landung und Durchflug von unten. Keine Einzelprüfung offen.
- **Gesamtfehlerstatus: nicht bestanden / weiter offen.** Entwickler bestätigt weiterhin sporadisches Durchfallen durch Plattformen; Kistentunneln **nur links → rechts mit Granatwerfer**; Kistendurchflug **links → rechts bei Aktivierung des Fluges**; Kistendurchfall **rechts → links im Fallen, wenn deren Plattform zuletzt aktiv war**. Die neue Kontaktgeometrie ist damit kompiliert und grundlegend regressionsfrei, aber **nicht als Fehlerbehebung nachgewiesen**.
- **Architekturfolgen:** Rückstoß-/Jetpack-Übergang und `LinkedPlateIndex`-abhängige Kistenrelevanz anhand der vier konkreten Reproduktionen untersuchen. Besonders die Flugaktivierung darf die korrekte seitliche Kistenkollision nicht allein durch Geometriewechsel verlieren; persistierte Stützung und Landekandidaten müssen bei Plattformwechseln nachvollziehbar sein. Keine Epsilon-/Integer-Rundungsreparatur auf Verdacht.
- **Neue Bedienideen (nur Backlog, keine Implementierung):** Granatwerfer-Taste halten lädt einen regulären Granatenwurf mit ballistischer Flugbahn und von Haltedauer abhängiger Wurfstärke. Steuerkreuz hoch kurz tippen = Sprung; hoch halten = Jetpack nach kurzer Verzögerung. Details/Schwellen und Konflikte mit bestehender Jetpackenergie vor Umsetzung separat spezifizieren.
- **Nächster Arbeitsschritt:** gezielte Analyse des Flug-/Rückstoß-Übergangs und der Kistenrelevanz nach Plattformwechsel; keine automatische Freigabe eines weiteren Code-Fixes aus diesem Testergebnis.

## 46. Vor-Code-Festlegung: fremde Kisten beim Fallen von oben (24.11.2026)

- **Ziel:** `LinkedPlateIndex` darf eine geometrisch gültige Landung auf einer Kiste einer anderen Plattform nicht ausschließen. Kleiner Schritt im bestehenden B-K1/B-K2-Sweep, noch kein globaler Kontaktresolver.
- **Kandidatenregel:** Aktive Kisten der eigenen Ebene bleiben wie bisher relevant; im Jetpack-Flug bleibt die bestehende globale Relevanz erhalten. Für **fremde** aktive Kisten wird beim normalen Fallen (`State.Fall = TRUE`, `State.Fly = FALSE`) ein Kandidat nur dann zusätzlich zugelassen, wenn Sonecs Füße am Beginn des Sweeps **auf oder oberhalb der Kistenoberkante** liegen, jeweils mit Float-Weltpositionen und dem gespeicherten Kisten-Bewegungsstart. Damit kann die bestehende relative Fußkreuzungsprüfung die Landung auswerten und die bestehende Seitenprüfung Kontakte von oben erfassen. Unterhalb der Kistenoberkante bleibt die fremde Kiste für diesen Schritt durchlässig, insbesondere während des Aufstiegs von unten.
- **Unverändert:** Fremde Kisten während des Aufstiegs von unten werden nicht neu solid; `LinkedPlateIndex` ändert sich erst durch `SonecSetGroundContact` bei gültiger Landung; `PassThroughChestIndex`, Weltrand-Ausnahme, Kontaktpriorität und Bewegungszustände bleiben unverändert. Die vollständige plattformweite Durchflugregel und einheitliche globale Kontaktpriorität bleiben spätere Architekturarbeit.
- **Erwartung:** Eine Verbesserung des Fallens durch Kisten nach Wechsel der Tiefenebene ist plausibel und im nächsten Entwicklertest gezielt zu prüfen. Keine erwartete Behebung des Granatwerfer-/Jetpack-Seitentunnelns oder des Plattformdurchfalls.
- **Tests:** AGK-Compile; von anderer Plattform aus von oben auf fremde Kiste fallen (rechts→links und links→rechts, kleine/große Kisten); Aufstieg von unten durch fremde Plattform samt Kisten; normale Kistenlandung und Seitenkollision; Flug/Jetpack; bewegte Kiste/Plattform; Weltlinke.

## 47. Umsetzung und Teststatus: fremde Kisten von oben (24.11.2026)

- **Code:** `b9735b17e9550b4550be0a2f5132af5599f4094d` in `source/sonec/sonec.agc`, ausschließlich `SonecChestRelevant`. Bei fremder Kiste und `State.Fall = TRUE` wird zusätzlich `CollisionMoveStart.y + Size.Height*0.5 <= Chest.CollisionMoveStart.y` geprüft. Bestehende Fälle (eigene Ebene, Jetpack) unverändert. Das gilt für bestehende Seiten- und Landekandidaten, nicht nur eine einzelne Kisten-ID.
- **Grenze:** Eine fremde Kiste, deren Oberkante bereits vor dem Sweep oberhalb der Füße liegt, wird nicht neu erfasst. Plattformweite Durchflugfreigabe und einheitlicher Resolver weiterhin offen. Keine neuen Float-Konvertierungen, kein Epsilon.
- **Teststatus:** AGK-Kompilierung und Laufzeit **noch nicht ausgeführt**; Entwickler prüft besonders den rechts→links-Kistendurchfall nach anderer aktiver Plattform und den Durchflug von unten. Die übrigen bekannten Kollisionsfehler bleiben offen.

## 48. Entwicklertest fremde Kisten / offene Rand- und Seitenfehler (24.11.2026)

- **Code-Commit:** `b9735b17e9550b4550be0a2f5132af5599f4094d`. Entwickler bestätigt **8/8 Prüfpunkte**, einschließlich AGK-Kompilierung, beidseitigem Fall auf Kisten einer anderen Plattform, kleine/große Kisten, Durchflug von unten, gewöhnliche Seitenkollision, Jetpack, bewegte Kiste und linke Weltrandregel. Keine Testpunkte offen. Das ist **keine Abnahme der Gesamt-Kollisionsarchitektur**.
- **Beobachtungen:** Nahezu vertikales Fallen endet stabil auf Kisten; bei Kistenrändern bleibt Durchfallen bei beliebigem Anflugwinkel möglich. Beim Fallen von oben kann Sonec seitlich in Kisten eindringen. Durchflug von unten und anschließende Landung auf derselben Kiste funktionieren. Jetpack-Seitentunneln **links→rechts möglich**, **rechts→links nicht beobachtet**. Linke Weltrand-Sonderbehandlung funktioniert.
- **Interpretation:** Fremde Fallkisten werden nun berücksichtigt, aber Randkontakte/Seitenkontakte und ihre zeitliche Priorität bleiben ungeklärt. Die B-K1-Landung prüft derzeit die horizontale **Endposition** innerhalb der Kiste, nicht die horizontale Position zur relativen Kontaktzeit. Die B-K2-Top-/Seitenpriorität betrachtet nur die bereits ausgewählte Kiste; die Seitensweep-Prüfung nutzt getrennte Kontaktwege und Richtungsbedingungen. Das sind konkrete Architekturgrenzen, noch keine bewiesene Einzelursache jedes Falls.
- **Nächster Vorschlag (nicht implementiert):** Für Kisten-Seiten- und Oberseitenkontakt gemeinsame zeitbezogene Kandidaten bestimmen, Kontakt-X zum tatsächlichen Sweep-Zeitpunkt prüfen, frühesten gültigen Kontakt deterministisch auflösen; bestehenden Jetpack-Geometriewechsel gesondert berücksichtigen. Keine ad-hoc-Rand-Epsilon-Korrektur. Plattformkontakte später in denselben Resolver integrieren.

## 49. Vor-Code: gemeinsamer zeitbezogener Kisten-Oberseitenkandidat (24.11.2026)

- **Architektur-Inkrement K-T1:** Ein wiederverwendbarer Float-Helfer ermittelt für eine aktive Kiste den relativen Fuß-/Oberseiten-Kreuzungszeitpunkt im Intervall 0..1 und prüft die horizontale **Sonec-Mittelpunktposition zum Kontaktzeitpunkt** gegen die zur gleichen Zeit interpolierten Kistenkanten. Er liefert -1 bei keinem gültigen Kontakt. Bei gleicher Kontaktzeit bleibt Array-Reihenfolge maßgeblich. Die bestehende B-K1-Landung und die B-K2-Top-vor-Seite-Entscheidung verwenden denselben Kandidaten; dadurch kein divergierender End-X-Test mehr.
- **Kontaktdefinition:** Nur `State.Fall = TRUE` und `State.Stand = FALSE`, relative Füße am Start oberhalb/auf der Kiste, am Ende auf/unter der Kiste, streng positive relative Abwärtsbewegung. Relative Positionen und Kontaktzeit ausschließlich Float; keine neue Epsilon-Regel. Horizontale Überdeckung zunächst wie bisher über den Sonec-Mittelpunkt, aber zum Kontaktzeitpunkt. Bestehende `SonecChestRelevant`-/Durchflug-Ausnahmen bleiben davor erhalten.
- **Begrenzung:** Dies ist die gemeinsame Kandidatenbasis, **noch nicht** die endgültige einheitliche Auflösung aller Seiten-/Top-Kontakte. Die Seitenauflösung und globale Plattform-Priorität bleiben vorerst unverändert; insbesondere kann ein anderer Seitenkontakt vor der Top-Landung liegen. Der nächste Schritt nach Tests ist die gemeinsame zeitliche Priorisierung aller Kistenkontakte, nicht ein Sonderfix.
- **Tests:** AGK-Kompilierung; Randlandungen beidseitig bei langsamem/schnellem schrägem Fall, nahezu senkrechte Landung, von unten durch Kiste und anschließend landen, fremde Kisten, bewegte Kisten, Seitenkontakt beidseitig, Jetpack und linker Weltrand. **Erwartung:** Bei Randlandungen, bei denen Sonec den Rand während des Frames überquert, ist eine sichtbare Verbesserung möglich; kein Versprechen für alle Tunnelfehler.
