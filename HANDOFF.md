# Übergabe: Alpha-Walker abgeschlossen → HTML5-Pre-Alpha

**Stand:** 16. November 2026  
**Ziel:** HTML5-Pre-Alpha kontrolliert testen und ausgewählten Personen über itch.io-Draft/Secret-URL zugänglich machen; öffentliche Veröffentlichung später entscheiden  
**Status:** Alpha-Walker abgeschlossen; **HTML5-Export und erster lokaler Browserstart laut Entwickler bestanden**; weitere Gamepad-/Pause-/Tod-/Neustarttests und Draft-Upload noch offen, kein öffentlicher Publish geplant  
**Repository:** ChristianEngel19820128/SonecBot  
**Arbeitsbranch:** `develop`  
**Letzter lokal getesteter Codecommit:** [`18f92a965810763b552bd96649607c112f966238`](https://github.com/ChristianEngel19820128/SonecBot/commit/18f92a965810763b552bd96649607c112f966238)

> Der Nutzer bestätigt nach dem letzten 3-px-Turmrückstoß: „test bestanden. funktioniert alles wie erwartet.“ Anschließend ausdrücklich: „aufgabe Alpha Walker abgeschloßen.“
> Jetzt Deployment fortsetzen, nicht die Walker-Entwicklung neu beginnen. Der tatsächliche develop-HEAD muss neu abgefragt werden; diese Übergabe selbst ist ein nachfolgender Dokumentationsstand.

> **Aktuelle gemeinsame Entscheidung (16. November 2026; ersetzt ältere Termin-/Veröffentlichungsformulierungen unten):** Kein hektischer öffentlicher Release am 16. November. Die HTML5-Pre-Alpha ist für die AGK-Community und ausgewählte Personen bestimmt. Die itch.io-Seite bleibt absichtlich **Draft**; der **Secret-URL-Link** ermöglicht den Zugang für alle, die ihn besitzen. Die Umstellung auf **Published** wird bewusst zurückgehalten, weil laut Entwickler der einmalige itch.io-Index-Push dadurch ausgelöst wird und später nicht erneut verfügbar ist. Veröffentlichung eventuell zu Beta 0.9 oder 1.0, **noch offen**. Kein Publish ohne ausdrückliche Freigabe. Der Besitzer pflegt itch.io manuell; Texte dafür **in englischem Markdown**. 💚 ist das vereinbarte Zeichen für README und itch.io.
>
> **Arbeitsweise:** In kleinen gemeinsam freigegebenen Schritten vorgehen. Nutzer exportiert/kompiliert in lokalem AGK Studio, testet mit lokalem Apache im Browser/Gamepad und pflegt itch.io; Assistent prüft GitHub-Quellen und dokumentiert präzise, ohne lokale Tests zu behaupten. Besonderheiten mit Nachweisstatus festhalten, aktuellen Schritt beenden, erst danach über Folgearbeit bzw. Knowledge-Base-Eintrag entscheiden. Crystals 1.0 ist die bewährte Prozesserfahrung. GitHub-HEAD bei jedem Einstieg neu lesen; Snapshot vor dieser Dokumentationsänderung: `3840bfa545aeec6df6902180415d22efdd58f3ba`.
> **Prüfkandidat, noch kein bestätigter Bug:** Spawn-Zufallsentscheidungen liegen in `GameDo()` und könnten pro Frame statt pro Zeit erfolgen. Vor jeder Änderung tatsächliche Frequenzen/Spielwirkung bewerten; keine pauschale Balancingmaßnahme.

## Aktueller HTML5-Testbefund (Entwicklermeldung, 16. November 2026)

- **Bestanden:** HTML5-Export mit lokalem AGK Studio; Browserstart über lokalen Apache/XAMPP im gemeinsam entwickelten Frame mit Run-Knopf (vergleichbar mit der geplanten itch.io-Einbettung). Spiel startet.
- **Darstellung:** Entwickler berichtet flüssiges Gameplay bei 60 Hz mit VSync und auch bei einer kurzen Umstellung auf 75 Hz. Für weitere Tests bleibt die Windows-Bildwiederholrate **60 Hz**. Das sind subjektive lokale Beobachtungen, kein unabhängiger Browser-/Performance-Benchmark.
- **Noch offen:** genaue exportierte Code-Revision nicht separat bestätigt; Browser-/Controllerkombination, alle Funktionen, Pause, Tod, zwei Neustarts und itch.io-Einbettung nicht als bestanden markieren.
- **XAMPP-Cache-Hinweis als Knowledge-Base-Kandidat:** Nach Austausch der HTML5-Dateien während des Entwickelns Browser-Cache deaktivieren (z. B. DevTools/Network „Disable cache“, wirksam bei geöffneten DevTools) und neu laden, sonst kann die alte Version weiter erscheinen. Entwicklerbeobachtung, noch kein separater plattformübergreifender Nachweis oder eigenständiger KB-Eintrag.
- **Nächste fachliche Prüfung (noch kein Änderungsauftrag):** Welche fehlenden Kollisionsabfragen wirken im Test widersprüchlich, wenn Treffer keine Wirkung zeigen? Relevante Aufrufpfade, Absichten und Priorität untersuchen, bevor Code verändert wird. Spawn-Zeitbasis bleibt separater Kandidat.
- **Arbeitsregel:** Beobachtung festhalten, aktuellen Prüfschritt abschließen, anschließend **gemeinsam** den nächsten Schritt wählen. Kein neues Walker-Polishing.

## 1. Sofortiger Einstieg im neuen Chat

1. `AGENTS.md`, diese Datei, `PROJECT.md`, die aktuelle `TODO.md` und den aktuellen Status/Übergabeabschnitt in `TECHNICAL.md` lesen. Alte datierte Technikabschnitte sind Historie, keine neue Aufgabenfreigabe.
2. Tatsächlichen `develop`-HEAD und benötigte Dateien direkt von GitHub neu lesen. `main` und `source/legacy/` unangetastet lassen.
3. Klären, ob der Nutzer bereits den aktuellen HTML5-Export hat. Bisher wurde dem Assistenten kein Export-ZIP und keine laufende Browserfassung bereitgestellt. Falls noch kein Export vorliegt, erstellt der Nutzer ihn in AppGameKit Studio.
4. Den echten HTML5-Build im Browser testen lassen bzw. bei bereitgestelltem Build selbst prüfen. Keine Windows-Ergebnisse als Browsertest ausgeben.
5. Nur gemeinsam bestätigte konkrete Releaseblocker beheben. Danach englische Beschreibung/Controls/bekannte Grenzen und manuellen Upload im itch.io-**Draft** samt Test des Secret-URL-Builds vorbereiten. Nicht auf Published umstellen.

**Nächste sinnvolle Nachricht:** „Der Alpha-Walker ist abgeschlossen. Hast du den aktuellen HTML5-Export schon erstellt? Wenn ja, prüfen wir damit zuerst Start, Gamepad, Pause, Tod und Neustart im Browser.“

Keine Annahme automatischer Übernahme des alten Chats, Videos, lokaler Dateien oder einer itch.io-Anmeldung. Falls Export/Projektseite gebraucht wird, muss der Nutzer sie im neuen Chat verfügbar machen.

## 2. Was abgeschlossen und eingefroren ist

| Bereich | Aktueller Stand |
| --- | --- |
| Name | **Alpha-Walker**; Gegnername, nicht Umbenennung des ganzen Spiels oder der Quellcodedateien |
| Unterkörper | Komplexe Zweiknochen-IK, Gang/Stand/Anhalten/Kantenwenden lokal optimal bzw. alpha-tauglich bewertet; erhalten |
| Corpus | Neigt um den roten Hüftpunkt, an dem der Corpus-Anchor fixiert ist |
| Turmanschluss | Corpus-Offset = `Corpus.Position`; nicht mit Corpus-Anchor verwechseln |
| Zielvorbereitung | 400 ms, gemeinsamer Neigungswinkel von Corpus/Turm/Rohren, maximal ±30° |
| Schwenken | Turm unabhängig von Laufrichtung, 800 ms; fünf Breitenstufen 100/85/70/55/40 %, Seitenbildwechsel in der Mitte; keine neue Draufsicht |
| Zielwinkel | Vor Salve einmal erfasst, mit Mündungsbewegung durch Neigung korrigiert; kein Nachführen während Vorbereitung/Salve |
| Streuung | ±3° anfangs, 0.5° Lernschritt pro Salve, mindestens ±1°; `(random(0,200)-100)*AimErrorMax/100.0` |
| Salve | Zwei Schüsse, 150 ms Abstand; 1800-ms-Timer; danach 300 ms Recovery |
| Rohrimpulse | Erst vorderes Rohr `[1]`, dann hinteres `[0]`; 5/10/5/0 px über 60/120/120 ms, je 300 ms; Überlappung beabsichtigt |
| Turmimpuls | Pro Schuss 3 px entgegen Schussrichtung; 60 ms halten + 90 ms Rücklauf, nach 150 ms neutral; keine Aufsummierung |
| Flash | Bleibt am neutralen Mündungspunkt, ohne Rohr- oder Turmrückstoß; folgt weiterhin Eltern-/Plattformbewegung |
| Grafik/Proto | Eigener Entwicklercommit [`0051b8b`](https://github.com/ChristianEngel19820128/SonecBot/commit/0051b8bee28b43f1f5cce787fbc5b412889bfa60), Rohrquelle 3×40 px, getestet/akzeptiert |
| Fairness | Gilt ausdrücklich für Sonec und Computergegner; Regel in PROJECT.md |

**Tatsächlich eingecheckte Barrel-Proto-Werte:** rechts Offset `(0,35)`, Anchor `(1.5,-6)`; links Offset `(0,35)`, Anchor `(1.5,-8)`. Diese sind bewusst vom Entwickler angepasst und lokal akzeptiert. Nicht auf alte 2-/4-px- oder vermeintlich „symmetrischere“ Werte normalisieren.

Letzter Zusatz ist im lokal getesteten Commit `18f92a9` enthalten. Der Nutzer hat ihn abschließend positiv geprüft. Assistentenprüfungen waren statische Analysen, mathematische Modelle und teilweise übersetzte AGK-Funktionslogik, **kein eigener AGK-Compile**. Ein ca. 10-s-Windowsvideo wurde anhand extrahierter Frames beurteilt. Ein vollständiger HTML5-Test ist nicht erfolgt.

## 3. Reihenfolge bis zum kontrollierten Draft-Testrelease

| Priorität | Aufgabe | Freigabekriterium / Stand |
| --- | --- | --- |
| 1 | HTML5 exportieren | Aktueller develop-Stand, Assets vollständig; Build noch nicht verfügbar |
| 2 | Browserstart und Eingabe | Laden, Intro, Start, Bewegung, Jetpack, Waffen, Schild/Energieaktionen und Pause mit dem angebotenen Eingabegerät funktionieren |
| 3 | Spielablauf | Kurzer Kampf, Pause/Fortsetzen, Tod und mindestens zwei Neustarts ohne unspielbaren Zustand |
| 4 | Nur Blocker korrigieren | Konkreter reproduzierter Fehler → kleinster Fix + tatsächlicher Nachtest; Walker nicht neu entwerfen |
| 5 | README/itch.io fertigstellen | Ehrliche Pre-Alpha-Kennzeichnung, tatsächliche Controls, Browser/Gamepad-Hinweise, bekannte Grenzen |
| 6 | Draft-Upload + eingebetteter Test | Besitzer lädt auf die bestehende Draft-Seite hoch und testet über deren Secret URL; kein Published-Wechsel |

Die frühere Zielmarke **16. November 2026** wurde als feste Deadline aufgehoben; Sorgfalt geht vor Geschwindigkeit. Spieltitel ist vorläufig SonecBot; Alpha-Walker bezeichnet den Gegner. Keine Veröffentlichung, fertige ZIP-Datei oder getestete Browser-/Controllerkombination behaupten, bevor diese tatsächlich vorliegt. itch.io-Seite ist im Draft; Secret URL und Zugriff sind hier noch nicht dokumentiert.

## 4. Eingabe: wichtigste bekannte Releasefrage

- `def_joypad.agc`: Für HTML5 ist `Game.JoystickIndex=1` fest; der Workaround wurde aus Crystals übernommen, SonecBot-Browsertest offen.
- `intro.agc: IntroDo()`: Menüwahl und Bestätigung verwenden aktuell Gamepad (D-Pad, Start/A).
- `main.agc`: Pause/Fortsetzen verwendet Gamepad-Start.
- `controls.agc` enthält einen Enter-Helfer, aber IntroDo benutzt ihn derzeit nicht.
- `sonec.agc` besitzt Tastaturteile; Maschinengewehr und Granatwerfer verwenden beide KEY_2. Kein vollständig spielbarer Tastaturpfad bestätigt.
- **Minimalvorschlag:** Gamepad-only-Pre-Alpha mit deutlich sichtbarem Hinweis „Gamepad required“, sofern der Browser-Test besteht. Noch keine vom Nutzer ausdrücklich abschließend festgelegte Eingabeentscheidung.
- Fällt Gamepad im Browser aus, ist das bei Gamepad-only ein echter Blocker. Dann gezielt mit [Crystals](https://github.com/ChristianEngel19820128/Crystals) vergleichen, nicht alle Controls pauschal umbauen.

## 5. Bekannte Grenzen: bewerten, nicht ungefragt ausbauen

- Sonec-Energie derzeit Maximum/Start **5250**, ausdrücklich Testhilfe und keine endgültige Alpha-Balance. Nicht automatisch zurücksetzen.
- Feindliche Bullets ziehen in `BulletCollide()` direkt Gesundheit ab; Schildwirkung gegen diese Schadensart ist kein bestätigter vollständiger Schutz.
- Neutrale Explosionstreffer gegen Walker sind noch nicht vollständig ergänzt. Bekannte Einschränkung statt großer Last-Minute-Kampfsystemumbau; nur bei konkretem Releaseblocker eingreifen.
- Walker-Feindbullets sollen eigene Walker und Orbs nicht treffen, Kisten/Minen vorläufig schon. Weitere Treffermatrix und Tunneling-Randfälle später.
- Windows-Arbeitsrenderer ist `#renderer "Basic"` (OpenGL); diese lokale Wahl ist keine allgemeine Browser-/GPU-Empfehlung. Nicht nur wegen alter „temporary“-Kommentare zurückändern.
- F1/F2 und F4/F5/F6 sind Windowsdiagnosen, kein Browser-Erfolg. Der HUD-Text „Flash“ ist vereinfacht, kein Messwert des tatsächlichen Pool-Flashes.
- Unbestätigte frühere Ruckel-/Timing-Hypothesen nicht als bewiesene neue Blocker behandeln. Erst am aktuellen HTML5-Build beobachten.
- Keine neue Aufräumaktion an Integer-Divisionen. Bei benötigten Bruchteilen Float-Operand **vor** Division; Float-Zielvariable allein genügt nach Entwicklererfahrung nicht.

## 6. Bewusst später / reguläre Alpha oder darüber hinaus

Draufsicht/weitere Grafik- und IK-Politur, zusätzliche Gegner, dynamisch winkelabhängige Zielzeiten, Vorhalt-KI, Optionsmenü und Key-Rebinding, neues Punktesystem/Online-Highscores, vollständige Energie-/Schadensbalance, zusätzliche Schild-/Explosionssysteme und ausführliche Kompatibilitäts-/Rendererstudien.

Die Knowledge Base [agk-knowledge-base](https://github.com/ChristianEngel19820128/agk-knowledge-base) soll mit den Projekten wachsen. Kandidaten bleiben dokumentiert: Schwenkprojektion ohne Zusatzsprite, Integer-/Float-Auswertung, negative Random-Grenzen und robustes Zentrieren, verschachtelte Konstanten, Zylinder für Himmel/Wolken in anderem Projekt. Kurzes Register mit Symptom/Muster/Status/Quelle ist vorgeschlagen. Negative Random-Grenzen sind **kein isoliert bewiesener Enginebug**: beim erfolgreichen 0°-Test wurden zugleich Streuung und Random-Eingaben geändert. Kandidaten ohne Druck dokumentieren; Knowledge-Base-Arbeit jeweils erst nach Abschluss des aktuellen Schritts gesondert priorisieren.

## 7. Arbeitsregeln und Quellen

- Aktive Änderungen nur auf `develop`; `main`, Legacy und Lizenz nicht ohne ausdrücklichen Auftrag verändern.
- Kleine nachvollziehbare Schritte, relevante Dokumente in jedem Commit mitpflegen. Untersuchung ist keine pauschale Implementierungsfreigabe.
- Nutzer kompiliert AGK und beurteilt das echte Spiel; Assistent kann Quellen/Modelle prüfen und bereitgestellte Browserbuilds bearbeiten.
- Unklarheiten vor Commit klären, bestätigte IK/Pivots/Spielmechanik schützen.
- Fairness für beide Seiten erhalten; keine perfekte laufende Zielverfolgung einführen.
- Vorherige ausführliche Entwicklungsnotizen sind über Git erhalten: [TODO vor dieser Übergabe](https://github.com/ChristianEngel19820128/SonecBot/blob/18f92a965810763b552bd96649607c112f966238/TODO.md), [TECHNICAL vor dieser Übergabe](https://github.com/ChristianEngel19820128/SonecBot/blob/18f92a965810763b552bd96649607c112f966238/TECHNICAL.md). Datierte historische Tests widersprechen nicht dem neuesten Abschlusstest; sie beschreiben ältere Stände.
- Der neue Chat beginnt beim **Deployment**, nicht beim nächsten optionalen Walker-Feature.
