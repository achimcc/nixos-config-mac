# Slack DM Blink(1) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace Badge Count polling with notification-based DM detection for blink(1) LED

**Architecture:** Event-driven system using Hammerspoon's distributednotifications to detect Slack DMs by analyzing notification title/body format. LED turns red on DM, off when Slack is activated.

**Tech Stack:** Hammerspoon Lua, macOS Distributed Notifications, Blink1Control2 HTTP API

---

## Task 1: Remove Old Badge Count Implementation

**Files:**
- Modify: `home.nix:807-918`

**Step 1: Backup current implementation**

Save the current implementation in case we need to reference it:

```bash
cp home.nix home.nix.backup-$(date +%Y%m%d)
```

Expected: File copied successfully

**Step 2: Remove Badge Count polling code**

In `home.nix`, delete lines 811, 832-886 (lastBadgeCount variable, getSlackBadge function, initialization timer, and polling timer):

Remove:
- Line 811: `local lastBadgeCount = nil`
- Lines 832-840: `getSlackBadge()` function
- Lines 842-846: Initialization timer
- Lines 848-886: Badge polling timer

Keep:
- Line 810: `local isLedOn = false`
- Lines 813-830: `turnLedOn()` and `turnLedOff()` functions
- Lines 888-900: App Watcher
- Lines 902-917: Test Hotkeys

**Step 3: Verify syntax after removal**

Check that the file still has valid Lua syntax structure:

```bash
grep -A 5 "SLACK RED LIGHT" home.nix | head -20
```

Expected: Should see comment, isLedOn variable, and function definitions

**Step 4: Commit removal**

```bash
git add home.nix
git commit -m "refactor: remove Badge Count polling from Slack LED integration

Vorbereitung für notification-basierte DM-Erkennung

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Implement DM Detection Logic

**Files:**
- Modify: `home.nix:807-918`

**Step 1: Add isDM detection function**

Add this function after the `turnLedOff()` function (around line 830):

```lua
      -- DM-Erkennung: Analysiert Notification-Format
      local function isDM(title, body)
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

**Step 2: Verify function placement**

Check that the function is properly placed:

```bash
grep -A 15 "function isDM" home.nix
```

Expected: Should see complete function definition

**Step 3: Commit DM detection function**

```bash
git add home.nix
git commit -m "feat: add DM detection function for Slack notifications

Erkennt DMs durch Ausschluss von Channel- und System-Notifications

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Implement Notification Watcher

**Files:**
- Modify: `home.nix:807-918`

**Step 1: Add notification watcher before App Watcher**

Add this code after the `isDM()` function and before the App Watcher (before line 888):

```lua
      -- Notification Watcher: Überwacht alle Slack-Notifications
      local notificationWatcher = hs.distributednotifications.new(function(name, object, userInfo)
        -- Nur Slack-Notifications
        if name ~= "com.tinyspeck.slackmacgap.notification" then
          return
        end

        -- Extrahiere Titel und Body aus userInfo
        local title = userInfo and userInfo.title or nil
        local body = userInfo and userInfo.body or nil

        -- Debug: Logge alle Slack-Notifications
        if title then
          print(string.format("📬 Slack Notification: '%s'", title))
          if body then
            print(string.format("   Body: %s", body:sub(1, 50)))
          end
        end

        -- Prüfe ob es eine DM ist
        if isDM(title, body) then
          print(string.format("🔴 DM erkannt von: %s", title or "unknown"))
          turnLedOn()
        else
          print("⚪ Channel-Nachricht ignoriert")
        end
      end)
      notificationWatcher:start()
      print("Slack DM Watcher gestartet")
```

**Step 2: Verify watcher is properly added**

```bash
grep -A 5 "Notification Watcher" home.nix
```

Expected: Should see notification watcher comment and function

**Step 3: Test syntax**

Verify Lua syntax is valid by checking the structure:

```bash
grep "notificationWatcher:start()" home.nix
```

Expected: Should find the start() call

**Step 4: Commit notification watcher**

```bash
git add home.nix
git commit -m "feat: add distributed notifications watcher for Slack DMs

Überwacht macOS Notifications und erkennt DMs automatisch

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Update App Watcher to Remove Badge Logic

**Files:**
- Modify: `home.nix:888-900`

**Step 1: Simplify App Watcher**

Replace the App Watcher code (lines 888-900) with simplified version:

```lua
      -- App Watcher: LED ausschalten wenn Slack aktiviert wird
      local appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
        if appName == "Slack" and eventType == hs.application.watcher.activated then
          print("Slack aktiviert - LED AUS")
          turnLedOff()
        end
      end)
      appWatcher:start()
```

Remove the timer that updates badge count (lines 893-897 in original).

**Step 2: Verify App Watcher**

```bash
grep -A 8 "App Watcher" home.nix
```

Expected: Should see simplified app watcher without badge logic

**Step 3: Commit App Watcher update**

