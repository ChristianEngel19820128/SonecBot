# SonecBot – Projektübersicht

**Dokumentstatus:** Spielkonzept; Status-/Dokumentverweise abgeglichen am 20. November 2026  
**Projektstatus:** In Entwicklung  
**Engine:** AppGameKit Studio (AGK)  
**Aktiver Entwicklungszweig:** `develop`  
**Erste Zielplattform:** HTML5  
**Offizieller Spieltitel:** Noch nicht endgültig festgelegt

---

## 1. Projektbeschreibung

SonecBot ist ein unabhängig entwickeltes 2D-Actionspiel mit automatisch scrollender Spielwelt, Plattformen, Gegnern und Ressourcenverwaltung.

Der Spieler steuert Sonec, einen ehemals menschlichen Charakter, dessen biologische Bestandteile nur noch einen geringen Anteil seiner Existenz ausmachen.

Die Verbindung von Mensch, Maschine und künstlicher Intelligenz ist ein wesentlicher Bestandteil seiner Geschichte.

Im Mittelpunkt des Spiels stehen Bewegung, Kampf, Energieversorgung, Überleben und das schrittweise Verstehen der Spielmechaniken.

SonecBot gehört zu einem größeren fiktiven Universum. Dieses Universum muss für das Verständnis des Spiels jedoch nicht vollständig erklärt werden. Verbindungen können durch Andeutungen und Easter Eggs sichtbar werden.

## 2. Projektgeschichte

Die ursprüngliche Version wurde mit **BlitzBasic Plus** entwickelt. Der letzte bekannte Kompilierstand stammt aus dem Jahr 2008.

Später wurde eine separate Datei in BlitzMax begonnen. Diese stellt keine vollständige Portierung dar.

Die aktuelle Neuentwicklung verwendet **AppGameKit Studio**.

Der historische Quellcode und die zugehörigen Grafiken werden unter `source/legacy/` archiviert und dienen ausschließlich als Referenz.

## 3. Spielprinzip

SonecBot kombiniert folgende Elemente:

- Automatisch horizontal scrollende Spielwelt
- Bewegung und Sprünge zwischen Plattformen
- Energiebegrenztes Fliegen mit einem Jetpack
- Kampf gegen unterschiedliche Gegner
- Verschiedene Waffen und Verteidigungsmöglichkeiten
- Einsammeln von Energie und anderen Ressourcen
- Überleben unter zunehmendem Gegnerdruck

Die Spielwelt enthält eine futuristische Stadtlandschaft, bewegliche Plattformen, Wolken und weitere Hintergrundelemente.

Die Kamera folgt der Spielfigur innerhalb festgelegter Grenzen auch vertikal.

Ein Sturz unter den spielbaren Bereich kann zum Tod der Spielfigur führen.

### Fairness als Grundregel

Fairness gilt für Sonec ebenso wie für computergesteuerte Gegner. Eine übermäßige Bevorzugung einer Seite darf das Zusammenspiel aus Bewegung, Kampf und Ressourcen nicht aushebeln. Treffer, Zielverhalten und Gegenwehr müssen nachvollziehbar und spielerisch angemessen sein; diese Regel ist bei jeder Änderung von KI, Waffen, Schaden und Balancing zu berücksichtigen.

### Spielbeginn und Spielerfahrung

Eine Spielrunde beginnt damit, dass Sonec vom Himmel fällt.

Das Spiel soll nicht zwangsläufig sämtliche Mechaniken im Voraus erklären. Es ist denkbar und wahrscheinlich, dass die erste Spielrunde mit dem Tod der Spielfigur endet, bevor der Spieler das Konzept vollständig verstanden hat.

Das schrittweise Erlernen der Spielmechaniken ist Teil der vorgesehenen Spielerfahrung.

Ein genauer Ablauf für Einführung, Spielende und Neustart ist noch nicht abschließend festgelegt.

## 4. Spielfigur: Sonec

