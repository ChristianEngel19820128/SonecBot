# SonecBot – Phase B: Gesamtkonzept und Umsetzungsplanung

**Stand:** 28. November 2026  
**Zielbranch:** `develop`  
**Status:** Gesamtkonzept und Arbeitspakete B01–B13 freigegeben; Umsetzung ausstehend.  
**Umsetzungsschätzung:** ca. eine Woche nach Erfahrungswert des Entwicklers; keine verbindliche Terminzusage. Enthalten sind Umsetzung, lokale Abnahme, Fehlerkorrekturen, Dokumentation und Bereinigung. Optionale Erweiterungen und nachfolgendes Balancing sind nicht enthalten.

## 1. Zusammenfassung

Phase B erweitert die abgeschlossene Phase A um sechs zusammenhängende Themenblöcke:

1. **Walker:** Individuelle Trefferzonen, Körperteil- und Gesamtlebenspunkte, funktionale Schäden, Absenken, Zusammenbruch und passive zerstörbare Wracks.
2. **Schaden und Panzerung:** Zentrale Schadensverarbeitung, vier Schadensarten, konfigurierbare Panzerungsmatrix, individuelle Resistenzen für Sonec und AP-Penetration.
3. **Explosionen:** Bestehender Flächenschaden bleibt erhalten; zusätzlicher Druckwellenmodus mit abnehmendem Schaden und einmaligen Treffern je Zielzone.
4. **Ressourcen und Upgrades:** Drei Ressourcenfamilien, spezialisierte Munition, automatische Verbrauchspriorität, Fallback-Ketten, elf verpflichtende permanente Upgrades und barrierearmes HUD.
5. **Erfahrung und Level:** Wirksame Aktionen und Überleben erzeugen kumulierte Erfahrung; Level beeinflussen das Gefahrenbudget.
6. **Gefahrenbudget und Spawnsteuerung:** Zentrale zeitbasierte Spawnversuche, vorzeichenbehaftete Gefahr, Belastungs- und Erholungsphasen, temporäre Gefahrenentlastung und Aufhebung künstlicher Gegnerlimits.

Die Umsetzung wird auf 13 einzeln abnehmbare Arbeitspakete verteilt. B13 schließt Phase B mit einer übergreifenden Quellcodebereinigung ab.

## 2. Zielsetzung und Arbeitsgrundsätze

- Die in Phase A abgenommenen Bewegungs-, Kollisions-, Waffen- und Gegnermechaniken bleiben erhalten, soweit Phase B nicht ausdrücklich eine Änderung vorsieht.
- Ein Arbeitspaket pro Implementierungschat; bei absehbarer Überschreitung der Chatgrenzen vor Beginn sinnvoll teilen. Reserve für Korrekturen, Tests und Dokumentation einplanen.
- Neue Datenstrukturen und Funktionen zunächst ergänzend implementieren, Aufrufstellen vorbereiten, anschließend kontrolliert aktivieren. Keine doppelte Schadensverarbeitung oder dauerhaft parallele Systeme. Unmittelbar notwendige Bereinigungen erfolgen im jeweiligen Paket; übergreifende Bereinigung in B13.
- Jedes Paket endet in einem eigenständig funktionsfähigen und überprüfbaren Zustand. Abhängige Pakete beginnen erst nach Abnahme.
- Keine eigenmächtigen Erweiterungen, Grafikänderungen, allgemeinen Refactorings oder Balancingmaßnahmen. Technische Detailentscheidungen innerhalb des freigegebenen Umfangs treffen; Änderungen des Konzepts mit dem Entwickler abstimmen.
- Neue gegnerische Schadensquellen gegen Sonec verwenden seine zentrale Zwei-Kreis-Hitbox. Waffen-Kollisionsebenen und vorhandene Schutzmechaniken bleiben erhalten.
- Der Entwickler verantwortet Design, Prioritäten, Grafiken, Sound, lokale AGK-Kompilierung, Spieltests, reine Parameteranpassungen und Releases. Tests nur als ausgeführt dokumentieren, wenn sie tatsächlich durchgeführt wurden.
- HANDOFF und TODO bei Änderungen kompakt aktualisieren; bestehende Repository-Regeln (AGENTS.md) beachten. Änderungen an main, Legacy, Lizenz oder Releases erfordern separate Freigabe.
- Phase A einschließlich Fehlerkorrekturen ist abgeschlossen; die zuletzt berichtete Abnahme umfasste 155/155 Tests. HTML5 und Langzeitverhalten wurden damit nicht abgenommen. Dieses Konzept ersetzt diese Prüfungen nicht.

## 3. Detailliertes Gesamtkonzept

### 3.1 Walker

#### Schadensmodell und Zustände

Jedes relevante Körperteil (Korpus, Turm, Ober- und Unterschenkel sowie Fuß/Sockel beider Beine) besitzt eigene HP und eine individuelle Panzerungsart. Die Gesamt-HP sind unabhängig von der Summe der Körperteil-HP und größer als die höchsten einzelnen Körperteil-HP. Der Korpus soll gezieltes Ausschalten ermöglichen; ungezielter Beschuss bleibt wirksam. Das Geschützrohr als eigenständige Trefferzone ist nicht vorgesehen (Detailabgrenzung bei Implementierung bestätigen).

Effektiver Schaden an einem intakten Körperteil reduziert gleichzeitig dessen HP und die Gesamt-HP. Körperteil-HP werden bei null begrenzt; Overkill am Körperteil wird vollständig als effektiver Gesamtschaden weitergegeben. Weitere Treffer auf zerstörte Teile reduzieren die Gesamt-HP nur mit einem noch zu definierenden Faktor. Kein erneuter funktionaler Bonus. Walker regenerieren keine HP und besitzen weder Reparatur noch Schild.

| Auslöser | Funktionale Folge |
|---|---|
| Ein Beinsegment erreicht null HP | Dauerhafte Immobilisierung; intakter Turm bleibt nach Absenken nutzbar |
| Turm erreicht null HP | Neutralisierung, Absenken und Zusammenbruch zum passiven Wrack |
| Korpus oder Gesamt-HP erreichen null | Sofortige Kernexplosion und vollständige Entfernung |

Priorität bei gleichzeitigem Schaden: Kernexplosion vor Neutralisierung vor Immobilisierung. Bei mehreren Körperteilschäden desselben Schadensereignisses (insbesondere einer Druckwelle innerhalb desselben Verarbeitungsschritts) die Zustandspriorität über alle betroffenen Teile hinweg wahren; keine mehrfachen funktionalen Übergänge oder Boni durch die Reihenfolge einzelner Treffer. Keine weiterlaufenden entwaffneten Walker. Das Wrack bleibt mit seinen HP und Panzerungen beschädigbar; spätere Korpus-/Gesamtzerstörung löst die Kernexplosion aus.

#### Trefferzonen

