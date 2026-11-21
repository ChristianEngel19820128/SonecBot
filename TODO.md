# SonecBot – Nächste Aufgaben

**Stand:** 21. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] **Belohnungen/Nachrichten inventarisieren.** Jede Zerstörung soll eine Belohnung geben; Energie am häufigsten, genaue Art/Menge Balancing. Fehlende Meldungen erfassen; Energie-Sammelmeldung `ENERGY COLLECTED xN` per bestehender N1a-Queue als kleiner erster Schritt eingebaut, Entwickler bestätigt E1 lokal 5/5. E2a: zentraler `RewardDrop`-Dispatcher mit Objekt-Konstanten und `select/case` für Smart-/SimpleMine eingebaut; lokal 6/6 bestanden, keine Balancingänderung. Weitere Objekttypen später einzeln migrieren; übrige Meldungen und Textkonstanten später vereinheitlichen.
- [ ] **Menü-Hilfetexte später erweitern.** Nur vormerken; gehört nicht in den aktuellen N1-/Cloud-Arbeitsschritt.

**Nachrichten-Polishing abgeschlossen:** N1b 9/9, N1c 6/6 und N1d 5/5 lokal vom Entwickler bestanden; Einflug rechts, Ausflug links, 24-Pixel-Abstand, ruhiger Duplikatrahmen. AGK nicht vom Assistenten ausgeführt.

**Abgenommen:** T4 vom Entwickler lokal 5/5, F1-Fix `09e1063` lokal 6/6 bestanden; N1a vollständig bestätigt: ursprünglich 7/10, gezielter Resttest 5/5 bestanden. Temporäre Testtasten 8–0 entfernt; FPS bleibt, Drohnen-Debug-Zusatz entfernt. Aufräumänderung lokal bestätigt (Spiel normal, Debug-Anzeige weg, Tasten 8–0 inaktiv). AGK wurde nicht vom Assistenten ausgeführt.

## Pflege

- Erledigtes nach dokumentierter Abnahme entfernen. Weitere Releasearbeit in Roadmap, unverbindliche Ideen in BACKLOG.
- Wiedereinstieg: [HANDOFF.md](HANDOFF.md).
