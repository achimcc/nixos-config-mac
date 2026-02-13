-- Quick test: What notification name does Slack send?
print("\n=== TESTING SLACK NOTIFICATION NAME ===\n")

local watcher = hs.distributednotifications.new(function(name, object, userInfo)
  if not name then return end

  local nameStr = tostring(name):lower()

  -- Show ALL notifications (for 10 seconds)
  if nameStr:find("slack") or nameStr:find("tinyspeck") then
    print(string.format("📢 Notification: %s", name))
    print(string.format("   Object: %s", object or "nil"))
    if userInfo then
      print(string.format("   UserInfo keys: %s", table.concat(hs.fnutils.keys(userInfo), ", ")))
      if userInfo.title then
        print(string.format("   Title: %s", userInfo.title))
      end
      if userInfo.body then
        print(string.format("   Body: %s", userInfo.body:sub(1, 50)))
      end
    end
    print("")
  end
end)

watcher:start()
print("✓ Listening for 30 seconds...")
print("📬 Send yourself a Slack DM now!\n")

hs.timer.doAfter(30, function()
  watcher:stop()
  print("\n=== TEST COMPLETE ===")
  print("If you see no Slack notifications above, that's the problem!")
end)
