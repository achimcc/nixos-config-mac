--[[
Usage: Copy this entire script and paste it into the Hammerspoon Console.
It will monitor Slack notifications for 60 seconds and display:
- Each notification's title and body
- Summary statistics at the end

To stop early: Close the Hammerspoon Console or reload config
--]]

print("Starting Slack notification monitor...")
print("Monitoring for 60 seconds...")
print("---")

local notificationCount = 0
local dmCount = 0
local channelCount = 0
local otherCount = 0

local watcher = hs.distributednotifications.new(function(name, object, userInfo)
    if name == "com.tinyspeck.slackmacgap.notification" then
        notificationCount = notificationCount + 1

        local title = userInfo.title or "No title"
        local subtitle = userInfo.subtitle or ""
        local body = userInfo.body or "No body"

        print(string.format("Notification #%d:", notificationCount))
        print("  Title: " .. title)
        if subtitle ~= "" then
            print("  Subtitle: " .. subtitle)
        end
        print("  Body: " .. body)

        -- Classify notification type
        if string.find(title, "^[^#]") and not string.find(title, "^%d+ new items") then
            dmCount = dmCount + 1
            print("  Type: DM")
        elseif string.find(title, "^#") then
            channelCount = channelCount + 1
            print("  Type: Channel")
        else
            otherCount = otherCount + 1
            print("  Type: Other")
        end
        print("---")
    end
end, "com.tinyspeck.slackmacgap.notification")

watcher:start()

-- Stop after 60 seconds
hs.timer.doAfter(60, function()
    watcher:stop()
    print("\n=== Monitoring Complete ===")
    print(string.format("Total notifications: %d", notificationCount))
    print(string.format("  DMs: %d", dmCount))
    print(string.format("  Channels: %d", channelCount))
    print(string.format("  Other: %d", otherCount))
    print("\nIf you didn't see any notifications, try:")
    print("1. Send yourself a test DM in Slack")
    print("2. Check System Settings > Notifications > Slack")
    print("3. Make sure Slack is running and notifications are enabled")
end)

print("Watcher started. Waiting for notifications...")