Einfache rotierte Rechtecke auf Basis der vorhandenen Körperteilgeometrie, keine pixelgenaue Kollision. Trefferzonen folgen der tatsächlichen Pose einschließlich Animation. Direktgeschoss: nur erste Trefferzone entlang der Flugbahn. Flächen-/Druckwellenschaden kann mehrere Zonen betreffen; pro Druckwelle maximal ein Treffer je Zone. Jeder effektive Körperteilschaden wird vollständig kumulativ auf die Gesamt-HP angerechnet (kein Maximum aus den Einzeltreffern). Keine zusätzliche Gewichtung nach Fläche oder Masse; HP repräsentieren strukturelle Stärke. Keine neue Abschattung zwischen Körperteilen oder durch Weltobjekte in der Real Alpha.

#### Animation und Lebenszyklus

- **A – Absenken:** Laufbewegung sofort einfrieren, angehobenen Fuß vertikal zur Plattform absenken, Beine mit relativ zur Plattform fixierten Füßen absenken. Korpus und Turm folgen vorhandener Kopplung; IK nur für Beine. Intakter Turm kann anschließend wieder horizontal ausrichten und feuern.
- **B – Zusammenbruch:** Aus abgesenkter Pose Korpus in Richtung der Geschützausrichtung rotieren/absenken, bis Bodenkontakt erreicht ist. Keine eigenständige Fallphysik.
- Beinzerstörung startet A; Turmzerstörung beim Laufen startet A und danach B; bei laufendem A folgt B nach Abschluss von A; aus abgesenkter Pose direkt B. Während A/B kein Feuer; Turmausrichtung bleibt während der Animation erhalten. Kernexplosion unterbricht jede Animation sofort.
- Zerstörte Körperteile abdunkeln, passives Wrack analog Flak umfärben; keine neuen Körperteilgrafiken erforderlich. Unzerstörte Teile zunächst unverändert darstellen.
- Immobilisierte Walker und Wracks bleiben an ihre bewegte Plattform gebunden, bis diese tatsächlich entfernt wird; kein eigener Lebensdauertimer. Natürliches Verlassen erzeugt weder Explosion noch Belohnung oder XP.
- Sonec kann immobilisierte Walker und Wracks in der Real Alpha durchqueren. Physische Hindernisse/Deckung und differenzierte Fortbewegung (Hinken) erst Beta. Verhalten feindlicher Geschosse gegenüber Wracks bei Implementierung klären.

#### Belohnungen und Gefahr

Materielle Belohnung einmal vollständig bei Neutralisierung oder unmittelbarer vollständiger Zerstörung, nicht bei bloßer Immobilisierung, späterer Wrackzerstörung oder natürlichem Entfernen. XP für tatsächlichen Gesamt-HP-Verlust, einmaligen taktischen Bonus bei Immobilisierung und Neutralisierung; weiterer Wrackschaden zählt als Schadenserfahrung. Gefahrenwert bei Immobilisierung reduzieren, beim passiven Wrack null.

### 3.2 Schaden und Panzerung

Treffererkennung bleibt grundsätzlich von Schadensverarbeitung getrennt. Zentraler Schadenspfad erfasst Schadensart, Verursacher, wirksamen Schaden und tatsächlich entfernte HP. Bestehende Schildabsorption bleibt eigenständig. Verursacherinformationen bleiben über zeitverzögerte Zerstörung und Kettenreaktionen erhalten.

Vier Schadensarten: Kinetik, Energie, Explosion, Feuer. Übertragungsform (Direkttreffer, Fläche, Druckwelle) ist unabhängig von der Schadensart. HP bilden Masse/strukturelle Stärke ab; Panzerung reduziert Schaden prozentual. Die zentrale Matrix wird per JSON konfiguriert.

| Panzerung (Schadensreduktion) | Kinetik | Energie | Explosion | Feuer |
|---|---:|---:|---:|---:|
| Ungepanzert | 0 % | 0 % | 0 % | 0 % |
| Massivpanzerung | 75 % | 0 % | 50 % | 25 % |
| Energiepanzerung | 25 % | 75 % | 0 % | 50 % |
| Verbundpanzerung | 50 % | 25 % | 75 % | 0 % |
| Thermopanzerung | 0 % | 50 % | 25 % | 75 % |
| Nanopanzerung (zurückgestellt) | 25 % | 25 % | 25 % | 25 % |

100 % Immunität technisch unterstützen; für besondere Gegner/Bosse reserviert, keine konkreten Bosspanzerungen in Phase B. Keine Schadensverstärkung über den Basisschaden durch die Matrix vorgesehen. AP-Penetration verringert die wirksame Panzerungsreduktion, kann jedoch 100 % Immunität nicht aufheben. B02-Freigabe: AP reduziert die Resistenz proportional (R_eff = R * (1 - AP/100)); 100 % bleiben immun. Nach Schild und Resistenz einmal kaufmännisch runden, bei positivem Restschaden und unter 100 % Resistenz mindestens 1 HP.

Sonec hat vier unabhängige permanente Resistenzen statt eines festen Panzerungstyps. Jede ist bis 75 % steigerbar; mit fortschreitendem Ausbau sinkt der Zugewinn, das Maximum muss tatsächlich erreichbar sein. Nur diese Upgrades verwenden abnehmende Steigerungswerte. Schild ist ein separates Schutzsystem; B02-Freigabe: zuerst Schildabsorption, dann individuelle Resistenz; alle vier Startresistenzen 0 %. Schildschaden liefert keine XP. Drohnenschild ist als Idee vorgesehen, aber keinem freigegebenen B-Paket zugeordnet.

Nanopanzerung ist mangels vorgesehenen Gegners zurückgestellt. Konzept: direkte HP-Regeneration nach Erholungszeit, keine separate Panzerungs-HP-Leiste; genaue Reset-/Regenerationsregeln erst bei Umsetzung festlegen. Zusätzliche schadensartspezifische Statuseffekte sind Beta; vorhandene Effekte bleiben unverändert.

### 3.3 Explosionen und Druckwellen

Drei unabhängige Eigenschaften: visuelle Explosionsart (Animation/Sound), Schadensmodus (Fläche/Druckwelle), Schadensart. Bestehende Explosionen behalten ihren bisherigen Flächenmodus mit zeitlich wiederholtem Schaden beim Anwachsen und Schrumpfen des Radius.

Druckwelle: expandierende Kreisfront auf Basis der bestehenden Radius-/Animationslogik; nur während Expansion schädlich, pro Objekt bzw. Trefferzone einmal. Schaden nimmt mit Entfernung ab, orientiert an idealisierter zweidimensionaler Ausbreitung (1/r); Restschaden am maximalen Radius. Exakte Kurve, Mindest-/Referenzradius und Parameter später abstimmen. Bewegliche Ziele bei Kontakt mit der auswärts wandernden Front treffen; Eintritt hinter der Front bleibt wirkungslos. Keine zusätzliche komplexe Physiksimulation oder Abschattung. Bestehender Plattformschutz bei Bomben bleibt erhalten. Ressourcen bleiben unzerstörbar; keine zusätzliche Sonderlogik für neu außerhalb der Welt erzeugte Objekte.

