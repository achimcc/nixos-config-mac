-- Debug Script für Slack Badge Detection
print("\n=== DEBUG: Slack Badge Detection ===")

-- Test 1: Prüfe ob lsappinfo funktioniert
print("\n1. Test lsappinfo command:")
local output, status = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
print("Status:", status)
if output then
  print("Output length:", string.len(output))
  -- Zeige relevanten Teil
  local statusLabel = output:match('"StatusLabel".-}')
  if statusLabel then
    print("Found StatusLabel:", statusLabel)
  else
    print("StatusLabel NOT FOUND in output")
    print("First 500 chars:", string.sub(output, 1, 500))
  end
else
  print("No output received!")
end

-- Test 2: Teste die Badge-Extraktion
print("\n2. Test badge extraction:")
local function getSlackBadge()
  local output, status = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
  if status and output then
    print("  Trying pattern: '\"StatusLabel\"=%s*{%s*\"label\"%s*=%s*\"(%d+)\"'")
    local badge = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
    print("  Badge found:", badge)
    return tonumber(badge) or 0
  end
  return 0
end

local badge = getSlackBadge()
print("Current badge count:", badge)

-- Test 3: Prüfe HTTP-Verbindung zur blink(1)
print("\n3. Test blink(1) HTTP connection:")
local success = hs.http.get("http://localhost:8934/blink1/fadeToRGB?rgb=%23FF0000&time=0.1", nil)
if success then
  print("HTTP request successful - blink(1) should be red now")
else
  print("HTTP request FAILED - is Blink1Control2 running?")
end

-- Test 4: Teste mit Slack-App-Objekt
print("\n4. Test hs.application approach:")
local slack = hs.application.find("com.tinyspeck.slackmacgap")
if slack then
  print("Slack app found")
  print("  Bundle ID:", slack:bundleID())
  print("  Name:", slack:name())
  print("  PID:", slack:pid())

  -- Versuche Badge Count direkt
  local badgeCount = slack:getBadgeCount()
  print("  getBadgeCount():", badgeCount)

  -- Fenster-Titel
  local window = slack:mainWindow()
  if window then
    print("  Main window title:", window:title())
  end
else
  print("Slack app NOT FOUND")
end

print("\n=== END DEBUG ===\n")
