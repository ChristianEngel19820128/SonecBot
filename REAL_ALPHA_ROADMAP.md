# SonecBot – Real Alpha Roadmap

**Stand:** 17. November 2026  
**Status:** gemeinsam vereinbarte Entwicklungsrichtung; **Planung, keine Freigabe zur Implementierung einzelner Gameplay-Funktionen**  
**Branch:** `develop`  
**Verwandte Dokumente:** [HANDOFF.md](HANDOFF.md) · [TODO.md](TODO.md) · [PROJECT.md](PROJECT.md) · [TECHNICAL.md](TECHNICAL.md)  
**Wichtig:** Die öffentlich sichtbare itch.io-Seite bleibt bis zu einer gesonderten Entscheidung im **Draft/Secret-URL-Modus**. Kein `main`-Merge oder Publish aufgrund dieses Dokuments.

## 1. Zielbild und bewusst begrenzter Umfang

SonecBot soll von einer spielbaren HTML5-Pre-Alpha zu einer **verständlich spielbaren Real Alpha** wachsen. Die drei gemeinsam **priorisierten und überschaubar gehaltenen Kernfeatures** sind:

1. **Minenvarianten:** intelligente/verfolgende Minen bleiben einzeln; einfache, nicht verfolgende Minen treten in **Feldern/Rudeln** auf.
2. **Drohnen:** neue, zunächst einfache Gegner, die **von links nach rechts schweben**.
3. **Warn-/Avatar-Hilfesystem:** kurze, kontextbezogene Hinweise **oben im laufenden Spiel**, als Ausbau des bereits angedachten `MINEFIELD DETECTED`-Ansatzes.

**Nicht gleichzeitig anfangen.** Die drei Features einzeln konkretisieren, schmal implementieren, lokal mit AGK Studio / HTML5 testen und ausdrücklich abnehmen. Entscheidend sind Lesbarkeit, Fairness, kontrollierbarer Schwierigkeitsanstieg und ein übersichtlicher Entwicklungsumfang – nicht möglichst viele neue Gegner.

### Grundgedanke aus dem ersten Community-Feedback

Erstes externes Feedback (17.11.2026): Grundidee und Animationen gefallen; Spieler meldet gelegentliches Durchfallen durch Plattformen, als sehr stark empfundene Beschleunigung, unklare linke Anzeigen, unverständliche plötzliche Todesfälle und scheinbar wirkungslose Rifle. **Dies sind Spielerbeobachtungen, keine automatisch bestätigten Bugs.**

Gemeinsame Einordnung des Entwicklers:
- **Schnelles Durchfallen** ist grundsätzlich als Spielmechanik geplant: „it's not a bug, it's a feature“. Dennoch **Fairness und erkennbare Ursache** prüfen; nicht ohne Abstimmung die Mechanik abschaffen.
- **Beschleunigung:** physikalisches Verhalten und tatsächlichen Bewegungs-/Bremsweg prüfen, bei Bedarf später anhand messbarer Vergleichstests anpassen.
- **HUD:** Erklärung der linken Anzeigen; vertikal gesetzter Text wäre bei Platzmangel möglich, rotierende/kontextuelle Hilfe ebenfalls.
- **Tod/Schaden:** vor allem fehlendes akustisches Feedback bei Bullet-Treffern; Avatar soll helfen. Vorhandene Idee für eine **Top-Warnmeldung** im Spiel eignet sich als Einstieg. Ursache und Anzeige von Minen, Überladung, Schild, Schaden unterscheiden.
- **Rifle:** rotes Treffer-Aufleuchten existiert bereits, kann aber zu wenig sein; Projektile und Kollisionsflächen prüfen. **Walker ist derzeit vor allem am Turm empfindlich**, Erweiterung der verwundbaren Zonen für später erwünscht; keine voreilige Behauptung, dass alle Projektile durchfliegen.
- Diese Themen gehören überwiegend zur **Real Alpha**, nicht zum aktuell klein gehaltenen Keyboard-/Pre-Alpha-Patch.

## 2. Vorbedingung: Pre-Alpha-/Keyboard-Patch abschließen

**Diese Phase ist vor jeder Real-Alpha-Featureimplementierung abzuschließen.**

### Stand der Persistenz

