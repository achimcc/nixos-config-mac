-- SIMULIERE NEUE NACHRICHT
-- Testet die LED-Logik ohne echte Nachricht

print("\n=== NACHRICHT SIMULIEREN ===\n")

local isLedOn = false

local function turnLedOn()
  if not isLedOn then
    print("🔴 LED EIN")
    hs.http.asyncGet("http://localhost:8934/blink1/fadeToRGB?rgb=%23FF0000&time=0.1", nil, function() end)
    isLedOn = true
  end
end

local function turnLedOff()
  if isLedOn then
    print("⚫ LED AUS")
    hs.http.asyncGet("http://localhost:8934/blink1/off", nil, function() end)
    isLedOn = false
  end
end

-- Hole aktuellen Badge Count
local function getBadge()
  local output, status = hs.execute("lsappinfo -all list | grep -A 20 'com.tinyspeck.slackmacgap'")
  if status and output then
    local badge = output:match('"StatusLabel"=%s*{%s*"label"%s*=%s*"(%d+)"')
    return tonumber(badge) or 0
  end
  return 0
end

local currentBadge = getBadge()
print("Aktueller Badge Count:", currentBadge)
print("\n📝 SIMULATION:")
print("   Angenommen, Badge steigt von", currentBadge, "auf", currentBadge + 1)
print("   (als ob Sie eine neue Nachricht bekommen hätten)\n")

-- Prüfe Slack Status
local slack = hs.application.find("com.tinyspeck.slackmacgap")
if not slack then
  print("❌ Slack läuft nicht!")
  return
end

local isFocused = slack:isFrontmost()
print("Slack Status:")
print("  - Läuft:", "JA")
print("  - Im Vordergrund:", isFocused and "JA" or "NEIN")

-- Simuliere die Logik aus der Config
print("\n🔍 LOGIK-TEST:")

local lastBadge = currentBadge
local newBadge = currentBadge + 1  -- Simuliere +1

print(string.format("  lastBadge: %d", lastBadge))
print(string.format("  newBadge:  %d", newBadge))
print(string.format("  Bedingung 1: newBadge > 0? %s", newBadge > 0 and "✓" or "✗"))
print(string.format("  Bedingung 2: newBadge > lastBadge? %s", newBadge > lastBadge and "✓" or "✗"))
print(string.format("  Bedingung 3: Slack NICHT fokussiert? %s", not isFocused and "✓" or "✗"))

print("\n📊 ERGEBNIS:")

if not isFocused then
  if newBadge > 0 and newBadge > lastBadge then
    print("  ✅ ALLE Bedingungen erfüllt - LED sollte EINGESCHALTET werden")
    print("\n  Schalte LED jetzt ein...")
    turnLedOn()

    print("\n  💡 Wenn die Lampe JETZT rot leuchtet, funktioniert die LED-Steuerung!")
    print("     Das Problem ist dann wahrscheinlich:")
    print("     1. Der Timer läuft nicht in der normalen Config")
    print("     2. Oder der Badge Count wird nicht richtig erkannt")
  else
    print("  ⚠️  Bedingungen NICHT erfüllt - LED würde NICHT eingeschaltet")
    if newBadge == 0 then
      print("     Grund: Badge Count ist 0")
    elseif newBadge <= lastBadge then
      print("     Grund: Badge ist nicht gestiegen")
    end
  end
else
  print("  ⚠️  Slack ist im VORDERGRUND - LED wird NICHT eingeschaltet")
  print("     Das ist korrekt! Die LED soll nur leuchten, wenn Slack")
  print("     NICHT im Vordergrund ist.")
  print("\n  📝 TEST:")
  print("     1. Wechsle zu einer anderen App (z.B. diesem Terminal)")
  print("     2. Führe dieses Script nochmal aus")
end

print("\n💡 TIPP: Zum Ausschalten der LED:")
print("   hs.http.get('http://localhost:8934/blink1/off')")
print("\n")
