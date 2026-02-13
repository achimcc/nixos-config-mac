# Manual Testing Guide - Slack DM Blink(1) Integration

## Vorbereitung

### 1. Konfiguration anwenden
```bash
darwin-rebuild switch --flake ~/.config/nix-darwin
```

### 2. Hammerspoon neu laden
- Klicke auf das Hammerspoon-Icon in der Menüleiste
- Wähle "Reload Config"
- Prüfe die Console auf Fehlermeldungen

### 3. Blink(1) Gerät prüfen
```bash
blink1-tool --list
```
Erwartetes Ergebnis: Mindestens ein Blink(1) Gerät wird gefunden.

## Test-Szenarien

### Test 1: LED Manual Control

**Ziel:** Überprüfen, dass die manuellen Hotkeys funktionieren.

**Schritte:**
1. Drücke `Ctrl + Cmd + B` (LED einschalten)
   - **Erwartetes Ergebnis:** LED leuchtet rot
   - **Console Output:** "Blink(1): Turning LED on"

2. Drücke `Ctrl + Cmd + X` (LED ausschalten)
   - **Erwartetes Ergebnis:** LED geht aus
   - **Console Output:** "Blink(1): Turning LED off"

3. Drücke `Ctrl + Cmd + S` (Status anzeigen)
   - **Erwartetes Ergebnis:** Notification mit aktuellem LED-Status
   - **Console Output:** "Blink(1): LED is on/off"

**Troubleshooting:**
- Wenn nichts passiert: Prüfe ob Hammerspoon läuft
- Wenn LED nicht reagiert: Prüfe `blink1-tool --list`
- Wenn andere Hotkeys gefeuert werden: Prüfe Hotkey-Konflikte in System Settings

### Test 2: DM Detection

**Ziel:** Überprüfen, dass eingehende Slack DMs die LED aktivieren.

**Schritte:**
1. Öffne Hammerspoon Console (Hammerspoon Icon → Console)
2. Stelle sicher, dass Slack im Hintergrund ist (nicht aktive App)
3. Lasse dir eine DM von einem Kollegen schicken
4. Beobachte die LED und Console

**Erwartetes Ergebnis:**
- LED leuchtet rot
- Console Output:
  ```
  Slack notification detected (DM/mention): [Nachrichtentext]
  Blink(1): Turning LED on
  ```

**Troubleshooting:**
- Wenn keine Console-Ausgabe: Accessibility-Rechte für Hammerspoon prüfen
- Wenn LED nicht leuchtet: Manuellen Test wiederholen (Test 1)
- Wenn DM nicht erkannt wird: Prüfe ob notification-center working richtig läuft

### Test 3: Channel Filter

**Ziel:** Überprüfen, dass normale Channel-Nachrichten NICHT die LED aktivieren.

**Schritte:**
1. Öffne Hammerspoon Console
2. Stelle sicher, dass Slack im Hintergrund ist
3. Lasse in einem Channel eine @mention von dir posten
4. Beobachte die LED und Console

**Erwartetes Ergebnis:**
- LED bleibt aus (oder geht nicht an)
- Console Output:
  ```
  Slack notification detected (DM/mention): [Nachrichtentext]
  Notification is from a channel - ignoring
  ```

**Alternative Test:**
- Normale Channel-Nachricht (ohne @mention) sollte gar keine Console-Ausgabe erzeugen

**Troubleshooting:**
- Wenn LED angeht: Filter funktioniert nicht → Prüfe notification text format
- Wenn keine Console-Ausgabe: @mention wurde nicht als "DM/mention" erkannt

### Test 4: LED Off bei Slack Activation

**Ziel:** Überprüfen, dass die LED automatisch ausgeht, wenn Slack aktiviert wird.

**Schritte:**
1. Drücke `Ctrl + Cmd + B` um LED manuell einzuschalten
2. LED sollte rot leuchten
3. Klicke auf das Slack-Fenster oder drücke `Cmd + Tab` zu Slack
4. Beobachte die LED

**Erwartetes Ergebnis:**
- LED geht sofort aus
- Console Output:
  ```
  Slack became active - turning off LED
  Blink(1): Turning LED off
  ```

**Troubleshooting:**
- Wenn LED nicht ausgeht: App-Watcher funktioniert nicht
- Console-Ausgabe prüfen: Wird "Slack" als App-Name erkannt?
- Alternative: Prüfe ob andere Apps auch erkannt werden

## Post-Test Checks

### Console Log analysieren
1. Öffne Hammerspoon Console
2. Prüfe auf Error-Meldungen
3. Dokumentiere alle unerwarteten Ausgaben

### System Resources
```bash
# Prüfe ob notification-center läuft
ps aux | grep notification-center

# Prüfe Hammerspoon memory usage
ps aux | grep Hammerspoon
```

### Blink(1) Device Status
```bash
# Prüfe LED-Status direkt
blink1-tool --glimmer 3
```

## Bekannte Probleme

### Accessibility Permissions
Wenn Slack-Notifications nicht erkannt werden:
1. System Settings → Privacy & Security → Accessibility
2. Hammerspoon muss aktiviert sein
3. Nach Änderung: Hammerspoon neu starten

### Notification Format
Slack könnte verschiedene Notification-Formate verwenden:
- "New message from X"
- "X sent you a message"
- "You have a new message"

Prüfe Console-Ausgabe für exakte Texte.

### LaunchAgent Status
```bash
launchctl list | grep notification-center
```
Sollte zeigen: `com.achimschneider.notification-center`

## Erfolgs-Kriterien

Alle Tests gelten als bestanden wenn:
- [ ] Alle 4 Test-Szenarien funktionieren wie erwartet
- [ ] Keine Error-Meldungen in Hammerspoon Console
- [ ] LED reagiert zuverlässig auf DMs
- [ ] LED ignoriert Channel-Nachrichten
- [ ] LED geht aus wenn Slack aktiviert wird
- [ ] Manuelle Hotkeys funktionieren

## Nächste Schritte

Nach erfolgreichem Test:
1. Testergebnisse in `test-results-YYYYMMDD.md` dokumentieren
2. Bei Problemen: Debug-Informationen sammeln
3. Bei Erfolg: Task 8 (Documentation) starten
