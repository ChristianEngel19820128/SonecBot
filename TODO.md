# SonecBot – Nächste Aufgaben

**Stand:** 22. November 2026 · **Arbeitszweig:** `develop`

## Jetzt

- [ ] **B5c – Schutzgrenze als Langzeitbeobachtung (kein akuter Blocker).** Lokaler Test 4/5 bestätigt; Schutz direkt unter der getroffenen Plattform mangels reproduzierbarer Spielsituation nicht beobachtbar (nicht fehlgeschlagen). Statische Prüfung auf `develop`: Kistentreffer übergibt Plattformoberkante, `ExplosionAddAboveY` aktiviert `LimitDamageBelowY`, `ExplosionDamageAllowed` wird für Sonec und andere Ziele bei Radiusprüfung verwendet; mitbewegte Plattformgrenze wird aktualisiert. Einschränkung: Sonec-Positionspunkt statt kompletter Kollisionsfläche. Kein Fix ohne beobachteten Fehler; temporäre Bomber-Testauftritte 8–15 s vorerst erhalten.

- [ ] **Balancing-Merkpunkt – Space Jet:** Aktiviert sich weiterhin beim Betreten des hohen Luftraums. Für weitere Tests bewusst unverändert lassen; später Aktivierungsverhalten balancieren.

- [ ] **Menü-Hilfetexte später erweitern.** Nur vormerken; gehört nicht in den aktuellen N1-/Cloud-Arbeitsschritt.

**N2 abgenommen:** Entwickler bestätigt AGK-Compile und alle neun Tests 9/9: Energie/xN, Gesundheit, MG-/Granatenmunition, Regeneration, Feuerrate/Burst, keine falschen Max-Meldungen, Animationen und Gameplay. Nachrichtentexte zentralisiert; Balancing/Fallbacks bleiben separat.

**Nachrichten-Polishing abgeschlossen:** N1b 9/9, N1c 6/6 und N1d 5/5 lokal vom Entwickler bestanden; Einflug rechts, Ausflug links, 24-Pixel-Abstand, ruhiger Duplikatrahmen. AGK nicht vom Assistenten ausgeführt.

**Abgenommen:** T4 vom Entwickler lokal 5/5, F1-Fix `09e1063` lokal 6/6 bestanden; N1a vollständig bestätigt: ursprünglich 7/10, gezielter Resttest 5/5 bestanden. Temporäre Testtasten 8–0 entfernt; FPS bleibt, Drohnen-Debug-Zusatz entfernt. Aufräumänderung lokal bestätigt (Spiel normal, Debug-Anzeige weg, Tasten 8–0 inaktiv). AGK wurde nicht vom Assistenten ausgeführt.

## Pflege

- Erledigtes nach dokumentierter Abnahme entfernen. Weitere Releasearbeit in Roadmap, unverbindliche Ideen in BACKLOG.
- Wiedereinstieg: [HANDOFF.md](HANDOFF.md).
