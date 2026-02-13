-- Slack Notification Watcher - Test Version
-- Kopiere diesen Code in ~/.hammerspoon/init.lua zum Testen
-- oder führe in der Hammerspoon Console aus: dofile(os.getenv("HOME") .. "/nix-darwin-config/claude/hammerspoon-slack-test.lua")

print("=== Slack Notification Watcher - Test Mode ===")

-- Variante 1: Monitor alle Distributed Notifications (Debug)
local debugWatcher = hs.distributednotifications.new(function(name, object, userInfo)
  print("=== Distributed Notification ===")
  print("Name:", name)
  print("Object:", hs.inspect(object))
  if userInfo then
    print("UserInfo:", hs.inspect(userInfo))
  end
  print("================================")
end)
debugWatcher:start()
print("Debug watcher started - alle Notifications werden geloggt")

-- Variante 2: Überwache Slack Badge Count
local lastBadgeCount = 0
local slackBadgeTimer = hs.timer.doEvery(2, function()
  local slack = hs.application.find("com.tinyspeck.slackmacgap")
  if slack then
    local badgeCount = slack:getBadgeCount() or 0
    if badgeCount > lastBadgeCount then
      print("Neue Slack-Nachricht erkannt! Badge Count:", badgeCount)
      hs.http.get("http://localhost:8934/blink1/fadeToRGB?rgb=%23FF0000&time=0.1", nil)
    end
    lastBadgeCount = badgeCount
  end
end)
print("Badge count watcher gestartet - prüft alle 2 Sekunden")

-- Variante 3: Monitor Slack-Fenster-Titel
local lastSlackTitle = ""
local slackTitleTimer = hs.timer.doEvery(1, function()
  local slack = hs.application.find("com.tinyspeck.slackmacgap")
  if slack then
    local window = slack:mainWindow()
    if window then
      local title = window:title() or ""
      -- Slack zeigt ungelesene Nachrichten im Titel mit Zahlen
      if title:match("%((%d+)%)") and title ~= lastSlackTitle then
        print("Slack Titel geändert:", title)
        local unreadCount = tonumber(title:match("%((%d+)%)"))
        if unreadCount and unreadCount > 0 then
          print("Ungelesene Nachrichten erkannt:", unreadCount)
          hs.http.get("http://localhost:8934/blink1/fadeToRGB?rgb=%23FF0000&time=0.1", nil)
        end
        lastSlackTitle = title
      end
    end
  end
end)
print("Title watcher gestartet - prüft alle 1 Sekunde")

-- Cleanup-Funktion
local function stopWatchers()
  if debugWatcher then debugWatcher:stop() end
  if slackBadgeTimer then slackBadgeTimer:stop() end
  if slackTitleTimer then slackTitleTimer:stop() end
  print("Alle Watcher gestoppt")
end

print("=== Test läuft ===")
print("Sende eine Slack-Nachricht an dich selbst, um zu testen")
print("Drücke Hyper+B zum Test der blink(1)")
print("Drücke Hyper+X zum Ausschalten der blink(1)")
print("Zum Stoppen: stopWatchers()")

return {
  stop = stopWatchers
}
