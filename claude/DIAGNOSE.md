# Slack blink(1) Integration - Diagnose

## Problem
Die blink(1) LED leuchtet nicht rot, wenn eine Slack DM eingeht.

## Aktueller Stand (2026-02-13 16:44)

### ✅ Was funktioniert
1. Hammerspoon läuft (PID 51994)
2. Blink1Control2 läuft mit HTTP-Server (Port 8934)
3. Slack läuft (com.tinyspeck.slackmacgap)
4. Aktuelle Badge Count: 4 ungelesene Nachrichten
5. Test-Hotkeys funktionieren (Hyper+B/X/S)

### ❓ Was wir herausfinden müssen

**HYPOTHESE 1: Notifications kommen nicht an**
- Die aktuelle Konfiguration wartet auf: `com.tinyspeck.slackmacgap.notification`
- Möglicherweise sendet Slack diesen Notification-Namen nicht (mehr)

**HYPOTHESE 2: DM-Erkennung schlägt fehl**
- Die `isDM()` Funktion erkennt DMs nicht korrekt
- Channel-Filter zu aggressiv

**HYPOTHESE 3: Timing-Problem**
- Notification kommt vor Badge-Änderung
- Badge-Watcher fehlt (im Gegensatz zu fixed-slack-watcher.lua)

## Nächste Schritte

### Schritt 1: Test ob Notifications ankommen

In Hammerspoon Console ausführen:
```lua
dofile(os.getenv("HOME") .. "/nix-darwin-config/claude/test-notification-name.lua")
```

Dann: **Sende dir selbst eine Slack DM**

**Erwartetes Ergebnis:**
- Wenn Notifications ankommen: Wir sehen den genauen Namen
- Wenn KEINE Notifications ankommen: Das ist die Root Cause!

### Schritt 2: Badge Count Monitoring

Wenn Notifications nicht funktionieren, nutzen wir Badge Count als Alternative:

```lua
dofile(os.getenv("HOME") .. "/nix-darwin-config/claude/fixed-slack-watcher.lua")
```

Dieser Code nutzt **3 Methoden parallel**:
1. Distributed Notifications (falls sie funktionieren)
2. **Badge Count Polling** (alle 3 Sekunden)
3. App Focus Watcher (LED aus bei Slack-Aktivierung)

### Schritt 3: Vollständiges Monitoring

Für umfassende Diagnose:
```lua
dofile(os.getenv("HOME") .. "/nix-darwin-config/claude/monitor-notifications.lua")
```

Läuft 60 Sekunden und zeigt:
- Alle relevanten Notifications
- Badge Count Änderungen
- Statistiken

## Unterschied zwischen aktueller Config und fixed-slack-watcher

**init.lua (aktuell):**
- Nur Notification-basiert
- Kein Badge Count Polling
- DM-Filter möglicherweise zu streng

**fixed-slack-watcher.lua (besser):**
- Badge Count Polling als Backup
- Redundante Erkennung über 3 Wege
- Weniger anfällig für Notification-Probleme

## Vermutete Root Cause

Basierend auf der Code-Analyse:
1. Die Notification `com.tinyspeck.slackmacgap.notification` kommt möglicherweise nicht an
2. Es fehlt der Badge Count Watcher als Fallback
3. Slack hat möglicherweise die Notification-Namen geändert

## Lösung

Sobald wir die Root Cause identifiziert haben:
1. Entweder: Badge Count Polling hinzufügen (aus fixed-slack-watcher.lua)
2. Oder: Korrekten Notification-Namen verwenden
3. Oder: Beide Methoden kombinieren (robusteste Lösung)