### Identität und Hintergrund

Sonec war ursprünglich ein Mensch. Heute bestehen nur noch geringe biologische Anteile.

Seine Existenz ist durch die Verbindung von Mensch, Maschine und KI geprägt. Die genaue Geschichte und die Beziehungen innerhalb des größeren Universums werden nicht vollständig im Spiel erklärt.

### Anzug und Fähigkeiten

Sonec trägt einen Anzug, der ihn schützt, verbessert und ihm besondere Fähigkeiten verleiht.

Der Anzug ist ein wichtiger Bestandteil des Charakterkonzepts. Welche Funktionen unmittelbar durch den Anzug, durch andere technische Komponenten oder durch Sonecs eigene Fähigkeiten ermöglicht werden, ist noch nicht vollständig dokumentiert.

### Bewegung

- Horizontale Bewegung
- Springen
- Einfluss der Schwerkraft
- Jetpack mit begrenztem Energievorrat

### Ressourcen

- Lebensenergie
- Energie für verschiedene Fähigkeiten
- Munition
- Aufsammelbare Energieobjekte

Sonec kann Energie aus seiner Umgebung aufnehmen. Zusätzliche Energie kann durch entsprechende Sammelobjekte gewonnen werden.

### Kisten und Belohnungen – Designidee (noch nicht implementiert)

Kisten verschiedener Größen sollen beim Zerstören nicht zwangsläufig dieselbe Belohnung liefern. **Kleine Kisten sind schwerer gezielt zu treffen** (zum Beispiel fliegen horizontale Maschinengewehrgeschosse bei der kleinsten Kistengröße darüber hinweg). Falls zerstörte Kisten Belohnungen ausgeben, sollen **kleine Kisten tendenziell mehr oder qualitativ bessere Belohnungen** anbieten, damit sich der höhere Aufwand lohnt. Denkbare Stellgrößen sind Menge, Seltenheit oder Qualität der Ressourcen/Upgrades. Die konkrete Gewichtung, Drop-Regel und das Verhältnis zur Kistengesundheit werden erst beim späteren Balancing festgelegt. Dieser Absatz ist ein **Spielkonzept**, keine Aussage über bereits implementierte Drops und keine Freigabe für Balancingänderungen.

### Waffen und Verteidigung

Im bisherigen Spielkonzept sind folgende Systeme vorgesehen beziehungsweise teilweise implementiert:

- Maschinengewehr
- Flammenwerfer
- Aufladbare Plasma- beziehungsweise Energiewaffe
- Granatwerfer
- Energieschild
- Weitere energieabhängige Fähigkeiten

Der tatsächliche Implementierungsstand wird in `TECHNICAL.md` festgehalten.


### Energieschild – Stand November 2026

Der Energieschild ist für die Alpha in seinen wesentlichen Funktionen lokal getestet: Auf- und Abbau, erneutes Aktivieren während des Abbaus, proportionaler Schutz gegen Explosionen, Schadensverbrauch der Schildladung, verzögerte Regeneration und eine rote HUD-Schadensanzeige. Die rote Anzeige wächst bei weiteren Treffern und baut sich anschließend ab. Die Schildregeneration beginnt nach dem letzten Explosionsschaden verzögert; dies wurde im Spieltest bestätigt.

**Größenentscheidung:** Die Standardgröße beträgt ungefähr 80 px (80 % der bisherigen Grafikgröße) bei etwa 50 px großer Spielfigur. Diese Standardgröße soll nicht weiter verkleinert werden; dynamisches Schrumpfen durch Schaden und Ausschalten bleibt gewollt. Für spätere Upgrades sind etwa 90 px und 100 px als mögliche Stufen vorgemerkt, aber noch nicht implementiert.

**Offen:** Die experimentelle Shape-Kollision ist noch keine Grundlage des tatsächlichen Explosionsschutzes. Zusätzliche Schadensarten und ein vom Animationsframe unabhängiger Ladungswert sind spätere technische Aufgaben.

