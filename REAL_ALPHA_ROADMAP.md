# SonecBot – Real Alpha Roadmap

**Stand:** 20. November 2026  
**Arbeitsbranch:** `develop`  
**Quellstand dieser Konsolidierung:** `a0a628e699f701ce773498645e773ca1d0d32807`  
**Status:** Bisherige Entwicklungsrichtung erhalten; verbleibenden Releaseumfang jetzt gemeinsam neu abstimmen.

Diese Roadmap beschreibt Ziel, erreichten Stand und noch offene Releaseentscheidungen.
Die unmittelbar nächsten Schritte stehen in [TODO.md](TODO.md), die Chatübergabe in [HANDOFF.md](HANDOFF.md).
Die Planung erteilt keine Freigabe für einzelne Codeänderungen, einen `main`-Merge oder eine Veröffentlichung.

## 1. Ziel und bisher vereinbarter Rahmen

Aus der spielbaren Pre-Alpha soll eine verständlich spielbare Real Alpha entstehen:
Gefahren müssen erkennbar, Treffer nachvollziehbar und die Schwierigkeit beherrschbar sein.
Es gibt keine feste Deadline und keine Mindestzahl zusätzlicher Gegner.

Die drei bisherigen Kernbereiche bleiben Grundlage der anschließenden Besprechung:

1. **Minenvarianten und Minenfelder:** intelligente Einzelminen sowie einfache, nicht verfolgende Gruppenminen.
2. **Schwebende Drohnen:** zunächst ein überschaubarer Gegner mit lesbarer Bewegung und Wirkung.
3. **Warnungen und Hilfe:** kurze kontextbezogene Hinweise; Umfang der Avatar-Unterstützung noch festlegen.

Eine Änderung dieser Ziele wird ausdrücklich vereinbart. Optionale Ideen sind in [BACKLOG.md](BACKLOG.md) gesammelt.

## 2. Erreichter Stand

| Bereich | Dokumentierter Stand |
|---|---|
| Pre-Alpha-Basis | Alpha-Walker akzeptiert; Keyboard-Rebinding, Persistenz und Restore Defaults abgeschlossen. Draft-Embed vom Entwickler am 18.11. mit 12/12 bestanden gemeldet. |
| Minen S1–S3 | Einfache Minen mit Linksdrift, diagonale Dreierformation, wiederkehrende Spawns; Entwicklertests 9/9, 10/10 und 12/12 bestanden. |
| Minenregeln | Einfache Minen verfolgen Sonec nicht und reagieren nicht auf Energieanziehung. Intelligente Minen behalten ihren eigenen Typ und ihr Verhalten. |
| Warnung S4 | `MINEFIELD DETECTED` auf Windows/HTML5 laut Entwickler sichtbar und funktional; keine erfundene vollständige S4-Testmatrix. |
| Drohne D1 | Ein unbewaffneter Patrouillenprototyp mit drei Ansichten; 11/11 Tests bestanden. 400-ms-Wende später positiv bewertet. Noch kein bewaffneter Gegnerausbau. |
| Treffer K1b/K1c | Frühester Spieler-Bullet-Treffer über die vorgesehenen Zielklassen sowie Sweep gegnerischer Bullets gegen Sonec: jeweils 12/12 bestanden. |
| Körper K1d | Zwei-Kreis-Körperkollision mit Segment-Sweep aktiv; Waffe ausgenommen, Schildwirkung geschützt. |
| Explosion E1/E1b | Radius/Kettenreaktion nachvollzogen; getrennte Schadenszeitpunkte beider Minenarten umgesetzt und mit 9/9 abgenommen. |
| Abendrunde 19./20.11. | Unter anderem Treffer-/Schildfarben, Regen-Timer-Fix, positive FIFO-Upgrade-Meldungen, Laufbegrenzung/Bremsen, Upgrade-Stern und Burst-Fallback umgesetzt. |

