# Hammerspoon Reload Instructions

Nach dem darwin-rebuild:

1. Klicke auf das Hammerspoon Icon in der Menu Bar
2. Wähle "Console"
3. Drücke Cmd+R oder führe aus: `hs.reload()`
4. Prüfe die Console auf: "Slack DM Watcher gestartet"
5. Prüfe auf Fehler (rote Meldungen)

## Erwartetes Console Output:

```
Slack DM Watcher gestartet
```

Wenn Fehler auftreten, prüfe die Lua-Syntax in home.nix.

## Test-Hotkeys

Nach dem Reload kannst du die Funktionalität testen:

- **Hyper + B**: Teste LED ROT (sollte blink(1) rot einschalten)
- **Hyper + X**: LED AUS (sollte blink(1) ausschalten)
- **Hyper + S**: LED Status anzeigen (zeigt ob LED ON oder OFF ist)

(Hyper = Cmd + Alt + Ctrl + Shift)

## Debugging

Falls die LED nicht funktioniert:

1. Prüfe ob blink1-server läuft: `curl http://localhost:8934/blink1`
2. Prüfe Hammerspoon Console auf Fehler
3. Sende eine Test-Slack-DM an dich selbst
4. Prüfe Console auf: "📬 Slack Notification: '<Name>'"
