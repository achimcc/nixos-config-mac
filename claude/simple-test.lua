-- Einfacher Test - kopiere diesen Code in die Hammerspoon Console

print("\n=== QUICK TEST ===")

-- 1. HTTP Test
print("1. HTTP Test...")
local body, status = hs.http.get("http://localhost:8934/blink1/fadeToRGB?rgb=%23FF0000&time=0.1")
print("   Status:", status, status == 200 and "✓ OK" or "✗ FAILED")

-- 2. Slack App Test
print("2. Slack App Test...")
local slack = hs.application.find("com.tinyspeck.slackmacgap")
print("   Slack found:", slack ~= nil and "✓ YES" or "✗ NO")
if slack then
  print("   Is frontmost:", slack:isFrontmost())
end

-- 3. Badge Count Test
print("3. Badge Count Test...")
local output, status = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
if status and output then
  local badge = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
  print("   Badge:", badge or "0")
else
  print("   ✗ Command failed")
end

-- 4. App Watcher Test
print("4. App Watcher Test (wechsle jetzt zu/von Slack)...")
local w = hs.application.watcher.new(function(name, event)
  if name == "Slack" then
    print("   → Slack event:", event == 0 and "ACTIVATED" or "DEACTIVATED")
  end
end)
w:start()
print("   Watcher läuft 10 Sekunden...")
hs.timer.doAfter(10, function() w:stop() print("   Watcher gestoppt") end)

print("=== TEST LÄUFT ===\n")
