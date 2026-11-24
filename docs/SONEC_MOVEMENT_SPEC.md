# SonecBot – Spezifikation der Bewegungs- und Kollisionsphysik

**Stand:** 24. November 2026  
**Status:** Fachlich freigegebenes Ziel für die erste Implementierung (Phasen A–G); Umsetzung in zusammenhängenden Arbeitspaketen auf `develop`, mit statischer Prüfung und gebündelten lokalen Entwicklertests  
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
- **Phase-E-Implementierung:** Jede aktive Plattform hält ihren eigenen `SonecDepthState` (neutral, Passage, freigegeben); bei Neuerstellung zurückgesetzt. Fremde Ebene mit Füßen unter Plattformoberkante wird als Passage behandelt, unabhängig von X-Überdeckung (bewusste einfache Erstregel). Passage bleibt bis zur Freigabe oberhalb der höchsten aktiven Kiste bestehen, bei kistenloser Plattform bis zur Plattformoberkante. Höhe aus Weltkoordinaten am absoluten Frame-Start/-Ende; Freigabe als nichtblockierendes zeitliches Ereignis im gemeinsamen Resolver. Nach Freigabe bleiben Fremdkistenseiten im ungestützten Flug/Fall relevant, bis die Füße wieder unter die Plattform gelangen. Neutrale fremde Oberseiten bleiben für gültige Landungen verfügbar, fremde Seiten am Boden nicht. Keine pauschale Jetpack-Relevanz. Eigene Ebene bleibt solid; bisherige Einzelkisten-Unterseiten-Ausnahme nur für Kiste der eigenen Ebene erhalten. `LinkedPlateIndex` wechselt nur bei Landung, ungültiger gelöschter Eintrag wird auf -1 gesetzt. Technische Höhen-Toleranz 0,0001 Welteinheiten; mehrere Gruppen unabhängig. 22 übersetzte Zustands-/Zeitrechenfälle und statische Struktur-/Geometrievergleiche bestanden. Entwicklertest `f2acaae142b778be75466b8c95a0ebbb89f58589` (24.11.2026, AGK Studio) 9/9 bestanden: Compile, fremde Plattform von unten, fremde Kisten beidseitig durchlässig, keine vorzeitige Landung, Landung nach vollständigem Durchflug, eigene Kisten nach Landung, mehrere unabhängige Gruppen, Jetpack-Landungen, Mitnahme und Seitenkontakt. Beobachtungen: Übernahmeregel situationsabhängig unfair, noch nicht genau beschreibbar; vertikale Plattformbewegung scheint nicht aktualisiert. Hypothese zum Spielgefühl: weit entfernte hohe Kiste kann nach Aufstieg eine lokal freie Landefläche weiterhin sperren. Keine neue Designentscheidung. Quellprüfung: `PlateMove` aktualisiert Y bei `YShift.Enabled`, `ChestMoveAll` folgt vor `SonecCollidePlate`; `SonecPrepareSupportPath` nutzt aktuelle Oberflächen-Y, `SonecDepthHighestTop` und `SonecDepthRefresh` interpolieren die Y-Snapshots. Vertikale Aktualisierung ist somit quellsichtlich vorgesehen, tatsächlicher Laufzeitbefund und betroffener Pfad offen. `SonecCarrierVelocity` benutzt die aktuelle YShift-Richtung und nominelle Geschwindigkeit, nicht den tatsächlich begrenzten Y-Weg; an Umkehrpunkten kann das von der letzten Verschiebung abweichen. Keine nachgewiesene Ursache der Beobachtung. Entwickler konkretisiert: Bei vertikal bewegter potenzieller Plattform scheint deren absoluter Abstand für die Übernahmeregel nicht aktualisiert bzw. gespeichert; Plattform unter Umständen nicht betretbar, obwohl aktuell weit oben. Gemeint ist die Übernahmeberechtigung, nicht das Ausbleiben der Plattformbewegung selbst. Quellbefund am HEAD `1fda9ba`: `PlateMove` und `ChestMove` aktualisieren Y-Snapshots vor `SonecCollidePlate`; `SonecDepthHighestTop` berechnet aktuelle Start-/Endhöhen. `SonecDepthRefresh` speichert dagegen `PASSAGE` bei Füßen unter Plattformoberkante auch ohne horizontale Nähe und behält den Zustand im Höhenband zwischen Plattform und höchster Kiste bei. Ein gültiger relativer Fußkontakt wird bei PASSAGE vorab ausgefiltert. Beispielrechnung (keine Laufzeitdiagnose): Füße Y=120, Plattform Y=100 -> PASSAGE; später Füße Y=70, Plattform Y=90, höchste Kiste Y=50 -> PASSAGE bleibt; erst Füße Y<=50 geben frei. Vertikale Plattformbewegung allein kann die gespeicherte Passage daher nicht zwingend aufheben, obwohl aktuelle Höhen verwendet werden. Bei Füßen oberhalb aktueller höchster Kiste müsste die Freigabe erfolgen; falls nicht, konkrete Laufzeitdaten erforderlich. Vorschlag: gezielte Diagnose der betroffenen Fremdplattform mit Fuß-/Plattform-/Kistenhöhe, Status und relativer Fußkreuzung; erst dann entscheiden, ob Eintritt/Ende der Passage geändert werden soll. Keine Codeänderung aus dem Testbericht.

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
- **Technisches Modell Phase D (implementiert, im Entwicklertest 9/9 bestätigt):** `MoveSpeed` am Boden relativ zum Träger, in der Luft Weltgeschwindigkeit; `AutoSpeed` signierte Trägergeschwindigkeit in Einheiten des letzten Sonec-Timerschritts. Tatsächliche Trägertranslation aus Start-/Endposition pro GameDo addieren, auch beim Gegenlaufen; bei ausgelassenem Plattformtick exakt null. Bei Landung Welt-X in Träger-X umrechnen, beim Absprung/Abgang Trägergeschwindigkeit genau einmal übernehmen. Vertikale Absprungimpulse werden zum übernommenen Träger-Y addiert; Impulswerte unverändert. Wände begrenzen die relative Eintrittsgeschwindigkeit, auf derselben Plattform somit die Eigenbewegung. Restweg bereits in Weltkoordinaten, keine zweite Mitnahme. Der Umrechnungsmaßstab ist letzter `MoveTimer.CalcRange` (bei noch nicht erfolgtem Tick `Range`), nicht eine globale Zeitphysik; wechselnde Ticklängen können Unterschiede verursachen. Das Modell ist im bisherigen Spieltest bestätigt; zeitliche Feinabstimmung bleibt der Integration vorbehalten.
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
- **Phase-F-Implementierung:** `SonecSupportExitTime` liefert tatsächlichen relativen Kantenabgang (Mittelpunktgrenze unverändert). Nur gewähltes Support-Exit-Ereignis Kind 4 auf Kiste ruft `SonecFinishChestEdge` auf; keine Vorab-/Frame-End-Auslösung, unabhängig von Eingabe, Blickrichtung, Ducken oder Anfangsgeschwindigkeit, auch nach Landung im selben Frame. Richtung aus tatsächlicher Kante. `SONEC_MINI_HOP_IMPULSE_Y=1.5` (bisheriger Wert), `SONEC_MINI_HOP_MIN_RELATIVE_X=1.0` (vorläufiger Testwert). Nur fehlenden relativen X-Anteil ergänzen, schnellere Bewegung erhalten. `SonecCollideReset` überträgt Trägergeschwindigkeit einmalig und löst Support, vertikaler Impuls wird addiert. Nur Impulsänderung auf Restweg anwenden, Weltgrenzen beachten, Restweg im Resolver prüfen. Normale Plattformkante ohne Hop; Sprung/Jetpack löst Support vorher. 22 übersetzte Richtungs-/Impuls-/Restwegfälle und statischer Funktionsvergleich bestanden. Entwicklertest `f4424a1cf78515196e042bd844314870085e7751` (24.11.2026, AGK Studio): 9/9 bestanden (Compile, langsame und schnelle Hops beidseitig, Ausrollen ohne aktive Richtung, keine vorzeitige/mehrfache Auslösung, bewegte Kisten, normale Sprünge/Plattformkanten, Landungen/Seitenkontakte/Weltrand). Zusatzbeobachtung: beim Fallen über den Spritemittelpunkt auf eine Kiste etwa halbe vertikale Durchdringung, scheinbar keine Kollision/kein Hop. G-Prüfbedarf: genaue Mittelpunktlage bei relativer Fußkreuzung, eigene oder fremde Ebene, Bodenstatus. Quellbefund: `SonecChestTopContactTime` verwirft Kontakt bei X <= linke oder X >= rechte Kistenkante; bloße Körperüberdeckung genügt nicht. `SonecSupportExitTime` und Hop benötigen bestehenden Kistensupport; ohne Landung kein Hop. Mögliche Erklärung, nicht nachgewiesene Laufzeitursache; Passagefilter oder Kontaktreihenfolge ebenfalls prüfen, falls Mittelpunkt innerhalb lag. Keine automatische Ausweitung der Landefläche; Soll für Randkontakte gemeinsam entscheiden. Phase F im getesteten Umfang bestätigt; Zusatzbefund in G offen.

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
- Eventuelle spätere elementweise Durchflugprüfung statt pauschaler Höhenregel. Gemeinsam beschlossen: E-Regel bis vollständiger Bewegungsimplementierung unverändert lassen; beide E-Beobachtungen im G-Gesamtspieltest gezielt untersuchen (Fuß-/Plattform-/Kistenhöhe, Passagezustand, relative Fußkreuzung), danach Regeländerung entscheiden.

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

**AGK-Kompilierung und Laufzeittests erfolgen lokal durch den Entwickler. Die fachliche Freigabe für die Erstimplementierung A–G liegt vor; jede spätere fachliche Regeländerung wird vor der betreffenden Umsetzung hier nachgeführt.**

### Aktuell verbindlicher Arbeitsmodus (24.11.2026)

