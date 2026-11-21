# SonecBot – Nächste Aufgaben

**Stand:** 21. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] **Belohnungen/Nachrichten inventarisieren.** Jede Zerstörung soll eine Belohnung geben; Energie am häufigsten, genaue Art/Menge Balancing. Fehlende Meldungen erfassen; Energie-Sammelmeldung `ENERGY COLLECTED xN` per bestehender N1a-Queue als kleiner erster Schritt eingebaut, Entwickler bestätigt E1 lokal 5/5. E2a: zentraler `RewardDrop`-Dispatcher mit Objekt-Konstanten und `select/case` für Smart-/SimpleMine eingebaut; lokal 6/6 bestanden, keine Balancingänderung. Weitere Objekttypen später einzeln migrieren; übrige Meldungen und Textkonstanten später vereinheitlichen.
- [ ] **N1b 9/9 und N1c 6/6 lokal bestanden; letzter Übergangs-Feinschliff, Test offen.** Einflug von rechts, Ausflug nach links, 24-Pixel-Abstand zwischen gleichzeitig gleitenden Panels; Duplikat-Feedback nur als dünner Rahmen. Animationen 500/250 ms; N1a-Queue unverändert.
- [ ] **Menü-Hilfetexte später erweitern.** Nur vormerken; gehört nicht in den aktuellen N1-/Cloud-Arbeitsschritt.

**Abgenommen:** T4 vom Entwickler lokal 5/5, F1-Fix `09e1063` lokal 6/6 bestanden; N1a vollständig bestätigt: ursprünglich 7/10, gezielter Resttest 5/5 bestanden. Temporäre Testtasten 8–0 entfernt; FPS bleibt, Drohnen-Debug-Zusatz entfernt. Aufräumänderung lokal bestätigt (Spiel normal, Debug-Anzeige weg, Tasten 8–0 inaktiv). AGK wurde nicht vom Assistenten ausgeführt.

## Pflege

- Erledigtes nach dokumentierter Abnahme entfernen. Weitere Releasearbeit in Roadmap, unverbindliche Ideen in BACKLOG.
- Wiedereinstieg: [HANDOFF.md](HANDOFF.md).
