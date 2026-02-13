-- LIVE TEST: Simuliert eine neue Slack-Nachricht
-- Führe dies aus, dann sende dir selbst eine Slack-Nachricht

print("\n" .. string.rep("=", 70))
print("LIVE TEST - Überwache Slack Badge Changes")
print(string.rep("=", 70))

-- Hilfsfunktion: Badge Count auslesen
local function getSlackBadge()
  local output, status = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
  if status and output then
    local badge = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
    return tonumber(badge) or 0
  end
  return 0
end

-- Hilfsfunktion: Fenster-Titel auslesen
local function getUnreadFromTitle()
  local slack = hs.application.find("com.tinyspeck.slackmacgap")
  if slack then
    local window = slack:mainWindow()
    if window then
      local title = window:title() or ""
      local count = title:match("%((%d+)%)") or title:match("•%s*(%d+)")
      return tonumber(count) or 0
    end
  end
  return 0
end

-- Aktueller Stand
local initialBadge = getSlackBadge()
local initialTitle = getUnreadFromTitle()
print("\nSTART-WERTE:")
print("  Badge Count (lsappinfo):", initialBadge)
print("  Title Count (Fenster):", initialTitle)

-- Prüfe ob Slack im Vordergrund ist
local slack = hs.application.find("com.tinyspeck.slackmacgap")
local slackFocused = slack and slack:isFrontmost()
print("  Slack im Vordergrund:", slackFocused and "JA" or "NEIN")

print("\n⏱️  Überwache jetzt 30 Sekunden lang...")
print("📱 JETZT: Sende dir selbst eine Slack-Nachricht!\n")

local testCount = 0
local lastBadge = initialBadge
local lastTitle = initialTitle

local testTimer = hs.timer.doEvery(1, function()
  testCount = testCount + 1

  -- Aktuelle Werte
  local currentBadge = getSlackBadge()
  local currentTitle = getUnreadFromTitle()
  local slack = hs.application.find("com.tinyspeck.slackmacgap")
  local isFocused = slack and slack:isFrontmost()

  -- Nur ausgeben wenn sich etwas ändert
  if currentBadge ~= lastBadge or currentTitle ~= lastTitle then
    print(string.format("[%02d] ÄNDERUNG ERKANNT!", testCount))
    print(string.format("     Badge: %d -> %d", lastBadge, currentBadge))
    print(string.format("     Title: %d -> %d", lastTitle, currentTitle))
    print(string.format("     Slack focused: %s", isFocused and "JA" or "NEIN"))

    -- Bedingung aus der Config nachbilden
    local maxCount = math.max(currentBadge, currentTitle)
    local lastMaxCount = math.max(lastBadge, lastTitle)

    print(string.format("     Max Count: %d -> %d", lastMaxCount, maxCount))

    if not isFocused then
      if maxCount > lastMaxCount then
        print("     ✓ WÜRDE LED EINSCHALTEN (neue Nachrichten, Slack nicht fokussiert)")
        -- Test: LED einschalten
        hs.http.get("http://localhost:8934/blink1/fadeToRGB?rgb=%23FF0000&time=0.1")
      elseif maxCount == 0 and lastMaxCount > 0 then
        print("     ✓ WÜRDE LED AUSSCHALTEN (alle gelesen)")
        hs.http.get("http://localhost:8934/blink1/off")
      end
    else
      print("     - LED-Aktion übersprungen (Slack im Vordergrund)")
    end

    lastBadge = currentBadge
    lastTitle = currentTitle
  end

  -- Stoppe nach 30 Sekunden
  if testCount >= 30 then
    testTimer:stop()
    print("\n" .. string.rep("=", 70))
    print("TEST BEENDET")
    print(string.rep("=", 70))
    print("\nFINAL-WERTE:")
    print("  Badge Count:", currentBadge)
    print("  Title Count:", currentTitle)

    if currentBadge == initialBadge and currentTitle == initialTitle then
      print("\n⚠️  KEINE ÄNDERUNG ERKANNT!")
      print("Hast du eine Nachricht gesendet?")
      print("Falls ja, gibt es ein Problem mit der Badge-Erkennung.")
    else
      print("\n✓ Änderung wurde erkannt und LED sollte geleuchtet haben!")
    end
  end
end)

print("\n💡 Hinweis: Drücke Cmd+Alt+Ctrl+Shift+X um die LED auszuschalten")
print("         : Der Test läuft 30 Sekunden\n")
