# SonecBot – Agent Instructions

Repository: `ChristianEngel19820128/SonecBot` · Engine: AppGameKit Studio (AGK).
Aktive Entwicklung: `develop` · Meilenstein-/Referenzbranch: `main`.
Der Entwickler entscheidet über Spielrichtung, Prioritäten und Veröffentlichungen.

## 1. Einstieg und Arbeitsumfang

1. `AGENTS.md` und den aktuellen `HANDOFF.md` lesen; den tatsächlichen `develop`-HEAD abfragen.
2. Die konkrete Aufgabe und vorhandene Freigaben aus dem Gespräch berücksichtigen.
3. Danach nur relevante Stellen in TODO, Release-Roadmap, Fachdokumenten und Quellcode lesen.
4. Archive nur bei einer konkreten historischen Frage öffnen. Keine automatische Chat-/Dateiübertragung voraussetzen.

Eine Bitte um Untersuchung, Review oder Buganalyse erlaubt zunächst nur lesende Arbeit.
Umsetzung braucht einen vereinbarten konkreten Umfang. Eine bereits erteilte Freigabe gilt innerhalb dieses Umfangs weiter; nicht für jeden notwendigen Teilschritt erneut fragen.
Bei einer echten Erweiterung des Umfangs Befund und kleinsten Vorschlag vorlegen und die Entscheidung abwarten.
Ein Dokumenteintrag oder eine Idee ist für sich noch kein Implementierungsauftrag.

## 2. Entwicklung und Schutz bestehender Funktionen

- Kleine, verständliche Änderungen auf `develop`; die betroffenen Ausführungspfade vorher nachvollziehen.
- Bewegung, Energie, Waffen, Schild, Kollisionen, Gegner, Animation, Eingabe und Sound vor unbeabsichtigten Nebenwirkungen schützen.
- Unfertige, deaktivierte oder experimentelle Funktionen können beabsichtigt sein; unbekanntes Sollverhalten klären.
- Keine beiläufigen Refaktorierungen, Grafikänderungen oder Balancekorrekturen. Technisch eleganter bedeutet nicht automatisch spielerisch besser.
- Neue gegnerische Schadensquellen gegen Sonec müssen die zentralen Zwei-Kreis-Hitbox-Funktionen aus `sonec.agc` wiederverwenden; keine neue lokale Sonec-Ein-Kreis-Hitbox anlegen. Details, abweichende Quellradien und Explosions-Plattformschutz stehen in `TECHNICAL.md` unter „Sonec-Treffergeometrie“.
- `main`, `source/legacy/`, Lizenz, Git-Historie, Releases und Veröffentlichung nur mit einem eigenen ausdrücklichen Auftrag verändern.
- `.gitignore` beachten; keine kompilierten Programme, temporären Builds oder Testartefakte einchecken.
- Commit-Nachrichten beschreiben die tatsächliche Änderung. Kein automatischer Wechsel auf ein anderes Repository.

## 3. Befunde und Bugberichte

Fakten, Entwicklerbeobachtungen und Hypothesen trennen. Relevante Dateien/Funktionen und möglichst die Quellrevision nennen.
Reproduktion oder geeignete Prüfung beschreiben; vorhandene Aufgaben auf Dubletten prüfen und die kleinste sinnvolle Korrektur vorschlagen.
Keine spekulativen Buglisten und keine erfundenen Tests, Messungen oder aktualisierten Register.

Bugberichte auf Deutsch mit:

- ID `SB-###` nur bei vorhandener, geprüfter Zuordnung, sonst `Noch nicht vergeben`; kurzer Titel.
- Priorität: Kritisch / Hoch / Mittel / Niedrig / Offen; Status: Vermutet / Bestätigt / In Bearbeitung / Behoben / Verworfen.
- Dateien/Funktionen, Quellbeleg, bestätigtes Soll und beobachtetes bzw. vermutetes Ist.
- Reproduktion/Prüfmethode, Auswirkung, minimale Korrektur und Dublettenprüfung.

Widersprüche mit dokumentierten Entscheidungen offen benennen; keine Spielentscheidung selbstständig umdeuten.
Eine ausdrücklich zusammenfassende Testbestätigung des Entwicklers zählt als solche. Fehlende Einzelprotokolle weder erfinden noch als nachträglichen Fehlschlag behandeln.

## 4. Zuständigkeiten der Dokumente

| Datei | Aufgabe und Richtwert |
| --- | --- |
| `AGENTS.md` | Dauerhafte Arbeitsregeln; keine wechselnden Meilensteine oder Testchronik. |
| `HANDOFF.md` | Kurzer Chatübergang: Basis, Teststand, offene Entscheidungen, genau ein nächster Schritt; etwa 60–120 kurze Zeilen. |
| `TODO.md` | Nur die nächsten konkreten, priorisierten Arbeitsschritte; höchstens fünf Einträge, möglichst unter 60 kurzen Zeilen. |
| `REAL_ALPHA_ROADMAP.md` | Ziel, Umfang, Stand und Abschlusskriterien dieses Releases; grob 100–180 kurze Zeilen, keine Sitzungshistorie. |
| Weitere Release-Roadmaps | Erst bei tatsächlicher Planung anlegen, etwa `PRE_BETA_ROADMAP.md`; denselben überschaubaren Aufbau verwenden. |
| `BACKLOG.md` | Unverbindliche Ideen und bewusst spätere Möglichkeiten; kurze Einträge ohne automatische Releasezusage. |
| `PROJECT.md` | Spielkonzept und längerfristige Designentscheidungen. |
| `TECHNICAL.md` | Architektur, relevante Implementierungsdetails und nachvollziehbare technische Erkenntnisse. |
| `README.md` | Öffentlicher Projekt-/Release-/Eingabestatus mit tatsächlich belegtem Umfang. |
| `docs/archive/` | Abgelöste Dokumentstände zur gezielten Nachschau; keine aktuellen Arbeitsaufträge. |