- Zusammenhängende technische Teilschritte innerhalb des vereinbarten Umfangs als sinnvolles Arbeitspaket umsetzen; Commits nach nachvollziehbaren technischen Grenzen, betroffene Dokumentation gemeinsam mit der Änderung aktualisieren.
- Statische Quellprüfung während der Umsetzung; keine obligatorische lokale Kompilierung nach jedem vorbereitenden Teilschritt. AGK-Compile am sinnvollen Paketende bündeln, sofern kein früherer Test für die weitere Umsetzung erforderlich ist.
- Funktionstests nur für aussagekräftige, tatsächlich prüfbare Verhaltensänderungen oder relevante Regressionen. Am Phasenende gemeinsam bewerten, ob ein eigenständiger Funktionstest sinnvoll ist; andernfalls den nächsten geeigneten Prüfpunkt festlegen.
- Innerhalb des freigegebenen Pakets ohne weitere Zwischenfreigaben fortfahren. Neue Designentscheidungen oder wesentliche Umfangserweiterungen vorher abstimmen.
- Implementierung, statische Prüfung, tatsächliche AGK-Kompilierung und funktionale Abnahme getrennt dokumentieren. Ausstehende Prüfungen nicht als bestanden behandeln.
- Phase-B-Paket: B3h, gemeinsamer Kontaktresolver und Restwegprüfung sind im aktuellen Code zusammengeführt. Gemeinsamer AGK-Compile für `18a615427c5e0d79fa3d5f773e79093b84e2ac04` am 24.11.2026 durch Entwickler in AGK Studio als bestanden bestätigt. Beobachtung: Spiel verhält sich nachvollziehbar für den aktuellen Stand. Anschließender Entwicklertest auf diesem Code-Stand: Fall aus großer Höhe bei maximal beobachteter Schwerkraftgeschwindigkeit und Plattformrandlandung ohne Tunneln; äußeres Bein kann überstehen, ab Sprite-Mittelpunkt Kante verlassen/nicht landen, für aktuellen Stand erwartet. Kistenkontakt beim Laufen und Springen/Fallen links nach rechts tunnelt, rechts nach links blockiert. Bewegung und Sprung direkt vor der Kiste blockieren in beiden Richtungen. Kistenoberseitenlandung bei maximaler Fallgeschwindigkeit sowie gezielte Kontaktreihenfolge/Restbewegung nicht separat bestätigt. Keine vollständige funktionale Abnahme.
- Quellbefund zum Test: `SonecFindChestContact` ermittelt Seitenkreuzung relativ zur bewegten Kiste; `SonecResolveContact` (Kind 2) begrenzt Ziel-X erneut auf den bereits erreichten Kontakt-X bzw. den restlichen Eigenweg. Da `PlateMove` Plattformen nach links verschiebt und `ChestMove` folgt, kann die linke Kistenkante am Frame-Ende links vom Kontakt-X liegen. Die Begrenzung lässt dann eine Überlappung zu; im Folgeframe verlangt der Ground-Sweep erneut einen Start außerhalb. Hypothese für Richtungsasymmetrie, nicht per Laufzeitdiagnose bewiesen. Vorschlag: in Phase C Seitenreaktion und bestehende Überlappungen konsistent behandeln, Mitnahme/relative Wandbewegung mit Phase D abstimmen, offene Kontaktreihenfolge und Restbewegung gemeinsam regressionsprüfen. Keine neue Codefreigabe aus dem Testbericht ableiten.
- Phase C: mechanische Frontlinie in `SonecMechanicalFrontOffset` mit `SONEC_MECHANICAL_FRONT_X=25` (vorläufige technische Orientierung am vorhandenen MG-Geschossstart), volle bestehende physikalische Höhe, spiegelbildlich für relative Eintrittsrichtung. In der Luft unveränderte zwei Körperkreise und Sweep. Kandidaten verwenden relative X-Bewegung auch bei passiv entgegenkommender Kiste. Bei Seitenkontakt wird der verbleibende Wandweg berücksichtigt; nur eigene Geschwindigkeit in die Wand hinein wird gelöscht. Bei bereits überlappender Frontlinie wird der vorhandene Abstand gehalten, nicht auf den neuen Geometrieabstand teleportiert. Linker Weltrand begrenzt den Weg; an der Grenze darf die links fahrende Kiste passieren. Kein vorgezogener separater Wandstop. Technische Toleranz 0,0001 Welteinheiten für relative X-Bewegung. Statische Block-/Aufrufprüfung und acht übersetzte Rechenfälle der Bodenformel bestanden; kein AGK-Lauf. Entwicklertest `0d0d7a03a237c52b6ed6e0d149d5820530b67dab` (24.11.2026, AGK Studio): Gesamtergebnis Auffälligkeiten/Fehler, 8/9 Prüfpunkte bestätigt. Bestätigt: Compile; Laufen beidseitig ohne Tunneln; Gewehrabstand; direkter Kontakt und Gegenlenken; vertikale Restbewegung; kein Positionssprung beim Geometriewechsel; linker Weltrand; schnelle Plattform- und Kistenlandungen. Zusammengesetzter Luft-Prüfpunkt teilweise bestätigt: Springen beidseitig Kollision, Fallen beidseitig Hineinbewegen in Kisten. Zusätzlich optisch kleiner Rückversatz beim Lauf von rechts nach links; Entwickler vermutet Zusammenhang mit linker Plattformbewegung, nicht gemessen. Keine vollständige B/C-Abnahme.
- Quellbefund zu den Restfehlern: `SonecChestRelevant` lässt fremde Fallkisten nur solange zu, wie die Füße am Segmentstart auf/oberhalb der Kistenoberkante liegen; ein seitlicher Kontakt kann danach aus dem Filter fallen. Auch bei eigener Ebene kann der Luft-Sweep einen ersten überwiegend vertikalen Eckkontakt ohne gültige Fußlandung verwerfen (`SonecFindChestContact`, Normalenklassifikation); spätere seitliche Annäherung innerhalb des Segments wird dann nicht gesondert ermittelt. Beide sind mögliche Ursachen, nicht nachgewiesene Laufzeitursachen. Entwickler konkretisiert: Sonec stand und landete mehrfach auf der Plattform, der die Kiste zugeordnet ist. Damit eigene Ebene als Ausgangspunkt plausibel; kein Nachweis eines gelöschten Ebenenindex. Phase-C-Nachkorrektur: Beim Fallen wird ein oberer Eckkontakt mit horizontaler Eintrittskomponente auch bei überwiegend vertikaler Normalenrichtung als Seitenkandidat berücksichtigt. Frühere/zeitgleiche gültige Fußlandung behält Vorrang. Bereits erreichter Seitenrand mit Nullnormaler bei t=0 begrenzt weitere horizontale Eintrittsbewegung ohne Positionssprung. Unterseitenregel und Bodenlinie unverändert. Neun übersetzte Rechenfälle zur Klassifikation bestanden. Entwicklertest `b1a21dd24cd1ac37b7685c465648aa514385043d` (24.11.2026, AGK Studio) 5/5 bestanden: Compile, Fallen beidseitig, Springen beidseitig, Landungen und Unterseitendurchflug. Grundverhalten vom Entwickler als bestanden bewertet. Beobachtung: Luft-Gewehrüberdeckung links beim Springen/Fallen unterschiedlich weit, rechts nach links nicht beobachtet; Bodenabstand und direkter Kontakt korrekt. Entwickler vermutet Kreisgeometrie bzw. links bewegte Kiste. Luft-Körperkreise decken den Gewehrlauf nicht zwingend ab; das ist gemäß Abschnitt 4 beabsichtigt. Ursache der Richtungsdifferenz nicht bewiesen, in D beobachten. B/C-Grundverhalten bestätigt; gezielte Kontaktreihenfolge-/Restwegfälle nicht separat gemeldet und bleiben Integrationsprüfung. Rückversatz: Resolver folgt verbleibendem Wandweg und löscht eigene Bewegung in die Wand; `SonecPrepareSupportPath` wechselt weiterhin zwischen Eigenweg und altem Mitnahme-Offset. Ob der beobachtete Rückversatz tatsächlich Welt-X, relative Position oder Übergang der Mitnahme ist, bleibt ohne Messung offen. Rückversatz separat in Phase D prüfen; keine Mitnahmeänderung in der C-Nachkorrektur. Plattformmitnahme/Übernahme Weltgeschwindigkeit und Sprungsteuerung sind weiterhin Folgearbeit; keine Änderung der Schadens-Hitboxen oder Waffen.
- Phase D: `SonecPrepareSupportPath` addiert tatsächliches X-Delta des Trägers an den Eigenweg und folgt seiner Oberfläche in Y; kein Wechsel zwischen Offset-Snap bei Stillstand und Eigenweg beim Laufen. Balanceziel folgt derselben Translation. Welt-X-Grenze nach Addition; Bewegung weg von der Grenze bleibt erhalten. `SonecReleaseSupportMotion` überträgt `AutoSpeed` einmalig bei Sprung/Jetpack/Stützverlust, `SonecSetGroundContact` rechnet X bei Landung in Trägerbezug um. `SonecResolveContact` begrenzt Eintrittsgeschwindigkeit relativ zu Wand und Träger. Geometrie, Kandidatensuche, Schadensfunktionen, Input-/Schubregeln und Mini-Hop-Schwellen unverändert; kein globaler Timer-Umbau. 15 übersetzte Rechenfälle und statische Struktur-/Geometrievergleiche bestanden. Entwicklertest `36a7f234516402666c998bbb79edde495a1b43e5`: Gesamtergebnis bestanden, 9/9 bestätigt (AGK-Compile, Mitnahme auf Plattform/Kiste, Lauf links, Gegenlauf rechts, Absprung ohne horizontalen Geschwindigkeitssprung, beidseitiger Laufkontakt ohne Zurückwerfen, Luftkontakt, linker Weltrand, Plattform-/Kistenlandungen). Luft-Gewehrüberdeckung nicht separat rückgemeldet. Neuer Sonderfall: bei schnellem Fallen und aktiviertem Jetpack vor Ausgleich der Fallgeschwindigkeit kann Sonec durch Plattformen fallen. Quellbefund: `SonecInputVerticalState` setzt sofort Fly=TRUE/Fall=FALSE; `SonecFindContact` und `SonecChestTopContactTime` verlangen Fall=TRUE, obwohl die vorhandene relative Fußkreuzungsprüfung eine tatsächliche Abwärtskreuzung unabhängig vom Eingabeflag ermitteln kann. `SonecSetGroundContact` löscht Fly derzeit nicht. Jetpack-Nachkorrektur vor E implementiert: `SonecFindContact` und `SonecChestTopContactTime` geben Oberseitenkandidaten bei fehlendem `GroundContactActive` frei statt anhand von Stand/Fall-Flags. Bestehende relative Fußkreuzungsformel, X-Prüfung zur Kontaktzeit, Kandidatenreihenfolge, Kistenrelevanz und Pass-through-Filter unverändert. `SonecSetGroundContact` setzt Fly=FALSE zusätzlich zu Fall=FALSE/Stand=TRUE. Gehaltenes Up wird beim nächsten regulären Input-Tick wie bisher geprüft, normale Aktivierungsenergiekosten bleiben erhalten. Neun übersetzte Rechenfälle und statische Strukturprüfung bestanden. Entwicklertest `be7dc311bb564f3fd6e1d47554664d0a9ef089dd` 6/6 bestanden: AGK-Compile, schnelle Jetpack-Landung auf Plattform und Kiste ohne Tunneln, erneutes Abheben bei gehaltenem Up, normale Landungen, Durchflug von unten. Keine weiteren Beobachtungen. Phase D einschließlich Nachkorrektur im getesteten Umfang abgeschlossen; Phase E folgt nach gemeinsamer Freigabe. Zusätzlich begrenzt `SonecMoveVerticalSpeed` im Fly-Zweig aktuell beide Vorzeichen auf Maximalbetrag, was separat bei Schub-/Kräfteabstimmung zu beachten ist. Keine Änderung an Schubwerten, Energiekosten, Timer oder Plattformmitnahmemodell in der Nachkorrektur.
- Aktuelle Implementierung: `SonecFindContact` wählt den frühesten vollständigen Kandidaten (Oberseiten vor Seiten bei Gleichstand); `SonecResolveContact` ändert den betroffenen Bewegungsanteil und setzt die absolute Segmentzeit fort. Hindernisstartpositionen bleiben unverändert, Restwegkandidaten verwenden die interpolierte Position. Durchflugeintritt der eigenen Kiste, fremde Höhenfreigabe und Stützverlust sind geordnete Ereignisse. Maximal acht mechanische Kontakte je Frame plus Platz für je ein Freigabeereignis pro Plattformslot; bei Erschöpfung keine ungeprüfte Restbewegung. Bestehende Mitnahme, Kanten-Hop-Regel und Hitbox-Geometrie bleiben Übergangsregeln der Folgephasen; insbesondere keine neue Luftbeschleunigungsregel. Alte getrennte Kisten-/Plattformlandungsresolver entfernt. Statische Prüfung: Funktions-/Blockstruktur und alte Aufrufpfade; kein AGK-Lauf. Verhalten noch nicht abgenommen.
- Die folgenden historischen Abschnitte dokumentieren damalige Entscheidungen, Implementierungen und Testergebnisse. Frühere Anweisungen zu Einzel-Compiles, Zwischenfreigaben oder Teststopps sind keine aktuellen Arbeitsaufträge; bei Widersprüchen gilt dieser Arbeitsmodus. Fachliche Regeln und historische Testevidenz bleiben unverändert. Allgemeine Repository-Regeln in AGENTS.md bleiben unverändert.

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

