# SonecBot – Projektübersicht

**Dokumentstatus:** Version 0.3  
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

### Waffen und Verteidigung

Im bisherigen Spielkonzept sind folgende Systeme vorgesehen beziehungsweise teilweise implementiert:

- Maschinengewehr
- Flammenwerfer
- Aufladbare Plasma- beziehungsweise Energiewaffe
- Granatwerfer
- Energieschild
- Weitere energieabhängige Fähigkeiten

Der tatsächliche Implementierungsstand wird in `TECHNICAL.md` festgehalten.

## 5. Gegner und Gefahren

### Minen

Minen können die Spielfigur verfolgen und stellen eine bewegliche Gefahr dar.

Ein entsprechendes System ist im AGK-Quellcode vorhanden.

### Walker

Der Walker ist ein größerer, mehrteiliger Gegner mit gelenkbasiert animierten Körperteilen und einem drehbaren Waffenaufbau.

Für die aktuelle AGK-Version sind schwere Maschinengewehre als Bewaffnung vorgesehen.

**Aktueller Stand (November 2026):** Der Walker ist als beweglicher, mechanisch animierter und zerstörbarer Gegner im lokalen Spieltest bestätigt. Maschinengewehr-Projektile treffen derzeit ausschließlich den Turm; bei Treffern blinkt dieser kurz rot. Die Grafiken wurden auf neutrale Graustufen umgestellt, die Standardfarbe wird im Code grün gesetzt. Bei Zerstörung entstehen Energie-Bubbles. Die Animation darf vorerst bewusst mechanisch wirken.

**Später zu prüfen:** Torso als zusätzliche Trefferzone für ein faireres Spielgefühl, Feinschliff der Animation und das übergreifende Kollisionskonzept. Eine eigene Walker-Bewaffnung ist damit noch nicht als funktionsfähig bestätigt.

**Projektentscheidung: Ein funktionsfähiger Walker ist Pflichtbestandteil der ersten Alpha-Version.**

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

Für die HTML5-Version müssen Browser- und Gamepad-Kompatibilität überprüft werden.

Ob eine zusätzliche Tastatursteuerung erforderlich ist und wie diese umgesetzt wird, ist noch nicht abschließend festgelegt.

## 8. Erste Veröffentlichung: Alpha

### Zielplattform

**HTML5**, mit einer Veröffentlichung auf itch.io als erstem Ziel.

Ein Windows-Build kann später zusätzlich angeboten werden.

### Verbindliche Anforderungen

- Das Spiel ist im Browser spielbar.
- Die grundlegende Steuerung funktioniert zuverlässig.
- Die wesentlichen Bewegungs- und Kampfmechaniken sind benutzbar.
- Der Walker ist als funktionsfähiger Gegner integriert.
- Kritische Fehler, die das Spielen verhindern, sind behoben.
- Ein getesteter Alpha-Build kann veröffentlicht werden.

### Noch zu klären

- Genauer Umfang einer Spielrunde
- Anforderungen an Menü, Pause, Tod und Neustart
- Tastatursteuerung zusätzlich zum Gamepad
- Mindestumfang weiterer Gegner
- Konkrete Abschlussbedingungen der Alpha

Die Alpha soll bewusst klein bleiben.

## 9. Mögliche Erweiterungen

### Informationsavatar

Es wird überlegt, einen Avatar einzublenden, der Sonec mit Informationen versorgt.

Dieser könnte Hinweise zur Spielwelt, zur Situation oder zu Aufgaben geben.

Für die Gestaltung eines entsprechenden Kopfes ist **HAELE 3D Portraitstudio** vorgesehen. Nach bisheriger Einschätzung könnte dafür die Pro-Version erforderlich sein; dies ist noch nicht verifiziert.

Die bevorzugte Darstellungsform sind **animierte Porträtbilder**. Ein dreidimensionales Kopfmodell bleibt theoretisch möglich, ist derzeit aber nicht die bevorzugte Lösung.

Die Entscheidung über Aussehen, technische Umsetzung und Integration steht noch aus.

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
7. Erkenntnisse dokumentieren.

Die Entwicklung erfolgt im Branch `develop`.

Der Branch `main` bleibt vorerst die Referenz für den bisherigen eingecheckten Stand.

## 11. Projektdokumentation

- `AGENTS.md` – Arbeitsregeln für Coding-Agenten
- `PROJECT.md` – Spielkonzept, Projektgeschichte und Ziele
- `TECHNICAL.md` – Technischer Aufbau und bestätigte Codebefunde
- `TODO.md` – Aufgaben, bekannte Probleme und Meilensteine

Unbestätigte Annahmen dürfen nicht als gesicherte Eigenschaften des Spiels dargestellt werden.

## 12. Offene Projektentscheidungen

- Endgültiger Spieltitel
- Genauer Umfang der Alpha
- Steuerungskonzept für HTML5
- Ablauf einer vollständigen Spielrunde
- Konkrete Rolle des Anzugs bei einzelnen Fähigkeiten
- Informationsavatar und dessen Darstellung
- Mögliche Aufgaben und Missionen
- Späteres Veröffentlichungs- und Versionsschema

**Nächster Meilenstein:** HTML5-Build und Gamepad-Steuerung praktisch testen; anschließend die noch offenen Alpha-Anforderungen priorisieren.
