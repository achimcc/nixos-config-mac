-- VERBESSERTER SLACK WATCHER
-- Reagiert nur auf ECHTE Slack-Nachrichten (nicht alle Notifications)

print("\n=== SLACK MESSAGE WATCHER (Verbessert) ===\n")

local isLedOn = false

-- Hilfsfunktion: LED einschalten
local function turnLedOn()
  if not isLedOn then
    print("🔴 Neue Slack-Nachricht - LED EIN")
    hs.http.asyncGet("http://localhost:8934/blink1/fadeToRGB?rgb=%23FF0000&time=0.1", nil, function() end)
    isLedOn = true
  end
end

-- Hilfsfunktion: LED ausschalten
local function turnLedOff()
  if isLedOn then
    print("⚫ Slack gelesen - LED AUS")
    hs.http.asyncGet("http://localhost:8934/blink1/off", nil, function() end)
    isLedOn = false
  end
end

-- METHODE 1: Distributed Notifications mit Slack-Filter
-- Diese werden nur bei echten Nachrichten gefeuert
local notificationWatcher = hs.distributednotifications.new(function(name, object, userInfo)
  if not name then return end

  local nameStr = tostring(name):lower()

  -- Debug: Zeige alle Slack-bezogenen Notifications
  if nameStr:find("slack") then
    print("Slack Notification:", name)
    if userInfo then
      print("  UserInfo:", hs.inspect(userInfo))
    end
  end

  -- Diese Notifications deuten auf neue Nachrichten hin:
  if nameStr:find("nsworkspacedidactivateapplicationnotification") or
     nameStr:find("nsapplicationdidchangestatusbarframenotification") or
     nameStr:find("com.tinyspeck.slackmacgap") then

    -- Prüfe ob Slack im Vordergrund ist
    local slack = hs.application.find("com.tinyspeck.slackmacgap")
    if slack and not slack:isFrontmost() then
      -- Nur LED einschalten wenn Slack NICHT fokussiert ist
      turnLedOn()
    end
  end
end)
notificationWatcher:start()
print("✓ Notification Watcher gestartet")

-- METHODE 2: Überwache Dock Badge (nur Nachrichten, nicht alle Notifications)
-- Slack zeigt im Dock Badge nur ungelesene NACHRICHTEN
local lastDockBadge = 0
local dockBadgeWatcher = hs.timer.doEvery(3, function()
  local slack = hs.application.find("com.tinyspeck.slackmacgap")
  if not slack then return end

  -- Prüfe ob Slack im Vordergrund ist
  local isFocused = slack:isFrontmost()

  -- Hole Dock Badge (zeigt nur echte Nachrichten)
  local output, status = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
  if status and output then
    -- StatusLabel = Dock Badge (nur bei echten Nachrichten)
    local badge = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
    local currentBadge = tonumber(badge) or 0

    -- Debug nur bei Änderungen
    if currentBadge ~= lastDockBadge then
      print(string.format("Dock Badge: %d -> %d (Focused: %s)",
        lastDockBadge, currentBadge, isFocused and "yes" or "no"))
    end

    -- Nur LED-Änderungen wenn Slack NICHT im Vordergrund
    if not isFocused then
      -- Neue Nachrichten: Badge steigt
      if currentBadge > 0 and currentBadge > lastDockBadge then
        turnLedOn()
      -- Alle gelesen: Badge = 0
      elseif currentBadge == 0 and lastDockBadge > 0 then
        turnLedOff()
      end
    end

    lastDockBadge = currentBadge
  end
end)
print("✓ Dock Badge Watcher gestartet (alle 3 Sekunden)")

-- METHODE 3: App Focus Watcher - LED aus wenn Slack aktiviert
local appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
  if appName == "Slack" and eventType == hs.application.watcher.activated then
    print("Slack aktiviert - LED AUS")
    turnLedOff()

    -- Badge Count nach 2 Sekunden aktualisieren
    hs.timer.doAfter(2, function()
      local output = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
      local badge = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
      lastDockBadge = tonumber(badge) or 0
      print("Badge Count aktualisiert:", lastDockBadge)
    end)
  end
end)
appWatcher:start()
print("✓ App Focus Watcher gestartet")

-- Test-Hotkeys
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "B", function()
  hs.alert.show("Test: blink(1) ROT")
  turnLedOn()
end)

hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "X", function()
  hs.alert.show("blink(1) AUS")
  turnLedOff()
end)

hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "S", function()
  local output = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
  local badge = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
  hs.alert.show(string.format("Dock Badge: %s, LED: %s",
    badge or "0", isLedOn and "ON" or "OFF"))
end)

print("\n✓ Watcher aktiv!")
print("  Hyper+B: Test LED (rot)")
print("  Hyper+X: LED aus")
print("  Hyper+S: Status anzeigen")
print("\n💡 WICHTIG: Der Dock Badge zeigt nur ECHTE Nachrichten!")
print("   Teste mit einer @mention oder Direct Message\n")

-- Cleanup-Funktion
_G.stopSlackWatcher = function()
  if notificationWatcher then notificationWatcher:stop() end
  if dockBadgeWatcher then dockBadgeWatcher:stop() end
  if appWatcher then appWatcher:stop() end
  turnLedOff()
  print("Watcher gestoppt")
end

-- Speichere global für Zugriff
_G.slackLedOn = turnLedOn
_G.slackLedOff = turnLedOff
_G.isSlackLedOn = function() return isLedOn end
