# Blink1Control2 Setup

## Installation über nix-darwin

Blink1Control2 wird jetzt deklarativ über nix-darwin installiert und startet automatisch beim Login.

### Konfiguration

- **Installation**: `modules/packages/gui-apps.nix`
- **Auto-Start**: `modules/system/launch-agents.nix`
- **Hammerspoon Integration**: `home.nix` (Zeilen 807-900)

### Anwenden

```bash
cd /Users/achimschneider/nix-darwin-config
sudo darwin-rebuild switch --flake .#achims-mac
```

### Nach der Installation

1. **Starte Blink1Control2**: Wird automatisch gestartet, oder manuell öffnen
2. **Aktiviere HTTP Server**:
   - Öffne Blink1Control2
   - Einstellungen → Enable HTTP Server
   - Port: 8934 (Standard)
3. **Test**: Hammerspoon Hotkey `Cmd+Alt+Ctrl+Shift+B` sollte Lampe rot machen

## Funktionsweise

Die Hammerspoon-Konfiguration:
- Überwacht macOS Distributed Notifications für Slack
- Erkennt Direct Messages durch Analyse des Notification-Formats
- Schaltet LED rot bei DM (nur wenn LED aus ist)
- Schaltet LED aus, wenn Slack aktiviert wird
- Channel-Messages und @mentions werden ignoriert

## Troubleshooting

### LED leuchtet nicht

1. Prüfe ob Blink1Control2 läuft: `ps aux | grep Blink1Control2`
2. Prüfe HTTP Server: `curl http://localhost:8934/blink1/fadeToRGB?rgb=%23FF0000&time=0.1`
3. Öffne Hammerspoon Console und prüfe auf Fehler
4. Test mit Hotkey: `Cmd+Alt+Ctrl+Shift+B`

### DM wird nicht erkannt

1. Öffne Hammerspoon Console
2. Führe aus: `hs.reload()`
3. Schaue nach: "Slack DM Watcher gestartet"
4. Sende dir Test-DM und prüfe Console Output
5. Status-Check: `Cmd+Alt+Ctrl+Shift+S`
6. Debug-Script verwenden: `claude/debug-notifications.lua`

### Slack-Einstellungen

Stelle sicher, dass Slack Notifications aktiviert sind:
- **Slack → Preferences → Notifications**
- macOS System Notifications müssen für Slack erlaubt sein