## 50. Umsetzung K-T1 und offener Entwicklertest (24.11.2026)

- **Code:** `8d9e00822ee70248561e2837750650ceb1cf8fbb` auf `develop`. Neuer Helfer `SonecChestTopContactTime` liefert bei gültiger relativer Fußkreuzung die Float-Kontaktzeit und prüft die horizontalen Positionen von Sonec und bewegter Kiste **zum selben Zeitpunkt**. `SonecCollideChestHorizontal` (B-K1) und die B-K2-Top-vor-Seite-Entscheidung verwenden diesen Helfer.
- **Unverändert:** Kisten-Seiten-Sweep, Auflösung, Plattform-Sweep, Kistenrelevanz, Durchflugausnahme, linker Weltrand, Landepose und Balance-Schritt. Die Gesamtpriorität über alle Kisten/Plattformen ist noch nicht vereinheitlicht; Seitenkontakt anderer Kisten kann weiterhin vor einer Top-Landung ausgewertet werden.
- **Status:** Quelländerung vorgenommen, **AGK-Compile und Laufzeit offen**. Entwickler soll vor allem schräges Fallen auf Kistenränder aus beiden Richtungen prüfen. Ein mögliches geändertes Verhalten an Rändern ist erwartet, aber noch nicht bestätigt; Jetpack-Tunneln und Plattformdurchfall sind nicht als behoben markiert.

## 51. Entwicklertest K-T1: Kontakt-X zur Kreuzungszeit (24.11.2026)

- **Getesteter Code:** `8d9e00822ee70248561e2837750650ceb1cf8fbb`. Entwickler bestätigt **10/10 Prüfpunkte**, einschließlich AGK-Kompilierung, schräger Randlandung links→rechts und rechts→links, schneller/langsamer Randlandungen, senkrechter Landung, Durchflug von unten und späterer Landung, fremder Kiste, bewegter Kiste, beidseitiger Seitenkollision, Jetpack und linker Weltrand. Keine Testpunkte offen.
- **Positiver Befund:** Kistenrandlandungen funktionieren nach Entwicklereindruck nun nachvollziehbar. Die gemeinsame zeitbezogene Oberseiten-Kandidatenprüfung K-T1 ist im getesteten Umfang bestätigt; dies ist **keine Abnahme** der vollständigen globalen Kontaktpriorität.
- **Neue Beobachtung:** Bei **langsamer Landung auf der linken Kistenecke** beschleunigt Sonec nach rechts. Die bestehende `BalanceActive`-/`BalanceTargetX`-Randlandelogik ist ein möglicher Zusammenhang, aber die Ursache wurde noch nicht nachgewiesen. Vor Verhaltensänderung gezielt untersuchen; nicht als behoben markieren.
- **Nächste geplante Architekturarbeit:** Gemeinsame zeitliche Auswahl zwischen Seiten- und Oberseitenkontakten über alle relevanten Kisten, danach Plattformkontakte; bisherige Jetpack-/Plattformfehler weiter offen. Keine automatische Implementierung aus diesem Testergebnis.

## 52. Vor-Code K-T2: globale Kisten-Top-/Seitenzeit (24.11.2026)

- **Freigegebener kleiner Architekturbaustein:** Vor Auflösung einer Kistenseite alle zulässigen Kisten-Oberseitenkandidaten mit dem gemeinsamen K-T1-Helfer prüfen; frühesten Top-Kontakt global über alle Kisten gegen den frühesten ermittelten Seitenkontakt vergleichen. Top bei gleicher Zeit vor Seite (wie bisher B-K2 für dieselbe Kiste). Kisten gleicher Art in Array-Reihenfolge. Ein zeitlich früherer Seitenkontakt darf keine spätere Kistenlandung im selben Schritt erlauben.
- **Umsetzungspfad:** `SonecCollideChestSideContacts` gibt neben der getroffenen Kisten-ID die tatsächlich zuerst blockierende Seitenzeit als Float-Referenz zurück. Ein früherer/gleichzeitiger gültiger Top-Kandidat unterdrückt die Seitenauflösung; `SonecCollideChestHorizontal` berücksichtigt nur Top-Kontakte bis zur ersten Seitenzeit. Die vorhandene Landelogik, Randbalance, `SonecChestRelevant`, Durchflug von unten, Weltrand-Ausnahme und Boden-/Flug-Seitengeometrie bleiben bestehen.
- **Grenzen:** Noch keine gemeinsame zeitliche **Restweg-Integration** und keine globale Plattform-vs.-Kiste-Priorisierung. Bestehende Seitensweep-Richtungsbedingungen und Jetpack-Geometriewechsel bleiben unverändert. Keine Änderung an Float-Ausdrücken außer Kontaktzeit-Vergleich, keine Epsilon-Justierung.
- **Folgetest:** AGK-Kompilierung; beidseitige schräge Randlandung und seitliches Anlaufen, besonders zwei nahe Kisten mit unterschiedlicher Kontaktzeit, Durchflug von unten, bewegte Kisten/Plattform, Jetpack, Weltrand, langsame linke Randlandung. Erwartet wird eine Änderung bei Top-/Seitenkonflikten verschiedener Kisten, nicht bei bereits bekannten Jetpack- oder Plattform-Tunnelfehlern.

## 53. K-T2 umgesetzt – AGK-Test offen (24.11.2026)

- **Code-Commit:** `19a23dc7fb4a08b644b9ceba9bf4b59a2351b4e8` auf `develop`. `SonecCollidePlate` übergibt `SideContactTime` als Float-Referenz an `SonecCollideChestSideContacts` und als Wert an `SonecCollideChestHorizontal`. Die Seitenfunktion sucht den frühesten gültigen Oberseitenkontakt **über alle relevanten Kisten**, bevor sie einen Seitenkontakt anwendet; frühere/gleichzeitige Oberseite unterdrückt Seitenauflösung. Eine früher aufgetretene Seite sperrt spätere Kistenlandungen im selben Schritt. Gleiche Topzeiten behalten die bisherige Array-Reihenfolge.
- **Nicht geändert:** Geometrie der Seitenkontakte, Kontakt-X-Helfer, BalanceActive, Bewegungsintegration, Durchflug von unten, Plattformpriorität und Weltrand-Ausnahme. Es bleibt eine erste gemeinsame Kisten-Zeitentscheidung ohne Restweg-Integration; mögliche Prioritätskonflikte mit Plattformen sind weiterhin offen.
- **Status:** AGK-Compile und Laufzeit **nicht durch Assistenten ausgeführt**. Entwickler soll insbesondere Kistenränder, zwei benachbarte Kisten, Jetpack, Durchflug von unten, linke Weltrand-Ausnahme und langsame linke Randlandung prüfen. Die bereits beobachtete Beschleunigung bei langsamer linker Randlandung ist nicht als behoben markiert.

## 54. Vor-Code K-T2 Compilerkorrektur (24.11.2026)

- **Entwickler-Compile:** `sonec.agc:1303` – primitive `float ref` in AGK unzulässig; `sonec.agc:1509` – `SideContactTime` nicht definiert (Folge-/Signaturfehler). K-T2 konnte deshalb nicht ausgeführt werden.
- **Korrektur innerhalb K-T2:** Kontaktzeit statt als `float ref` als Float-Feld `ChestSideContactTime` im bereits per `ref` übergebenen `TSonec` übermitteln. Die Seitenprüfung setzt den Wert pro Aufruf auf 2 (kein blockierender Seitenkontakt) bzw. auf die früheste Seitenzeit. Die Landefunktion liest diesen Wert aus `Sonec`. Keine Änderung an der Kontaktgeometrie oder Zeitpriorität.
- **Status:** AGK-Kompilierung erneut erforderlich, keine Laufzeitbehauptung.

