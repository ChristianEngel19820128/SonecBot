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
