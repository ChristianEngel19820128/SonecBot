# SonecBot – Nächste Aufgaben

**Stand:** 24. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] **K3.3 – Ausgleichsschritt bei knapper Kistenlandung:** K3.2 (`568e2a2`) vom Entwickler lokal mit 6/6 bestanden; K3.2b Weltrandfix (`b83cc4f`) ebenfalls 6/6 bestanden. K3.3a Animationsgrundlage (`RepeatAnimation`, `Finished`) nach AGK-Reserviertwort-Korrektur vom Entwickler lokal mit 6/6 bestanden (23.11.2026). K3.3b Ausgleichsschritt für langsame Randlandungen mit einmaliger Laufanimation implementiert (`acdde81`, `bb520e7`); Entwickler bestätigt 8/8 Funktionstests bestanden (23.11.2026), meldet aber dauerhaft falsche Flugpose nach Ausgleich. Quellprüfung: Kistenstand stellte bei MoveSpeed.x=0 den alten relativen x-Offset wieder her und verhinderte so den Abschluss des Schritts. Kleiner Offset-Fix (`4cf978d`) umgesetzt; Entwickler meldet anschließend, dass die Korrektur zu funktionieren scheint (positiver lokaler Nachtest, vorläufig bestätigt; keine erneute vollständige 8/8-Abnahme behauptet). K3.4 bis K3.6 damals abgenommen; K3.3-Regression dabei lokal bestätigt. Die spätere Seitenkollisionsregression ist unter „Jetzt“ offen.
- [ ] **SonecMove-Parameter – AGK-Compile (Schritt 2):** **Priorität: Hoch; Status: In Bearbeitung; ID: Noch nicht vergeben.** Entwickler bestätigt Schritt-1-Kompilierung (`f7a52a6`). Weitere direkt eingetragene Bewegungs-/Kameraparameter in benannte Konstanten ausgelagert; Werte und Ablauf unverändert. **Nächster Schritt:** Entwickler prüft ausschließlich die AGK-Kompilierung von Schritt 2. Danach Spezifikation der Plattform-Tiefenebenen und Kollisionsausnahmen vor neuer Implementierung; seitliches Tunneln, Zurückwerfen und unbegrenzte Luftbeschleunigung weiterhin offen.
- [ ] **Sporadisches Sprite nach Neustart (Fehlerverdacht):** Entwickler beobachtet gelegentlich ein unerwartetes gezeichnetes Sprite nach Spielneustart; vor früheren Flarak-Tests nicht beobachtet. Zusammenhang mit Flarak-Testresten nur Hypothese. Priorität: Offen; Status: Vermutet; ID: Noch nicht vergeben. Reproduktion: mehrfach neu starten, Zeitpunkt/Bildposition/Spritezuordnung prüfen; mögliche nicht zurückgesetzte Sprite-/Objektzustände erst dann untersuchen. Dublette bisher nicht bestätigt.
- [ ] **Granatwerfer/Flarak/Flak Direkttreffer:** Nutzer beobachtet gelegentliches Durchfliegen ohne Direkttreffer. Projektilbewegung und Kollisionsprüfung untersuchen; Explosionstreffer getrennt betrachten.
- [ ] **Schnelles Fallen durch Plattformen:** Gemeldeten möglichen Durchfallfehler untersuchen und priorisieren; zunächst reproduzieren und Fallgeschwindigkeit/Plattformprüfung prüfen.
- [ ] **Flammenwerfer/Kisten:** Deckungswirkung als Designentscheidung klären. Plasma-Blitz-Balancing und Rauchwolken an zerstörten Flarak/Flak später separat behandeln.

## Danach / beobachten

B5c Plattform-Schutzgrenze bei reproduzierbarer Auffälligkeit prüfen; Drohnen-/Minen-/Belohnungsbalancing und Menü-Hilfetexte später bündeln.

## Abgeschlossen / Nachweise

- **Kisten-Kollisionsregel (vom Entwickler geklärt, 23.11.2026):** Sonec darf von unten durch Kisten springen; das ist beabsichtigt und kein Fehler. Von oben soll er landen, von der Seite müssen Kisten blockieren. Der Durchflug von unten ist beabsichtigt; seitliche Blockade am Boden in K3.6 lokal bestätigt. Seitliches Eindringen während eines Sprungs bleibt als separater Fehlerverdacht offen.


