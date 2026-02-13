-- SOFORT-CHECK: Was sieht Hammerspoon gerade?
print("\n=== SOFORT-CHECK ===")

-- Badge Count via lsappinfo
local output, status = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
if status and output then
  local statusLabel = output:match('"StatusLabel".-}')
  print("StatusLabel aus lsappinfo:", statusLabel or "NICHT GEFUNDEN")

  local badge = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
  print("→ Extrahierter Badge Count:", badge or "0")
end

-- Slack App Status
local slack = hs.application.find("com.tinyspeck.slackmacgap")
if slack then
  print("\nSlack App:")
  print("  - Läuft:", "JA")
  print("  - Im Vordergrund:", slack:isFrontmost() and "JA" or "NEIN")

  local window = slack:mainWindow()
  if window then
    local title = window:title() or ""
    print("  - Fenster-Titel:", title)

    -- Suche nach Zahlen im Titel
    local count1 = title:match("%((%d+)%)")
    local count2 = title:match("•%s*(%d+)")
    print("  - Pattern (XX):", count1 or "nicht gefunden")
    print("  - Pattern • XX:", count2 or "nicht gefunden")
  else
    print("  - Kein Hauptfenster gefunden")
  end

  -- Versuche getBadgeCount (funktioniert nicht immer)
  local badgeCount = slack:getBadgeCount()
  print("  - getBadgeCount():", badgeCount or "nil")
else
  print("\nSlack App: NICHT GEFUNDEN")
end

print("\n=== ENDE ===\n")