Richtwerte verhindern Wachstum, sind keine Aufforderung, Fakten zu verlieren oder Zeilen künstlich zu verdichten.
Aktuelle Aussagen ersetzen statt immer neue Nachträge davorzustellen. Erledigtes aus TODO entfernen; Ergebnis am zuständigen Ort knapp festhalten.
Neue Wünsche zuerst einordnen: nächster vereinbarter Schritt, Releaseentscheidung oder unverbindliche Idee. Bestätigte Fehler nicht als bloße Ideen wegparken.
Roadmaps bündeln größere Arbeitspakete; technische Einzelheiten gehören in Fachdokumente. Releaseumfang nur gemeinsam ändern.
BACKLOG bei der Releaseplanung auf Dubletten und Relevanz prüfen; keine Kopie der gesamten alten TODO erzeugen.
Historie bleibt in Git. Größere abgelöste Übergaben bei einer Konsolidierung archivieren; kein neues Archiv für jeden Chat und kein fortlaufendes Gesprächsprotokoll.

## 5. Abschluss jedes vereinbarten Schritts

1. Änderung im freigegebenen Umfang umsetzen und soweit hier möglich prüfen.
2. Betroffene Dokumentation im selben Commit auf den tatsächlich bekannten Stand bringen; nicht routinemäßig alle Dateien anfassen.
3. Falls erforderlich einen kleinen, passenden Entwicklertest benennen. Bis zur Rückmeldung bleibt sein Laufzeitstatus offen.
4. Rückmeldungen auswerten und zeitnah dokumentieren: getestete Revision soweit bekannt, Person/Umgebung, Ergebnis und verbleibende Unsicherheit.
5. TODO und HANDOFF bei geändertem Arbeitsstand ersetzen; genau einen nächsten vereinbarten Schritt benennen.

Dokumentationspflege gehört zum Abschluss; nicht erst auf den nächsten Chat verschieben.
Code-HEAD, tatsächlich getestete Revision und ausgelieferter Build können verschieden sein. Fehlende Export-SHAs ausdrücklich offen lassen.
Abgeschlossene oder bewusst vertagte Aufgaben nicht durch einen alten Archiveintrag wieder aktivieren.

## 6. Tests und Testbericht

Der Entwickler führt lokale AGK-Compiles/-Exporte sowie Windows-, Browser-/Gamepad- und itch.io-Tests aus.
Assistenten-Quellprüfung, übersetzte Simulationen und tatsächliche AGK-/Browserläufe bleiben getrennte Evidenz.
Testumfang nach Änderung und Risiko wählen: keine Pflicht, jedes Detail zusätzlich in HTML5 zu testen.
Browserrelevante Änderungen gezielt dort prüfen; übergreifende HTML5-Prüfungen an Meilensteinen oder im eigenen Themenchat bündeln.
Optionale, nicht durchführbare oder gemeinsam vertagte Punkte sind keine automatischen Blocker. Bestätigte Fehler und notwendige Freigabekriterien gezielt klären.
Bei Performanceberichten Sitzungslänge, Umgebung und Neustartzustand unterscheiden; ein flüssiger Neustart widerlegt kein Problem nach längerer Laufzeit.

Für vereinbarte Entwicklerchecks eine kurze, optional teilweise ausfüllbare Testliste anbieten:

- Titel mit Schritt und Zähler `x / n bestätigt`; Haken bedeutet bestanden, leer bedeutet unbestätigt, nicht gescheitert.
- Gesamtergebnis: `Noch nicht vollständig getestet` / `Bestanden` / `Auffälligkeiten / Fehler`; keine Einzelhaken daraus ableiten.
- Optionales mehrzeiliges Feld für Beobachtungen; genau ein expliziter Button `Testergebnis senden`.
- Haken, Auswahl und Texteingabe senden nie automatisch. Bericht enthält Schritt, Gesamtergebnis, Bestätigt, Offen und Beobachtungen bzw. `Keine Angaben`.
- Unterstützt der Chat diese Bedienelemente nicht, dieselben Felder als kopierbaren Text anbieten. Keine funktionsfähigen Buttons vortäuschen.

Das ist eine Chatkonvention, keine Aufgabe zum Einbau eines Testformulars ins Spiel.

## 7. Veröffentlichung und wiederverwendbare Erkenntnisse

- Balancing, Deployment und HTML5-Themen können eigene Chats erhalten; dabei denselben aktuellen Dokumentstand verwenden. Es gibt keinen pauschalen Zeitdruck.
- itch.io-Uploads und Seitenänderungen führt der Entwickler manuell aus. Sichtbarkeit und Veröffentlichung benötigen einen eigenen ausdrücklichen Auftrag; Git-Merge und Deployment sind getrennte Vorgänge.
- Öffentliche Release-/itch.io-Texte in englischem Markdown vorbereiten; 💚 bleibt die vereinbarte Kennzeichnung. Secret-URL-Tokens nicht in öffentliche Dokumentation schreiben.
- AGK-Besonderheiten mit Quelle, Bedingungen und Evidenzgrad im passenden Fachabschnitt knapp festhalten. Erst den laufenden Arbeitsschritt abschließen.
- Beiträge zur [AGK Knowledge Base](https://github.com/ChristianEngel19820128/agk-knowledge-base) separat entscheiden, vorhandene Themen prüfen und Quellprojektverhalten von bewiesenem Engine-Verhalten trennen.
- Ein interessanter Befund allein erlaubt keine Änderungen in der Knowledge Base oder anderen Repositories.