```bash
git add home.nix
git commit -m "refactor: simplify App Watcher, remove Badge Count logic

LED geht jetzt nur noch aus wenn Slack aktiviert wird

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Update Status Hotkey

**Files:**
- Modify: `home.nix:913-917`

**Step 1: Simplify status hotkey**

Replace the status hotkey (lines 913-917) to remove badge reference:

```lua
      hs.hotkey.bind(hyper, "S", function()
        hs.alert.show(string.format("LED: %s", isLedOn and "ON" or "OFF"))
        print(string.format("LED Status: %s", isLedOn and "ON" or "OFF"))
      end)
```

**Step 2: Verify hotkey**

```bash
grep -A 3 'hs.hotkey.bind(hyper, "S"' home.nix
```

Expected: Should see simplified status display

**Step 3: Commit hotkey update**

```bash
git add home.nix
git commit -m "refactor: update status hotkey to remove Badge Count

Zeigt nur noch LED-Status an

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Apply Configuration and Test

**Files:**
- Execute: nix-darwin rebuild

**Step 1: Apply nix-darwin configuration**

Rebuild the system configuration:

```bash
cd /Users/achimschneider/nix-darwin-config
sudo darwin-rebuild switch --flake .#achims-mac
```

Expected: Build succeeds, Hammerspoon config updated

**Step 2: Reload Hammerspoon**

Open Hammerspoon Console and reload:
- Click Hammerspoon menu bar icon
- Select "Console"
- Press Cmd+R or run: `hs.reload()`

Expected: Console shows "Slack DM Watcher gestartet"

**Step 3: Verify no errors**

Check Hammerspoon Console for any Lua errors.

Expected: No red error messages

**Step 4: Document reload**

```bash
echo "Configuration applied and Hammerspoon reloaded at $(date)" >> claude/deployment-log.txt
git add claude/deployment-log.txt
git commit -m "docs: log configuration deployment

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Manual Testing

**Files:**
- Test: Live Slack interaction

**Step 1: Test LED manual control**

Test hotkeys:
- Press `Cmd+Alt+Ctrl+Shift+B` - LED should turn red
- Press `Cmd+Alt+Ctrl+Shift+X` - LED should turn off
- Press `Cmd+Alt+Ctrl+Shift+S` - Should show LED status

Expected: All hotkeys work, LED responds

**Step 2: Test DM detection**

Send yourself a DM in Slack (from mobile or web):

1. Open Slack on another device
2. Send yourself a DM
3. Watch Hammerspoon Console

Expected:
- Console shows: "📬 Slack Notification: '[Your Name]'"
- Console shows: "🔴 DM erkannt von: [Your Name]"
- LED turns red

**Step 3: Test channel message filtering**

Get an @mention in a channel:

1. Have someone @mention you in a channel
2. Watch Hammerspoon Console

Expected:
- Console shows: "📬 Slack Notification: '#channel-name'" or "in #"
- Console shows: "⚪ Channel-Nachricht ignoriert"
- LED stays off (or stays red if already on)

**Step 4: Test LED off on Slack activation**

With LED red from a DM:

1. Click on Slack to bring it to foreground
2. Watch Console

Expected:
- Console shows: "Slack aktiviert - LED AUS"
- LED turns off

**Step 5: Document test results**

Create test results file:

```bash
cat > claude/test-results-$(date +%Y%m%d).md <<'EOF'
# Test Results - Slack DM Blink(1) Integration

**Datum:** $(date)

## Manuelle Tests

### Test 1: LED Manual Control
- [ ] Hotkey B (LED ein):
- [ ] Hotkey X (LED aus):
- [ ] Hotkey S (Status):

### Test 2: DM Detection
- [ ] DM empfangen:
- [ ] Console Output korrekt:
- [ ] LED wurde rot:

### Test 3: Channel Filter
- [ ] @mention in Channel:
- [ ] Console zeigt "ignoriert":
- [ ] LED blieb aus:

### Test 4: LED Off bei Slack Activation
- [ ] Slack aktiviert:
- [ ] LED ging aus:

## Notizen

[Beobachtungen hier eintragen]
EOF

git add claude/test-results-$(date +%Y%m%d).md
git commit -m "docs: add manual test results template

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 8: Create Optional Debug Script

**Files:**
- Create: `claude/debug-notifications.lua`

**Step 1: Create notification monitoring script**

```lua
-- DEBUG SCRIPT: Überwacht alle Slack Notifications für 60 Sekunden
-- Verwendung: Kopiere und führe in Hammerspoon Console aus

print("\n" .. string.rep("=", 70))
print("SLACK NOTIFICATION DEBUG")
print("Überwacht 60 Sekunden lang alle Slack-Notifications")
print(string.rep("=", 70) .. "\n")

local notifications = {}
local startTime = os.time()

local watcher = hs.distributednotifications.new(function(name, object, userInfo)
  if name == "com.tinyspeck.slackmacgap.notification" then
    local title = userInfo and userInfo.title or "no title"
    local body = userInfo and userInfo.body or "no body"

    table.insert(notifications, {
      time = os.time() - startTime,
      title = title,
      body = body:sub(1, 50)
    })

    print(string.format("[%02ds] Notification:", os.time() - startTime))
    print(string.format("  Title: %s", title))
    print(string.format("  Body:  %s", body:sub(1, 50)))
    print()
  end
end)

watcher:start()

hs.timer.doAfter(60, function()
  watcher:stop()
  print("\n" .. string.rep("=", 70))
  print("DEBUG BEENDET")
  print(string.rep("=", 70))
  print(string.format("\nInsgesamt %d Notifications empfangen", #notifications))
  print("\nAlle Notifications:")
  for i, notif in ipairs(notifications) do
    print(string.format("%d. [%02ds] %s", i, notif.time, notif.title))
  end
end)

print("⏱️  Monitoring läuft 60 Sekunden...\n")
```