### Transparenzstand und weitere Wünsche

- Die HUD-Balken sind teilweise transparent umgesetzt; technischer Referenzwert in [TECHNICAL.md](TECHNICAL.md).
- Die Inenergie-Animation soll teilweise transparent sein, ungefähr wie der Schild.
- Energie-Sammelobjekte sollen mit sinkendem Energiewert transparenter werden, innerhalb festgelegter Minimal- und Maximalwerte.

Die Energieaufnahme verbraucht derzeit selbst Energie; dies wird zunächst als mögliche ältere Designentscheidung beibehalten und nicht ungeprüft geändert.

## 5. Gegner und Gefahren

### Minen

Minen können die Spielfigur verfolgen und stellen eine bewegliche Gefahr dar.

Ein entsprechendes System ist im AGK-Quellcode vorhanden.

### Alpha-Walker (Walker)

Der Walker ist ein größerer, mehrteiliger Gegner mit gelenkbasiert animierten Körperteilen und einem drehbaren Waffenaufbau.

Für die aktuelle AGK-Version sind schwere Maschinengewehre als Bewaffnung vorgesehen.

**Aktueller Stand (14. November 2026):** Der Walker ist als plattformgebundener, zerstörbarer Gegner lokal getestet. Seine Spawnwahrscheinlichkeit steigt mit der Plattformlänge. Maschinengewehr-Projektile von Sonec treffen derzeit die Turm-Trefferzone; ein Treffer erzeugt einen kurzen roten Blitz, bei Zerstörung entstehen Energie-Bubbles. Die ursprünglich grauen Sprite-Grafiken werden im Code grün eingefärbt.

**Meilenstein: Alpha-taugliche Laufanimation.** Aufbauend auf der erfolgreichen 2-Knochen-IK und korrekten Corpus-/Turmanbindung (Referenz-Commit `deb8b74`, 13. November) wurden die getrennten Fußziele, der Wechsel zwischen Stand- und Schwungbein, die sanfte Rückkehr zur Standpose und das kontrollierte Umdrehen an Plattformkanten umgesetzt. Die Walker laufen jetzt mit einer einheitlichen Testgeschwindigkeit von `0.05`. Die Fußgelenke werden für eine optisch stimmige Auflage um 8 px über die Plattformoberkante gesetzt. Der Standpose-Test sowie die weißen Skelett-, Gelenk- und Winkelanzeigen sind deaktiviert, bleiben im Code aber zuschaltbar. Der Entwickler hat Stand und Gangbild mit Screenshots und kurzen Videos lokal geprüft und die Laufanimation als **für die Alpha ausreichend** bewertet. Das bedeutet nicht, dass ein HTML5-Test oder eine abschließende Prüfung aller Randfälle bereits erfolgt ist.

**Alpha-Walker – lokal akzeptierter Stand (16. November 2026):** Der Entwickler bewertet den Walker nach Gesamtgefühl-Test als alpha-tauglich und benennt ihn **Alpha-Walker**. Gemeinsame Corpus-/Waffenneigung, eigenständige Turmseitenwahl mit 800-ms-Schwenkprojektion, 400-ms-Zielvorbereitung, Zwei-Schuss-Salve mit gespeichertem Winkel, kleine lernende Streuung ±3° bis ±1°, wechselnder Rohrrückstoß und neutral positionierter Flash sind umgesetzt und in der lokalen Entwicklung bewertet. Rohrgrafik und passende Proto wurden mit Commit `0051b8b` vom Entwickler eingecheckt. Das Referenzvideo zeigt mehrere Walker in Plattformumgebung und optisch zusammenhängenden Bein-/Waffenaufbau. **Letzter ausdrücklich freigegebener Walker-Zusatz:** pro Schuss ein 3-px-Turmrückstoß mit Rückkehr, Rohre folgen, Corpus/IK bleiben fest. **Abschlusstest bestanden (16. November 2026):** Entwickler bestätigt volle Funktion wie erwartet. Aufgabe **Alpha-Walker abgeschlossen**, einschließlich dieses Turmimpulses. Für den Pre-Alpha-Release keine weitere Walker-Politur ohne konkreten spielverhindernden Befund. Lokale Windows-/Video-Bewertung ersetzt keinen HTML5-/Gamepad-/Neustarttest; verbleibende Randfälle bleiben dokumentiert.

