# Design: Blink(1) LED für Slack Direct Messages

**Datum:** 2026-02-13
**Status:** Approved
**Ziel:** Rote blink(1) LED leuchtet nur bei 1-zu-1 Direct Messages in Slack

## Anforderungen

1. LED leuchtet rot bei Direct Messages (1-zu-1)
2. LED leuchtet NICHT bei @mentions in Channels
3. LED bleibt rot bei weiteren DMs (keine Änderung)
4. LED geht aus, sobald Slack aktiviert wird
5. Keine Slack API, keine Änderung der Slack Badge-Einstellungen
6. Implementierung mit Hammerspoon

## Architektur

### Komponenten

- **Notification Watcher** - Überwacht macOS Distributed Notifications
- **DM Detector** - Analysiert Notification-Format um DMs zu erkennen
- **LED Controller** - Steuert blink(1) via HTTP API (Port 8934)
- **App Watcher** - Erkennt wenn Slack aktiviert wird
- **State Manager** - Speichert LED-Status (boolean: isLedOn)

### Datenfluss

```
macOS Notification → DM Detector → LED Controller → blink(1)
                          ↓
Slack aktiviert → App Watcher → LED aus
```

### Integration

- Ersetzt bestehende Badge-Count-Lösung in home.nix (Zeilen 807-900)
- Nutzt gleiche Blink1Control2 HTTP API
- Behält bestehende Test-Hotkeys (B, X, S)

## Notification-Erkennung

### Slack Notification-Formate

Slack sendet Notifications über `com.tinyspeck.slackmacgap.notification`.

**Direct Message:**
- Titel: Personenname (z.B. "Max Mustermann")
- Kein "#" Zeichen im Titel
- Kein "in #" im Titel oder Body

**Channel Message / @mention:**
- Titel enthält: "#channel-name" oder "in #channel-name"
- Oder: "@mention in #channel"

### Erkennungs-Logik

```lua
function isDM(title, body)
  if not title then return false end

  -- Ausschließen: Channel-Notifications
  if title:match("#") then return false end
  if title:match("in #") then return false end
  if body and body:match("in #") then return false end

  -- Ausschließen: System-Notifications
  if title:match("Slack") then return false end
  if title:match("Reminder") then return false end

  -- Alles andere = vermutlich DM
  return true
end
```

### Edge Cases

- Gruppenchats werden als DMs behandelt (haben keine "#" im Titel)
- Wenn jemand "#" in seinem Namen hat → wird fälschlich als Channel erkannt (sehr selten)

## LED-Steuerung

### LED einschalten

- Wenn DM-Notification erkannt wird
- Nur wenn LED aktuell aus ist
- Unabhängig davon, ob Slack läuft oder fokussiert ist

### LED bleibt an

- Bei weiteren DMs keine Änderung
- LED bleibt rot bis Slack aktiviert wird

### LED ausschalten

- Sobald Slack in den Vordergrund kommt (aktiviert wird)
- Oder manuell via Hotkey (Cmd+Alt+Ctrl+Shift+X)

### API-Calls

```lua
-- LED rot
http://localhost:8934/blink1/fadeToRGB?rgb=%23FF0000&time=0.1

-- LED aus
http://localhost:8934/blink1/off
```

### Wichtige Änderungen

- Keine Badge Count Überwachung mehr
- Kein Polling-Timer (nur event-basiert)
- Einfacher State: `isLedOn` (boolean)

## Error Handling

### Blink1Control2 nicht erreichbar

- HTTP-Fehler werden ignoriert (keine User-Störung)
- Console-Log für Debugging
- LED-State wird trotzdem getrackt

### Slack läuft nicht

- Notification Watcher läuft weiter
- DMs werden erkannt und LED schaltet ein
- App Watcher wartet auf Slack-Start

### Notification-Format ändert sich

- Fallback: Bei Unsicherheit keine LED (false negatives besser als false positives)
- Console-Logging aller Slack-Notifications für Debugging

### Mehrere Workspaces

- Alle Slack-Notifications werden behandelt
- Keine Unterscheidung zwischen Workspaces

### Do Not Disturb Mode

- Wenn macOS DND aktiv ist, kommen keine Notifications
- LED schaltet nicht ein (erwartetes Verhalten)

## Testing

### Manuelle Tests

**Test 1: DM-Erkennung**
- Dir selbst eine DM in Slack senden
- Erwartung: LED schaltet rot ein
- Console: "🔴 DM erkannt von: [Name]"

**Test 2: Channel-Nachricht ignorieren**
- @mention in einem Channel bekommen
- Erwartung: LED bleibt aus
- Console: "⚪ Channel-Nachricht ignoriert"

**Test 3: LED ausschalten**
- LED ist rot (nach DM)
- Slack aktivieren
- Erwartung: LED geht sofort aus

**Test 4: Mehrere DMs**
- Mehrere DMs hintereinander empfangen
- Erwartung: LED bleibt rot, keine Änderung

### Debugging-Tools

- Hotkey `Cmd+Alt+Ctrl+Shift+S` - zeigt LED-Status
- Hotkey `Cmd+Alt+Ctrl+Shift+B` - LED manuell einschalten
- Hotkey `Cmd+Alt+Ctrl+Shift+X` - LED manuell ausschalten
- Hammerspoon Console - zeigt alle erkannten Notifications

### Test-Script (optional)

- Separates Lua-Script zum Monitoring aller Notifications für 60 Sekunden
- Hilft bei Debugging von Notification-Formaten

## Implementierung

### Dateien

- `home.nix` - Hauptkonfiguration (Zeilen 807-900 ersetzen)
- Optional: `claude/test-dm-notifications.lua` - Test-Script

### Abhängigkeiten

- Hammerspoon (bereits installiert via homebrew)
- Blink1Control2 (bereits installiert, läuft)
- Blink1Control2 HTTP Server aktiviert (Port 8934)

## Trade-offs

### Vorteile

- Einfache, event-basierte Architektur
- Keine externe API nötig
- Sofortige Reaktion (kein Polling)
- Nutzt bestehende Infrastruktur

### Nachteile

- Abhängig von Slack Notification-Format
- Gruppenchats werden als DMs behandelt
- Funktioniert nicht im Do Not Disturb Mode
- Bei Notification-Format-Änderungen muss Logik angepasst werden

## Nächste Schritte

1. Implementation Plan schreiben
2. Bestehenden Code in home.nix ersetzen
3. Testen mit echten DMs
4. Optional: Test-Script erstellen