Walker-Kernexplosion nutzt den allgemeinen Druckwellenmodus, wirkt auf alle zulässigen Ziele einschließlich Sonec und nicht auf den bereits zerstörten Walker selbst. Verursacherinformation bei Kettenreaktionen weitergeben. Neue Druckwellengrafik ist keine Voraussetzung für die technische Abnahme.

### 3.4 Ressourcen, Munition und Upgrades

Drei Munitions-/Energieressourcen: Geschosse, Granaten, Energie. Plasma und Flammenwerfer verwenden Energie, keine eigenen Brennstoffe. Leben und Schild bleiben separate Zustände. Handgranaten und manuelle Munitionswahl sind Beta.

| Familie | Munition | Wirkung | Verbrauch (1 = zuerst) |
|---|---|---|---:|
| Geschosse | Explosivgeschoss | Kinetik mit zusätzlicher Explosionswirkung | 1 |
| Geschosse | AP | Kinetik mit Panzerungsdurchdringung | 2 |
| Geschosse | Standard | Kinetik | 3 |
| Granaten | Feuer | Feuer, Flächenschaden | 1 |
| Granaten | Explosiv | Explosion, Druckwelle | 2 |
| Energie | Plasmablitz | Energie | – |
| Energie | Flammenwerfer | Feuer | – |

Gemeinsame Kapazität pro Munitionsfamilie. Standard füllt ausschließlich freie Kapazität. Spezialmunition füllt zunächst freie Kapazität und verdrängt anschließend Standardmunition; Spezialtypen verdrängen sich nicht gegenseitig. Bei teilweise erfolgreicher Aufnahme verfällt der Rest, kein zusätzlicher Fallback. Nur vollständig wirkungslose Aufnahme fällt auf Energie zurück. XP für tatsächlich akzeptierte Menge (einschließlich ersetzter Standardmunition). Verbrauch automatisch höchste verfügbare Priorität, auch innerhalb einer Salve, keine taktische Automatik. Abzug nur bei tatsächlichem Abschuss. Kapazitätsupgrades wären ausschließlich Drops und erhöhen nur das Maximum, nicht den Bestand; vorerst optional.

Fallbacks zentral in JSON konfigurierbar, erste anwendbare Verbesserung gewinnt, keine Mehrfachwirkung. Energie ist finale Stufe; wenn keine weitere Energieaufnahme möglich ist, Sammelobjekt dennoch verbrauchen, ohne XP. Bestehende Energieüberladung erhalten; Grenze tatsächlich anrechenbarer Aufnahme noch präzisieren.

| Verpflichtendes permanentes Upgrade | Fallback-Kette |
|---|---|
| Burst-Anzahl | Burst-Rate → Energie |
| Burst-Rate | Energie |
| Fire-Rate | Energie |
| Lebensregeneration | Direkte Heilung → Energie |
| Energieregeneration | Energie |
| Kinetikresistenz | Energie |
| Energieresistenz | Energie |
| Explosionsresistenz | Energie |
| Feuerresistenz | Energie |
| Plasmablitz-Höhe | Energie |
| Flammenwerfer-Kegelbreite | Energie |

Fire-Rate und Burst-Rate bewusst trennen; bisheriges gemeinsames Upgrade aufteilen. Plasmablitz behält maximale Reichweite, Höhe separat skalieren. Flammenwerfer-Kegel verbreitern, bisherige Bewegungsvererbung erhalten. Darstellung und Treffergeometrie müssen übereinstimmen. Alle Nicht-Resistenzupgrades mit regulärer Steigerungslogik; genaue Schritte/Grenzen später balancieren. XP bei tatsächlicher permanenter Verbesserung als konfigurierbarer fester Wert; direkte Heilung und Ressourcen nach tatsächlich erhaltenem Betrag.

HUD: vorhandene Balkengrafiken weiterverwenden, farblich differenzieren, verkleinern und unten vertikal beschriften nach grafischen Vorgaben des Entwicklers. Munitionsarten nicht allein anhand Farbe unterscheiden; feste Anordnung, Beschriftung oder Form und geeignete Kontraste berücksichtigen Farbsehschwächen. Grafiken und Sound beim Entwickler. Grafischer Bedarf für neue permanente Upgrades nach bisherigem Stand sieben Sammelobjekte (Burst-Rate, vier Resistenzen, zwei Waffenupgrades); neue Munitionsgrafiken separat prüfen.

### 3.5 Erfahrung und Level

Erfahrung innerhalb eines Spieldurchlaufs permanent kumuliert, nicht ausgebbar. Materielle Belohnungen und Gefahrenentlastung sind getrennte Systeme.

- Schaden: Nur tatsächlicher HP-Verlust nach Schadensreduktion zählt. Overkill, Schildschaden, wirkungslose Treffer und Fehlschüsse erzeugen keine XP. Erneut verlorene regenerierte HP zählen erneut; kein separater XP-Deckel pro Gegner. Walker nur Gesamt-HP-Verlust, keine doppelte Anrechnung von Körperteil-HP.
- Ressourcen und Heilung: tatsächliche wirksame Menge; bei Fallback nur dessen tatsächliche Wirkung. Permanente Upgrades: definierter XP-Wert je wirksamer Verbesserung.
- Taktische Boni: einmalig für Walker-Immobilisierung und vorgesehene Gegnerneutralisierung; kein erneuter Bonus beim Wrack. Natürliches Verlassen der Welt erzeugt keine XP.
- Verursacherprinzip: ursprünglicher Verursacher bei Kettenreaktionen erhalten; konfigurierbare Faktoren, konkrete Werte noch nicht beschlossen.
- Überleben: standardmäßig alle 20 Sekunden aktiver Spielzeit, konfigurierbares Intervall, Betrag und levelabhängige Steigerung. Keine XP in Pause/Touchdown-Countdown.
- Ansteigende konfigurierbare Levelschwellen, unmittelbarer Levelaufstieg auch über mehrere Schwellen. Budgetanpassung ohne Neustart der Belastungsphase. Neuer Spieldurchlauf setzt XP und Level zurück. Dauerhafte grafische XP-/Levelanzeige noch nicht vereinbart; Diagnoseausgabe für Abnahme genügt zunächst.

### 3.6 Gefahrenbudget und Spawnsteuerung

G = Summe der vorzeichenbehafteten Gefahr aller aktiven relevanten Weltobjekte; B = reguläres level- und phasenabhängiges Budget; E = kumulierte temporäre Gefahrenentlastung; P = Gefahr des ausgewählten Spawnkandidaten.

**Verbindliche letzte Fassung:** `B_eff = B - E` (keine Begrenzung auf null). Spawnfreigabe genau dann, wenn `G < B_eff` und `P <= B_eff`. Negative Werte werden nicht gesondert behandelt. Nach erfolgreichem Spawn darf `G + P` das Budget überschreiten. Kein künstliches Entfernen existierender Gegner, keine erzwungene Budgetausschöpfung.