**Grafisches Polishing – bewusst nachrangig:** Die Bein-Grafiken könnten bei Bedarf etwas schlanker werden oder feinere Gelenk-, Kontur- und Lichtdetails erhalten. Die aktuelle kräftige, eigenständige Walker-Silhouette ist für die Alpha akzeptiert; Änderungen an den Originalgrafiken sind nicht Voraussetzung für die Bewaffnung. Ein Keyframe-Werkzeug wie Spriter bleibt optional für besondere Animationen (z. B. Knien, Aufstehen oder Zerstörung).

**Projektentscheidung: Ein funktionsfähiger Walker ist Pflichtbestandteil der ersten Alpha-Version.**

### Kollisions- und Schadensmodell: abgestimmte Entwicklungsrichtung (16. November 2026)

Für den aktuellen Pre-Alpha-Schritt gilt: **Sonec soll grundsätzlich allen beschädigbaren Spielobjekten mit allen vier Waffen Schaden zufügen können.** Keine Waffe wird pauschal von einer Zielklasse ausgeschlossen. Die bereits vorgesehenen Fraktionskategorien sind Player/Sonec (historisch mit zweitem Spieler für möglichen Multiplayer), Enemy und Neutral. Welche später benötigten Interaktionen daraus entstehen, bleibt offen; Fraktionen sind nicht mit Schadensarten gleichzusetzen.

Als **spätere Designbasis**, noch nicht implementierte Schadens-/Rüstungsrechnung, sind Plasmaexplosion, Plasmaflammen, kinetischer Schaden (einschließlich Granatenaufprall) und Plasma-Blitz vorgesehen. Passende Panzerungs- und Schild-Gegenwerte werden später entwickelt. Das gewünschte Konterprinzip ähnelt Stein/Schere/Papier/Brunnen; Flammen sollen etwa gegen kleine schnelle Minen besonders nützlich sein. Noch **keine** konkreten Multiplikatoren oder Widerstandsparameter festlegen.

**Vorgehen bei weiteren Kollisionsfragen:** Den tatsächlichen Pfad und bestätigtes Sollverhalten prüfen, den nächsten kleinen Eingriff gemeinsam auswählen und passende Tests nach [AGENTS.md](AGENTS.md) festlegen. Kein pauschales Balancing und keine zusätzliche Walker-Politur.

### Weitere Gegner und Gefahren

Aus dem bisherigen Spielkonzept und der historischen Version sind weitere Ideen bekannt:

- Bomber
- Raketenstellungen
- Geschützstellungen
- Jumppods
- Weitere Bots
- Bossgegner

Diese Elemente sind nicht automatisch Bestandteil der ersten Alpha.

## 6. Spielwelt und Darstellung

Die Spielwelt verwendet eine seitlich scrollende 2D-Darstellung.

Bekannte Gestaltungselemente sind:

- Futuristische Stadtsilhouetten
- Mond und Himmel
- Bewegliche Wolken
- Plattformen mit unterschiedlichen Bewegungsmustern
- Parallax-Effekte
- Explosionen und weitere visuelle Effekte

Ein Teil der Grafiken wurde mit Paint.NET erstellt. Für die Audioentwicklung wurde unter anderem Samplitude verwendet.

## 7. Steuerung

Das Spiel wurde bisher insbesondere für Gamepads entwickelt und orientiert sich an Xbox-Controllern.

