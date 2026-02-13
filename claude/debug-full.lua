-- Vollständiges Debug-Script für Slack + blink(1)
print("\n" .. string.rep("=", 60))
print("HAMMERSPOON SLACK DEBUG")
print(string.rep("=", 60))

-- Test 1: Prüfe ob Slack läuft
print("\n[1] Slack Application Check:")
local slack = hs.application.find("com.tinyspeck.slackmacgap")
if slack then
  print("✓ Slack gefunden")
  print("  - Name:", slack:name())
  print("  - Bundle ID:", slack:bundleID())
  print("  - PID:", slack:pid())
  print("  - Is Frontmost:", slack:isFrontmost())

  local window = slack:mainWindow()
  if window then
    print("  - Window Title:", window:title())
  else
    print("  - No main window")
  end
else
  print("✗ Slack NICHT gefunden - ist die App geöffnet?")
end

-- Test 2: Badge Count via lsappinfo
print("\n[2] Badge Count (lsappinfo):")
local output, status = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
if status and output then
  local statusLabel = output:match('"StatusLabel".-}')
  print("  StatusLabel:", statusLabel or "NOT FOUND")

  local badge = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
  print("  Extracted Badge:", badge or "0")
else
  print("✗ lsappinfo command failed")
end

-- Test 3: Fenster-Titel Analyse
print("\n[3] Window Title Analysis:")
if slack then
  local window = slack:mainWindow()
  if window then
    local title = window:title() or ""
    print("  Full Title:", title)

    -- Teste verschiedene Patterns
    local count1 = title:match("%((%d+)%)")
    local count2 = title:match("•%s*(%d+)")
    print("  Pattern (XX):", count1 or "nicht gefunden")
    print("  Pattern • XX:", count2 or "nicht gefunden")
  end
end

-- Test 4: HTTP Connection zu blink(1)
print("\n[4] blink(1) HTTP Test:")
local httpBody, httpStatus = hs.http.get("http://localhost:8934/blink1/fadeToRGB?rgb=%230000FF&time=0.1")
if httpStatus == 200 then
  print("✓ HTTP OK - blink(1) sollte jetzt BLAU sein")
  print("  Response:", httpBody:sub(1, 100))
else
  print("✗ HTTP FAILED - Status:", httpStatus)
  print("  Ist Blink1Control2 gestartet?")
  print("  Ist der HTTP-Server in Blink1Control2 aktiviert?")
end

-- Test 5: Application Watcher Test
print("\n[5] Application Watcher Test:")
print("  Teste ob App-Watcher funktioniert...")
print("  Wechsle jetzt zu einer anderen App und dann zurück zu Slack")
print("  Es sollte eine Nachricht erscheinen:")

local testWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
  if appName == "Slack" then
    if eventType == hs.application.watcher.activated then
      print("  → SLACK AKTIVIERT (Watcher funktioniert!)")
    elseif eventType == hs.application.watcher.deactivated then
      print("  → SLACK DEAKTIVIERT")
    end
  end
end)
testWatcher:start()

print("  Test-Watcher läuft für 10 Sekunden...")
hs.timer.doAfter(10, function()
  testWatcher:stop()
  print("  Test-Watcher gestoppt")
end)

-- Test 6: Timer Test
print("\n[6] Timer Test:")
print("  Erstelle Test-Timer (läuft 3x alle 2 Sekunden)...")
local timerCount = 0
local testTimer = hs.timer.doEvery(2, function()
  timerCount = timerCount + 1
  print(string.format("  Timer Tick #%d (Zeit: %s)", timerCount, os.date("%H:%M:%S")))

  if timerCount >= 3 then
    testTimer:stop()
    print("  Timer gestoppt")
  end
end)

-- Test 7: Prüfe ob die Variablen/Funktionen existieren
print("\n[7] Variable/Function Check:")
print("  isLedOn:", type(_G.isLedOn))
print("  turnLedOn:", type(_G.turnLedOn))
print("  turnLedOff:", type(_G.turnLedOff))
print("  slackWatcher:", type(_G.slackWatcher))
print("  appWatcher:", type(_G.appWatcher))

-- LED zurück auf aus nach 3 Sekunden
hs.timer.doAfter(3, function()
  hs.http.get("http://localhost:8934/blink1/off")
  print("\n[INFO] LED ausgeschaltet")
end)

print("\n" .. string.rep("=", 60))
print("DEBUG ABGESCHLOSSEN")
print("Warte auf App-Watcher Events (10 Sek.)...")
print(string.rep("=", 60) .. "\n")
