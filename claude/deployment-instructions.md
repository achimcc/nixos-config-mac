# Deployment Instructions for Slack DM Blink(1) Integration

## Status: Ready for Deployment

All code changes have been completed in Tasks 1-5. The configuration is ready to be applied.

## Step 1: Apply nix-darwin Configuration

Run the following command to apply the configuration:

```bash
cd /Users/achimschneider/nix-darwin-config
sudo darwin-rebuild switch --flake .#achims-mac
```

**Expected output:**
- Build process will compile the configuration
- Hammerspoon config files will be updated in `~/.hammerspoon/`
- The command should complete without errors

**If errors occur:**
- Check the error message carefully
- Most common issues are Lua syntax errors or missing dependencies
- You can verify Lua syntax by extracting the config: `grep -A 100 "SLACK RED LIGHT" home.nix`

## Step 2: Reload Hammerspoon

After the darwin-rebuild completes successfully:

See detailed instructions in: `claude/reload-instructions.md`

Quick summary:
1. Click Hammerspoon menu bar icon
2. Select "Console"
3. Press Cmd+R to reload
4. Verify console shows: "Slack DM Watcher gestartet"

## Step 3: Test the Integration

### Test 1: Manual LED Control
- **Hyper + B**: Turn LED red (should work immediately)
- **Hyper + X**: Turn LED off
- **Hyper + S**: Check LED status

(Hyper = Cmd + Alt + Ctrl + Shift)

### Test 2: Slack DM Detection
1. Send yourself a DM in Slack (from another device or ask a colleague)
2. Check Hammerspoon Console for:
   ```
   📬 Slack Notification: '<Sender Name>'
   🔴 DM erkannt von: <Sender Name>
   🔴 Neue Slack-Nachricht - LED EIN
   ```
3. Verify LED turns red

### Test 3: LED Auto-Off
1. With LED on (red), activate Slack app
2. Check Hammerspoon Console for: "Slack aktiviert - LED AUS"
3. Verify LED turns off

## Troubleshooting

### LED doesn't turn on/off
- Verify blink1-server is running: `curl http://localhost:8934/blink1`
- Check Hammerspoon Console for HTTP errors

### No notifications detected
- Verify Slack has notification permissions in System Settings
- Check Hammerspoon Console - should show "📬 Slack Notification" for any Slack notification
- Try sending a test message

### Channel messages trigger LED (false positives)
- Check Hammerspoon Console to see what title/body format the notification has
- The `isDM()` function may need adjustment if channel format is unexpected

## What Changed

### Removed:
- Badge count polling (old method)
- `getBadgeCount()` function
- Timer-based polling

### Added:
- `isDM(title, body)` function - Detects DM vs channel messages
- Notification watcher - Monitors all Slack notifications in real-time
- Better logging - Shows all notifications and DM detection results

### Benefits:
- Instant detection (no 5-second delay)
- Lower CPU usage (no polling)
- More reliable (based on actual notifications, not badge count)
- Better debugging (clear console logs)
