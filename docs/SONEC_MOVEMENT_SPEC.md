# SonecBot – Spezifikation der Bewegungs- und Kollisionsphysik

**Stand:** 25. November 2026  
**Status:** A–G2d abgeschlossen und im vereinbarten Umfang lokal abgenommen.
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
- Die Zuordnung bleibt beim Springen, Fallen und Fliegen bestehen, solange der Körper horizontal mit der bisherigen Plattform überlappt; keine Löschung allein aufgrund einer Höhe.
- G2c: Bei vollständigem horizontalem Verlassen wird die Zuordnung auf -1 gelöst. Eine neue Zuordnung entsteht **erst bei gültiger Landung** auf einer Plattform oder ihrer Kiste.
- Beim Durchflug einer **fremden Plattform von unten** sind deren Boden **und sämtliche ihrer Kisten**, auch seitlich, vorübergehend durchlässig. Sonecs bisherige Ebene bleibt dabei bestehen.
- G2c: Durchflugausnahme bei horizontaler Plattformüberdeckung und Füßen unter der Plattform; außerhalb der Plattform keine pauschale Passage. Freigabehöhe ist die höchste Oberkante im dynamischen horizontalen Relevanzbereich (einschließlich Plattformoberkante), nicht die höchste Kiste der ganzen Plattform. Horizontale Distanz zur Kistenkante vorläufig 100 Welteinheiten. Freigabe bei relativer Höhenkreuzung oder Verlassen der Reichweite eines blockierenden Elements; aktuelle interpolierte Weltkoordinaten.

## 3. Landungen und gleichzeitige Kontakte

- Eine Landung ist nur bei einem gültigen **Kontakt von oben** möglich: Die Füße müssen die Oberfläche von oben erreichen und beim Abwärtsweg kreuzen. Dass nur der Kopf eine Höhe erreicht, genügt nicht.
- Plattformoberflächen und Oberseiten aktiver Kisten sind mögliche Landeflächen.
- Beim gültigen Landekontakt wird die Plattformzuordnung übernommen.
- Bei mehreren Kandidaten gewinnt der **früheste gültige Kontakt entlang des Wegs**. Bei gleicher Höhe gilt „first in“: die in Bewegungsrichtung zuerst erreichte gültige Fläche; exakte Gleichstände sind deterministisch aufzulösen.
- Hohe Fallgeschwindigkeit darf keine gültige Landung überspringen.
- Bereits vorhandener Bodenkontakt blockiert keine zulässige horizontale Bewegung.

## 4. Mechanische Kollisionsgeometrie

**G2c:** Direkter Seitenkontakt am Boden und in der Luft über die gespiegelte Frontlinie (±25). Am Boden bisherige vertikale Ausdehnung; in der Luft direkter Seitenkontakt bei Überdeckung des vertikalen Bereichs zwischen den Kreiszentren, Eck-/Unterseitenkontakte weiter über die zwei Körperkreise. Landung über Fußkontakt.

- Kein Teleport bei Geometriewechsel. Kleine begrenzte, erneut kollisionsgeprüfte Abstandskorrektur nach Landung erlaubt; kein zusätzlicher Geschwindigkeitsimpuls.
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
- **Technisches Modell Phase D (implementiert, im Entwicklertest 9/9 bestätigt):** `MoveSpeed` am Boden relativ zum Träger, in der Luft Weltgeschwindigkeit; `AutoSpeed` signierte Trägergeschwindigkeit in Einheiten des letzten Sonec-Timerschritts. Tatsächliche Trägertranslation aus Start-/Endposition pro GameDo addieren, auch beim Gegenlaufen; bei ausgelassenem Plattformtick exakt null. Bei Landung Welt-X in Träger-X umrechnen, beim Absprung/Abgang Trägergeschwindigkeit genau einmal übernehmen. Vertikale Absprungimpulse werden zum übernommenen Träger-Y addiert; Impulswerte unverändert. Wände begrenzen die relative Eintrittsgeschwindigkeit, auf derselben Plattform somit die Eigenbewegung. Restweg bereits in Weltkoordinaten, keine zweite Mitnahme. Der Umrechnungsmaßstab ist letzter `MoveTimer.CalcRange` (bei noch nicht erfolgtem Tick `Range`), nicht eine globale Zeitphysik; wechselnde Ticklängen können Unterschiede verursachen. Das Modell ist im bisherigen Spieltest bestätigt; zeitliche Feinabstimmung bleibt der Integration vorbehalten.
- **Einzige ausdrücklich vereinbarte Kisten-Durchdringung am Weltrand:** Wenn eine weiter nach links fahrende Kiste Sonec am linken Weltrand erreicht und er nicht weiter ausweichen kann, darf die Kiste ihn durchdringen. Kein Verschieben aus der Welt und kein Teleport.
- Plattform-Richtungswechsel sind derzeit nicht vorgesehen; mögliche Bossmechaniken werden später separat entworfen.