- OPTIONS-Untermenüs `GAMEPLAY / CONTROLS / AUDIO / BACK` durch Entwickler **14/14 bestanden**.
- Schritt **7e.1**: `GameOptions`-Hover-Modus für Windows und lokales HTML5 gespeichert, **12/12 bestanden**, Windows-Datei vom Entwickler zusätzlich geöffnet und geprüft.
- Schritt **7e.2**: separater, versionierter `KeyBindings`-Datensatz (15 Keyboard/Gamepad-Paare) auf `develop`, alle **10/10 Funktionschecks durch Entwickler bestätigt**. Test A: Gültige Datei, Key0 `87` (W) → `38` (Pfeil hoch), geänderte Bindung wird geladen. Test B: Versionsnummer auf `2` setzen; unbekannte Version führt zur **Standardbelegung**. **Wichtig:** anfängliche Aussage, die Datei sei beim Versionswechsel automatisch überschrieben worden, war **ein Beobachtungsfehler des Entwicklers**; er hatte Zahlen verwechselt. Der ursprüngliche Codevertrag bleibt gültig: Daten mit unbekannter Version werden nicht automatisch überschrieben. Keine Fehlerbehebung nötig.
- `CONTROLS` ist weiterhin ein **Platzhalter**, keine interaktive Remapping-Oberfläche. Speichercode ist vorbereitet; neue Belegungen wurden bisher nur manuell in der Datei getestet.

### Konkreter nächster Arbeitsabschnitt: Keyboard-Patch

1. Gemeinsam **engen UI-Umfang des Rebinding-Patches freigeben**, bevor Source verändert wird: Keyboard-Belegung unter `CONTROLS > KEYBOARD`; Gamepad-Umbelegung nicht stillschweigend mitbauen.
2. Sichere Steuerung beim Belegungsdialog: Auswahl, Tastenerkennung, Konflikte/Doppelbelegung, reservierte Tasten und garantierte Rückkehr (START/BACK nicht verlieren) vor Implementierung entscheiden. Gamepad-Y bleibt Menü-BACK, im Spiel Plasma.
3. Neue Belegungen über bestehende **eine** `KeyBindings`-Speichergruppe persistieren; `GameOptions` bleibt getrennt.
4. Eine **„RESTORE DEFAULTS“**-Funktion wurde vorgemerkt. Umfang und Platzierung (nur Keyboard, ganze Controls, Gameplay getrennt) sowie Bestätigungsdialog **vor Implementierung besprechen**; keine automatische ungefragte Löschung der gespeicherten Daten.
5. Nach jedem kleinen Schritt AGK-Compile, Windows- und ggf. lokaler Apache-/HTML5-Test mit Regression der bisherigen Gamepad-, Menü- und Gameplay-Steuerung. Fehler vor neuer Arbeit eingrenzen.
6. **Ganz am Ende des Pre-Alpha-Patches**, und erst mit gesondertem Bildauftrag: ein **kleines Tastatur-/Keyboard-Patch-Promobild**, gestalterisch verwandt mit dem bestehenden Cover. Jetzt weder Artwork generieren noch itch.io hochladen.
7. itch.io-Seite bleibt Draft, keine automatische Aktualisierung oder Veröffentlichung.

**Wiedereinstieg im neuen Chat:** `AGENTS.md`, `HANDOFF.md`, diese `REAL_ALPHA_ROADMAP.md`, `TODO.md` und tatsächlichen `develop`-HEAD prüfen; **als erstes Keyboard-Rebinding-Patch eng spezifizieren/freigeben**. Keine Real-Alpha-Feinde parallel implementieren.

## 3. Real Alpha – Kernfeature 1: Minefields und intelligente Minen

### Spielidee

Bisherige intelligente Minen weiterhin **einzeln** und mit vorhandener Bewegung/Annäherung an Sonec. Zusätzlich ein **einfacher Minentyp** für erkennbare **Minenfelder bzw. Rudel**, ohne aktive Verfolgung von Sonec. So entstehen zwei deutlich unterscheidbare Gefahren: gezielte Bedrohung versus Raumkontrolle.

### Entwurfsfragen vor Code