## 55. K-T2 AGK-Signaturkorrektur umgesetzt (24.11.2026)

- `def_game.agc` Commit `e7613223c767cc89bea8de6f5715fe25f67e7128`: `TSonec.ChestSideContactTime as float` ergänzt.
- `sonec.agc` Commit `369a56facfad91b3416827c5d4fbcd668cdd70f0`: primitive `float ref`-Parameter und lokale Übergabe entfernt; `SonecCollideChestSideContacts` schreibt die früheste blockierende Seitenzeit in `Sonec.ChestSideContactTime` (sonst 2); `SonecCollideChestHorizontal` verwendet das Feld beim Vergleich. Die gemeldeten Fehlerstellen werden damit ohne geänderte Kollisionsentscheidung adressiert.
- **Teststatus:** erneute AGK-Kompilierung und vollständiger K-T2-Test ausstehend; kein Test als bestanden angenommen.

## 56. Entwicklertest K-T2 nach AGK-Signaturkorrektur (24.11.2026)

- **Getesteter Stand:** K-T2 ursprünglich Code-Commit `19a23dc7fb4a08b644b9ceba9bf4b59a2351b4e8`, nach Compilerkorrektur `e7613223c767cc89bea8de6f5715fe25f67e7128` und `369a56facfad91b3416827c5d4fbcd668cdd70f0`. Entwickler meldet **AGK-Kompilierung erfolgreich und 10/10 Prüfpunkte bestanden**: beidseitige schräge Randlandung, zwei benachbarte Kisten mit unterschiedlichen Kontaktzeiten, beidseitige Seitenkollision, langsame linke Randlandung, Jetpack und linker Weltrand, bewegte Kiste, fremde Kiste, Durchflug von unten und anschließende Landung. Keine Testpunkte offen.
- **Zusätzlicher positiver Test:** Beim Laufen von einer höheren auf eine niedrigere Kiste funktioniert die Landung.
- **Weiterer Befund:** Rechtsdrall/Beschleunigung nach rechts bei Randlandung **sowohl an linker als auch rechter Kistenecke** beobachtet. Die Ursache ist nicht nachgewiesen; nicht pauschal als erwünschte Randbalance einstufen. Vor Änderung gezielt prüfen, ob `BalanceActive`/`BalanceTargetX`, Support-Restaurierung oder horizontale Bewegung den Effekt verursachen.
- **Status:** K-T2 im getesteten Umfang bestätigt, aber **keine Gesamtabnahme** der Kisten-/Plattformkollision. Bekannte Jetpack- und Plattformfehler bleiben ohne ausdrücklichen Gegenbeleg offen. Nächster Architekturbaustein nur nach weiterer Freigabe.

## 57. Vor-Code Diagnose D-R1: Randdrall inklusive Mini-Hop (24.11.2026)

- **Freigabe:** Nur Diagnoseinstrumentierung für Randlandung, horizontale Restbewegung, Kistentransport, Balance und ausdrücklich **Mini-Hop**. Keine Änderung an Bewegung, Kollisionspriorität, Randbalance oder Hop-Impulsen.
- **Ereignisse:** Bei Landung nahe linker/rechter Kistenkante Diagnosefenster aktivieren; bei Mini-Hop nach links/rechts Ereignis markieren und Fenster neu starten. Sichtbare AGK-`Print`-Ausgabe über begrenzte Folgeframes: Ereignis, `Position.x`, `MoveSpeed.x/y`, `AutoSpeed.x`, `BalanceActive`/`BalanceTargetX`, X-Verschiebung vor/nach Balance-Schritt, Kisten-X und Kisten-MoveSpeed.x, `State.Move`/`Stand`/`Fall`, Kollisionsindex. Ziel ist die Unterscheidung von eigenem Momentum, automatischer Balance, Kistenbewegung und ungewolltem Mini-Hop.
- **Eingrenzung:** Randlandung links und rechts, auch ohne Richtungseingabe; langsames Laufen an die Kante und Mini-Hop beider Richtungen; ruhende/bewegte Kisten. Ereignisfenster begrenzt, damit normale Spielszenen nicht dauerhaft mit Diagnoseausgaben überlagert werden. AGK-Kompilierung und Laufzeit offen.

## 58. D-R1 Diagnoseinstrumentierung umgesetzt, Test offen (24.11.2026)

- **Code:** `dd94932b44068ea6a18d34422d0a090fe8ba84ac` ergänzt Diagnosefelder in `TSonec`; `f95c0e76cc694fbb7499f797ddd8d192189a1bcc` ergänzt AGK-`Print`-Overlay bei Randlandung und Mini-Hop sowie Messung der Balance-X-Verschiebung; `e86f598cd731bb505cb0771ee72c0ff2d44f4601` setzt Ereigniskennung vor erneuter Randklassifikation zurück.
- **Ereignisse:** 1 = linke Randlandung, 2 = rechte Randlandung, 3 = Mini-Hop links, 4 = Mini-Hop rechts. Je Ereignis 60 Bewegungsframes Overlay: aktuelle X-Position, X-/Y-Geschwindigkeit, AutoSpeed.x, Balance aktiv/Ziel, tatsächlich durch Balance erzeugtes X-Delta, Kisten-X/-Geschwindigkeit und Bewegungs-/Boden-/Fallstatus. Bei Hop wird Kistenbezug **vor** `SonecCollideReset` erfasst. Der Mini-Hop-Impuls `MoveSpeed.y = -1.5` bleibt unverändert.
- **Einschränkung:** Die Overlay-Ausgabe erfolgt in `SonecMove`; die Landung wird danach in der Kollisionsphase erkannt, deshalb erscheint das Landungsereignis ab dem nächsten Bewegungsdurchlauf. Kisten-X/-Geschwindigkeit sind Ereignis-Snapshots, keine laufend aktualisierten Werte. Nur Diagnose; kein automatischer Fehlerbeweis.
- **Status:** AGK-Kompilierung und Sichtbarkeit des Overlays durch Entwickler zu prüfen. Besonders Rechtsdrall bei linker/rechter Kistenecke und möglicher ungewollter Mini-Hop.

## 59. Vor-Code D-R1 Ausgabekorrektur: vorhandenes Game.DebugText-Array (24.11.2026)

- **Entwicklerhinweis:** `Print` ist für diese Diagnose ungeeignet; vorhandenes Debug-Array aus dem Hauptspiel verwenden, damit Messwerte dauerhaft sichtbar und aufnehmbar sind.
- **Codebefund:** `source/sonec/main.agc` besitzt kein eigenständiges Debug-Array; das Hauptspiel hält `Game.DebugText as integer[-1]` in `def_game.agc`, initialisiert und zeichnet bisher Slots 0/1 in `game.agc`. Slot 0 ist Schilddiagnose, Slot 1 Zwei-Kreis-Diagnose. Diese Slots nicht überschreiben.
- **Korrektur:** `Game.DebugText` um Slot 2 erweitern; Diagnose mit `SetTextString(Game.DebugText[2],...)` und `DrawText` in `GameDraw` sichtbar machen, solange `Game.Sonec.DebugEdgeFrames > 0`. Keine `Print`-Ausgabe in `SonecMove`; dort nur Messwerte und Ereignisfenster beibehalten. Bei ruhenden Bildern bleibt der letzte Messstand sichtbar, solange das Fenster aktiv ist. Keine Kollisions-/Bewegungsänderung.
- **Test:** AGK-Kompilierung, sichtbarer mehrzeiliger Diagnose-Text, 60 Frames nach Randlandung und Mini-Hop, bestehende Debug-Slots unverändert.

## 60. D-R1 Diagnose auf Game.DebugText umgestellt, Test offen (24.11.2026)

- **Code:** `be0a6547c445ec64e1c501bc1fa7244a40dbe51e` entfernt `Print` aus `SonecMove`. `2c114a78c0f7fb502990a2208c185f4b167ceb7a` erweitert `Game.DebugText` von Slots 0–1 auf 0–2 und rendert die Rand-/Mini-Hop-Diagnose in Slot 2 über `SetTextString`/`DrawText` in `GameDraw`. Das Diagnosefenster zählt dort 60 gezeichnete Frames; die vorhandenen Slots 0/1 bleiben unverändert.
- **Hinweis:** Der Text zeigt Ereignis, aktuelle X-/X-Y-Geschwindigkeit, Carry, Balance und Delta, Kisten-Snapshot sowie Move/Stand/Fall. Die Diagnosedaten werden weiterhin in `Sonec` erfasst; keine Bewegungskorrektur.
- **Teststatus:** AGK-Kompilierung, mehrzeilige Darstellung und Aufnehmbarkeit vom Entwickler zu bestätigen.

## 61. Entwicklerbeobachtung D-R1: Screenshots Randlandung (24.11.2026)

- **Bild 1, rechte Seite:** Debug `event=2`, `x=602.344604`, `vx=0`, `vy=0`, `carryX=-0.055000`, `balance=0`, `target=603.035156`, `dxBalance=0`, `chestX=540.535156`, `chestVx=0`, `move=0`, `stand=1`, `fall=0`.
- **Bild 2, linke Seite:** Debug `event=0`, `x=299.052032`, `vx=0`, `vy=0`, `carryX=0`, `balance=0`, `target=603.035156`, `dxBalance=0`, `chestX=327.520325`, `chestVx=0`, `move=0`, `stand=1`, `fall=0`. Entwickler: Werte veränderten sich im Zeitverlauf.
- **Einordnung:** Momentaufnahmen zeigen weder aktive Balance noch aktuelle horizontale Eigengeschwindigkeit. `target` bleibt nach abgeschlossener Balance als alter Wert stehen. `event=0` im zweiten Bild entsteht im aktuellen Diagnosecode beim neuen Kisten-Topkontakt ohne Randklassifikation; der alte 60-Frame-Zähler wird dabei nicht zurückgesetzt. `chestX` und `chestVx` sind Snapshots, `carryX` dagegen aktueller Wert. Diese Diagnose kann den Verlauf des Rechtsdralls oder einen fehlerhaften Mini-Hop noch nicht beweisen/widerlegen.
- **Nächste geeignete Prüfung (noch nicht freigegeben):** Diagnosetext um aktuelle Kistenposition, vor/nach Kollisionskorrektur X, Verlauf der letzten Frames und getrennte Ereignismarkierung für Balance-/Hop-Beginn erweitern, ohne Bewegungslogik zu verändern. Erst danach gezielte Fehlerkorrektur planen.