Für die gesamte implementierte Abendrunde bis Code-Commit `c2a2d4e` meldete der Entwickler erfolgreiche Tests.
Das gilt als Entwicklerbericht; fehlende einzelne Matrizen oder Plattformzuordnungen werden nicht nachträglich erfunden.
Der Assistent hat keine eigenen AGK- oder Browser-Laufzeittests durchgeführt.
Die damalige Draft-Abnahme belegt keine Auslieferung aller späteren Alpha-Änderungen auf itch.io.

## 3. Verbleibende Kernplanung

### Minenfelder

- Diagonale Dreierformation beibehalten; zusätzliche Muster wie Keil, Vertikalstaffelung oder unregelmäßiges Rudel gezielt auswählen.
- 5er-/7er-Formationen waren Möglichkeiten, keine beschlossene Mindestanforderung.
- Abstände so planen, dass Kettenreaktionen je nach Formation unterschiedlich wahrscheinlich sind.
- Schwierigkeit bevorzugt über Muster, Dichte, Häufigkeit und Kombinationen gestalten; kein pauschaler Schadensanstieg.
- Aktuell 18–30 Sekunden pro Spawnversuch und maximal sechs einfache Minen sind Ausgangswerte für späteres Balancing.
- Die Welt-Y-Korrektur wurde positiv rückgemeldet; ausführliche Langzeit-/Randbeobachtungen wurden nicht vollständig protokolliert.

### Drohnen

- D1 ist die vorhandene Basis. Kollision, Verwundbarkeit, Schaden und gegebenenfalls Bewaffnung vor dem nächsten Ausbau festlegen.
- Vorhandene drei Grafiken weiterverwenden; geplanten Art-Pass und separaten Sensor als eigenen Schritt behandeln.
- Vertikale Bewegung, Jet-Sprite, Eintritt/Austritt, Spawnabstände und Maximalzahl sind noch zu konkretisieren.
- Die Bewegungs-A/B-Diagnose hat den inhaltlichen D1-Ausbau nicht ersetzt oder erweitert.

### Warnungen, Hilfe und Rückmeldung

- Auf vorhandener Minenwarnung und positiven Upgrade-Meldungen aufbauen.
- Weitere Warnfälle auswählen, etwa Energieüberladung, geringe Energie/Schildreserve oder kritischen Schaden.
- HUD-Erklärung und nachvollziehbare Schadens-/Todesursachen anhand des Spielerfeedbacks verbessern.
- Meldungspriorität, Wiederholrate und Lesbarkeit bewerten; Warnung, Hilfe und Belohnung unterscheidbar halten.
- Avatar-Grafik, Portrait oder Sprache sind noch nicht als fertiger Alpha-Umfang festgelegt.

## 4. Technische Gates und bekannte Qualitätsfragen

| Thema | Aktueller Status und erforderliche Entscheidung |
|---|---|
| **M1 – Bewegungsmodell** | Ursprünglich verbindliches Alpha-Gate. Untersuchung auf Wunsch zurückgestellt; Ruckeln verschwand laut Entwickler bei 75 Hz, Ursache unbewiesen. Vor Release ausdrücklich entscheiden, welche Untersuchung/Migration noch erforderlich ist oder welche Einschränkung bewusst akzeptiert wird. Keine automatische Walker-Umstellung. |
| **K1 – Trefferzuverlässigkeit** | K1b/K1c abgenommen, K1d und Abendrunde erfolgreich rückgemeldet. Verbleibenden Umfang der abschließenden K1-Abnahme gemeinsam festlegen; keine bereits bestandenen Tests pauschal wieder öffnen. |
| **K1a – spezielle Anordnungen** | Zwei kontrollierte Fälle mit hintereinanderliegenden Minen waren damals nicht durchführbar. Offen, nicht fehlgeschlagen; K1b prüfte separat Orb-vor-Mine und Mine-vor-Orb. Bedarf eines gezielten Testaufbaus klären. |
| **Bewegung und Plattformen** | Laufbegrenzung/Bremsen wurden inzwischen angepasst. Schnelles Durchfallen ist beabsichtigt; verbleibende Fairnessfragen nur anhand konkreter Beobachtungen untersuchen. |
| **Sonec → Walker** | Walker hält vor Sonec an; Sonec kann weiterhin in den Walker springen. Separaten Körperkontakt und eventuelle zusätzliche Trefferzonen bewerten, akzeptierte IK und Turm-Schadenszone schützen. |
| **Audio** | Kratzen/Überlagerung bei mehreren Sounds wurde beobachtet, konkret etwa drei Explosionen einer Kettenreaktion. Reproduzieren, Pegel/Instanzen und gewünschtes Treffer-/Todesfeedback prüfen; kein bestätigter Enginefehler oder fertiger Fix. |
| **Minen/Warnungsdichte** | Warnungen wirken im längeren Spiel zu häufig. Im Balancing-Chat mit übrigen Gegnern beurteilen; neue Intervalle noch nicht beschlossen. |