Vor jedem Versuch G vollständig neu berechnen, keine persistente Gefahrenbuchhaltung. Ein zentraler framerateunabhängiger, konfigurierbarer Timer auf Basis aktiver virtueller Spielzeit; nach jedem Versuch (auch Ablehnung) nächstes Intervall. Zufälliger Kandidat aus zentraler Liste; bei Ablehnung kein unmittelbarer Ersatz. Keine levelabhängige Gewichtung oder künstlichen Gegnerzahlgrenzen, auch nicht für Drohnen. Bomber bleibt technische Einzelinstanz. Notwendige Platzierungsbedingungen bleiben bestehen. Dekorative Wolken/Türme separat verwalten.

Objekttypbezogene, feste konfigurierbare Gefahrenwerte, unabhängig von Rest-HP und Level. Positive Bedrohungen (z. B. Minen, Flak, Walker), negative unterstützende Objekte (Platten, Kisten, Jumppods). Immobilisierter Walker reduzierte Gefahr, Wrack null. Plattform samt geplanter Aufbauten ist ein gemeinsamer Kandidat mit Summe der Werte; keine zweite Budgetprüfung einzelner Aufbauten. Die tatsächlich erzeugte Zusammensetzung muss der geprüften Zusammensetzung entsprechen; nach Freigabe keine erneute zufällige Auswahl der Aufbauten. Nach Erzeugung aktuelle Einzelzustände zählen. Projektile, aktive Bomben und Explosionen vorerst nicht in der Gefahr enthalten. Plattformlebenszyklen und Instanzidentitäten beachten; frei erzeugte Sammelobjekte in zentraler Spawnverwaltung, genaue Gefahrenbewertung noch festzulegen.

E entsteht ausschließlich durch tatsächliche Reduzierung positiver Gefahr infolge Bekämpfung/funktionaler Einschränkung. Gefahrenreduktion × eigener Entlastungsfaktor × eigener Verursacherfaktor (unabhängig von XP). Bei einem unmittelbaren Zustandsübergang (z. B. aktiver Walker direkt zur vollständigen Zerstörung) die tatsächliche positive Gefahrenreduktion nur einmal anrechnen; keine zusätzlichen Entlastungen für übersprungene Zwischenzustände. Mehrere Entlastungen addieren, linear zeitabhängig bis null abbauen, keine Obergrenze, phasenübergreifend. Natürliches Verlassen erzeugt keine Entlastung; Zerstörung eines hilfreichen Objekts entfernt dessen negativen Wert, erhöht G und verändert E nicht. Kein pauschaler Spawnstopp. Bei negativen Budgets gelten unverändert die beiden Freigabebedingungen.

Belastungs-/Erholungsphasen mit statischen konfigurierbaren Dauern; Budget beider Phasen wächst mit Level. Keine dynamische Dauer oder Neustart beim Levelaufstieg. Pause friert Timer ein; neuer Durchlauf initialisiert sämtliche Zustände neu.

## 4. Technische Bestandsaufnahme

Statische Lesesichtung des Branches `develop`; keine Kompilierung, keine Laufzeitmessungen, keine Änderungen. Ausgangsstand der früheren Sichtung: `b0afb25a49dcd56b66ecf06999b3730897205017`; die nachfolgenden Quellcodeverweise zeigen den Branch und sind nicht auf diesen Commit fixiert. Pfade nachfolgend relativ zu `source/sonec/`.

| Bereich | Befund und Konsequenz |
|---|---|
| `reward.agc` | Zentrale materielle Drops für acht Objekttypen; als Grundlage erhalten. Teilweise Auswahl über Länge des Grafikarrays, neue Pickup-Typen daher kontrolliert anbinden. |
| `bullet.agc`, `grenade.agc`, `flame.agc`, `plasmablitz.agc`, `explosion.agc` | Direkte HP-Abzüge und unterschiedliche Zielpfade; zentralisieren, Geometrie und Prioritäten erhalten. Auch Spezialpfade in Gegnerdateien prüfen. |
| `shield.agc` | `ShieldAbsorbDamage` bereits zentrale Schildabsorption; nicht mit Panzerung gleichsetzen. |
| `sonec.agc`, `weaponcollision.agc` | Zwei-Kreis-Hitbox, Bewegungssegmente und Waffen-Kollisionsebenen vorhanden; nicht neu entwickeln. Energieüberladung besitzt eigene HP-Verlustpfade. |
| `def_game.agc` | Gemeinsame Typen; `TBulletData` enthält bisher Typ/Schaden, kein vollständiges Schadens-/Verursachermodell. |
| `walker.agc` | Rund 2100 Zeilen; `WalkerHealthRegenerate` verarbeitet Regeneration und Zerstörung; Turm-Treffergeometrie vorhanden; IK und plattformrelative Position vorhanden. `WalkerMoveAll` entfernt nach eigener X-Position (1491 ff.); Plattformbindung und Slot-Identität korrigieren. |
| `explosion.agc` | Radius wächst und schrumpft anhand Animation; Maximalradius aus Grafikgröße und Skalierung, bestehender zeitlicher Schaden (100 ms, 30 HP im gesichteten Stand). Trefferhistorien überwiegend slotbezogen; bei Druckwellen eindeutige Zielinstanzen sicherstellen. Schutz und Mitführung von Bombenexplosionen an Plattformen erhalten. |
| `energie.agc` | Acht bisherige Pickup-Typen (Energie, Energieregeneration, Heilung, Lebensregeneration, kombinierte Fire-/Burst-Rate, Burst-Anzahl mit bisherigem Rate-Fallback, Geschosse, Granaten). Bestehende Grafik und Meldungen laut Entwickler vorhanden. JSON-geladene Grafikprototypen; Fallbacks neu vereinheitlichen. |
| `sonec.agc`, `def_game.agc` | Maximalwerte Geschosse 300, Granaten 50, Energie 4000, Leben 1000 im gesichteten Stand; keine Kapazitätsupgrades. Bisher je Munitionsfamilie nur ein Bestand. |
| `bullet.agc` | `BulletSetModification` und Explosivgeschoss-Zünder der Flak vorhanden; Eignung für Sonec prüfen, insbesondere Treffer-/Zünderpfade und Verursacher. |
| `plasmablitz.agc` | Einheitliche Sprite-Skalierung, Breite/Höhe in Treffergeometrie verwendet; vertikale Ausdehnung separat skalieren und alle Kollisionspfade berücksichtigen. |
| `flame.agc`, `sonec.agc` | Einzelpartikel mit Bewegung, dynamischem Kollisionsradius und vererbter Sonec-/Plattformgeschwindigkeit; steuerbare Kegelstreuung fehlt. |
| `gui.agc` | Lebens-, Energie- und Geschossbalken normiert; Granaten absolut dargestellt. HUD-Grafiken wiederverwenden. |
| `drone.agc`, `def_game.agc` | Tatsächliche Einzelinstanz `Game.Drone`, zahlreiche globale Scan-, Lade-, Laser-, Bewegungs- und Effektzustände; ein verzögertes Zerstörungsereignis. Mehrinstanzumbau benötigt eigenes Paket. |
| `bomber.agc` | Einzelinstanz mit eigener Angriffsphase, Warnung und Bombenliste; erhalten, zentralen Start anbinden. |
| `game.agc`, `plate.agc`, `simplemine.agc`, `jumppod.agc` | Framebasierte Spawnchancen und Limits (Platten, Walker, Orbs, Minen), eigene Scheduler (Drohne, einfache Minen, Bomber, Jumppod), Plattenplatzierung und Aufbauten nach Erzeugung. Kandidaten vor Erzeugung planbar machen; technische Platzierung von künstlichen Limits unterscheiden. |
| `flarak.agc`, `jumppod.agc`, `chest.agc` | Plattformgebundene Objekte und wiederverwendete Slots; Lebenszyklen und Identitäten prüfen. Flak besitzt bereits Carrier-ID-Prüfung. |
| `main.agc`, `game.agc` | Virtuelle pausebewusste Spielzeit `CurrentNow`, Initialisierung und Touchdown-Countdown; gemeinsame Grundlage für XP-, Spawn-, Phasen- und Entlastungstimer. |

