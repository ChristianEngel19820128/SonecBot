# SonecBot – Aktuelle Übergabe

**Stand:** 20. November 2026 · **Arbeitszweig:** `develop`

Diese Datei ermöglicht den nächsten Chatwechsel. Sie wird aktualisiert und gekürzt, nicht um Chatprotokolle erweitert.

## Einstieg und Arbeitsstand

- Zuerst [AGENTS.md](AGENTS.md) und diese Übergabe lesen, dann den tatsächlichen `develop`-HEAD abfragen.
- Code-Referenz der letzten Entwicklungsrunde: [`c2a2d4e`](https://github.com/ChristianEngel19820128/SonecBot/commit/c2a2d4ed1dd7b27de6aa13f1058a5431509b2d45).
- Dokumentationsbasis vor dieser Bereinigung: [`a0a628e`](https://github.com/ChristianEngel19820128/SonecBot/commit/a0a628e699f701ce773498645e773ca1d0d32807). Das ist eine feste Quellenreferenz, kein dauerhaft aktueller HEAD.
- Die aktuelle Arbeit ordnet ausschließlich Dokumentation und Planung. Die Inhalte der Real Alpha werden anschließend gemeinsam neu abgegrenzt.
- Es gibt keine neue Deadline. Alpha-Entwicklung, Balancing, Deployment und HTML5-Themen dürfen getrennte Chats beanspruchen.
- Den aktuellen `develop`-Stand nicht mit dem auf itch.io hochgeladenen Build gleichsetzen; der Export-SHA wurde nicht durchgehend protokolliert.

## Implementiert und vom Entwickler geprüft

Die folgenden Angaben beruhen auf dokumentierten Entwicklertests. Der Assistent hat hier weder AGK kompiliert noch Windows-/HTML5-Laufzeittests durchgeführt.

| Bereich | Übernahmestand und Evidenz |
| --- | --- |
| Alpha-Walker | Vom Entwickler abgeschlossener Referenzstand. IK, Pivots, Grafikprototypen, Zielen und Rückstoß erhalten; keine erneute Politur als Standardauftrag. |
| Tastatur / Pre-Alpha | Belegung, Umbelegung und Wiederherstellung der Standardtasten umgesetzt; lokaler HTML5-Abschluss und itch.io-Draft-Smoke-Test gemeldet, letzterer am 18.11. mit 12/12. |
| Einfache Minen | S1–S3 umgesetzt und mit 9/9, 10/10, 12/12 unter Windows und lokalem HTML5 bestätigt. Minen verfolgen Sonec nicht und reagieren nicht auf Energieanziehung. |
| Warnsystem | S4-Minenfeldwarnung funktional unter Windows/HTML5 gesehen; daraus keine vollständige nummerierte S4-Abnahme ableiten. |
| Drohne D1 | Unbewaffnete Patrouillenbasis, 11/11 unter Windows/HTML5 gemeldet. In der Abendrunde kein weiterer inhaltlicher Gegnerausbau; A/B-Diagnostik zählt nicht als neue Ausbaustufe. |
| K1b / K1c | Zuverlässigere Projektiltreffer per Segmentprüfung gegen Zielklassen bzw. Sonec; jeweils 12/12 gemeldet, einschließlich lokalem HTML5. |
| E1b | Unabhängige Explosions-Schadenszeitpunkte für einfache/intelligente Minen; 9/9 einschließlich unabhängiger Treffer beider Minenarten innerhalb derselben Explosion und lokalem HTML5 gemeldet. |
| K1d | Zwei-Kreis-Körperkollision gegen Gegnerbullets aktiv; Waffenbereich ausgeschlossen. Frühere Diagnose-only-Notizen sind überholt. |

**Abendrunde 19./20.11.:** Der Entwickler bestätigt zusammenfassend, dass alle an diesem Abend implementierten Änderungen erfolgreich getestet wurden. Das gilt als Entwicklerabnahme; fehlende Einzelprotokolle werden weder erfunden noch als pauschal offene Tests behandelt.

Zusätzlich in dieser Runde umgesetzt:

- Debug-Tasten 1–7 und HTML5-Hinweise zu Canvas-Fokus und erster Gamepad-Eingabe.
- Grünes Sonec-Farbfeedback, rotes Aufblitzen bei tatsächlichem Health-Schaden und eisblaues Schildfeedback bei Absorption.
- Health-Regenerations-Upgrade-Timer, Boden-Laufgeschwindigkeitsbegrenzung/Bremsen und FIFO-Nachrichten mit Upgrade-Feedback korrigiert bzw. ergänzt.
- Mintfarbener Upgrade-Stern; ausgeschöpfte Burst-Pickups wechseln zu Fire-Rate-Upgrades.
- Paintball-Easter-Egg im Hauptmenü mit anklickbaren Energie-Orbs, bleibenden Spritzflecken und animierten Laufspuren.

## Offene oder zurückgestellte Punkte

- **M1 / Bewegungsruckeln:** Ursachenuntersuchung ausdrücklich zurückgestellt. Bei 75 Hz war das Ruckeln laut Entwickler nicht mehr vorhanden; Ursache und plattformübergreifende Wirkung sind unbewiesen. Umgang mit dem früher vereinbarten Alpha-Gate in der Roadmap-Besprechung klären; keine automatische Wiederaufnahme oder Abnahme.
- **Browserlaufzeit:** Nach längerem Testen half laut Entwickler ein Browserneustart gegen Performance-Einbußen. Bei Vergleichen frischen Start und längere Sitzung getrennt beobachten; ein Neustart klärt die Ursache nicht. Siehe [TECHNICAL.md](TECHNICAL.md).
- **Paintball-Optik:** Laufnasen wirken weiterhin rechteckig. Runde Tropfenenden und organische, variable Spuren sind eine offene Gestaltungsidee, keine bereits erledigte Änderung.
- **Drohne und weitere Alpha-Inhalte:** D1 ist die Basis; Ausbau, Art-Pass und zusätzliche Gegner gemeinsam einordnen. Die Zusammenfassung der Abendtests ersetzt keinen neuen Drohnenausbau.
- Weitere Qualitätsbefunde und ungeklärte Release-Zuordnungen stehen in der [Real-Alpha-Roadmap](REAL_ALPHA_ROADMAP.md); sie werden hier nicht nochmals als Aufgabenliste geführt.

## Arbeitsaufteilung und Tests

- **Alpha-Entwicklung:** Zuerst Releaseumfang und Abschlusskriterien besprechen, danach kleine Umsetzungsblöcke auswählen.
- **Balancing:** Eigener Chat für Gegnerdichte, Formationen, Ressourcen, Upgrades und Schwierigkeit; vorläufige Werte bleiben als solche erkennbar.
- **Deployment:** Eigener Chat für Build-Zuordnung, Upload und Release-Entscheidungen. itch.io bleibt nach bisheriger Vereinbarung Draft/Secret URL; `main` und Veröffentlichung brauchen einen eigenen Auftrag.
- **HTML5:** Plattformbezogene Fragen und ein gemeinsamer Meilensteincheck können in einem eigenen Chat gebündelt werden. Keine vollständige Windows-/HTML5-Wiederholung für jede Kleinigkeit.
- Tests richten sich nach der Änderung. Entwicklerberichte, statische Prüfung und tatsächliche Laufzeittests getrennt ausweisen; vereinbarte vertagte Prüfungen als solche erhalten.

## Genau ein nächster Schritt

**Die Real-Alpha-Roadmap gemeinsam neu besprechen:** Was gehört zwingend in diesen Release, was ist optional, wie behandeln wir M1 und woran erkennen wir den Abschluss? Erst danach den ersten kleinen Implementierungsschritt auswählen.

## Weiterführende Dokumente

- [TODO.md](TODO.md): nur die unmittelbar nächsten Aufgaben.
- [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md): Releaseumfang und offene Entscheidungen.
- [BACKLOG.md](BACKLOG.md): unverbindliche Ideen ohne Releasezusage.
- [PROJECT.md](PROJECT.md) / [TECHNICAL.md](TECHNICAL.md): nur passende Konzept- bzw. Technikabschnitte nachlesen.
- [Archivübersicht](docs/archive/README.md): frühere Langfassungen und historische Testdetails; kein Pflichtlesestoff beim Chatstart.