## 62. Vor-Code D-R2: persistente Randdiagnose mit Verlauf und Mini-Hop (24.11.2026)

- **Freigabe:** Diagnoseerweiterung inklusive Mini-Hop und **Entfernung der 60-Frame-Zeitbegrenzung**, damit Screenshots während des Spielens möglich sind. Keine Bewegungsänderung.
- **Anzeige:** Bestehendes `Game.DebugText[2]` dauerhaft anzeigen, sobald ein Randlandungs- oder Mini-Hop-Ereignis erfasst wurde; Werte als **eingefrorener Ereignis-Snapshot** statt flüchtigem Live-Zustand ausgeben. Neu auftretende Rand-/Hop-Ereignisse ersetzen den Snapshot; andere Kontakte dürfen ihn nicht löschen.
- **Messung:** Bei Ereignis die letzten vier Bewegungsschritte (X, VX, Balance-Delta), die aktuelle Kistenposition und Geschwindigkeit sowie Sonec-X vor/nach der Kollisionsphase erfassen; Hop-Richtung und Impuls im Ereignis festhalten. Der Snapshot ist mit der Erfassungsphase zu beschriften, um falsche zeitliche Kausalität zu vermeiden.
- **Grenzen:** Ohne AGK-Kompilierung keine Funktionsbestätigung. Keine Veränderung an `MoveSpeed`, `AutoSpeed`, Kollision oder Hop-Bedingungen.

## 63. D-R2 persistente Diagnose umgesetzt (24.11.2026)

- **Commits:** `bdf0ac88515aaaa0cb6ccb1c1b97822a20c6baa8` Diagnosefelder/Snapshot/Verlauf; `a10f1c180c0abaebd9f3da97b4840f9ac685fd06` Ereignis-Snapshot bei Randlandung und Mini-Hop, vier letzte Bewegungsupdates sowie Kollisions-X vor/nach; `796ade6c621112a08ba96311fdb43d02232e7439` dauerhafte Anzeige über `Game.DebugText[2]`; `4e1e008ca6a1db079a0f6b8509d10c548940cdf2` Ringpuffer ohne ungesicherte Modulo-Syntax; `1a835de819cbadac62a289757772bba760ed1971` entfernt 60-Frame-Zuweisungen.
- **Verhalten:** Die Anzeige bleibt nach einem erfassten Randlandungs- oder Mini-Hop-Ereignis **unbegrenzt sichtbar**, bis ein neues solches Ereignis den Snapshot ersetzt oder das Spiel neu initialisiert wird. Normale Kistenlandungen ohne Randereignis löschen die Diagnose nicht. Gespeichert werden vier vorangehende Bewegungsschritte, X vor/nach Kollisionsauflösung, Ereignis-X/-Geschwindigkeit, Kisten-X/-Geschwindigkeit zum Ereignis, Balance-Zustand/-Ziel und Balance-Delta. Keine Veränderung der Bewegungsimpulse.
- **Wichtig:** Der Snapshot zeigt den Zustand am **Ereigniszeitpunkt**, nicht kontinuierlich aktualisierte Werte. Das erlaubt ruhige Screenshots; ein ungewollter Mini-Hop kann als Ereignis 3/4 erkannt werden, wenn er nach dem letzten Randkontakt ausgelöst wurde.
- **Status:** AGK-Kompilierung und Laufzeitprüfung durch Entwickler ausstehend.

## 64. D-R2 Entwicklerscreenshots linke/rechte Randlandung (24.11.2026)

- **Bild 1 linke Seite:** `event=1`, `eventX=633.599854`, `vx=-1.701001`, `vy=0`, `collisionX 633.599854 -> 633.599854`, `balance=0`, `target=0`, `dxBalance=0`, `chestX=629.858276`, `chestVx=0`, `carryX=-0.041000`, `move=0 stand=1 fall=0`. Verlauf X 638.727844 → 637.009827 → 635.300842 → 633.599854; VX -1.726001 → -1.718001 → -1.709001 → -1.701001, jeweils Balance-Delta 0.
- **Bild 2 rechte Seite:** `event=2`, `eventX=464.903931`, `vx=-0.549500`, `vy=0`, `collisionX 464.903931 -> 464.903931`, `balance=1`, `target=458.155548`, `dxBalance=0`, `chestX=411.655548`, `chestVx=0`, `carryX=-0.041000`, `move=0 stand=1 fall=0`. Verlauf X 466.575928 → 466.010437 → 465.453430 → 464.903931; VX -0.573500 → -0.565500 → -0.557000 → -0.549500, jeweils Balance-Delta 0.
- **Befund:** Beide Aufnahmen zeigen beim Kontakt Bewegung **nach links**, ohne X-Kollisionskorrektur und ohne bereits ausgeführten Balance-Schritt. Im zweiten Fall ist Balance gerade aktiv und Ziel links, der Folgeschritt liegt außerhalb des eingefrorenen Snapshots. Keine der Aufnahmen belegt Rechtsdrall oder Mini-Hop als Ursache; Ereignis 3/4 wurde nicht erfasst. `carryX=-0.041` bei `chestVx=0` erfordert getrennte Prüfung der Trägergeschwindigkeit, ist aber kein Nachweis eines Fehlers.
- **Nächster Diagnoseschritt, noch nicht freigegeben:** gezielte Nach-Kontakt-Beobachtung über mehrere Frames (insbesondere bei `BalanceActive=1`) und Mini-Hop-Auslösung erfassen, statt allein Vor-Kontakt-Historie einzufrieren. Kein Bewegungscode geändert.

## 65. Vor-Code D-R3: CSV-Diagnose im App-Local-Verzeichnis (24.11.2026)

- **Freigabe:** Entwickler möchte Messwerte direkt aus dem App-Local-Verzeichnis holen; CSV bevorzugt, keine manuelle Screenshot-Erfassung mehr. **Keine Änderung der Bewegung.** Bestehendes Debug-Array bleibt.
- **Format und Ort:** `sonec_edge_diagnostics.csv` im AGK-Schreibverzeichnis (App Local), mit Spaltenüberschriften; eine Zeile pro aktiver `GameDo`-Simulation nach `SonecCollidePlate`. Zeitstempel, Ereignis (0/1/2/3/4; 0 = kein neues Ereignis), X/Y, VX/VY, Carry, Balance-Status/-Ziel/-Delta, X vor/nach Kollisionsphase, Kistenindex/aktuelle X-Position/-Geschwindigkeit, Boden-/Bewegungszustand, LinkedPlateIndex und Support-Typ. Mini-Hop 3/4 und Randlandung 1/2 als Ereigniszeilen; alle übrigen Zeilen erlauben Nachlaufanalyse.
- **Lebensdauer:** Datei beim ersten aktiven Spielstart mit Header neu beginnen; nachfolgende Simulationsframes anhängen, jede Zeile sofort durch Schließen des Dateihandles sichern. Neustart innerhalb desselben Programmprozesses hängt an; vollständiger Programmneustart startet eine neue Datei. So ist die Datei nach Beenden oder während Pausen lesbar. Nur bei `GAME_DEBUG_ENABLED=1` schreiben. Keine weiteren 60-Frame-Grenzen.
- **Risiko/Test:** Öffnen/Schließen je Frame kann die Performance beeinflussen; als temporäre Diagnoseinstrumentierung, nach Test entfernen. AGK-Kompilierung, Dateiort, CSV-Spalten und Ereigniszuordnung durch Entwickler prüfen.

## 66. D-R3 CSV-Ausgabe implementiert, AGK-Test offen (24.11.2026)

- **Code:** `8099d141bbc81c91abce1255ebf58124aed4ce76` ergänzt globalen Startstatus in `source/sonec/main.agc`; `ceedbec181a51a93643082f1b8a07b0d0b371366` ergänzt `SonecEdgeCsvWrite` in `source/sonec/game.agc` und ruft es direkt nach `SonecCollidePlate` auf.
- **Datei:** `sonec_edge_diagnostics.csv` im AGK App-Local-Schreibverzeichnis; beim ersten aktiven Spiel-Frame wird die Datei neu erstellt und Header geschrieben, danach pro Simulationsframe eine Zeile angehängt und Datei geschlossen. Neustart des Spiels innerhalb derselben App-Laufzeit hängt an, neuer App-Prozess ersetzt die alte Datei. Nur bei `GAME_DEBUG_ENABLED=1` aktiv.
- **Spalten:** `time_ms,event,x,y,vx,vy,carry_x,balance_active,balance_target_x,balance_dx,collision_start_x,collision_end_x,chest_index,chest_x,chest_vx,stand,fall,fly,move,ground_contact,linked_plate,support_type,support_index,hop_impulse_y`. `event=0` heißt kein neues Rand-/Hop-Ereignis in diesem Frame; 1/2 linke/rechte Randlandung, 3/4 Mini-Hop links/rechts. `hop_impulse_y=-1.5` nur für Event 3/4, ansonsten 0. Kistenwerte stammen vom aktuellen Support, wenn vorhanden; `chest_index=-1` heißt kein aktiver Kistensupport.
- **Status:** AGK-Kompilierung, Dateierzeugung, Schreibberechtigung, Inhalt und Performance noch nicht getestet. Es werden keine Spielbewegungswerte verändert. Temporäre Debug-Instrumentierung später nach Befund entfernen.

## 67. D-R3 erste Entwickler-CSV: 2.098 Simulationszeilen (24.11.2026)

- **Datei:** `sonec_edge_diagnostics.csv`, 2.098 Zeilen, `time_ms` 13161–48162 (~35 s). Ereignisse: `event=3` einmal (Zeile 1500, 38186 ms), `event=1` zweimal (Zeilen 1501/1502, 38202/38219 ms), `event=2/4` nicht enthalten.
- **Mini-Hop-Befund:** Bei 38186 ms `event=3` (Hop links), `x=231.254074`, `vx=-1.679250`, `vy=0`, `stand=1`, `fall=0`, `support_type=2`, `support_index=0`. Schon 16 ms später linke Randlandung `event=1`, weiterhin `vy=0`, `stand=1`; weitere linke Randlandung 17 ms später. Der im Code gesetzte Hop-Impuls `-1.5` ist in den nach der Kollisionsphase erfassten Zeilen **nicht mehr sichtbar**. **Verdacht:** Hop wird in derselben/nächsten Kollisionsauflösung vom vorhandenen Kistensupport übersteuert oder wieder aufgelöst. Noch kein Beweis ohne Phasenmessung.
- **Weitere Daten:** Im gesamten Ausschnitt kein `balance_active=1` und kein `balance_dx != 0`; keine Rechtsrandlandung, damit der Rechtsdrall beider Seiten nicht aus dieser Datei vergleichbar. Während des Ausschnitts bewegt sich die Kiste `chest_x` von 213.462967 auf 196.227966 (38019–38402 ms), obwohl `chest_vx=0` ausgewiesen ist: `chest_vx` allein repräsentiert nicht zwingend die Weltbewegung einer Kiste auf bewegter Plattform.
- **Nächste Prüfung:** Hop-Impuls vor und nach Kollisionsauflösung getrennt loggen und Kontakt-/Supportstatus dazwischen erfassen; Rechtsrandlandung gezielt mit CSV wiederholen. Keine Codeänderung aus diesen Daten abgeleitet.