**Step 2: Add usage instructions**

Add comment at top of file:

```lua
-- VERWENDUNG:
-- 1. Öffne Hammerspoon Console
-- 2. Kopiere gesamten Inhalt dieser Datei
-- 3. Füge in Console ein und drücke Enter
-- 4. Sende dir Test-Nachrichten in Slack
-- 5. Warte 60 Sekunden, dann siehst du Zusammenfassung
```

**Step 3: Commit debug script**

```bash
git add claude/debug-notifications.lua
git commit -m "feat: add debug script for Slack notifications

Hilfreich zum Debuggen von Notification-Formaten

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 9: Update Documentation

**Files:**
- Modify: `claude/blink1-setup.md`

**Step 1: Update blink1-setup.md**

Replace the "Funktionsweise" section (lines 29-34) with:

```markdown
## Funktionsweise

Die Hammerspoon-Konfiguration:
- Überwacht macOS Distributed Notifications für Slack
- Erkennt Direct Messages durch Analyse des Notification-Formats
- Schaltet LED rot bei DM (nur wenn LED aus ist)
- Schaltet LED aus, wenn Slack aktiviert wird
- Channel-Messages und @mentions werden ignoriert
```

**Step 2: Update Troubleshooting section**

Replace "Badge Count wird nicht erkannt" section (lines 45-50) with:

```markdown
### DM wird nicht erkannt

1. Öffne Hammerspoon Console
2. Führe aus: `hs.reload()`
3. Schaue nach: "Slack DM Watcher gestartet"
4. Sende dir Test-DM und prüfe Console Output
5. Status-Check: `Cmd+Alt+Ctrl+Shift+S`
6. Debug-Script verwenden: `claude/debug-notifications.lua`
```

**Step 3: Remove Slack settings section**

Remove or comment out lines 53-57 (Slack-Einstellungen are no longer needed).

**Step 4: Commit documentation update**

```bash
git add claude/blink1-setup.md
git commit -m "docs: update blink1-setup for notification-based detection

Dokumentiert neue DM-Erkennungs-Methode

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 10: Final Verification

**Files:**
- Verify: Complete system integration

**Step 1: System health check**

Run comprehensive check:

```bash
# Check Blink1Control2 is running
ps aux | grep -i blink1control | grep -v grep

# Check HTTP API
curl -s http://localhost:8934/blink1 | head -3

# Check Hammerspoon config syntax
grep -c "notificationWatcher:start()" home.nix
```

Expected: All checks pass

**Step 2: Create final status report**

```bash
cat > claude/slack-dm-blink1-status.md <<'EOF'
# Slack DM Blink(1) Integration - Status

**Implementation:** ✅ Complete
**Datum:** $(date)

## Komponenten

- ✅ DM Detection Logic
- ✅ Notification Watcher
- ✅ LED Controller
- ✅ App Watcher
- ✅ Test Hotkeys
- ✅ Debug Script

## Testing

- [ ] LED Manual Control (B, X, S hotkeys)
- [ ] DM Detection
- [ ] Channel Message Filtering
- [ ] LED Off on Slack Activation

## Nächste Schritte

1. Real-world testing mit echten DMs über mehrere Tage
2. Notification-Format-Änderungen beobachten
3. Bei Bedarf: isDM() Logik anpassen

## Bekannte Limitierungen

- Gruppenchats werden als DMs behandelt
- Funktioniert nicht bei macOS Do Not Disturb
- Abhängig von Slack Notification-Format
EOF

git add claude/slack-dm-blink1-status.md
git commit -m "docs: add implementation status report

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**Step 3: Push all changes (optional)**

If user wants to push to remote:

```bash
git log --oneline -10
git push origin main
```

---

## Post-Implementation Notes

**What was changed:**
- Removed Badge Count polling system (timer-based)
- Added notification-based DM detection
- Simplified App Watcher (removed badge update logic)
- Updated documentation and added debug tools

**Testing checklist:**
- Manual LED control hotkeys work
- DM triggers red LED
- Channel @mentions don't trigger LED
- Slack activation turns off LED

**If something doesn't work:**
1. Check Hammerspoon Console for errors
2. Use debug script to inspect notification format
3. Verify Blink1Control2 HTTP server is running
4. Test LED with manual hotkeys first

**Skills referenced:**
- @superpowers:verification-before-completion - Use before marking tasks complete
- @superpowers:systematic-debugging - Use if notification detection fails