- Eindeutige visuelle Unterscheidung der Minentypen (Form, Farbe, Bewegung).
- Regel für Gruppengröße, Abstand, Spawnregion, Lebensdauer, maximale gleichzeitige Minenzahl und Performance.
- Wie bewegen sich einfache Minen in der Welt, wenn sie Sonec **nicht verfolgen**? „Nicht verfolgen“ heißt nicht automatisch vollkommen statisch.
- Spawn-Fairness: niemals unangekündigt direkt in Sonec oder an Stellen, aus denen man nicht ausweichen kann; Mindestabstände und Sichtbarkeit.
- Zusammenhang mit der Warnung `MINEFIELD DETECTED`: Warnung früh genug, aber keine ständigen Spams.
- Bestehende Minen/Explosions-Kettenreaktionen und Energieanziehung beachten; diese zieht bereits Minen an.
- Bestehende frameabhängige Zufalls-Spawns sind **als Beobachtung dokumentiert**, nicht pauschal umzubauen; auf tatsächliche Dichte und Frame-Rate prüfen.

### Akzeptanzkriterien (Entwurf)

Intelligente Einzelminen verhalten sich wie bisher; einfache Minen verfolgen Sonec nicht; Minenfelder sind sichtbar unterscheidbar, beherrschbar, nicht unfair bei Spawn/Bewegung und verursachen keine ungewollten Performance-/Kollisionseffekte. Gamepad, Waffen, Explosionsreaktionen und HTML5 bleiben funktional.

## 4. Real Alpha – Kernfeature 2: Schwebende Drohnen

### Spielidee

Ein neuer, zunächst **einfacher fliegender Gegner**, der sich **von links nach rechts** durchs Bild beziehungsweise den sichtbaren Weltbereich bewegt. Nicht von Anfang an komplexe KI oder Angriffssysteme voraussetzen. Drohnen schaffen eine eigene vertikale Gefahr und nachvollziehbare Ziele für Waffen.

### Entwurfsfragen vor Code

- Höhe, Geschwindigkeit, Eintritt/Austritt, Sichtbarkeit, Maximalzahl, Spawnabstand und Rücksicht auf Kamera/Plattformen.
- Kollisionshülle, Gesundheit, Trefferbereiche, Projektilreaktionen, Explosion und Sound.
- Muss die erste Drohne angreifen oder reicht vorerst Überflug/Kontaktgefahr? **Noch offen**.
- Trefferklarheit und Feedback: besonders MG/Rifle und Plasma; sichtbare Trefferwirkungen bestätigen.
- Basisgrafik vorhanden? **Für Drohnen noch nicht bestätigt**, vor Artwork-Bau prüfen.

### Akzeptanzkriterien (Entwurf)

Drohnen schweben verlässlich auf der festgelegten Route, sind sichtbar und fair, Treffer/Schaden sind erkennbar, keine Kollisionseffekte auf Walker/Plattformen, stabile Windows-/HTML5-Läufe.

## 5. Real Alpha – Kernfeature 3: Top-Warnungen / Avatar-Unterstützung

### Spielidee

Die angedachte Meldung **`MINEFIELD DETECTED` oben im laufenden Spiel** wird zu einem **kleinen wiederverwendbaren Hinweis-/Warnsystem** ausgebaut. Langfristig hilft der Avatar; sein tatsächlicher Darstellungs-/Audioanteil ist erst zu entwerfen. Keine Annahme, dass es bereits ein fertiges Hilfesystem gibt.

### Vorschläge für Warnfälle (noch nicht endgültig)

- `MINEFIELD DETECTED` – räumliche Gefahr, abgestimmt auf Minenfeldspawn.
- `ENERGY OVERLOAD` – erklärt, dass Überladung gesundheitsschädlich sein kann.
- `SHIELD DOWN` / `LOW ENERGY` – Schutz-/Energiereserven.
- `CRITICAL DAMAGE` – gefährlicher Gesundheitsschaden.
- Spätere Gegner: `BOMBER APPROACHING`, `MISSILE LOCK` erst, **wenn** diese Mechaniken existieren.

### Gestaltung und Architektur

- Kurzer Text **oben**, damit HUD links und Action-Fokus erhalten bleiben.
- Priorität bei konkurrierenden Meldungen, Cooldown, Mindest-/Maximaldauer, keine Textüberflutung.
- Unterschied zwischen Warnung, kurzer Anleitung und Todesursache. Nicht jeden Spielzustand als Alarm ausgeben.
- Farbigkeit/Transparenz im bestehenden Cyan-/HUD-Stil testen, gute Lesbarkeit auf HTML5 und kleinen Screens.
- Warnungen können später mit einfachen Sounds/Avatar kombiniert werden, aber **Sound und Instanzlogik** separat testen.
- Gegebenenfalls Hilfetext-Definitionen später strukturiert/extern, z. B. JSON; aktuell nur Zukunftsidee und kein automatischer Umbau.