## 68. Entwicklerkorrektur zur ersten CSV: sichtbarer Mini-Hop rechts (24.11.2026)

- **Entwicklerbeobachtung:** Der tatsächlich beobachtete Mini-Hop fand **am rechten Kistenrand statt und ging nach rechts**. Frühere Zuordnung als linksgerichteter Hop anhand von `event=3` ist für den beobachteten Vorgang **nicht bestätigt**.
- **Rohdatenprüfung:** CSV bei 38186 ms: `event=3`, `x=231.254074`, `vx=-1.679250`; die Nachbarframes zeigen fallende X-Werte (232.933319 → 231.254074 → 229.494827) und negative VX. Der Quellcode setzt `event=3` nur in der MOVELEFT-/VX<0-Bedingung, `event=4` nur in der MOVERIGHT-/VX>0-Bedingung. Die CSV dokumentiert also ein **linksgerichtetes Codeereignis**, das sich ohne weitere Zuordnung nicht mit dem vom Entwickler beobachteten **rechtsgerichteten sichtbaren Hop** gleichsetzen lässt.
- **Offen:** Ob ein anderes, nicht erfasstes Hop-Ereignis gemeint ist, die Ereigniszuordnung falsch ist, oder Welt-/Bildschirmbewegung den visuellen Eindruck verändert, ist nicht belegt. Keine Änderung der Hop-Regeln aus diesem Widerspruch ableiten. Nächste Diagnose muss tatsächliche Hop-Auslösung, Bewegungsrichtung und Bildschirm-/Weltkoordinaten eindeutig korrelieren.

## 69. Vor-Code D-R4: Hop-Richtung und Impulsphasen eindeutig loggen (24.11.2026)

- **Freigabe:** Entwickler vermutet einen zusätzlichen Rechtsimpuls während des sichtbaren rechtsgerichteten Hops; Diagnose ergänzen, **keine Bewegungskorrektur**.
- **Messung:** In der bestehenden App-Local-CSV je Frame zusätzlich X-/Y-Geschwindigkeit **vor** und **nach** der Kollision, X/Y vor der Bewegungsintegration und nach der Kollisionsphase, Alignment/Move/Stand, Welt-/Kamera-X und bei Hop die X-/Y-Geschwindigkeit **unmittelbar vor und nach `SonecCollideReset` plus Hop-Impuls**, tatsächliche Kistenkante, Hop-Auslöser (links/rechts), Kisten- und Plattformbewegung. Ereigniscode und Auslösebedingung müssen dieselbe Quellcode-Stelle repräsentieren; `event=3` links, `event=4` rechts.
- **Auswertung:** So lässt sich unterscheiden zwischen vorbestehender horizontaler Geschwindigkeit, einem durch Input/Physik neu erzeugten Rechtsimpuls, Support-/Kollisionskorrektur und einer Bildschirmbewegung durch Kamera-/Plattformtransport. Nicht aus `hop_impulse_y=-1.5` allein auf tatsächliche Vertikalgeschwindigkeit schließen.
- **Dateiformat:** Bestehende `sonec_edge_diagnostics.csv` mit zusätzlichen Spalten; Programmneustart erstellt neuen Header. Alte CSV separat aufbewahren. Keine Zeitbegrenzung.
- **Status:** AGK-Kompilierung und Laufzeitprüfung offen.

## 70. D-R4 CSV-Phasenmessung implementiert, Test offen (24.11.2026)

- **Commits:** `ed5a6ebe3af3afa5a0b31ae4e5ae5f50affb4e70` TSonec-Diagnosefelder; `8a970b5a99c85e0c9d156a70eaa8c66cf243a45a` Messung in Bewegung/Kollision/Mini-Hop; `6994625431c8536fe2fa457b625bd7c983b32cd7` CSV-Phasenspalten inkl. Welt-/Bildschirm-X und Plattformbewegung; `eca4f96a06af68626f2170ebdc4b054a55cb6ad0`, `3b30082aa77b8c7c6aab9b6764f36e37b4e07dc4`, `47ee1f83d48bd16f0cf8800d3fc8b3db2016b7bc` zusätzliche horizontale Geschwindigkeitsmessung **vor und nach `SonecMoveHorizontalSpeed`**.
- **Neue CSV-Spalten:** `move_start_x,move_start_y,pre_collision_vx,pre_collision_vy,post_collision_vx,post_collision_vy,hop_pre_vx,hop_pre_vy,hop_post_vx,hop_post_vy,hop_chest_index,hop_chest_left,hop_chest_right,alignment,world_x,screen_x,plate_x,plate_vx,move_start_vx,after_horizontal_vx`. Alle bestehenden Spalten bleiben erhalten. `event=3/4` aus der tatsächlichen linken/rechten Hop-Bedingung; Hop-Vorher/Nachher erfasst den `SonecCollideReset` und den gesetzten `-1.5`-Y-Impuls, während die Post-Collision-Werte die gesamte anschließende Kollisionsauflösung zeigen.
- **Interpretation:** `after_horizontal_vx - move_start_vx` isoliert die Änderung durch die horizontale Geschwindigkeitsfunktion (nicht zwingend alle anderen Impulse). `post_collision_vx - pre_collision_vx` erfasst spätere Kollisions-/Supportänderungen. `world_x`/`screen_x` helfen beim Vergleich sichtbarer und physikalischer Bewegung; `plate_vx` ist nur die explizite Geschwindigkeit der verlinkten Plattform, nicht notwendigerweise die gesamte Kistenbewegung.
- **Status:** AGK-Kompilierung und Dateiinhalt noch vom Entwickler zu bestätigen. Diagnose schreibt weiterhin jede aktive Simulation in App Local, ohne Zeitlimit. Keine beabsichtigte Änderung von Bewegungswerten oder Kollisionsentscheidungen.

## 71. D-R4 Kurztest und Diagnosefehler (24.11.2026), vor Korrektur

- **Entwickler-CSV:** `sonec_edge_diagnostics(1).csv`, 290 Zeilen, Zeit 6897–11719 ms (4.822 s), alle `event=0`; kein Randlandungs- oder Hop-Ereignis, `balance_active=0` durchgehend. Kein Kistensupport (`chest_index=-1`); Test wegen kurzer Laufzeit/weniger Kisten für Hop-Ursache nicht aussagekräftig.
- **Messfehler:** `pre_collision_vx` ist in allen Zeilen 0, obwohl `vx` variiert. Codeprüfung: die neue Zuweisung `DebugCsvPreCollisionVX/VY` wurde versehentlich nach `CollisionMoveEnd` in `SonecInit` statt in `SonecMove` eingefügt. Daher ist die bisherige Vor-/Nach-Kollision-Messung ungültig.
- **Korrekturumfang:** Ausschließlich Zuweisungen aus `SonecInit` entfernen und am Ende von `SonecMove` direkt nach dem Setzen von `CollisionMoveEnd` platzieren. Keine Bewegungs-/Kollisionsänderung; AGK-Kompilierung und neuer CSV-Test ausstehend.

## 72. D-R4 Vor-Kollisionsmessung korrigiert (24.11.2026)

- **Code-Commit:** `0e983e95d5164901efe536c11755193550f47721`. `DebugCsvPreCollisionVX/VY` wird nun in `SonecMove` direkt nach `CollisionMoveEnd` gesetzt; falsche einmalige Initialisierungs-Zuweisung entfernt. Die CSV-Schreibfunktion und die Bewegungslogik bleiben unverändert.
- **Teststatus:** erneute AGK-Kompilierung und CSV-Test erforderlich; alte Datei darf für `pre_collision_vx/vy` nicht als Beleg verwendet werden.

## 73. D-R4 Entwickler-CSV 3 ausgewertet (24.11.2026)

- **Datengrundlage:** `sonec_edge_diagnostics(2).csv`, 853 Simulationszeilen von 4779–18991 ms (~14.2 s), 44 Spalten. `event=4` einmal, `event=3` einmal, `event=2` einmal, `event=1` dreimal; `balance_active=1` in 28 Zeilen. Die korrigierte `pre_collision_vx`-Messung enthält nicht-null Werte (350 Zeilen).
- **Rechter Mini-Hop 14938 ms:** vor Horizontalbeschleunigung `move_start_vx=0`, danach `after_horizontal_vx=+0.085`, `hop_pre_vx=hop_post_vx=+0.085`, `hop_pre_vy=0`, `hop_post_vy=-1.5`; `post_collision_vy=-1.5`. Folgesteps `vx=+0.170,+0.255,+0.335`. Die X-Beschleunigung entsteht vor Hop-Auslösung in `SonecMoveHorizontalSpeed`; Hop selbst ändert VX hier nicht.
- **Linker Mini-Hop 18224 ms:** `move_start_vx=0`, `after_horizontal_vx=-0.085`, `hop_pre_vx=hop_post_vx=-0.085`, `hop_pre_vy=0`, `hop_post_vy=-1.5`, `post_collision_vy=-1.5`. Danach linksgerichtete Beschleunigung. Kein in diesen Hop-Frames verlorener Vertikalimpuls.
- **Rechte Randlandung 15222 ms:** `vx=+0.405`, `balance_active=1`, im Nachlauf `balance_dx=-0.5` pro Frame: automatische Korrektur nach links trotz anfänglich positiver VX.
- **Linke Randlandung 18508 ms:** `vx=-0.3115`, `balance_active=1`, Nachlauf `balance_dx=+0.5` pro Frame: automatische Korrektur nach rechts trotz anfänglich negativer VX. Bei 18558 ms `vx=0`, aber Balance schiebt weiter bis `x=679.454041` (18658 ms). **Rechtsdrall nach linker Landung ist damit als Balancebewegung messbar**; nicht mit zusätzlichem positiven VX-Impuls verwechseln.
- **Zusatzbeobachtung:** Bei 18908 ms fällt `stand` von 1 auf 0 und `fall` von 0 auf 1, bei unverändertem `x=679.454041`; Ursache dieser Kontaktaufhebung aus CSV allein nicht beweisbar. Keine Aussagen über Tod/Gegnerkontakte, da nicht mitgeloggt.
- **Status:** Reine Auswertung, keine Codeänderung. Vor Verhaltenskorrektur geplante Randbalance gegen Bewegungsspezifikation und tatsächlichen gewünschten Effekt abgleichen.