Gamepad und Tastatur sind in der HTML5-Pre-Alpha verfügbar. Tastaturbelegung, Umbelegung, Speicherung und Wiederherstellung der Standardtasten wurden umgesetzt und vom Entwickler geprüft; der aktualisierte itch.io-Draft-Embed wurde am 18.11. mit 12/12 bestanden gemeldet. Belegumfang und spätere Änderungen stehen in [HANDOFF.md](HANDOFF.md), aktuelle Bedienhinweise in [README.md](README.md). Kompatibilität mit weiteren Browsern und Controllern bleibt gezielt zu prüfen.

## 8. Erste Veröffentlichung: HTML5-Pre-Alpha, danach Alpha

### Zielplattform

**HTML5**, mit einer Veröffentlichung auf itch.io als erstem Ziel.

Ein Windows-Build kann später zusätzlich angeboten werden.

### Veröffentlichungsrahmen

Die HTML5-Pre-Alpha ist laut Entwickler über die Secret URL der bewusst im Draft belassenen itch.io-Seite für ausgewählte Tester zugänglich. Ein Wechsel auf Published wird gesondert entschieden; Beta 0.9 oder 1.0 sind keine beschlossenen Veröffentlichungstermine. Der Entwickler möchte den von ihm berichteten einmaligen Sichtbarkeitsschub aufbewahren; diese Plattformannahme ist hier nicht unabhängig verifiziert. Öffentliche Texte werden in englischem Markdown vorbereitet, 💚 bleibt die vereinbarte Kennzeichnung.

Es besteht keine feste Release-Deadline. Den verbleibenden Real-Alpha-Umfang hält [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md) fest. Balancing, Deployment und HTML5-Themen erhalten bei Bedarf eigene Chats. Ein öffentlicher Build benennt seinen tatsächlichen Eingabeumfang, Entwicklungsstand und bekannte Einschränkungen; der aktuelle Codebranch belegt keine bereits erfolgte Auslieferung.

Der akzeptierte Alpha-Walker bleibt Referenz. Möglicherweise frameabhängige Spawnwahrscheinlichkeiten sind eine Untersuchungsidee, kein nachgewiesener Defekt. Energie- und andere Balancingwerte sind vorläufig; technische Werte werden in [TECHNICAL.md](TECHNICAL.md) gepflegt.

### Verbindliche Anforderungen

- Das Spiel ist im Browser spielbar.
- Die grundlegende Steuerung funktioniert zuverlässig.
- Die wesentlichen Bewegungs- und Kampfmechaniken sind benutzbar.
- Der Walker ist als funktionsfähiger Gegner integriert.
- Kritische Fehler, die das Spielen verhindern, sind behoben.
- Ein getesteter Alpha-Build kann veröffentlicht werden.

### Noch zu klären

- Genauer Umfang bzw. mögliches Ziel einer Spielrunde
- Verbleibender Umfang weiterer Gegner und Warn-/Hilfefunktionen
- Konkrete Abschlussbedingungen der Real Alpha, einschließlich gebündelter Integrationstests

Menü, Pause, Tod/Neustart und Tastatur sind bereits vorhanden und vom Entwickler getestet gemeldet. Der noch festzulegende Releaseumfang wird nur in der jeweiligen Roadmap gepflegt.

Die Alpha soll bewusst klein bleiben.

## 9. Mögliche Erweiterungen

### Informationsavatar

Es wird überlegt, einen Avatar einzublenden, der Sonec mit Informationen versorgt.

Dieser könnte Hinweise zur Spielwelt, zur Situation oder zu Aufgaben geben.

Für die Gestaltung eines entsprechenden Kopfes ist **HAELE 3D Portraitstudio** vorgesehen. Nach bisheriger Einschätzung könnte dafür die Pro-Version erforderlich sein; dies ist noch nicht verifiziert.

Die bevorzugte Darstellungsform sind **animierte Porträtbilder**. Ein dreidimensionales Kopfmodell bleibt theoretisch möglich, ist derzeit aber nicht die bevorzugte Lösung.