### Akzeptanzkriterien (Entwurf)

Warnungen erscheinen im richtigen Moment, bleiben ausreichend lang, stören weder Gameplay noch Menüsteuerung, erscheinen nicht ständig wiederholt und erklären mindestens eine zuvor unverständliche Gefahr; lokaler AGK-/HTML5-Test mit Entwicklerabnahme.

## 6. Weitere Real-Alpha-Kandidaten – bewusst nachrangig

Diese Ideen sind **nicht Bestandteil der drei vorrangigen Kernfeatures**. Nur später gezielt priorisieren:

| Kandidat | Aktueller Stand | Besonderheit |
|---|---|---|
| **Bomber** | Vorversion der Grafiken laut Entwickler vorhanden | Hoher Überflug, mehrere Bomben in Salven; Warnzeit, Fallbahn, faire Ausweichmöglichkeit, Kamera |
| **Flarakstellung** | Vorversion der Grafiken laut Entwickler vorhanden | Fährt aus dem Boden, feuert mehrere zielgesteuerte Raketen; komplexere Zustands-/Ziel-/Projektil-Logik |
| **MG/Rifle-Trefferfeedback und Hitboxen** | Rotes Aufleuchten existiert, frühere Trefferchecks erfolgreich; neuer Spieler unsicher | Walker ist aktuell vor allem am **Turm** verletzbar; weitere empfindliche Bereiche prüfen, keine Trefferprobleme unbelegt behaupten |
| **Bewegungsphysik und Fall-Fairness** | Community-Spieler meldet „Raketenbeschleunigung“ und Plattformdurchfall | Schnelles Durchfallen ist **bewusst vorgesehen**, aber auf Fairness/physikalische Plausibilität testen |
| **Schaden-/Tod-Erklärung** | Spieler versteht Ursachen teilweise nicht | Bullet-Soundfeedback fehlt laut Entwickler, mögliche Warn-/Avatar-Anbindung, Overload und Tod durch Weltgrenze beachten |
| **HUD-Beschriftung/Tutorial** | Linke Balken unverständlich für Erstspieler | Gesundheit/Schild, Energie/Overload, MG-/Granatenmunition; vertikaler Text möglich, kontextbezogene Hilfe bevorzugt ausprobieren |
| **Kleines Missions-/Überlebensziel** | Reiner Vorschlag, nicht beschlossen | Orientierung geben ohne großes Missionssystem |
| **Phasen-/Wellensteuerung** | Reiner Vorschlag, nicht beschlossen | Erst nach vorhandenen Gegnern; aktuelle Spawnlogik nicht beiläufig ersetzen |
| **HTML5-Sound-Überlagerung** | Entwickler beobachtet Kratzen bei überlappenden SFX | Separater **Knowledge-Base-Kandidat**; Soundinstanzen, Summenpegel/Clipping und Absenkung laufender Instanzen **erst reproduzieren**, kein bestätigter Fix |

### Reihenfolge innerhalb der Real Alpha

- **Kernentwicklung:** (1) Minenvarianten, (2) Drohnen, (3) Warnsystem – Warnsystem darf konzeptionell parallel geplant werden, nicht ungeprüft in fremde Features eingreifen.
- **Qualität/Verständlichkeit:** Kollisions-/Physik-Fairness, Treffer-/Todesfeedback, HUD/Anleitung passend zu Testerbefunden in kleinen Einzelprüfungen.
- **Optional danach:** Bomber, Flarakstellung, einfache Ziele, Wellenlogik – nur wenn Umfang und Testaufwand vertretbar sind.

Keine feste Deadline oder Release-Versprechen.

## 7. itch.io-Plan für beide Spiele – Inhalt zunächst vorbereiten

Die folgende **gemeinsame Inhaltsidee gilt für SonecBot und Columns**, aber Änderungen an beiden itch.io-Seiten bleiben manuell und nur nach Freigabe:

- **COMING SOON** – kurze, realistische Vorschau auf tatsächlich geplante Features; klar von verfügbaren Features unterscheiden. Bei SonecBot ggf. drei Kernfeatures und später Bomber/Flarak **als Pläne**, nicht als bereits spielbar ausgeben.
- **TIPS & TRICKS** – verständliche Bedienungs- und Spielhinweise, möglichst aus Nutzerfragen/Feedback: Schild/Energie/Overload, Gefahr durch Minen, Bewegung, Waffen/Verwundbarkeit; für Columns später entsprechend eigenständig ausarbeiten.
- Englisches Markdown für itch.io vorbereiten, keine neuen Termine, keine unbestätigten technischen Behauptungen, keine automatische Umstellung auf Published.
- **Pre-Alpha-Abschluss-Promobild mit Keyboard** für SonecBot erst **am Ende** des Keyboard-Patches, als eigener freigegebener Gestaltungsauftrag.

## 8. Columns – nur projektübergreifende Übergabe, keine Änderungen im anderen Repo

Der Entwickler hat folgende Arbeiten für **Columns** genannt:

- **Columns 1.1 hat vorerst keine Priorität.**
- **Eigenes TODO-Dokument** im Columns-Repository erstellen, **nur sofern dort noch keines existiert**; vorhandene TODO nicht überschreiben und zuerst die aktuelle Projektlage/Branch-Regeln prüfen.
- `AGENTS.md` für Columns ist eine **Baustelle** und soll später gesondert überarbeitet werden.
- **Zwei Theme-Tracks** für Columns sollen später entstehen (Kompositions-/Lizenz-/Format- und Looppunkte vorher besprechen).
- itch.io-Seite später mit **COMING SOON** und **TIPS & TRICKS** verbessern, im gleichen Arbeitsgang wie SonecBot oder besser im separaten Columns-Chat. Inhalte/Releaseplan für Columns nicht aus SonecBot ableiten.

**Zugriffslücke am 17.11.2026:** Die aktuell angeschlossene GitHub-Installation listet Columns **nicht** als zugängliches Repository; Suche nach Columns und `ChristianEngel19820128/Columns` ohne Treffer. Deshalb **kein Columns-TODO angelegt** und keine `AGENTS.md`-Änderung vorgenommen. Erst bei Zugang/konkreter Repositoryadresse und Projektregeln in eigenem Columns-Chat handeln. Diese Roadmap hält die Informationsbrücke.

## 9. Zusammenarbeit und Abnahme

- In allen Folgeschritten zunächst `AGENTS.md` beachten: **read-only als Standard**, nur **eng vom Besitzer freigegebene** Änderungen.
- `develop` ist der Arbeitsbranch; `main`, `source/legacy`, itch.io und das unabhängige AGK-Knowledge-Base-Repo bleiben ohne separate Freigabe unberührt.
- Jede einzelne Änderung: GitHub-HEAD prüfen → genaue Quelllage verstehen → gewünschtes Verhalten vereinbaren → minimal ändern → statisch kontrollieren → Entwickler kompiliert/prüft Windows und HTML5 → Bericht auswerten → dokumentieren → erst dann nächster Schritt.
- Prüfberichte präzise auseinanderhalten: **Spielerfeedback**, **Hypothese**, **Quellprüfung**, **lokaler AGK-Test** und **Browser-/itch.io-Test**.
- Keine generelle automatische „Fehlerbereinigung“ und keine Balanceänderung nur aufgrund eines Kommentars.
- Bei Chatwechsel: dieses Dokument und die frisch ergänzte Top-Sektion in `HANDOFF.md` sind die **aktuelle Richtung**. Ältere anderslautende offene Einträge sind Projektgeschichte.

## 10. Ein Satz für den nächsten Chat

> **SonecBot weiter auf `develop`. 7e.1 bestanden, 7e.2 mit 10/10 Funktionschecks bestanden (Datei-Neuschreiben bei ungültiger Version war ein Beobachtungsfehler). Jetzt zuerst Keyboard-Rebinding-/Reset-Umfang eng abstimmen und Pre-Alpha-Patch fertigstellen. Tastatur-Patchbild erst ganz am Ende. Danach Real Alpha mit genau drei priorisierten Kernfeatures: Minenfelder plus intelligente Einzelminen, links-nach-rechts schwebende Drohnen und Top-/Avatar-Warnsystem. Feedback zu Plattform-Fairness, Beschleunigung, HUD, Tod und Rifle als Untersuchungs-/Qualitätsthemen erhalten. Columns 1.1 ohne Priorität; eigenes TODO, AGENTS.md und zwei Theme-Tracks später separat. itch.io für beide Spiele später mit COMING SOON und TIPS & TRICKS verbessern; nicht publishen.**