## 74. Entwicklerklärung zu 18.908 ms (24.11.2026)

- **Entwicklerbeobachtung:** Sonec ist bei 18.908 ms gestorben. Der dortige Wechsel von `stand=1`/`fall=0` auf `stand=0`/`fall=1` ist deshalb **nicht als eigenständiger Kollisionsfehler zu werten**. Ohne Todes-/Schadensereignis im CSV lässt sich der genaue Todesablauf daraus nicht rekonstruieren.
- **Weiter gültig:** Die Messungen zu horizontaler Beschleunigung vor den beiden Mini-Hops und zur Randbalance nach den Landungen bleiben unverändert. Keine Codeänderung.

## 75. Phase B3a – gemeinsamer Plattform-Oberseitenkandidat (vor Code, 24.11.2026)

- **Ziel:** Den relativen Plattform-Fußkreuzungstest aus `SonecCollidePlate` in eine reine Kandidatenfunktion auslagern. Diese liefert eine Kontaktzeit 0..1 oder -1 und prüft die horizontale Position **zur Kontaktzeit** (statt ausschließlich am Frame-Ende). Der Test benutzt die gespeicherten Sonec- und Plattformbewegungswege.
- **Umfang dieses Schritts:** Ausschließlich die Plattform-Oberseitenkandidaten-Ermittlung und ihren Aufruf ersetzen. Noch **keine** gemeinsame Auflösung von Plattform, Kistenoberseite und Kistenseite; bestehende Prioritäten bleiben vorerst bestehen. Die neue Kontaktzeit wird später in B3b für die globale Auswahl genutzt. Keine Anpassung von Sprung, Balance, Schaden oder Kistenbewegung.
- **Test:** AGK-Kompilierung; stehende und bewegte Plattformen, langsame und schnelle Landung; Landung nahe Plattformrand; keine unberechtigte Landung, wenn die horizontale Kreuzung nur am Frame-Ende passt. Vollständige Phase B bleibt offen.

## 76. Phase B3a – Implementierung und Teststatus (24.11.2026)

- **Code:** `a2399a4e1e0bde7c128945c9b0c957ce827cac5d` auf `develop`. `SonecPlateTopContactTime` berechnet relative Fußkreuzung und prüft Sonecs horizontale Position sowie die Plattformposition zur **gleichen Kontaktzeit**. `SonecCollidePlate` verwendet die Funktion zur Auswahl des frühesten Plattformkandidaten; vorhandene Landungsauflösung bleibt unverändert.
- **Verhaltensänderung im Folgetest erwartet:** Bei Bewegung entlang eines Plattformrands kann sich die Landungsentscheidung gegenüber dem bisherigen Endpositions-X-Test ändern. Kein Anspruch, dass globale Plattform-/Kistenpriorität bereits korrigiert ist.
- **Status:** AGK-Kompilierung und Entwicklertest ausstehend. B3b (globale Kandidatenauswahl) erst nach Rückmeldung; Phase B insgesamt offen.

## 77. Entwicklertest B3a und B3b-Festlegung (vor Code, 24.11.2026)

- Entwickler meldet: **B3a-Verhalten gut**. Keine vollständige Phase-B-Abnahme daraus ableiten.
- **B3b:** Plattform- und Kistenoberseiten über ihre relative Kontaktzeit gegeneinander auswählen. Die bestehende Seitenkollisionsprüfung und die vorhandene Kistenlandungsauflösung (inkl. Randbalance) bleiben vorerst erhalten; Seitenkontakte werden erst in B3c in die gemeinsame früheste Entscheidung aufgenommen. Bei gleicher Kontaktzeit gilt vorerst der bestehende Kistenvorrang als deterministische Übergangsregel; endgültige Gleichstandsregel später im gemeinsamen Resolver.
- **Dateipfad:** Vor jeder CSV-Dateiöffnung den App-Local-Pfad über den vorhandenen Helfer `FilePathSetAndCheck` aus `source/sonec/file.agc` setzen. Der Helfer heißt im Repository **nicht** `FileCheckAndSet`; bei leerem Namen prüft er keine vorhandene Datei, setzt aber den Ordner. Die Datei muss beim ersten Schreiben neu angelegt werden können.
- **Prüfung:** AGK-Compile; konkurrierende Kisten-/Plattformlandung mit verschiedener Kontaktzeit, Kistenrandlandung/Mini-Hop, bestehende Seitenkollision, CSV-Datei im App-Local-Verzeichnis. Keine Änderung an Bewegungseingaben oder Schadenslogik.

## 78. B3b und CSV-Dateipfad umgesetzt (24.11.2026)

- **Code:** `ff596bf0402c63d46abdcdc26ebf03bf83b7c2d3`: `SonecCollidePlate` ermittelt vor der Kistenbehandlung die früheste gültige Plattform-Oberseitenzeit. `SonecCollideChestHorizontal` erhält diese Zeit und akzeptiert eine Kistenoberseite nur, wenn sie nicht später als die früheste Plattformoberseite liegt. Bei Gleichstand weiterhin Kiste zuerst. Plattformlandung wird danach wie bisher aufgelöst, sofern Sonec noch fällt. Damit entfällt für **Oberseiten** der pauschale Kistenvorrang; Seitenkontakte bleiben noch im getrennten Ablauf und sind Thema B3c.
- **Datei:** `8dab328e3884c2d23d68f98143b865c76fa2ae03`: `SonecEdgeCsvWrite` setzt vor Dateiöffnungen den App-Local-Stammordner über `FilePathSetAndCheck` mit `TFilePath.Path="/"`, `Name=""`; so wird keine existierende Datei vorausgesetzt.
- **Teststatus:** AGK-Compile und Funktionstest durch Entwickler ausstehend. **Erwartete Änderung:** Bei konkurrierenden Kisten-/Plattformoberseiten gewinnt jetzt die früher gekreuzte Oberfläche. Die CSV sollte nach anderem vorherigem Dateipfad wieder im App-Local-Verzeichnis entstehen. Noch keine vollständige Phase-B-Abnahme.

## 79. B3c – Seitenkontakt gegen globale Oberseitenzeit (vor Code, 24.11.2026)

- Entwickler gibt mit „ok weiter“ die Fortsetzung frei; eine explizite B3b-Testabnahme liegt dabei nicht vor.
- **Kleiner Integrationsschritt:** Die früheste bereits berechnete Plattformoberseitenzeit zusätzlich an `SonecCollideChestSideContacts` übergeben. Dort die früheste gültige Kistenoberseitenzeit mit der Plattformzeit zusammenführen. Nur wenn der Seitenkontakt **vor** beiden Oberseiten liegt, wird dessen horizontale Blockade im bisherigen Resolver angewandt. Bei Gleichstand gewinnt vorläufig die Oberseite. Bestehende Pass-through- und Weltrand-Ausnahmen bleiben erhalten.
- **Begrenzung:** Die Auflösung erfolgt weiterhin in getrennten Routinen; nach einem frühen Seitenkontakt kann eine spätere vertikale Landung im selben Frame weiterhin stattfinden. Die vollständige gemeinsame Bewegungspfad-Fortsetzung und Ablösung des Altresolvers sind **noch nicht** Bestandteil von B3c und bleiben als Phase-B-Folgearbeit offen. Keine neue Priorität durch Kisten-/Plattform-Reihenfolge einführen.
- **Test:** AGK-Kompilierung, früherer Seitenkontakt gegen spätere Plattformlandung, frühere Plattformlandung gegen spätere Kistenseite, Kistenlandung gegen Seite, Weltrand, Mini-Hop. Verhaltensänderung im ersten Fallvergleich erwartet.

## 80. B3c – Umsetzung und Teststatus (24.11.2026)

- **Code:** `cf451389efc1335ae5163f3d13859cc2cca74290`. `SonecCollidePlate` übergibt `BestPlateContactTime` an `SonecCollideChestSideContacts`; die Funktion vergleicht nun früheste Kisten-/Plattformoberseite mit dem frühesten Kistenseitenkontakt. Bei gleichzeitiger Kollision wird die Oberseite bevorzugt. Kistenlandungs- und Plattformlandungsauflösung selbst bleiben unverändert.
- **Teststatus:** AGK-Kompilierung und Funktionstest ausstehend. Phase B **nicht abgeschlossen**: zeitlich korrekte Restbewegung nach Kontakt, gemeinsame Auflösung und Ablösung getrennter Altpfade fehlen. Kein Nachweis einer B3b-Abnahme aus dem knappen „ok weiter“ ableiten.

## 81. B3d – Plattform-Kandidat nur einmal ermitteln (vor Code, 24.11.2026)

- Entwickler erlaubt Fortsetzung nach B3c; keine explizite B3c-Abnahme gemeldet.
- **Befund:** `SonecCollidePlate` durchsucht Plattformoberseiten zweimal: zuerst für die Zeit, dann nach der Kistenbehandlung nochmals für den Index. Die zweite Suche kann eine andere Durchflug-Ausnahme sehen und ist kein gemeinsamer Kandidatenzustand.
- **Kleiner Architekturbaustein:** Den besten Plattform-Index, die Kontaktzeit und die Zielhöhe in der ersten Suche gemeinsam speichern und bei der späteren Landungsauflösung wiederverwenden. Wird während der Kistenprüfung `PassThroughChestIndex` aktiv und betrifft dessen Plattform den zuvor gewählten Kandidaten, den Kandidaten vor der Landung verwerfen. Bestehende Kisten-/Seitenauflösung, Restbewegung und Zustände unverändert lassen. Dies bereitet den einzigen Kontaktresolver vor; ersetzt ihn noch nicht.
- **Test:** AGK-Compile, Plattform-/Kistenlandungen, Durchflug von unten, Mini-Hop, Seitenkontakt. Eine Änderung der bekannten Fehler wird nicht erwartet.

