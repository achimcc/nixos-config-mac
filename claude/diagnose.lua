-- DIAGNOSE SCRIPT
-- Führe dies in der Hammerspoon Console aus mit:
-- dofile(os.getenv("HOME") .. "/nix-darwin-config/claude/diagnose.lua")

print("\n" .. string.rep("=", 70))
print("HAMMERSPOON SLACK + BLINK(1) DIAGNOSE")
print(string.rep("=", 70))

-- Test 1: Slack App finden
print("\n[1] SLACK APP")
local slack = hs.application.find("com.tinyspeck.slackmacgap")
if slack then
  print("  ✓ Slack gefunden")
  print("    - Name:", slack:name())
  print("    - PID:", slack:pid())
  print("    - Im Vordergrund:", slack:isFrontmost() and "JA" or "NEIN")

  local window = slack:mainWindow()
  if window then
    local title = window:title() or ""
    print("    - Fenster-Titel:", title)

    -- Pattern-Tests
    local count1 = title:match("%((%d+)%)")
    local count2 = title:match("•%s*(%d+)")
    if count1 then print("    - Pattern (XX) gefunden:", count1) end
    if count2 then print("    - Pattern • XX gefunden:", count2) end
  end
else
  print("  ✗ Slack NICHT gefunden!")
  print("    Ist Slack geöffnet?")
end

-- Test 2: Badge Count via lsappinfo
print("\n[2] BADGE COUNT (lsappinfo)")
local output, status = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
if status and output then
  -- Suche nach StatusLabel
  local statusLabel = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
  if statusLabel then
    print("  ✓ Badge Count gefunden:", statusLabel)
  else
    print("  ✗ Badge Count NICHT gefunden")
    -- Zeige die StatusLabel Zeile falls vorhanden
    local labelLine = output:match('"StatusLabel".-}')
    if labelLine then
      print("    StatusLabel-Zeile:", labelLine)
    else
      print("    Keine StatusLabel-Zeile gefunden")
    end
  end
else
  print("  ✗ lsappinfo Kommando fehlgeschlagen")
end

-- Test 3: blink(1) HTTP Test
print("\n[3] BLINK(1) HTTP SERVER")
local body, httpStatus = hs.http.get("http://localhost:8934/blink1/fadeToRGB?rgb=%2300FF00&time=0.1")
if httpStatus == 200 then
  print("  ✓ HTTP Server erreichbar - blink(1) sollte jetzt GRÜN leuchten")
else
  print("  ✗ HTTP Server NICHT erreichbar")
  print("    Status Code:", httpStatus or "nil")
  print("    Ist Blink1Control2 gestartet?")
  print("    Ist der HTTP-Server in den Einstellungen aktiviert?")
end

-- Test 4: Teste die getSlackBadge Funktion aus der Config
print("\n[4] AKTUELLE CONFIG-FUNKTION")
local function getSlackBadge()
  local output, status = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
  if status and output then
    local badge = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
    return tonumber(badge) or 0
  end
  return 0
end

local currentBadge = getSlackBadge()
print("  Badge Count:", currentBadge)
if currentBadge > 0 then
  print("  ✓ Es gibt ungelesene Nachrichten!")
else
  print("  - Keine ungelesenen Nachrichten")
end

-- Test 5: Prüfe ob die Watcher laufen
print("\n[5] RUNNING WATCHERS")
print("  slackWatcher:", type(_G.slackWatcher) == "userdata" and "✓ läuft" or "✗ nicht gefunden")
print("  appWatcher:", type(_G.appWatcher) == "userdata" and "✓ läuft" or "✗ nicht gefunden")
print("  notificationWatcher:", type(_G.notificationWatcher) == "userdata" and "✓ läuft" or "✗ nicht gefunden")

-- Test 6: Prüfe LED-Status
print("\n[6] LED STATUS")
print("  isLedOn:", type(_G.isLedOn) == "boolean" and (_G.isLedOn and "✓ EIN" or "- AUS") or "✗ Variable nicht gefunden")
print("  lastBadgeCount:", type(_G.lastBadgeCount) == "number" and _G.lastBadgeCount or "✗ Variable nicht gefunden")

-- Zusammenfassung
print("\n" .. string.rep("=", 70))
print("ZUSAMMENFASSUNG")
print(string.rep("=", 70))

if slack and httpStatus == 200 and currentBadge >= 0 then
  print("\n✓ Alle Komponenten funktionieren!")
  if currentBadge > 0 then
    print("\n⚠️  PROBLEM: Es gibt " .. currentBadge .. " ungelesene Nachricht(en), aber die LED leuchtet nicht?")
    print("\nMögliche Ursachen:")
    print("  1. Der Timer läuft nicht (slackWatcher fehlt)")
    print("  2. Die lastBadgeCount-Variable ist falsch initialisiert")
    print("  3. Die Bedingung im Timer schlägt fehl")
    print("\nLösung: Lade die Hammerspoon-Config neu mit: hs.reload()")
  end
else
  print("\n⚠️  Es gibt Probleme:")
  if not slack then
    print("  - Slack ist nicht geöffnet")
  end
  if httpStatus ~= 200 then
    print("  - blink(1) HTTP Server läuft nicht")
  end
end

-- LED nach 2 Sekunden ausschalten
hs.timer.doAfter(2, function()
  hs.http.get("http://localhost:8934/blink1/off")
  print("\n[INFO] LED ausgeschaltet")
end)

print("\n" .. string.rep("=", 70) .. "\n")
