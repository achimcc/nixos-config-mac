-- NOTIFICATION MONITOR
-- Zeigt ALLE Notifications und Badge-Änderungen an
-- So sehen wir, was genau den Badge Count verändert

print("\n" .. string.rep("=", 70))
print("NOTIFICATION MONITOR")
print("Überwacht alle macOS Notifications und Slack Badge Changes")
print(string.rep("=", 70) .. "\n")

-- Badge Count Tracking
local lastBadge = 0

-- Hole initialen Badge Count
local function getBadge()
  local output, status = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
  if status and output then
    local badge = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
    return tonumber(badge) or 0
  end
  return 0
end

lastBadge = getBadge()
print("📊 Initialer Badge Count:", lastBadge)
print("\n🎯 Überwache jetzt 60 Sekunden...\n")
print("BITTE:")
print("  1. Sende dir eine @mention oder DM in Slack")
print("  2. Sende eine normale Nachricht in einem Channel (ohne @mention)")
print("  3. Wir sehen dann, was den Badge Count verändert\n")
print(string.rep("-", 70))

-- 1. Monitor ALLE Distributed Notifications
local allNotifications = {}
local notifWatcher = hs.distributednotifications.new(function(name, object, userInfo)
  if not name then return end

  local nameStr = tostring(name)

  -- Zähle Notifications
  allNotifications[nameStr] = (allNotifications[nameStr] or 0) + 1

  -- Zeige nur relevante Notifications
  local isRelevant = nameStr:lower():find("slack") or
                     nameStr:find("NSWorkspace") or
                     nameStr:find("NSApplication") or
                     nameStr:find("notification") or
                     nameStr:find("badge")

  if isRelevant then
    print("📢 Notification:", nameStr)
    if object then
      print("   Object:", object)
    end
    if userInfo and next(userInfo) then
      print("   UserInfo:", hs.inspect(userInfo):sub(1, 200))
    end
    print()
  end
end)
notifWatcher:start()

-- 2. Monitor Badge Changes (jede Sekunde)
local checkCount = 0
local badgeTimer = hs.timer.doEvery(1, function()
  checkCount = checkCount + 1

  local currentBadge = getBadge()

  -- Nur bei Änderung ausgeben
  if currentBadge ~= lastBadge then
    print(string.rep("=", 70))
    print(string.format("🔔 BADGE CHANGE [%02ds]: %d -> %d", checkCount, lastBadge, currentBadge))

    -- Prüfe Slack Status
    local slack = hs.application.find("com.tinyspeck.slackmacgap")
    if slack then
      local window = slack:mainWindow()
      if window then
        print("   Window Title:", window:title() or "")
      end
      print("   Is Focused:", slack:isFrontmost() and "YES" or "NO")
    end

    -- Zeige was sich geändert hat
    if currentBadge > lastBadge then
      print("   ➡️  Badge GESTIEGEN um", currentBadge - lastBadge)
      print("   💡 Das sollte die LED einschalten!")
    elseif currentBadge < lastBadge then
      print("   ⬅️  Badge GEFALLEN um", lastBadge - currentBadge)
      print("   💡 Das sollte die LED ausschalten!")
    end

    print(string.rep("=", 70) .. "\n")

    lastBadge = currentBadge
  end

  -- Stoppe nach 60 Sekunden
  if checkCount >= 60 then
    badgeTimer:stop()
    notifWatcher:stop()

    print("\n" .. string.rep("=", 70))
    print("MONITORING BEENDET")
    print(string.rep("=", 70))

    print("\n📊 STATISTIK:")
    print(string.format("   Final Badge Count: %d", currentBadge))
    print(string.format("   Anzahl Checks: %d", checkCount))
    print(string.format("   Anzahl verschiedener Notification-Typen: %d", #allNotifications))

    -- Zeige Top 5 häufigste Notifications
    local sorted = {}
    for name, count in pairs(allNotifications) do
      table.insert(sorted, {name = name, count = count})
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)

    print("\n📢 Top Notifications (max 10):")
    for i = 1, math.min(10, #sorted) do
      print(string.format("   %2d. %s (%dx)", i, sorted[i].name, sorted[i].count))
    end

    print("\n💡 ANALYSE:")
    if currentBadge == lastBadge then
      print("   ⚠️  Badge Count hat sich nicht geändert")
      print("   Hast du eine Nachricht gesendet?")
    else
      print("   ✓ Badge Count hat sich geändert")
      print("   Überprüfe oben, WAS die Änderung ausgelöst hat")
    end

    print("\n")
  end
end)

print("⏱️  Monitoring läuft 60 Sekunden...\n")