Browserneustart und Vergleich von frischer mit längerer Sitzung als Testbedingungen dokumentieren; siehe [TECHNICAL.md](TECHNICAL.md).
Das Paintball-Polishing im Hauptmenü bleibt ein offener Präsentationspunkt in [BACKLOG.md](BACKLOG.md); seine Release-Zuordnung ist noch zu besprechen.

## 5. Getrennte Arbeitsblöcke und Abnahme

| Arbeitsblock | Zweck |
|---|---|
| Alpha-Entwicklung | Vereinbarte Kernfunktionen und konkrete Qualitätsbefunde in kleinen Schritten bearbeiten. |
| Balancing – eigener Chat | Waffen/Energie/Drop-Verhalten, Minen-/Warnhäufigkeit, Gefahrendichte und mögliche gemeinsame Steuerung beurteilen. |
| HTML5 – eigener Chat bei Bedarf | Browserspezifische Themen sowie gebündelte Meilensteinprüfung; nicht jedes kleine Detail zusätzlich im Browser wiederholen. |
| Deployment – eigener Chat | Getestete Revision, Export, Draft-Embed und tatsächlichen Auslieferungsstand getrennt prüfen; Merge-/Publish-Entscheidungen ausdrücklich treffen. |

Pro Änderung passende Prüfungen auswählen. Plattformübergreifende oder browserkritische Änderungen brauchen gezielte entsprechende Nachweise.
Die integrierte Alpha soll im Zielbrowser spielbar sein; Umfang und Zeitpunkt der Abschlussprüfung gemeinsam festlegen.
Offene optionale Prüfpunkte und bewusst zurückgestellte Untersuchungen sind nicht automatisch fehlgeschlagene Tests.
itch.io bleibt Draft/Secret URL bis zu einer gesonderten Entscheidung.

## 6. Nächste gemeinsame Entscheidung

Nach der Dokumentationsbereinigung diese Roadmap inhaltlich durchgehen:

1. Was soll bei Minen, Drohnen und Warn-/Hilfesystem für **diese** Real Alpha noch fertig werden?
2. Wie behandeln wir das zurückgestellte M1-Gate und die übrigen konkreten Qualitätsfragen?
3. Welche optionalen Kandidaten kommen bewusst dazu, welche bleiben ohne Releasezusage?
4. Welcher einzelne nächste Arbeitsschritt kommt anschließend in die kurze TODO?

## Quellen und Vorgeschichte

- [Bisherige vollständige Real-Alpha-Planung](docs/archive/REAL_ALPHA_ROADMAP_BIS_2026-11-20.md)
- [Bisherige TODO mit historischen Test- und Planungsdetails](docs/archive/TODO_BIS_2026-11-20.md)
- [Bisherige Übergaben](docs/archive/HANDOFF_BIS_2026-11-20.md)

Archive werden nur bei konkretem Bedarf gelesen. Alte „nächste Schritte“ darin sind keine aktuellen Arbeitsaufträge.