## 7. Springen und Schwerkraft

- Der normale Sprung ist wie ein **Weitsprung**: ein einmaliger vertikaler Impuls; der horizontale Anlauf bestimmt den Schwung.
- G2d-1: Während des normalen Sprungs ist eine schwache energieunabhängige horizontale Korrektur zulässig (0.001 Beschleunigung, 1.5 Richtungsgrenze). Ohne Eingabe bleibt Schwung erhalten; vorhandenes stärkeres Momentum wird nicht abrupt gekappt.
- Die Schwerkraft wirkt weiter und hebt den anfänglichen vertikalen Impuls allmählich auf.
- Seitenkontakte beenden den Sprung nicht und setzen keine Bodenhaltung.

## 8. Mini-Hop beim Verlassen einer Kistenkante

- Beim Überstehen eines Fußes beim Verlassen einer Kistenkante einmaliger Mini-Hop; an Plattformkanten normaler Fall. Einfüßige Kistenrandlandung: relativ nach innen oder ohne Bewegung Ausgleichsschritt, relativ nach außen Mini-Hop. Bei beiden Füßen auf Fläche normale Landung; ohne Fußkontakt keine Landung.
- Ein kleiner **vertikaler Impuls** unterstützt den Übergang.
- Ist die horizontale Geschwindigkeit für ein korrektes Verlassen der Kante zu gering, kommt ein **zusätzlicher horizontaler Impuls in Bewegungsrichtung** hinzu.
- Wiederholte Impulse für denselben Kantenübergang sind ausgeschlossen.
- Die Impulse sind zentral parametriert; einmalige Trägerübernahme und erneute Restwegprüfung.

## 9. Jetpack, Energie und Eingaben

- Jetpack-Schub muss die Schwerkraft überwinden; `Fly` allein darf Sonec nicht nach oben teleportieren.
- Verfügbare Energie bestimmt, ob der Schub eingesetzt werden kann.
- **G2d-1-Eingaberegel (erweitert G2b):** Neuer Hoch-Druck bei tatsächlichem Bodenkontakt löst immer zunächst einen normalen Sprung aus, unabhängig von Energie. Nur derselbe gehaltene Druck wartet `SONEC_JETPACK_HOLD_MS` (180 ms); neuer Druck im freien Fall/Flug oder nach Loslassen im Sprung ohne zusätzliche Wartezeit. Ausstehender Sprungimpuls zuerst konsumieren. Energieaufnahme während Halten aktiviert Jetpack bei erfüllten Bedingungen. Loslassen beendet Schub, gehaltenes Hoch nach Landung erzeugt keinen neuen normalen Sprung. Action-Key-Binding und Joystick-Achse bleiben.
- Beim Übergang soll vorhandene Bewegung nicht ohne Grund zurückgesetzt werden.
- Die frühere Doppeldruck-Idee ist durch die abgestimmte Tippen/Halten-Regel ersetzt; keine zweite separate Eingabemechanik.

## 10. Zustandsmodell

Bisher können mehrere Bool-Werte gleichzeitig wahr sein; verschachtelte `if`-Abfragen entscheiden stellenweise über ihre Priorität.

Das Zustandsmodell unterscheidet:
- **Eingaben/Aktionen:** Laufwunsch, Sprungimpuls, Jetpack-Schub.
- **Physikalische Eigenschaften:** tatsächlicher Bodenkontakt, Geschwindigkeiten, Tiefenebene.
- **Kontaktergebnisse:** Landung, seitliche Blockade, tragende Oberfläche.

Bestehende Begriffe und Beziehungen:
- `Stand` und `Duck`: unterschiedliche, gegenseitig ausgeschlossene Haltungen.
- `Fall` und `Fly`: unterschiedliche, gegenseitig ausgeschlossene Bewegungszustände.
- `Jump`: einmaliger Impuls, kein dauerhafter Schub.
- `Back` und `Forward`: Richtungen relativ zur Ausrichtung.