Quellcode: [SonecBot/develop/source/sonec](https://github.com/ChristianEngel19820128/SonecBot/tree/develop/source/sonec). Besonders relevante Einstiegspunkte: [GameDo](https://github.com/ChristianEngel19820128/SonecBot/blob/develop/source/sonec/game.agc#L302-L530), [Walker](https://github.com/ChristianEngel19820128/SonecBot/blob/develop/source/sonec/walker.agc), [Drohnenzustände](https://github.com/ChristianEngel19820128/SonecBot/blob/develop/source/sonec/drone.agc#L35-L65), [Pickup-Verarbeitung](https://github.com/ChristianEngel19820128/SonecBot/blob/develop/source/sonec/energie.agc#L190-L290), [Explosionen](https://github.com/ChristianEngel19820128/SonecBot/blob/develop/source/sonec/explosion.agc).

## 5. Umfangsbewertung

| Themenblock | Verpflichtender Umfang | Zurückgestellt |
|---|---|---|
| Walker | HP, Panzerung, Trefferzonen, funktionale Zustände, Animationen, Wrack, Lebenszyklus, Belohnung | Hindernisse/Deckung und Hinken (Beta); keine Reparatur |
| Schaden | Zentrale Verarbeitung, Matrix, vier Schadensarten, Immunitätsunterstützung, Resistenzupgrades, AP | Nanopanzerung, konkrete Bosspanzerungen, neue Statuseffekte |
| Explosion | Beide Modi, Distanzschaden, Trefferhistorie, Attribution, bestehender Plattformschutz | Neue Abschattung (Beta), keine Fall-/Druckwellenphysiksimulation |
| Ressourcen | Drei Familien, fünf Munitionsarten, Priorität/Verdrängung, Fallbacks, HUD, elf permanente Upgrades | 16 optionale Upgrades; manuelle Munitionswahl und Handgranaten (Beta) |
| Erfahrung | Sämtliche vereinbarten Quellen, Level, Zeit und Attribution | Missionen später; XP-Anzeige noch offen |
| Gefahr | Zentraler Spawn, vorzeichenbehaftetes Budget, Zustandsgefahr, Entlastung, Phasen, Drohnenliste | Gefahr von Projektilen/Bomben/Explosionen optional; keine dynamischen Phasendauern oder Levelgewichtungen |

Neue Druckwellengrafik sinnvoll, jedoch kein technischer Abnahmeblocker. Optionale Erweiterungen sind keine Abschlussvoraussetzungen und nicht in die Wochenschätzung eingerechnet.

## 6. Alpha-/Beta-Abgrenzung und optionale Upgrades

11 permanente Upgrades verpflichtend (siehe 3.4), 16 optional:

| Gruppe | Optionale Upgrades | Anzahl |
|---|---|---:|
| Kapazitäten | Geschosse, Granaten, Energie, Leben | 4 |
| Bewegung | Jetpack-Schub, maximaler Sprungimpuls, maximale Laufgeschwindigkeit | 3 |
| Schild | Kapazität, Regeneration | 2 |
| Waffenschaden | Geschosse, Granaten, Plasmablitz, Flammenwerfer jeweils separat | 4 |
| Weitere Waffen | Flammenwerfer-Reichweite, Plasma-Energieeffizienz, Flammenwerfer-Energieeffizienz | 3 |
| Gesamt | | 16 |

Kapazitätszweig besitzt noch keine Grafiken; vorhandene Maximalwerte allein rechtfertigen keinen verpflichtenden Ausbau. Bewegungsparameter bleiben zunächst unverändert. Bei späterer Umsetzung sollen zwei Drittel des Upgrade-Spielraums unter dem heutigen Wert und ein Drittel darüber liegen; absolute Spanne im Balancing bestimmen. Keine pauschale Senkung um 67 %. Schildupgrades optional, bestehender Schild bleibt erhalten. Kein generisches Schadensupgrade. Mögliche Fallbacks optionaler Zweige sind nicht beschlossen.

Beta bzw. spätere Phase: physische Walker-Hindernisse/Deckung, Hinken, zusätzliche Druckwellenabschattung, zusätzliche Schadensstatuseffekte, manuelle Munition, Handgranaten; konkrete Bosspanzerungen, Nanopanzerung erst mit vorgesehenem Gegner. Missionen, Qualitäts-/Langzeittests, HTML5 und abschließendes Balancing separat planen. Drohnenschild bleibt Konzeptidee ohne zugewiesenes Paket; nicht stillschweigend in B10 integrieren.

## 7. Technische Abhängigkeiten

Empfohlene und freigegebene Reihenfolge B01 bis B13. B01 schafft zentrale Schadens- und Ereignisgrundlage; B02 ergänzt Panzerung; B03 stellt Druckwellen bereit; B04/B05 nutzen diese für Walker. B06 schafft Aufnahmelogik; B07 benötigt B03 und B06, B08 B02 und B06. B09 bindet die Ereignisse aus B01–B08 an XP/Level an. B10 setzt B01, B02 und B09 voraus, stellt Drohnenmehrinstanzfähigkeit her und integriert die vorhandenen Schadens-/XP-Pfade. B11 nutzt B05/B10; B12 setzt B09/B11 voraus; B13 folgt allen Paketen.

B01 und B02 bewusst getrennt: zunächst Verhaltensparität, erst danach neue Schadensregeln. B04 und B05 bewusst getrennt: funktionale Zustände zunächst eingefroren, danach endgültige Animationen. B11 und B12 bewusst getrennt: technische Erzeugung zuerst, Freigabeentscheidung anschließend. Keine dauerhaften Übergangssysteme. Kontrollierte Testbestände/-auslöser nur soweit zur Abnahme erforderlich.

## 8. Freigegebene Arbeitspakete

| Paket | Titel | Voraussetzungen | Aufwand (relativ) |
|---|---|---|---|
| B01 | Zentrale Schadensverarbeitung und Verursacherzuordnung | Phase A | Hoch |
| B02 | Schadensarten und Panzerungssystem | B01 | Mittel |
| B03 | Explosionen und Druckwellen | B02 | Mittel |
| B04 | Walker – Trefferzonen und Schadensmodell | B01–B03 | Hoch |
| B05 | Walker – Animationen und Lebenszyklus | B04 | Hoch |
| B06 | Ressourcenverwaltung und Fallback-System | B02 | Mittel |
| B07 | Munitionsarten und barrierearmes HUD | B02, B03, B06 | Mittel |
| B08 | Permanente Upgrades | B02, B06 | Mittel bis hoch |
| B09 | Erfahrung und Levelsystem | B01–B08 | Mittel |
| B10 | Mehrinstanzfähigkeit der Drohne | B01, B02, B09 | Hoch |
| B11 | Zentrale Spawnverwaltung | B05, B10 | Hoch |
| B12 | Gefahrenbudget und Belastungsphasen | B09, B11 | Mittel |
| B13 | Abschließende Quellcodebereinigung | B01–B12 | Mittel |

Gesamtschätzung: eine Woche nach Erfahrung des Entwicklers, keine künstliche Aufteilung in Tagesstunden. Relative Aufwände basieren auf statischer Sichtung, keine verifizierten Stundenwerte. Jede Abnahme umfasst lokale Kompilierung, gezielte vereinbarte Tests, notwendige Korrekturen und Dokumentationsaktualisierung. Keine Implementierung in diesem Konzeptschritt.

### B01 – Zentrale Schadensverarbeitung und Verursacherzuordnung

**Ziel:** Gemeinsame Schadensgrundlage bei unverändertem bestehendem Spielverhalten.

**Umfang:** Aktive kampfbezogene Schadenspfade vollständig erfassen; zentrale Schnittstelle, tatsächlicher HP-Verlust, getrennte Schildabsorption, Verursacherinformation auch bei verzögerter Zerstörung und Kettenreaktion. Ereignisse für spätere XP/Entlastung vorbereiten. Bestehende Geometrie, Priorität, Intervalle, Schadenswerte und Drops erhalten. Den tatsächlich anrechenbaren HP-Verlust getrennt von der bisherigen internen HP-Verarbeitung bestimmen; keine vorzeitige Änderung bestehender HP-Grenzen oder Zerstörungsschwellen.

**Abgrenzung:** Keine neuen Schadensarten, Panzerung, Druckwellen, Walker-Teile, Munition, XP oder Entlastung. Überladung und weitere nicht kampfbezogene Verluste eindeutig abgrenzen, nicht unbeabsichtigt verändern.

**Aktivierung:** Ergänzende Funktionen und Daten zuerst, Übergaben vorbereiten, anschließend kontrolliert umstellen; keine doppelte Verarbeitung. Alte nachweislich unnötige Pfade soweit unmittelbar erforderlich entfernen, Rest B13.

**Abnahme:** Alle bisherigen aktiven Waffen-/Angriffspfade funktionieren wie zuvor; tatsächlicher HP-Verlust und Schildverlust unterscheidbar; Attribution bei Kettenreaktionen und verzögerter Zerstörung korrekt; Zerstörung/Belohnung unverändert. Risiko: viele Module und zeitversetzte Ereignisse; bei Bedarf vor Umsetzung teilen.

### B02 – Schadensarten und Panzerungssystem

**Ziel:** Beschlossenes Schadens-/Panzerungsmodell zentral verfügbar.

**Umfang:** Vier Schadensarten, JSON-Matrix mit ungepanzert und vier regulären Typen, Immunitätsunterstützung, Zuordnung bestehender Gegner/Weltobjekte, vier Sonec-Resistenzen, AP-Rechenlogik. Parameter/Zuordnungen vor Aktivierung abstimmen.

**Abgrenzung:** Körperteilpanzerung B04, AP-Munition B07, Resistenzpickups B08, Nano/Bosspanzerungen zurückgestellt; endgültige Werte Balancing.

**Abnahme:** Alle Matrixkombinationen korrekt, 100 % Immunität auch bei AP wirksam, unabhängige Resistenzen, konfigurierbare Matrix ohne Codeänderung, Schild und Treffermechanik erhalten.

**Freigegebene Startzuordnung:** Walker/Flak/Flarak massiv, Orb/Drohne Energie, intelligente Mine/Bomber Verbund; einfache Mine, Landmine, Kiste und Jumppod ungepanzert. Geschosse und Granatendirekttreffer kinetisch, Plasmablitz/Laser Energie, Flammen Feuer, Bomben/Raketen/Explosionen explosiv; vorhandene Quellen AP 0. Unmittelbare Zerstörungen und Abfangen bleiben unverändert. B02 im vereinbarten Umfang abgeschlossen: 31/31 lokale Prüfpunkte, 31/31 AGK-Selbsttest, 623/623 aktive CSV-Treffer korrekt; externe Matrixänderung ohne Compile einschließlich kinetischer Immunität nachgewiesen. Abnahmegrenzen siehe TECHNICAL.md.

### B03 – Explosionen und Druckwellen

**Ziel:** Allgemeiner zusätzlicher Druckwellenmodus bei unverändertem Flächenschaden.

**Umfang:** Darstellung/Modus/Schadensart trennen; vorhandene Radiuslogik nutzen; abnehmender Schaden mit Restschaden am Maximalradius, einmaliger Treffer je Zielzone, bewegliche Ziele und eindeutige Instanzen, Attribution und Plattformschutz. Kontrollierter Testauslöser.

**Abgrenzung:** Walker-Kernexplosion und Körperteile B04; Spielermunition B07; neue Abschattung Beta. Neue Grafik kein technischer Blocker.

**Abnahme:** Bestehende Explosionen unverändert, beide Modi nutzbar, nur auswärts wandernde Front schädlich, kein Mehrfachtreffer, Distanzabnahme, bewegliche Ziele, Slot-Wiederverwendung, Kettenreaktion, Zwei-Kreis-Hitbox und Plattformschutz korrekt.

### B04 – Walker: Trefferzonen und Schadensmodell

**Ziel:** Individuelle Körperteile und funktionale Zerstörungszustände.

**Umfang:** Teil-/Gesamt-HP, Panzerungen, bewegliche rotierte Rechtecke, alle Waffen und Druckwellen, reduzierte Wirkung zerstörter Teile, Zustandspriorität, Kernexplosion, einmalige Drops, Regeneration entfernen, XP-/Entlastungsereignisse vorbereiten.

**Abgrenzung:** Animation, Farbe und endgültiger Plattformlebenszyklus B05. XP B09, Entlastung B12, Hindernisse Beta. Zwischenstand bewusst eingefrorene Pose ohne provisorische Animation, funktionale Zustände bereits wirksam.

**Abnahme:** Gezielt treffbare Teile, erste Trefferzone bei Geschoss, einmal je Teil bei Druckwelle und kumulativer Gesamtverlust, Bein stoppt Bewegung, Turm neutralisiert, Korpus/Gesamt-HP lösen Kernexplosion aus, keine Mehrfachbelohnung, passiver Walker bleibt beschädigbar. Risiko: alle Waffengeometrien konsistent integrieren.

### B05 – Walker: Animationen und Lebenszyklus

**Ziel:** Vollständige visuelle und funktionale Walker-Zustände.

**Umfang:** Animationen A/B gemäß 3.1, IK und Kopplung, Feuerunterbrechung und Wiederaufnahme, unmittelbare Unterbrechung bei Kernexplosion, Abdunklung/Wrackfarbe, Trefferzonen mitführen, Plattformlebenszyklus einschließlich wiederverwendeter Slots.

**Abgrenzung:** Keine neue Grafik, Fallphysik, Reparatur, Hindernisse oder Hinken. Gefahr B12. JSON für Animationen nur falls technisch sinnvoll.

**Abnahme:** Aus jeder Laufpose korrekt absenken, Füße relativ zur Plattform fixiert, A→B bei Turmverlust, kein Feuer während Animation, intakter Turm feuert danach, passive beschädigbare Wracks, geometrisch korrekte Trefferzonen, immobilisierte Walker/Wracks bleiben bis Plattformentfernung, natürlicher Abgang ohne Explosion/Drop. Risiko: tatsächliche IK-/Kontaktgeometrie erst praktisch verifizierbar.

### B06 – Ressourcenverwaltung und Fallback-System

**Ziel:** Gemeinsame Aufnahmearchitektur für bestehende und neue Pickup-Typen.

**Umfang:** Drei Familien, Mehrtypenbestände, gemeinsame Kapazitäten, Teilaufnahme, Verdrängung nur von Standard, JSON-Fallbacks (erste Wirkung), tatsächliche Wirkung für XP erfassen, bestehende Pickups und Drops anbinden. Testbestände für Spezialmunition.

**Abgrenzung:** Neue Munitionsarten, Verbrauch und HUD B07, permanente Upgrades und Rate-Trennung B08, XP B09. Bestehendes gemeinsames Rate-Upgrade bis B08 erhalten; keine neuen Grafiken erforderlich.

**Abnahme:** Bestehende Pickups funktionsfähig, Kapazität/Verdrängung korrekt, Teilaufnahme ohne weiteren Fallback, wirkungslose Aufnahmen durchlaufen Kette bis Energie, effektive Wirkung erfasst, Energieüberladung erhalten. Aufnahmegrenze bei Überladung klären.

### B07 – Munitionsarten und barrierearmes HUD

**Ziel:** Fünf nutzbare Munitionsarten mit automatischer Priorität und verständlicher Anzeige.

**Umfang:** Standard/AP/Explosivgeschosse, Explosiv-/Feuergranaten gemäß 3.4; neue Pickups, Kapazität/Verdrängung, Energie-Fallback, Drops, Verbrauchspriorität auch in Salven, HUD-Farben, Verkleinerung, vertikale Beschriftung, nicht ausschließlich farbliche Unterscheidung. Flak-Explosivgeschossgrundlage prüfen.

**Abgrenzung:** Schadens-/Kapazitätsupgrades optional, manuelle Wahl/Handgranaten Beta, kein taktischer Selektor. Grafikgestaltung durch Entwickler.

**Abnahme:** Schadensarten und Modi korrekt, AP respektiert Immunität, Explosivgeschosswirkung korrekt, Prioritäten und Abzug nur bei Abschuss, Aufnahme/Fallback, tatsächliche Bestände im HUD und Unterscheidbarkeit bei Farbsehschwächen, bestehende Steuerung/Kollisionen erhalten. Direkter Explosivgeschoss-Trefferschaden und Explosionsmodus vor Aktivierung festlegen; Grafikverfügbarkeit prüfen.

### B08 – Permanente Upgrades

**Ziel:** Elf freigegebene permanente Upgrades mit Fallbacks gemäß 3.4.

**Umfang:** Bestehende Burst-Anzahl, Fire-Rate und Regeneration übernehmen; Burst-Rate separat; vier Resistenzen mit abnehmenden Zuwächsen; Plasmablitz-Höhe ohne Reichweitenänderung; Flammenkegelbreite; alle Fallbacks, Ereignisse und Pickup-Grafiken anbinden. Sieben neue Upgrade-Grafiken nach bisheriger Einschätzung.

**Abgrenzung:** 16 optionale Upgrades nicht umsetzen; XP B09, endgültige Schritte/Grenzen Balancing. Technik kann vor Grafikfertigstellung vorbereitet werden.

**Abnahme:** Elf unabhängig wirksame Upgrades, Rate-Trennung, Resistenzen bis 75 %, nur dort abnehmende Zuwächse; Plasma-Höhe und Flammenkegel korrekt dargestellt und getroffen; Fallbacks, XP-Ereignisse, bestehende Bewegungs-/Waffenmechanik erhalten. Bei Umfangsrisiko vorab in allgemeine und individuelle Waffenupgrades teilen.

### B09 – Erfahrung und Levelsystem

**Ziel:** Zentrale XP-/Levelberechnung und Ereignisanbindung.

**Umfang:** Sämtliche Quellen und Regeln aus 3.5, konfigurierbare Faktoren/Schwellen, Überlebensintervall 20 s, ursprünglicher Verursacher, unmittelbare Levelaufstiege, Reset je Durchlauf; Level für B12 bereitstellen.

**Abgrenzung:** Gefahrenbudget B12, keine Levelbelohnungen, ausgebbaren XP oder Missionen; dauerhafte Anzeige offen, Diagnose genügt zur Abnahme.

**Abnahme:** Keine doppelte oder wirkungslose Vergabe, tatsächliche HP/Ressourcen, Schild/Overkill ausgeschlossen, Walker-Gesamt-HP und einmalige Boni, korrekte Attribution, mehrere Levelsprünge, keine Überlebens-XP in Pause/Countdown, Reset und Unabhängigkeit materieller Drops.

### B10 – Mehrinstanzfähigkeit der Drohne

**Ziel:** Bisherige Einzelinstanz ohne Änderung der Mechanik in Mehrinstanzbetrieb überführen.

**Umfang:** Dynamische Liste, instanzbezogene bisher globale Bewegungs-/Scan-/Lade-/Laser-/Effektdaten, individuelle HP/Panzerung/IDs, unabhängige Treffer, Zerstörungsereignisse, Drops, XP, Slot-Recycling, Reset und Spawnfunktion. Alle Aufrufstellen kontrolliert umstellen.

**Abgrenzung:** Kein Drohnenschild, keine neuen Angriffe/Koordination, keine Bombermehrinstanz. B11 zentrale Spawnsteuerung, B12 Gefahr. Bis B11 reguläre automatische Erzeugung weiterhin maximal einer Drohne; mehrere Instanzen gezielt testen.

**Abnahme:** Mehrere unabhängige Drohnen, alle Waffen korrekt, gleichzeitige Zerstörungen mit separaten Effekten/Drops/XP, sauberes Slot-Recycling, Laser nutzt zentrale Zwei-Kreis-Hitbox, Einzelverhalten unverändert. Risiko: viele globale Zustände und bislang nur ein verzögertes Zerstörungsereignis.

### B11 – Zentrale Spawnverwaltung

**Ziel:** Ein gemeinsamer zeitbasierter Spawnpfad vor Einführung der Budgetentscheidung.

**Umfang:** Konfigurierbarer Timer, Kandidatenliste, Zufallsauswahl, Vorbereitung/Prüfung/Erzeugung trennen, Plattform samt Kisten/Walker/Flak/Jumppod und gegebenenfalls weiteren Aufbauten als Einheit planen, Orbs, intelligente/einfache Minen, Drohnen, Bomberstart und freie Pickups zentral anbinden. Künstliche Limits/alte Scheduler deaktivieren; technische Platzierung und Bomber-Einzelinstanz erhalten. Dekoration separat. Freigabeschnittstelle für B12.

**Abgrenzung:** Gefahr, Entlastung, Phasen B12; keine Levelgewichtung; alte ungenutzte Funktionen B13; endgültige Chancen Balancing. Bis B12 kontrollierte Freigabebedingungen, die unkontrollierte Gegnererzeugung verhindern; keine unbeschränkte reguläre Spawnfreigabe und kein provisorisches Schwierigkeitssystem. Konkrete Testbedingungen vor Aktivierung abstimmen.

**Abnahme:** Alle Kandidaten zentral erzeugbar, framerateunabhängige Intervalle nach Erfolg/Ablehnung, kein Ersatzkandidat, zusammengesetzte Kandidaten vor Erzeugung bewertbar und geprüfte Zusammensetzung bei Erzeugung unverändert, technische Platzierung, reguläre Mehrdrohnen, keine künstlichen Gegnerlimits, bestehende Angriffsabläufe, keine Spawns in Pause. Risiko: bisher Aufbauten erst nach Plattenerzeugung; Minenformationen und Bomber-Warnphase prüfen.

### B12 – Gefahrenbudget und Belastungsphasen

**Ziel:** Budgetbasierte Schwierigkeitssteuerung und Entlastung gemäß 3.6.

**Umfang:** Vorzeichenbehaftete Gefahr, volle Neuberechnung je Versuch, konfigurierbare Objektwerte, zusammengesetzte Kandidaten, Level-/Phasenbudget, unmittelbare Levelwirkung, Entlastungsereignisse mit eigenen Faktoren, Kumulation und linearer Abbau. Aktivierung an B11-Freigabeschnittstelle nach Tests mit simulierten Leveln/Beständen.

**Abgrenzung:** Keine Sonderbehandlung negativer Budgets (keine Nullbegrenzung), keine Projektile/Bomben/Explosionen im Pflichtumfang, keine dynamischen Phasendauern/Levelgewichtung/erzwungene Füllung/Entfernung. Parameter Balancing.

**Abnahme:** Exakt `G < B-E` und `P <= B-E` einschließlich negativer Werte, Überschreitung nach Spawn erlaubt; Walkerzustände ohne mehrfache Entlastung bei direkten Zustandsübergängen, negative Weltobjekte, natürliche Abgänge ohne Entlastung, kumulative Entlastung/Abbau, Phasenwechsel, Level ohne Reset, Pause/Neustart korrekt.

### B13 – Abschließende Quellcodebereinigung

**Ziel:** Konsistenter wartbarer Stand ohne Änderung des abgenommenen Spielverhaltens.

**Umfang:** Verwendungen prüfen, nachweislich überflüssige Schadens-/Spawn-/Drohnenaltpfade, Datenstrukturen, Konstanten, Variablen, Parallelimplementierungen und temporäre Tests entfernen; redundante/unerreichbare Abschnitte prüfen; Kommentare, JSON-Konsistenz und Projektdokumentation aktualisieren. Sinnvolle Diagnosefunktionen behalten.

**Abgrenzung:** Kein vorsorgliches Refactoring, allgemeine Performanceoptimierung, funktionale Erweiterung, optionale Upgrades oder Balancing. Alter allein ist kein Löschkriterium.

**Abnahme:** Kompilierbar, gezielte Regressionstests für Phase A/B, keine unbeabsichtigte doppelte Verarbeitung, abgelöste Bestandteile entfernt, notwendige Diagnosen erhalten, Dokumentation entspricht tatsächlichem Stand, bekannte Fehler und Rückstellungen nachvollziehbar. Umfang erst nach B01–B12 abschließend beurteilbar.

## 9. Offene Punkte und Entscheidungen vor Aktivierung

| Punkt | Zuständiges Paket / Zeitpunkt |
|---|---|
| Schadensschnittstellen, vollständige aktive Pfade und nicht kampfbezogene Verluste, Attribution bei mehreren Schadensursachen und verzögerter Zerstörung | B01 |
| Schild-/Resistenzreihenfolge, Schadensrundung, AP-Formel, Panzerungszuordnung je Objekt, Startresistenzen | B02; konkrete Werte Balancing |
| Druckwellenformel, Restschaden/Radius, Instanz-IDs, kontinuierliche Wellenfrontprüfung | B03 |
| Walker-Trefferzonenabgrenzung, HP, Schadensfaktor zerstörter Teile, Verhalten bei Mehrfachtreffern; Zuordnung Teilpanzerung | B04; Werte Balancing |
| IK-Kontaktgeometrie, Animationsdauer, JSON-Eignung, Projektilinteraktion mit Wrack und Trägeridentität | B05 |
| Energiefallback bei Überladung, tatsächliche Energieaufnahme und XP-Abgrenzung, JSON-Struktur | B06 |
| Explosivgeschoss: genauer Direkt-/Explosionsschaden und Modus; neue Pickup-Grafiken, HUD-Farbwahl/Form/Anordnung | B07, Entwickler für Gestaltung |
| Upgrade-Grafiken, Schritte/Maxima, Resistenzkurve, unabhängige Plasma-Skalierung und Flammenstreuung | B08; Werte Balancing |
| XP-Faktoren und Attribution, Schwellenkurve, Überlebensbetrag und Levelanzeige | B09; Werte Balancing |
| Drohnenschild als separate Idee ohne freigegebenes Paket | Separate Entscheidung |
| Kandidatenliste und allgemeine Spawnwahrscheinlichkeiten (keine levelabhängige Gewichtung), Minenformationen, Plattformaufbauten, technische Platzierung, Bomber-Warnphase und freie Pickups | B11 |
| Konkrete Gefahrenwerte, Phasenbudget/-dauer, Entlastungs-/Verursacherfaktoren, Abbaurate | B12; Werte Balancing |
| Bereinigungsumfang und Regressionstestliste | B13 |

Nicht als bereits entschieden behandeln: konkrete numerische Balancingwerte außerhalb ausdrücklich beschlossener Matrix/Resistenzgrenze und Standard-Überlebensintervall, zusätzliche optionale Fallbacks, neue Boss- oder Schildmechaniken. Offene Punkte vor Umsetzung mit dem Entwickler abstimmen, soweit sie über reine technische Ausgestaltung hinausgehen.

**Dokumentstatus:** Konzeptphase abgeschlossen; Gesamtkonzept und Arbeitspakete B01–B13 freigegeben, Dokument im Branch `develop` hinterlegt und auf Konsistenz geprüft. Ausschließlich dokumentarische Änderungen, keine Quellcodeänderungen und keine praktischen Tests im Rahmen der Konzeptphase. Nächster Schritt: B01 in einem neuen Implementierungschat nach Prüfung des aktuellen Quellcodebestands und Freigabe des konkreten Implementierungsplans.