Die Entscheidung über Aussehen, technische Umsetzung und Integration steht noch aus.

**Vorhandene Basis (Abgleich 20. November 2026):** Die Textwarnung `MINEFIELD DETECTED` und positive Upgrade-Meldungen sind umgesetzt und vom Entwickler funktional geprüft. Weitere avatarspezifische Symbole, ein animiertes Avatarbild oder Sprachausgabe bleiben Optionen. Weitere Warnfälle, Wiederholraten und Hilfeumfang gehören in die Releaseplanung; ein vollständiger Avatar ist damit noch nicht beschlossen.

### Aufgaben und Missionen

Eine spätere Erweiterung durch Aufgaben oder Missionen ist denkbar.

Ob diese durch den Informationsavatar vermittelt werden und wie sie sich in den Spielablauf einfügen, ist noch nicht entschieden.

### Weitere Entwicklungsziele

- Online-Highscore-System für eine spätere Beta
- Zusätzliche Gegner und Spielinhalte
- Verbesserungen an Benutzeroberfläche, Grafik und Sound
- Weitere Bezüge zum übergeordneten Universum

Diese Ideen sind noch keine verbindlichen Anforderungen an die Alpha.

## 10. Entwicklungsmethode

Das Projekt wird in kleinen, überschaubaren Schritten entwickelt.

1. Vorhandenen Code zunächst verstehen.
2. Bestehende Funktionen möglichst erhalten.
3. Fehler von unvollständigen Funktionen unterscheiden.
4. Änderungen einzeln planen und freigeben.
5. Keine ungefragten Refaktorierungen.
6. Nachvollziehbare Commits verwenden.
7. Erkenntnisse am passenden Ort dokumentieren; bei Chatwechsel zuerst `AGENTS.md`, den kurzen `HANDOFF.md` und den aktuellen GitHub-HEAD lesen, danach nur aufgabenrelevante Fachabschnitte.

Die Entwicklung erfolgt im Branch `develop`.

Der Branch `main` bleibt vorerst die Referenz für den bisherigen eingecheckten Stand.

## 11. Projektdokumentation

- [HANDOFF.md](HANDOFF.md) – Kurzer Chatübergang, Evidenz und genau ein nächster Schritt
- `README.md` – Öffentlicher Projekt-/Release-/Eingabestatus
- `AGENTS.md` – Arbeitsregeln für Coding-Agenten
- `PROJECT.md` – Spielkonzept, Projektgeschichte und Ziele
- `TECHNICAL.md` – Technischer Aufbau und bestätigte Codebefunde
- [TODO.md](TODO.md) – Nur die unmittelbar nächsten Aufgaben
- [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md) – Umfang und Abschlusskriterien dieses Releases; weitere Roadmaps erst bei konkreter Releaseplanung
- [BACKLOG.md](BACKLOG.md) – Unverbindliche spätere Ideen
- [Archiv](docs/archive/README.md) – Abgelöste Langfassungen zur gezielten Nachschau

Unbestätigte Annahmen dürfen nicht als gesicherte Eigenschaften des Spiels dargestellt werden.

## 12. Offene Projektentscheidungen

- Endgültiger Spieltitel
- Genauer Umfang der Alpha
- Weitergehende Browser-/Controller-Kompatibilität und spätere Bedienoptionen
- Ablauf einer vollständigen Spielrunde
- Konkrete Rolle des Anzugs bei einzelnen Fähigkeiten
- Informationsavatar und dessen Darstellung
- Mögliche Aufgaben und Missionen
- Späteres Veröffentlichungs- und Versionsschema

**Arbeitsplanung:** Aktueller Wiedereinstieg und nächster Schritt stehen in [HANDOFF.md](HANDOFF.md), der verbleibende Releaseumfang in [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md). Die akzeptierten Walker-/IK-/Grafikwerte bleiben Referenz.