- **K3.6 – Seitliche Kistenkollision / Abschlussregression:** Entwickler bestätigte den damaligen Code `d949f57` lokal mit 7/7 (Kompilierung, beidseitiger Stopp, kein aktives Schieben, linker Weltrand, Stand/Landung, K3.3/K3.4 sowie Mini-Hop/Knieschliddern). Dieser bestandene Test bleibt gültig; die spätere Revision `67d9e71` zeigte erneut seitliche Fehler. Neuer Stand unter „Jetzt“, keine nachträglich erfundenen Fehlschläge für K3.6.

- **K3.5b – Mini-Hop-Kantentoleranz:** Entwickler bestätigt lokalen AGK-Test 8/8 bestanden (23.11.2026), aber Hop nach eigener Beobachtung nur bei sehr langsamem Herantasten zuverlässig wahrnehmbar. Code `31b5670`; Feintuning bleibt offen.


- **K3.4 – Schwung und aktives Bremsen:** Entwickler bestätigt lokalen AGK-Test mit 7/7 bestanden (23.11.2026): Kompilierung, Schwung bei schneller Kistenlandung, unverändertes Loslassen, stärkeres Gegenlenken, Richtungswechsel, aktives Knieschliddern sowie K3.3-Ausgleich und Standbild. Keine offenen Testpunkte oder Beobachtungen. Code `d4917a4`.


- **K3.3a – Wiederverwendbare Animationssteuerung:** Entwickler bestätigt lokalen AGK-Test mit 6/6 bestanden (23.11.2026): Kompilierung, Laufanimation links/rechts, Loop, Standbild beim Anhalten, Springen/Knieschliddern und Kistenlandungen. AGK-Reserviertwörter `Loop` und `Step` wurden in `RepeatAnimation` und `FrameIncrement` umbenannt (`9265f2c`, `9e7256c`).

- **K3.2/K3.2b – Kistenlandung und linker Weltrand:** Entwickler bestätigt beide lokalen AGK-Tests mit jeweils 6/6 bestanden (23.11.2026). Kleine/große Kisten, stabiler Stand, kein Einsinken, seitliches Anlaufen, K2-Ausnahme sowie kein Verlassen/Teleportieren am linken Weltrand. Commits `568e2a2`, `b83cc4f`.

- **K2 – Seitliche Kistenkollision:** Entwickler bestätigt lokalen AGK-Test mit 5/5 bestanden (23.11.2026): Kisten stoppen Sonec beim Anlaufen, schieben ihn nicht aktiv, dürfen ihn am linken Rand durchdringen; kein Herausschieben beim Sprung; Übersprunghilfe unverändert (`c7e1da8`).

- **K1 – Zerstörte Kisten:** Landekollision berücksichtigt nur aktive Kisten (`44783e0`); Entwickler bestätigt lokalen AGK-Test mit 4/4 bestanden (23.11.2026).
- **Flarak/Flak und Raketen:** Entwickler bestätigt beide Stellungen vollständig funktionsfähig, inklusive abschießbarer Raketen. Abfangexplosion auf Raketen-Typ 3 geändert (`3c0606a`). Granaten-Direkttreffer als separater neuer Fehler offen.

- **Drohne D1–D6:** frühere Funktionstests abgenommen; Scan-/Laserverhalten und kürzeres Scanintervall vom Entwickler positiv beurteilt. Temporäre gelbe Scan-Diagnose entfernt. 10° optische Flugneigung und drei mitrotierende Jetstream-Auslässe anhand Screenshot positiv beurteilt (22.11.2026). Kein vollständiger neuer Regressionstest für diese Optik behauptet.
- **Sonec-Zwei-Kreis-Treffer S1–S4:** Gegnergeschosse, direkte Bomberbomben, Minenkontakt und Explosionen lokal getestet (S2 7/7, S3 7/7, S4 8/8). Zentrale Debug-Treffermarkierung für weitere Schadensquellen bleibt eine spätere Option.
- **Nachrichten N1/N2, T4 und F1:** lokal abgenommen; detaillierte Nachweise bleiben in Git und Fach-/Übergabedokumentation.

Weitere Real-Alpha-Arbeit: [REAL_ALPHA_ROADMAP.md](REAL_ALPHA_ROADMAP.md). Unverbindliche spätere Ideen: [BACKLOG.md](BACKLOG.md). Übergabe: [HANDOFF.md](HANDOFF.md).
