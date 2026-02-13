-- Prüfe ob die Slack-Watcher aus der Config laufen

print("\n=== STATUS CHECK ===\n")

-- 1. Prüfe ob die Variablen existieren
print("1. GLOBALE VARIABLEN:")
print("   lastBadgeCount:", _G.lastBadgeCount or "NICHT GEFUNDEN")
print("   lastSlackTitle:", _G.lastSlackTitle and "existiert" or "NICHT GEFUNDEN")
print("   isLedOn:", _G.isLedOn ~= nil and tostring(_G.isLedOn) or "NICHT GEFUNDEN")

-- 2. Prüfe ob die Watcher-Objekte existieren
print("\n2. WATCHER-OBJEKTE:")
print("   slackWatcher:", _G.slackWatcher and "✓ existiert" or "✗ NICHT GEFUNDEN")
print("   notificationWatcher:", _G.notificationWatcher and "✓ existiert" or "✗ NICHT GEFUNDEN")
print("   appWatcher:", _G.appWatcher and "✓ existiert" or "✗ NICHT GEFUNDEN")

-- 3. Teste die Funktionen
print("\n3. FUNKTIONEN:")
local hasTurnLedOn = type(_G.turnLedOn) == "function"
local hasTurnLedOff = type(_G.turnLedOff) == "function"
print("   turnLedOn:", hasTurnLedOn and "✓ definiert" or "✗ NICHT GEFUNDEN")
print("   turnLedOff:", hasTurnLedOff and "✓ definiert" or "✗ NICHT GEFUNDEN")

-- 4. Teste die getSlackBadge Funktion
print("\n4. BADGE-ERKENNUNG:")
local output, status = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
if status and output then
  local badge = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
  print("   Aktueller Badge Count:", badge or "0")
  print("   lastBadgeCount (gespeichert):", _G.lastBadgeCount or "nicht gesetzt")

  if badge and _G.lastBadgeCount then
    local current = tonumber(badge)
    if current > _G.lastBadgeCount then
      print("   ⚠️  WARNUNG: Badge Count (" .. current .. ") > lastBadgeCount (" .. _G.lastBadgeCount .. ")")
      print("      Die LED sollte eigentlich leuchten!")
    elseif current == _G.lastBadgeCount then
      print("   ✓ Badge Count stimmt mit lastBadgeCount überein")
    end
  end
else
  print("   ✗ FEHLER beim Auslesen des Badge Count")
end

-- 5. Zusammenfassung
print("\n=== ZUSAMMENFASSUNG ===")

if not _G.slackWatcher or not _G.appWatcher then
  print("\n❌ PROBLEM GEFUNDEN:")
  print("   Die Watcher-Objekte wurden nicht erstellt!")
  print("\nLÖSUNG:")
  print("   1. Öffne die Hammerspoon Console")
  print("   2. Führe aus: hs.reload()")
  print("   3. Warte 2-3 Sekunden")
  print("   4. Führe dieses Script nochmal aus")
elseif not hasTurnLedOn or not hasTurnLedOff then
  print("\n❌ PROBLEM GEFUNDEN:")
  print("   Die LED-Funktionen wurden nicht definiert!")
  print("\nLÖSUNG: hs.reload()")
else
  print("\n✓ Alle Komponenten scheinen vorhanden zu sein")
  print("\nNÄCHSTER SCHRITT:")
  print("   Führe den Live-Test aus:")
  print('   dofile(os.getenv("HOME") .. "/nix-darwin-config/claude/test-live.lua")')
end

print("\n")