## 82. B3d – Implementiert, AGK-Test offen (24.11.2026)

- **Code:** `ac5429166855a7311ed1e699d0b7e0c510f0b1ce`. Die erste Plattformkandidatensuche speichert nun `BestPlateIndex`, `BestPlateContactTime` und `BestPlateY`; die Landung verwendet denselben Kandidaten. **Ausnahme:** Wenn die Kistenprüfung `PassPlateIndex` ändert, wird der Kandidat mit der neuen Durchflugausnahme neu berechnet, damit eine andere gültige Plattform weiterhin gewählt werden kann.
- **Status:** Noch kein AGK-Compile/Entwicklertest. Die getrennte Auflösung von Seitenkontakt und Landung bleibt; Phase B ist nicht abgeschlossen. Nächster Architekturbaustein: gemeinsame Kontaktrepräsentation und früheste Auswahl vor Auflösung.

## 83. B3e – Gemeinsame Kontaktrepräsentation (vor Code, 24.11.2026)

- Entwickler hat B3e freigegeben; B3d ist noch nicht ausdrücklich getestet/abgenommen.
- **Architektur:** Ein eigener Typ `TSonecContactCandidate` hält `Valid`, `ContactTime`, `ListType` und `Index`. Eine reine Funktion `SonecContactChooseEarlier` vergleicht Kandidaten nach Zeit; bei Gleichstand behält sie den zuerst angebotenen Kandidaten. Die Aufrufer bestimmen die Reihenfolge bewusst (Kistenoberseite vor Plattformoberseite, wie in B3b vereinbart).
- **B3e-Umfang:** Den gemeinsamen Typ und Vergleichshelfer anlegen und die bisherige Plattformkandidatensuche damit betreiben; vorhandene Kisten- und Seitenauflösung noch nicht ersetzen. Keine neue Kontaktreaktion, keine Änderung der Restbewegung. Der gemeinsame Typ wird im nächsten Schritt für Kistenoberseiten und Seitenkontakte verwendet.
- **Test:** AGK-Kompilierung und bisherige Plattform-/Kisten-/Durchflug-Regression; keine Änderung der bekannten Fehler erwartet.

## 84. B3e – Umsetzung und Teststatus (24.11.2026)

- **Typ:** `3c6d934802e32cbf50fb55d86a991504053795be` ergänzt `TSonecContactCandidate` mit `Valid`, `ContactTime`, `ListType`, `Index` in `def_game.agc`.
- **Funktion und Nutzung:** `1ce5a6b30869fad4b6108b2d4ec3eddf01260c5b` ergänzt `SonecContactChooseEarlier` und nutzt den Typ bei beiden Plattform-Kandidatensuchen in `SonecCollidePlate` (initial und bei geänderter Durchflugausnahme). Vergleichssemantik: kleinere Zeit gewinnt, Gleichstand behält früheren Kandidaten. Noch kein gemeinsamer Resolver und keine Restbewegungsfortsetzung.
- **Status:** AGK-Compile/Entwicklertest ausstehend. Phase B offen. Folgeschritt: Kistenoberseiten und Seitenkontakte in dieselbe Kandidatenrepräsentation überführen, bevor getrennte Auflösung ersetzt wird.

## 85. Entwickler bestätigt B3e-Kompilierung; gebündelter Phase-B-Test (24.11.2026)

- **Entwicklerrückmeldung:** B3e kompiliert in AGK Studio. Kein Funktionstest durchgeführt; die Kompilierung ist **keine Verhaltensabnahme**.
- **Teststrategie:** Die einzelnen B3-Architekturschritte werden vorerst nicht jeweils funktional abgenommen. Zum Abschluss von Phase B werden die tatsächlich testbaren Szenarien, erwarteten Soll-Ergebnisse aus dieser Spezifikation und die bekannten Fehler gezielt in einem gemeinsamen Testplan gegenübergestellt. Neue Zwischenschritte weiterhin klein halten und Compile-Status separat dokumentieren.
- **Weiterhin offen:** Kistenoberseiten und Seitenkontakte in gemeinsamen Kandidatentyp integrieren, gemeinsame früheste Kontaktentscheidung und Auflösung mit Restbewegung, Altpfade ersetzen; erst dann gebündelter Regressionstest und explizite Phase-B-Freigabe.

## 86. B3f – Kistenoberseiten in gemeinsame Kandidatenstruktur (vor Code, 24.11.2026)

- **Umfang:** Die bereits bestehende globale Suche nach der frühesten gültigen Kistenoberseite in `SonecCollideChestSideContacts` verwendet künftig `TSonecContactCandidate` und `SonecContactChooseEarlier` anstelle eines eigenen Float-Minimums. Der vorhandene Vergleich gegen Plattformoberseitenzeit und Seitenzeit bleibt identisch; die getrennten Resolver bleiben in diesem Schritt bestehen.
- **Architekturziel:** Plattform- und Kistenoberseiten verwenden denselben Zeitvergleich und speichern Typ/Index, sodass die spätere globale Auswahl auf derselben Repräsentation aufbauen kann. Die nächste Teilaufgabe ist, die Seitentreffer ebenfalls als Kandidaten zu erfassen und danach die Auflösung zu vereinheitlichen.
- **Teststrategie:** AGK-Kompilierung einzeln, Funktionstest gesammelt zum Phase-B-Abschluss. Keine gezielte Verhaltensänderung in B3f.

## 87. B3f – Umsetzung und Teststatus (24.11.2026)

- **Code:** `9071a1d9713b8b1cb9a4a5dfd63671a11a5ecd77` auf `develop`. In `SonecCollideChestSideContacts` sammelt `BestChestTopCandidate` die gültigen Kistenoberseiten mittels `SonecContactChooseEarlier`; `BestTopTime` wird aus dem Kandidaten übernommen. Der bestehende Plattform-/Seitenvergleich und alle Kontaktreaktionen bleiben unverändert.
- **Status:** AGK-Kompilierung ausstehend, Funktionstest gemäß Vereinbarung erst am Ende von Phase B. Phase B nicht abgeschlossen; nächster Schritt ist die Aufnahme der Kistenseitenkontakte in die gemeinsame Kandidatenrepräsentation.

## 88. B3f-Kompilierung und B3g-Seitenkandidat (vor Code, 24.11.2026)

- **Entwickler bestätigt:** B3f kompiliert erfolgreich in AGK Studio. Kein Funktionstest; gesammelt am Phase-B-Ende.
- **B3g:** Die bereits ermittelte früheste gültige Kistenseite wird nach Abschluss der bestehenden Sweep-Schleife als `TSonecContactCandidate` mit `ListType=TYPECHEST`, `Index=HitIndex`, `ContactTime=SideTime` abgebildet. Der vorhandene Vergleich mit Oberseiten und die Reaktion bleiben unverändert; Kandidatenrepräsentation allein darf keine neue Blockade auslösen.
- **Begrenzung:** Die vorhandenen Trefferattribute `HitSide`, `HitOffsetX`, `HitPositionX` verbleiben bis zum späteren gemeinsamen Resolver in lokalen Variablen. Keine Änderung an Durchflug, Weltgrenze, Restbewegung oder Kollisionspriorität.
- **Prüfung:** AGK-Kompilierung; Funktionstests gebündelt. Keine Änderung der bekannten Fehler erwartet.

## 89. B3g – Implementiert, Compile ausstehend (24.11.2026)

- **Code:** `1fedca7a6b2deff054c0d3a950b3c134e79c0653`. `SonecCollideChestSideContacts` bildet den bisher gewählten Seitentreffer in `BestChestSideCandidate` ab und liest Index/Zeit für den unveränderten Oberseitenvergleich daraus zurück. Der Seitenkandidat enthält noch keine separate Normalen-/Positionsinformation; diese bleibt vorerst in den bestehenden lokalen Variablen.
- **Status:** AGK-Kompilierung ausstehend, Funktionstest gemäß Vereinbarung am Ende von Phase B. **Phase B offen**: echte globale Kandidatenauswahl, einheitlicher Resolver und zeitlich korrekte Restbewegung stehen noch aus.

## 90. B3g-Kompilierung und B3h – gemeinsame früheste Kandidatenwahl (vor Code, 24.11.2026)

- **Entwickler bestätigt:** B3g kompiliert erfolgreich; Funktionstests weiterhin zum Phase-B-Abschluss.
- **B3h:** Die Seitenkontaktroutine führt die bereits vorliegenden drei Zeiten (früheste Kistenoberseite, früheste Plattformoberseite, früheste Kistenseite) in einem einzigen `TSonecContactCandidate` als frühesten Treffer zusammen. Für die Auswahl wird die Reihenfolge Kistenoberseite, Plattformoberseite, Kistenseite verwendet, damit die bereits festgelegte Oberseitenentscheidung bei Gleichstand unverändert bleibt. Da der Plattformindex hier noch nicht übergeben wird, ist der Plattformkandidat zunächst ein zeitlicher Platzhalter mit Index -1; keine Auflösung über diesen Platzhalter.
- **Begrenzung:** Die neue Gewinnerwahl steuert in B3h nur die bisherige Entscheidung, ob ein Kistenseitenkontakt aufgelöst wird. Die eigentlichen getrennten Resolver und ihre Positionierung bleiben unverändert. Restbewegung und vollständige gemeinsame Auflösung folgen später. Keine gezielte Änderung bekannter Fehler erwartet.
- **Prüfung:** AGK-Kompilierung; Funktionstest gesammelt.

## 91. B3h – Gemeinsame früheste Auswahl umgesetzt (24.11.2026)

- **Code:** `0db1191cefd37baa408b462e41e68d944fc2aa46`. `SonecCollideChestSideContacts` bildet aus dem frühesten Kistenoberseiten-, Plattformoberseiten- und Kistenseitenkontakt einen `EarliestContactCandidate`; bei Gleichstand gewinnen Oberseiten. Nur wenn die Seite früher ist, wird die bestehende Seitenauflösung ausgeführt. Plattformkandidat trägt hier noch Index -1 und darf nicht aufgelöst werden.
- **Status:** AGK-Kompilierung ausstehend. Funktionstest gebündelt am Ende von Phase B. Der globale Kandidat ist zunächst nur innerhalb der Seitenroutine vorhanden; getrennte Landungsauflösung, Restbewegung und Ablösung der Altpfade bleiben offen.