Die Bool-Werte müssen nicht pauschal entfernt werden. Entscheidend ist, dass versteckte Prioritäten nicht zu widersprüchlichen physikalischen Ergebnissen führen. Die **tatsächliche Bodenberührung**, nicht bloß ein priorisierter Bool-Wert, bestimmt die mechanische Kollisionsgeometrie.

## 11. Technischer Entwurf (implementiert)

1. Eingaben, Kräfte und einmalige Impulse auswerten.
2. Geplante Sonec-, Plattform- und Kistenbewegungen für den Frame bestimmen.
3. Anhand der Tiefenebene und aktiver Durchflugphase gültige Kollisionskandidaten wählen.
4. Frühesten Kontakt entlang der **relativen Bewegungswege** bestimmen (Swept Collision).
5. Nur die betroffene Bewegungskomponente begrenzen; verbleibende Bewegung gegebenenfalls erneut prüfen.
6. Position, Bodenkontakt, Trägeroberfläche, Tiefenebene und übrige Zustände konsistent aktualisieren.

Vermeiden: mehrere unabhängige Routinen, die nacheinander dieselbe Position korrigieren und sich gegenseitig überschreiben. Der gemeinsame Resolver ist in den AGK-Updatezyklus integriert.

## 12. Ergänzende endgültige Regeln

- Eingaben einschließlich Waffen, Schild und Hover bis zum vollständigen Welteintritt sperren; passive Simulation bleibt.
- Schwerkraft wirkt auch bei Jetpack; Bruttoschub getrennt, Fall kontinuierlich abbremsen. Geschwindigkeitsgrenzen begrenzen zusätzliche Beschleunigung, kein abruptes Abschneiden vorhandenen Momentums.
- Granatwerferrückstoß einmalig additiv entgegen Schussrichtung, Richtungsumkehr möglich, keine Änderung der Eingabeflags; aktive Randbalance endet.
- Fußhalbabstand 8 (bei schmalen Flächen höchstens 45 % der Breite); Plattformlandung nur im stabilen Fußbereich. Kistenrandentscheidung nach relativem Restweg, bei null nach relativer Geschwindigkeit. Ausgleichsschritt durch bewusste Eingabe abbrechbar.
- Begrenzte horizontale Abstandskorrektur nach Landung: 1 Welteinheit je Kollisionsframe, erneut prüfen. Frühere Eckkontakte haben Vorrang vor späterer Frontlinie.
- Optionaler horizontaler Mindestimpuls beim Absprung bleibt deaktiviert; bei Aktivierung nur bei eindeutiger Richtung und ohne entgegenstehenden Schwung.
- Normale Sprungkorrektur ohne Energie/Jetfire, beide Richtungen neutral; Landung oder tatsächlicher Jetpack-Einsatz beendet Korrektur.
- Aktuelle Parameter im zentralen Konstantenblock von `source/sonec/sonec.agc`; keine zweite verbindliche Wertetabelle. Jetstream-Zwischenpartikel rein visuell, Energieabzug nur reguläre erfolgreiche Emission.

## 13. Abschluss und Testevidenz

- A lokal geprüft; B gemeinsamer Resolver und Restweg, Compile `18a6154`; C Nachtest `b1a21dd` 5/5.
- D `36a7f23` 9/9, Jetpack-Nachkorrektur `be7dc31` 6/6; E `f2acaae` 9/9; F `f4424a1` 9/9.
- G1 `093c173` 9/9 angekreuzt, normale Sprünge laut Freitext nicht gezielt prüfbar. G2a `a41162c` 8/8, G2b `6c53fac` 11/11, G2c `d87a2f6` 13/13, G2d-1 `3e6e07c` 8/8. Jetstream `4cba3e3` 7/7; Entwicklerparameter `ffe2e39`, `43f4a35` akzeptiert.
- Entwicklerabnahme 25.11.2026: Ziele erreicht. Keine separate Langzeit-/HTML5-Abnahme oder vollständige Einzelmatrix (u.a. Energiezufluss während Halten, konkurrierende Kandidaten) behauptet. Keine akute Bewegungsaufgabe.
- CSV-Diagnose bleibt unter Debug-Schaltern verfügbar; Messmethode bei Bedarf validieren. Alte sichtbare Hop-Anzeige entfernt.
- Historische Detailentscheidungen, Testprotokolle und Diagnoseschema vollständig im [Stand vor Konsolidierung](https://github.com/ChristianEngel19820128/SonecBot/blob/0ba2ee8c665325f25a9e7da38a86c9ca49cb7e5a/docs/SONEC_MOVEMENT_SPEC.md). Arbeitsregeln jetzt zentral in AGENTS.md.

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

